//
//  StaticStringManager.swift
//  Reter
//
//  Created by apple on 1/15/18.
//  Copyright © 2018 Comx Softech Private Limited. All rights reserved.
//

import Foundation

let baseUrl = "http://reter.urldiary.com/index.php/reterapi/"

var isDeviceOnline:Bool = false
var appMode:String = "Offline"
var offlineSmsLimit:Int = 1000
var offlineContactsLimit:Int = 10000
var userCountryCode:String = ""
