//
//  SearchPhotoViewController.swift
//  Images - iOS Application
//
//  Created by Oleksii  Kolomiiets on 11/6/18.
//  Copyright © 2018 Oleksii  Kolomiets. All rights reserved.
//

import UIKit

class SearchPhotoViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - Outlets:
    
    @IBOutlet weak var searchTextField: UITextField!
    
    
    // MARK: - Properties:
    
    private var helper: FlickrKitHelper!
    

    // MARK: - Lifecycle SearchPhotoViewController:
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        helper = FlickrKitHelper()
        searchTextField.delegate = self
    }
    
    
    // MARK: - UITextFieldDelegate:
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.becomeFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if let text = textField.text,
            !text.isEmpty {
            helper.load(for: [text], perPage: Int.random(in: 5 ... 10)) { (dictionary, error) in
                
            }
        }
        
        return true
    }
    
    
    
}
