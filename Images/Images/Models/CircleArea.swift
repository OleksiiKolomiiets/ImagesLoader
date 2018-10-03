//
//  CircleArea.swift
//  Images
//
//  Created by Oleksii  Kolomiiets on 10/2/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import UIKit

struct CircleArea {
    let centr   : CGPoint
    let radius  : CGFloat
}

extension CircleArea {
    init(with rect: CGRect) {
        let yPosition   = rect.origin.y
        let xPosition   = rect.origin.x
        let width       = rect.size.width
        let height      = rect.size.height
        let centr = CGPoint(x: xPosition + width / 2,
                            y: yPosition + height / 2)
        let radius = height * 0.9 / 2
        
        self.init(centr: centr, radius: radius)
    }
}
