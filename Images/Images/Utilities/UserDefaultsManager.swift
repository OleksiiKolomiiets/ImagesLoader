//
//  UserDefaultsManager.swift
//  Images - iOS Application
//
//  Created by Oleksii  Kolomiiets on 10/26/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import Foundation

class UserDefaultsManager {
    
    // MARK: Properties:
    
    private let userDefaults = UserDefaults.standard
    
    
    // MARK: Functions:
    
    public func append(_ data: Data, for key: String) {
        
        var userDefaultsData = savedData(for: key)
        userDefaultsData.append(data)
        
        save(data: userDefaultsData, for: key)
    }
    
    public func remove(at index: Int, for key: String) {
        
        var userDefaultsData = savedData(for: key)
        userDefaultsData.remove(at: index)
        
        save(data: userDefaultsData, for: key)
    }
    
    private func save(data: [Data], for key: String) {
        userDefaults.set(data, forKey: key)
        userDefaults.synchronize()
    }
    
    public func savedData(for key: String) -> [Data] {
        return userDefaults.object(forKey: key) as? [Data] ?? [Data]()
    }
}
