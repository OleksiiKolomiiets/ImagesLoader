//
//  FlickrKitHelper.swift
//  Images
//
//  Created by Oleksii  Kolomiets on 8/22/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import Foundation
import FlickrKit

class FlickrKitHelper {    
    
    typealias FlickrKitImageDictionary = [String: Any]
    
    typealias FlickrKitHelperCompletionHandler = ([String: [ImageData]]?, Error?) -> Void
    
    
    // MARK: - Variables:
    
    private var imageDataDictionary: [String: [ImageData]]?
    private var imageGeoDataDictionary: [ImageGeoData] = []
    
    private var flickrError: Error?
    
    private let flickrKitHelperDispatchQueue = DispatchQueue(label: "FlickrKitHelper")
    private let loadingImageDataDispatchGroup = DispatchGroup()
    private let loadingPolygonGeoDataDispatchGroup = DispatchGroup()
    
    
    // MARK: - Functions:
    
    // Load images data by tags
    public func load(for tags: [String], perPage: Int, completion: @escaping FlickrKitHelperCompletionHandler) {
        
        imageDataDictionary?.removeAll()
        flickrError = nil
        
        tags.forEach() { tag in
            loadingImageDataDispatchGroup.enter()
            
            self.startLoadingData(for: tag, perPage) { imagesDataArray in
                guard let imagesDataArray = imagesDataArray else { return }
                if self.imageDataDictionary != nil {
                    self.imageDataDictionary![tag] = imagesDataArray
                } else {
                    self.imageDataDictionary = [tag: imagesDataArray]
                }
                
                self.loadingImageDataDispatchGroup.leave()
            }
        }
        
        loadingImageDataDispatchGroup.notify(queue: .main) {
            completion(self.imageDataDictionary, self.flickrError)
        }
        
        
    }
    
    
    //Loading image geo data for polygon by tag
    public func loadPolygonLocation(for tag: String, perPage: Int, completion: @escaping ([ImageGeoData]?) -> Void) {
        
        imageGeoDataDictionary.removeAll()
        
        self.startLoadingData(for: tag, perPage) { imagesDataArray in
            guard let imagesDataArray = imagesDataArray else {
                completion(nil)
                return
            }
            self.loadLocationFor(imagesData: imagesDataArray) { imagesGeoDataDictionary in
               completion(imagesGeoDataDictionary)
            }
        }
        
        
    }
    
    // Loading dictionary with image geo data by its IDs
    public func loadLocationFor(imagesData: [ImageData], completion: @escaping ([ImageGeoData]) -> Void) {
        
        imagesData.forEach() { imageData in
            loadingPolygonGeoDataDispatchGroup.enter()
            
            loadLocationBy(imageData: imageData, completion: { imageGeoData in
                if let imageGeoData = imageGeoData {
                    self.imageGeoDataDictionary.append(imageGeoData)
                }
                
                self.loadingPolygonGeoDataDispatchGroup.leave()
            })
        }
        
        loadingPolygonGeoDataDispatchGroup.notify(queue: .main) {
            completion(self.imageGeoDataDictionary)
        }
        
    }
    
    // Loading image geo data by image ID
    public func loadLocationBy(imageData: ImageData, completion: @escaping (ImageGeoData?) -> Void) {
        
        flickrKitHelperDispatchQueue.async {
            FlickrKit.shared().call("flickr.photos.geo.getLocation", args: ["api_key": "60b5143bcc14e2d43ff380b7b26b2430", "photo_id": imageData.id ] ) { (response, error) -> Void in
                
                guard let response = response,
                    let photo    = response["photo"] as? FlickrKitImageDictionary,
                    let location = photo["location"] as? FlickrKitImageDictionary,
                    
                    let latitudeString  = location["latitude"]  as? String,
                    let longitudeString = location["longitude"] as? String,
                    let countryInfo     = location["country"]   as? FlickrKitImageDictionary,
                    let regionInfo      = location["region"]    as? FlickrKitImageDictionary,
                    
                    let country = countryInfo["_content"] as? String,
                    let region  = regionInfo["_content"]  as? String,
                    
                    let latitude = Double(latitudeString), let longitude = Double(longitudeString)
                    
                    else {
                        DispatchQueue.main.async {
                            completion(nil)
                        }
                        return
                }
                
                let imageGeoData = ImageGeoData(with: imageData, country, latitude, longitude, region)
                
                DispatchQueue.main.async {
                    completion(imageGeoData)
                }
                
            }
        }
    }
    
    // Loading images data by tag
    public func startLoadingData(for tag: String, _ perPage: Int, completion: @escaping ([ImageData]?) -> Void) {
        
        let perPageString = String(perPage)
        
        var imageDataArray = [ImageData]()
        
        flickrKitHelperDispatchQueue.async {
            FlickrKit.shared().call("flickr.photos.search", args: ["tags": tag, "per_page": perPageString, "has_geo": "1"] ) { (response, error) -> Void in
                
                if let error = error {
                    if self.flickrError == nil {
                        self.flickrError = error
                    }
                } else {
                    guard let response = response,
                        let photos = response["photos"] as? [String: Any],
                        let photo  = photos["photo"] as? [FlickrKitImageDictionary]
                        else {
                            completion(nil)
                            return
                    }
                    
                    imageDataArray = [ImageData]()
                    
                    for flickrKitImageData in photo {
                        guard let id = flickrKitImageData["id"] as? String else {
                            break
                        }
                        guard let title = flickrKitImageData["title"] as? String else {
                            break
                        }
                        let url240 = self.getFlickrUrl(forSize: .small240,  using: flickrKitImageData)
                        let url320 = self.getFlickrUrl(forSize: .small320,  using: flickrKitImageData)
                        let url1024 = self.getFlickrUrl(forSize: .large1024, using: flickrKitImageData)
                        let url75 = self.getFlickrUrl(forSize: .smallSquare75, using: flickrKitImageData)
                        let imageData = ImageData(id: id, title: title,
                                                  urlSmall75  : url75,
                                                  urlSmall240 : url240,
                                                  urlSmall320 : url320,
                                                  urlLarge1024: url1024)
                        
                        imageDataArray.append(imageData)
                    }
                }
                
                completion(imageDataArray)
            }
        }
    }
    
    // Getting images URL using Flickr image data dictionary
    private func getFlickrUrl(forSize flickrKitPhotoSize: FKPhotoSize, using flickrKitImageDictionary: FlickrKitImageDictionary) -> URL {
        return FlickrKit.shared().photoURL(for: flickrKitPhotoSize, fromPhotoDictionary: flickrKitImageDictionary)
    }
}
