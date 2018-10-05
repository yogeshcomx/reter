//
//  Message.swift
//  Reter
//
//  Created by apple on 1/22/18.
//  Copyright © 2018 Comx Softech Private Limited. All rights reserved.
//

import Foundation

struct Message {
    let messageId:String
    let recipients: [String]
    let message: String
    let sentTimestamp:String
    let sentByUsrID: String
    var isSelected: Bool = false
}

struct Mail {
    let mailId:String
    let recipients: [String]
    let subject: String
    let message: String
    let sentTimestamp:String
    let sentByUsrID: String
    var isSelected: Bool = false
}


