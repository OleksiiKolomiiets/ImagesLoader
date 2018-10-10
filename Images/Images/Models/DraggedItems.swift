//
//  DraggedItems.swift
//  Images
//
//  Created by Oleksii  Kolomiiets on 10/10/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import UIKit

class DragedItems {
    // MARK: - Variables:
    static var limit = 3
    
    static var source: [UIViewController]! {
        didSet {
            // rewrite titles for view controllers
            for (index, vc) in source.enumerated() {
                vc.tabBarItem.title = "Item №\(index + 1)"
            }
        }
    }
    
    // MARK: - Function:
    static func add(item: UIViewController) {
        
        guard let source = self.source else {
            self.source = [item]
            return
        }
        
        if source.count < limit {
            self.source.append(item)
        } else {
            self.source[0] = self.source[1]
            self.source[1] = self.source[2]
            self.source[2] = item
        }
    }
}

