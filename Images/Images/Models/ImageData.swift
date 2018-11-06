//
//  ImageData
//  Images
//
//  Created by Oleksii  Kolomiets on 8/27/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import UIKit

struct ImageData: Codable {
    let id          : String
    let title       : String
    let urlSmall240 : URL
    let urlSmall320 : URL
    let urlLarge1024: URL
}

extension ImageData {    
    public var data: Data {
        return try! JSONEncoder().encode(self) as Data
    }
    
    static public func instance(from jsonData: Data) -> ImageData {
        return try! JSONDecoder().decode(ImageData.self, from: jsonData)
    }
    
    static public func instance(from coreDataEntity: FavoriteImage) -> ImageData {
        return ImageData(title: coreDataEntity.title!,
                         urlSmall240: coreDataEntity.urlSmall240!,
                         urlSmall320: coreDataEntity.urlSmall320!,
                         urlLarge1024: coreDataEntity.urlLarge1024!)
    }
    
}

extension ImageData: Equatable {
    public static func ==(lhs: ImageData, rhs: ImageData) -> Bool {
        return (lhs.urlSmall240 == rhs.urlSmall240)
            && (lhs.urlSmall320 == rhs.urlSmall320)
            && (lhs.urlLarge1024 == rhs.urlLarge1024)
    }
}
