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
    
    typealias ImageGeoDataDictionary = [String: ImageGeoData]
    
    typealias FlickrKitHelperCompletionHandler = ([String: [ImageData]]?, Error?) -> Void
    
    // MARK: - Variables:
    
    private var imageDataDictionary   : [String: [ImageData]]?
    private var imageGeoDataDictionary: [String: ImageGeoData] = [:]
    
    private var flickrError: Error?
    
    private let flickrKitHelperDispatchQueue = DispatchQueue(label: "FlickrKitHelper")
    private let loadingImageDataDispatchGroup = DispatchGroup()
    private let loadingPolygonGeoDataDispatchGroup = DispatchGroup()
    
    private enum FlickrKitHelperError: Error, LocalizedError {
        case responseKeyInvalid(String)
        case feildTypeInvalid
        
        var errorDescription: String? {
            switch self {
            case .responseKeyInvalid(let key):
                return "Response key:\(key) is invalid."
            case .feildTypeInvalid:
                return "Feild type is invalid."
            }
        }
    }
    
    
    // MARK: - Functions:
    
    // Load images data by tags
    public func load(for tags: [String], perPage: Int, completion: @escaping FlickrKitHelperCompletionHandler) {
        
        imageDataDictionary?.removeAll()
        flickrError = nil
        
        tags.forEach() { tag in
            loadingImageDataDispatchGroup.enter()
            
            self.startLoadingData(for: tag, perPage) { imagesDataArray in
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
    public func loadPolygonLocation(for tag: String, perPage: Int, completion: @escaping (ImageGeoDataDictionary) -> Void) {
        
        imageGeoDataDictionary.removeAll()
        
        self.startLoadingData(for: tag, perPage) { imagesDataArray in
            
            let imagesId = imagesDataArray.map() { $0.id }
            
            self.loadLocationFor(imagesId: imagesId) { imagesGeoDataDictionary in
                
               completion(imagesGeoDataDictionary)
            }
        }
        
        
    }
    
    // Loading dictionary with image geo data by its IDs
    public func loadLocationFor(imagesId: [String], completion: @escaping (ImageGeoDataDictionary) -> Void) {
        
        imagesId.forEach() { imageId in
            loadingPolygonGeoDataDispatchGroup.enter()
            
            loadLocationBy(imageId: imageId, completion: { imageGeoData in
                self.imageGeoDataDictionary[imageId] = imageGeoData
                
                self.loadingPolygonGeoDataDispatchGroup.leave()
            })
        }
        
        loadingPolygonGeoDataDispatchGroup.notify(queue: .main) {
            completion(self.imageGeoDataDictionary)
        }
        
    }
    
    // Loading image geo data by image ID
    public func loadLocationBy(imageId: String, completion: @escaping (ImageGeoData) -> Void) {
        
        flickrKitHelperDispatchQueue.async {
            FlickrKit.shared().call("flickr.photos.geo.getLocation", args: ["api_key": "60b5143bcc14e2d43ff380b7b26b2430", "photo_id": imageId ] ) { (response, error) -> Void in
                
                if let error = error {
                    print(error.localizedDescription)
                } else if let response = response {
                    guard let photo  = response["photo"] as? FlickrKitImageDictionary else {
                        print(FlickrKitHelperError.responseKeyInvalid("photo"))
                        return
                    }
                    
                    guard let location = photo["location"] as? FlickrKitImageDictionary else {
                        print(FlickrKitHelperError.responseKeyInvalid("location"))
                        return
                    }
                    guard let latitudeString = location["latitude"] as? String else {
                        print(FlickrKitHelperError.responseKeyInvalid("latitude"))
                        return
                    }
                    guard let longitudeString = location["longitude"] as? String else {
                        print(FlickrKitHelperError.responseKeyInvalid("longitude"))
                        return
                    }
                    
                    guard let countryInfo = location["country"] as? FlickrKitImageDictionary,
                        let country = countryInfo["_content"] as? String else {
                        print(FlickrKitHelperError.responseKeyInvalid("country"))
                        return
                    }
                    
                    guard let regionInfo = location["region"] as? FlickrKitImageDictionary,
                        let region = regionInfo["_content"] as? String else {
                        print(FlickrKitHelperError.responseKeyInvalid("region"))
                        return
                    }
                    
                    guard let latitude = Double(latitudeString), let longitude = Double(longitudeString) else {
                        print(FlickrKitHelperError.feildTypeInvalid)
                        return
                    }
                    
                    DispatchQueue.main.async {
                        completion(ImageGeoData(country: country, latitude: latitude, longitude: longitude, region: region))
                    }
                }
            }
        }
    }
    
    // Loading images data by tag
    public func startLoadingData(for tag: String, _ perPage: Int, completion: @escaping ([ImageData]) -> Void) {
        
        let perPageString = String(perPage)
        
        var imageDataArray = [ImageData]()
        
        flickrKitHelperDispatchQueue.async {
            FlickrKit.shared().call("flickr.photos.search", args: ["tags": tag, "per_page": perPageString, "has_geo": "1"] ) { (response, error) -> Void in
                
                if let error = error {
                    if self.flickrError == nil {
                        self.flickrError = error
                        print(error.localizedDescription)
                    }
                } else if let response = response {
                    
                    guard let photos = response["photos"] as? [String: Any] else {
                            print(FlickrKitHelperError.responseKeyInvalid("photos"))
                            return
                    }
                    guard let photo  = photos["photo"] as? [FlickrKitImageDictionary] else {
                        print(FlickrKitHelperError.responseKeyInvalid("photo"))
                        return
                    }
                    
                    imageDataArray = [ImageData]()
                    
                    for flickrKitImageData in photo {
                        guard let id = flickrKitImageData["id"] as? String else {
                            print(FlickrKitHelperError.responseKeyInvalid("id"))
                            break
                        }
                        guard let title = flickrKitImageData["title"] as? String else {
                            print(FlickrKitHelperError.responseKeyInvalid("title"))
                            break
                        }
                        let url240 = self.getFlickrUrl(forSize: .small240,  using: flickrKitImageData)
                        let url320 = self.getFlickrUrl(forSize: .small320,  using: flickrKitImageData)
                        let url1024 = self.getFlickrUrl(forSize: .large1024, using: flickrKitImageData)
                        let imageData = ImageData(id : id, title : title, urlSmall240 : url240, urlSmall320 : url320, urlLarge1024: url1024)
                        
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
