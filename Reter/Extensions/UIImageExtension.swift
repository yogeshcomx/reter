//
//  UIImageExtension.swift
//  Reter
//
//  Created by apple on 2/10/18.
//  Copyright © 2018 Comx Softech Private Limited. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    func convertToBase64String() -> String {
        let imageData = (UIImagePNGRepresentation(self))
        let base64String = imageData?.base64EncodedString(options: .lineLength64Characters)
        return base64String!
    }
}
