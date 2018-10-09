//
//  Parsable.swift
//  Images
//
//  Created by Oleksii  Kolomiiets on 10/5/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import Foundation

protocol Parsable {
    func decode(_ itemPath: IndexPath) -> NSString
    func encode(_ item    : NSString)  -> IndexPath?
}
