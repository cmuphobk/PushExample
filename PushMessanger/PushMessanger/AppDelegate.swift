//
//  AppDelegate.swift
//  PushMessanger
//
//  Created by ksmirnov on 29.04.2020.
//  Copyright © 2020 ksmirnov. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    private let viewController = ViewController()
    
    private let messageService: MessageServiceProtocol = MessageService()
    
    private var deviceTokenString: String? {
        didSet {
            guard let deviceTokenString = deviceTokenString, let fcmTokenString = fcmTokenString else { return }
            viewController.showCredentials(deviceTokenString: deviceTokenString, fcmTokenString: fcmTokenString)
        }
    }
    private var fcmTokenString: String? {
        didSet {
            guard let deviceTokenString = deviceTokenString, let fcmTokenString = fcmTokenString else { return }
            viewController.showCredentials(deviceTokenString: deviceTokenString, fcmTokenString: fcmTokenString)
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
        }
        center.delegate = self
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = viewController
        window?.makeKeyAndVisible()
        
        return true
    }

}

extension AppDelegate {
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        deviceTokenString = deviceToken.reduce("") { $0 + String(format: "%02X", $1) }
        print("\(#function), APNs device token: \(deviceTokenString ?? "none") [PushManager]")
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("\(#function), error:\(error.localizedDescription) [PushManager]")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        defer {
            viewController.reloadData()
        }
        print("\(#function), userInfo:\(userInfo) [PushManager]")
        guard let aps = userInfo["aps"] as? [AnyHashable : Any] else { return }
        
        guard let contentAvailableStr = aps["content-available"] as? String else { return }
        print("\(#function), content-available string value:\(contentAvailableStr) [PushManager]")
        
        guard let contentAvailable = Int(contentAvailableStr) else { return }
        print("\(#function), content-available int value:\(contentAvailable) [PushManager]")
        
        guard contentAvailable > 0 else { return }
            
        guard let title = userInfo["title"] as? String else { return }
        print("\(#function), title:\(title) [PushManager]")
        
        messageService.storeModel(MessageModel(text: title, timeInterval: Date().timeIntervalSince1970))
        // FIXME: - maybe trigger local notification
    }
    
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        fcmTokenString = fcmToken
        print("\(#function), firebase registration token: \(fcmToken) [PushManager]")
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        print("\(#function), notification: \(notification)")
        defer {
            viewController.reloadData()
        }
        completionHandler([.alert, .sound, .badge])
    }
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        print("\(#function), response: \(response) [PushManager]")
        completionHandler()
    }
}
