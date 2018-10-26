//
//  UserDefaultsHelper.swift
//  Images - iOS Application
//
//  Created by Oleksii  Kolomiiets on 10/26/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import Foundation

class UserDefaultsHelper {
    
    // MARK: Properties:
    
    public let key: String
    
    private let userDefaults = UserDefaults.standard
    
    private var savedData: [Data] {
        return userDefaults.object(forKey: key) as? [Data] ?? [Data]()
    }
    
    
    
    init(key: String) {
        self.key = key
    }
    
    // MARK: Functions:
    
    public func appendOnUserDefaults(_ data: Data) {
        
        var userDefaultsData = savedData
        userDefaultsData.append(data)
        
        userDefaults.set(userDefaultsData, forKey: key)
    }
    
    public func removeFromUserDefaults(atIndex: Int) {
        
    }
    
}
