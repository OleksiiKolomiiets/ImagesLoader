//
//  FavoriteManagerProtocol.swift
//  Images - iOS Application
//
//  Created by Oleksii  Kolomiiets on 11/2/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import Foundation

fileprivate class FavoriteManagerSettings {
    static let kMaxNumberOfImages = 10
}

protocol FavoriteManagerProtocol {
    static var maxImagesCount: Int { get }
    static var isOverlapTheLimit: Bool { get }
    static var allFavoriteImages: [ImageData] { get }
    static func addFavoriteImage(_ image: ImageData)
    static func deleteFavoriteImage(_ image: ImageData)
}

extension FavoriteManagerProtocol {
    static var maxImagesCount: Int {
        return FavoriteManagerSettings.kMaxNumberOfImages
    }
}
