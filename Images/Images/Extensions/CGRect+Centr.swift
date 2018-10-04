//
//  CGRect+Centr.swift
//  Images
//
//  Created by Oleksii  Kolomiiets on 10/4/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import UIKit

extension CGRect {
    var centr: CGPoint {
        let startX: CGFloat = self.origin.x
        let startY: CGFloat = self.origin.y
        let width = self.size.width
        let height = self.size.height
        
        let centrX = startX + width / 2
        let centrY = startY + height / 2
        return CGPoint(x: centrX, y: centrY)
    }
}
