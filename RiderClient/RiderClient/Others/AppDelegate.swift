//
//  AppDelegate.swift
//  RiderClient
//
//  Created by Neo Ighodaro on 12/02/2018.
//  Copyright © 2018 CreativityKills Co. All rights reserved.
//

import UIKit
import GoogleMaps

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        GMSServices.provideAPIKey(AppConstants.GOOGLE_API_KEY)
        return true
    }
}

