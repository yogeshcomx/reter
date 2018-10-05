//
//  UIViewExtension.swift
//  Reter
//
//  Created by apple on 1/18/18.
//  Copyright © 2018 Comx Softech Private Limited. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    func roundAllCorners(radius: CGFloat) {
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }
    
    func setBorderWidthAndColor(width: CGFloat, color: CGColor) {
        self.layer.borderWidth = width
        self.layer.borderColor = color
    }
}
