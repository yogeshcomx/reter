//
//  StringExtension.swift
//  Reter
//
//  Created by apple on 2/10/18.
//  Copyright © 2018 Comx Softech Private Limited. All rights reserved.
//

import Foundation
import UIKit

extension String {
    func convertToTimestamp() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormatter.date(from: self)!
        return date
    }
    
    func convertToUIImage() -> UIImage? {
        let dataDecode:NSData = NSData(base64Encoded: self, options:.ignoreUnknownCharacters)!
        let image:UIImage? = UIImage(data: (dataDecode as! Data))
        return image
    }
    
}
