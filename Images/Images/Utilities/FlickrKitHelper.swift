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
    
    private static var imageDataDictionary: [String: [ImageData]]?
    
    private static var flickrError: Error?
    
    private static let flickrKitHelperDispatchQueue  = DispatchQueue(label: "FlickrKitHelper")
    private static let loadingImageDataDispatchGroup = DispatchGroup()
    private static let loadingGeoDataDispatchGroup   = DispatchGroup()
    
    
    // MARK: - Functions:
    
    // Load images data by tags
    public static func load(for tags: [String], perPage: Int, completion: @escaping FlickrKitHelperCompletionHandler) {
        
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
    public static func loadPolygonLocation(for tag: String, perPage: Int, completion: @escaping ([ImageData]?) -> Void) {
        
        self.startLoadingData(for: tag, perPage) { imagesDataArray in
            guard let imagesDataArray = imagesDataArray else {
                completion(nil)
                return
            }
            
            self.imageDataDictionary = [tag: imagesDataArray]
            
            self.loadLocationFor(imagesData: imagesDataArray) { imagesData in
               completion(imagesData)
            }
        }
        
        
    }
    
    // Loading dictionary with image geo data by its IDs
    public static func loadLocationFor(imagesData: [ImageData], completion: @escaping ([ImageData]) -> Void) {
        var imageDataWithLocation = [ImageData]()
        imagesData.forEach() { imageData in
            loadingGeoDataDispatchGroup.enter()
            
            loadLocationBy(imageData: imageData, completion: { imageGeoData in
                if let imageGeoData = imageGeoData {
                    var copyImageData = imageData
                    copyImageData.geoData = imageGeoData
                    imageDataWithLocation.append(copyImageData)
                }
                
                self.loadingGeoDataDispatchGroup.leave()
            })
        }
        
        loadingGeoDataDispatchGroup.notify(queue: .main) {
            completion(imageDataWithLocation)
        }
        
    }
    
    // Loading image geo data by image ID
    public static func loadLocationBy(imageData: ImageData, completion: @escaping (ImageGeoData?) -> Void) {
        
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
                    
                    let latitude  = Double(latitudeString),
                    let longitude = Double(longitudeString)
                    
                    else {
                        DispatchQueue.main.async {
                            completion(nil)
                        }
                        return
                }
                
                let imageGeoData = ImageGeoData(country, latitude, longitude, region)
                
                DispatchQueue.main.async {
                    completion(imageGeoData)
                }
                
            }
        }
    }
    
    // Loading images data by tag
    public static func startLoadingData(for tag: String, _ perPage: Int, completion: @escaping ([ImageData]?) -> Void) {
        
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
    private static func getFlickrUrl(forSize flickrKitPhotoSize: FKPhotoSize, using flickrKitImageDictionary: FlickrKitImageDictionary) -> URL {
        return FlickrKit.shared().photoURL(for: flickrKitPhotoSize, fromPhotoDictionary: flickrKitImageDictionary)
    }
}
