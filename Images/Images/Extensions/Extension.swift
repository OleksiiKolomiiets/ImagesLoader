//
//  Extension.swift
//  Images - iOS Application
//
//  Created by Oleksii  Kolomiiets on 10/18/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import Foundation
import UIKit

extension Bool {
    mutating func toggle() {
        self = !self
    }
}

extension UIView {
    func rounded() {
        layer.cornerRadius = min(frame.size.width, frame.size.height) / 2
    }
}
