//
//  AppDelegate.swift
//  RiderAdmin
//
//  Created by Neo Ighodaro on 13/02/2018.
//  Copyright © 2018 CreativityKills Co. All rights reserved.
//

import UIKit
import GoogleMaps

class AppConstants {
    static let GOOGLE_API_KEY = "AIzaSyBCcSVBYDADArHJFn1mVWeElNGDZ_06d8U"
    static let URL = "http://127.0.0.1:4000"
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        GMSServices.provideAPIKey(AppConstants.GOOGLE_API_KEY)
        return true
    }
}

