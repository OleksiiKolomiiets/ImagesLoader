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
    private var flickrError: Error?
    
    private let flickrKitHelperDispatchQueue = DispatchQueue(label: "FlickrKitHelper")
    private let flickrKitHelperDispatchGroup = DispatchGroup()
    
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
    
    // Starting to load images data
    public func load(for tags: [String], perPage: Int, completion: @escaping FlickrKitHelperCompletionHandler) {
        
        imageDataDictionary?.removeAll()
        flickrError = nil
        
        tags.forEach() { tag in
            self.startLoadingData(for: tag, perPage) 
        }
        
        flickrKitHelperDispatchGroup.notify(queue: .main) {
            completion(self.imageDataDictionary, self.flickrError)
        }
        
        
    }
    
    // Loading image geo data: coordinates and region info
    public func getLocationBy(imageId: String, completion: @escaping (ImageGeoData) -> Void) {
        
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
    
    // Loading images data: URLs and title
    private func startLoadingData(for tag: String, _ perPage: Int) {
        
        flickrKitHelperDispatchGroup.enter()
        
        let perPageString = String(perPage)
        
        flickrKitHelperDispatchQueue.async {
            FlickrKit.shared().call("flickr.photos.search", args: ["tags": tag, "per_page": perPageString, "has_geo": "1"] ) { (response, error) -> Void in
                
                if let error = error {
                    if self.flickrError == nil {
                        self.flickrError = error
                        print(error.localizedDescription)
                    }
                } else if let response = response {
                    
                    let photos = response["photos"] as! [String: Any]
                    let photo  = photos["photo"]    as! [FlickrKitImageDictionary]
                    
                    var imageDataArray = [ImageData]()
                    
                    photo.forEach({ flickrKitImageData in
                        imageDataArray.append(ImageData(id          : flickrKitImageData["id"] as! String,
                                                        title       : flickrKitImageData["title"] as! String,
                                                        urlSmall240 : self.getFlickrUrl(forSize: .small240,  using: flickrKitImageData),
                                                        urlSmall320 : self.getFlickrUrl(forSize: .small320,  using: flickrKitImageData),
                                                        urlLarge1024: self.getFlickrUrl(forSize: .large1024, using: flickrKitImageData)))
                    })
                    
                    if self.imageDataDictionary != nil {
                        self.imageDataDictionary![tag] = imageDataArray
                    } else {
                        self.imageDataDictionary = [tag: imageDataArray]
                    }
                    
                }
                
                self.flickrKitHelperDispatchGroup.leave()
            }
        }
    }
    
    // Getting images URL using Flickr image data dictionary
    private func getFlickrUrl(forSize flickrKitPhotoSize: FKPhotoSize, using flickrKitImageDictionary: FlickrKitImageDictionary) -> URL {
        return FlickrKit.shared().photoURL(for: flickrKitPhotoSize, fromPhotoDictionary: flickrKitImageDictionary)
    }
}
