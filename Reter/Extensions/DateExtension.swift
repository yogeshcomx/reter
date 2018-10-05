//
//  DateExtension.swift
//  Reter
//
//  Created by apple on 2/10/18.
//  Copyright © 2018 Comx Softech Private Limited. All rights reserved.
//

import Foundation

extension Date {
    func convertToString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = dateFormatter.string(from: self)
        return dateString
    }
    
}
