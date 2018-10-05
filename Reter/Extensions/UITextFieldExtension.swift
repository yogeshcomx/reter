//
//  UITextFieldExtension.swift
//  Reter
//
//  Created by apple on 1/15/18.
//  Copyright © 2018 Comx Softech Private Limited. All rights reserved.
//

import Foundation
import UIKit

extension UITextField {
    func setBottomBorder() {
        self.borderStyle = .none
        self.layer.backgroundColor = UIColor(hex: "fdfdff").cgColor
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor(hex: "4464C3").cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 0.0
    }
    
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._ %+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self.text!)
    }
    
    func isValidPhoneNumber() -> Bool {
        if self.text!.count >= 8 && self.text!.count <= 16 {
            return true
        } else {
            return false
        }
    }
    
    func isValidPassword() -> Bool {
        if self.text!.count >= 8 {
           return true
        } else {
            return false
        }
    }
    
    func isValidName() -> Bool {
        if self.text!.count > 0 {
            return true
        } else {
            return false
        }
    }
    
    
}
