//
//  AppDelegate.swift
//  RiderAdmin
//
//  Created by Neo Ighodaro on 13/02/2018.
//  Copyright © 2018 CreativityKills Co. All rights reserved.
//

import UIKit
import GoogleMaps
import PushNotifications
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    
    var pushNotifications = PushNotifications.shared

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        GMSServices.provideAPIKey(AppConstants.GOOGLE_API_KEY)
        
        self.pushNotifications.start(instanceId: AppConstants.PUSH_NOTIF_INSTANCE_ID)
        self.pushNotifications.registerForRemoteNotifications()
        
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        
        let cancelAction = UNNotificationAction(identifier: "cancel", title: "Reject", options: [.foreground])
        let acceptAction = UNNotificationAction(identifier: "accept", title: "Accept Request", options: [.foreground])
        let category = UNNotificationCategory(identifier: "DriverActions", actions: [acceptAction, cancelAction], intentIdentifiers: [])
        
        center.setNotificationCategories([category])
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        self.pushNotifications.registerDeviceToken(deviceToken) {
            try? self.pushNotifications.subscribe(interest: "ride_requests")
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let name = Notification.Name("status")

        if response.actionIdentifier == "cancel" {
            NotificationCenter.default.post(name: name, object: nil, userInfo: ["status": RideStatus.Neutral])
        }
        
        if response.actionIdentifier == "accept" {
            NotificationCenter.default.post(name: name, object: nil, userInfo: ["status": RideStatus.FoundRide])
        }
        
        completionHandler()
    }
}

