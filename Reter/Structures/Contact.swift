//
//  Contact.swift
//  Reter
//
//  Created by apple on 1/20/18.
//  Copyright © 2018 Comx Softech Private Limited. All rights reserved.
//

import Foundation

struct Contact {
    let contactId:String
    let name:String
    let countryCode:String
    let phone:String
    let email: String?
    let imageData: String?
    let lastUpdateDate: String
    let addedByUser: String
    var isActive:Bool
    var isSelected: Bool = false
}

