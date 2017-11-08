//
//  AppDelegate.swift
//  Vlack
//
//  Created by Yuma Antoine Decaux on 2/9/17.
//  Copyright © 2017 Yuma Antoine Decaux. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NSApplication.shared().registerForRemoteNotifications(matching: [.alert, .sound])
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func application(_ application: NSApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenString = deviceToken.map{String(format: "%02.2hhx", $0)}.joined()
        manager.initiatePushNotificationSequence(token: tokenString, first: false)
    }
    
    func application(_ application: NSApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Remote notification unavailable \(error)")
    }

    func application(_ application: NSApplication, didReceiveRemoteNotification userInfo: [String : Any]) {
manager.updateModel(userInfo)
    }
    
    
    
    
}
