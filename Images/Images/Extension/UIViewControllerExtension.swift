//
//  UIViewControllerExtension.swift
//  Images
//
//  Created by Oleksii  Kolomiets on 8/31/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import UIKit

extension UIViewController {
    
    // MARK: Extending VC to present error info instead
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        
        present(alert, animated: true, completion: nil)
    }
}
