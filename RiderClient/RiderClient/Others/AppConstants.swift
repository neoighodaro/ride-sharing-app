//
//  AppConstants.swift
//  RiderClient
//
//  Created by Neo Ighodaro on 20/02/2018.
//  Copyright © 2018 CreativityKills Co. All rights reserved.
//

import Foundation

class AppConstants {
    static let GOOGLE_API_KEY = "AIzaSyBCcSVBYDADArHJFn1mVWeElNGDZ_06d8U"
    static let PUSHER_KEY = "c2051f3b34ec87913faa"
    static let PUSHER_CLUSTER = "mt1"
    static let API_URL = "http://127.0.0.1:4000"
    static let PUSH_NOTIF_INSTANCE_ID = "672559fa-d7d9-4f46-ac74-e14bb64ad3ab"
    static let USER_ID = UUID().uuidString.replacingOccurrences(of: "-", with: "_")
}
