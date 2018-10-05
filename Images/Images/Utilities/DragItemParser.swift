//
//  DragItemParser.swift
//  Images
//
//  Created by Oleksii  Kolomiiets on 10/5/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import Foundation

class DragItemParser: Parsable {
    func decode(_ itemPath: IndexPath) -> NSString {
        let section = String(itemPath.section)
        let row = String(itemPath.row)
        let separator = " "
        let item = section + separator + row
        
        return item as NSString
    }
    
    func encode(_ item: NSString) -> IndexPath? {
        let string = String(item)
        let stringArray = string.split(separator: " ")
        
        guard let subStringSection = stringArray.first, let section = Int(String(subStringSection)),
            let subStringRow = stringArray.last, let row = Int(String(subStringRow)) else {
                return nil
        }
        
        return IndexPath(row: row, section: section)
    }
}
