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
    
    private let messageService: MessageServiceProtocol = MessageService()
    
    var window: UIWindow?
    private let viewController = ViewController()
        
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
    
    private var backgroundTaskIdentifier: UIBackgroundTaskIdentifier = .invalid

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
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        viewController.reloadData()
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
    
    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable : Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        print("\(#function), userInfo:\(userInfo) [PushManager]")
        handleSilentNotification(application, userInfo: userInfo)
        completionHandler(.newData)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        print("\(#function), userInfo:\(userInfo) [PushManager]")
        handleSilentNotification(application, userInfo: userInfo)
    }
    
    private func handleSilentNotification(_ application: UIApplication, userInfo: [AnyHashable: Any]) {
        if application.applicationState != .active {
            if backgroundTaskIdentifier == .invalid {
                backgroundTaskIdentifier = application.beginBackgroundTask(expirationHandler: { [weak self, weak application] in
                    guard let backgroundTaskIdentifier = self?.backgroundTaskIdentifier else { return }
                    application?.endBackgroundTask(backgroundTaskIdentifier)
                    self?.backgroundTaskIdentifier = .invalid;
                })
            }
        }
        
        defer {
            if application.applicationState == .active {
                DispatchQueue.main.async { [weak self] in
                    self?.viewController.reloadData()
                }
            }
        }
        
        let payloadParser = PayloadParser(userInfo: userInfo)
        messageService.storeModel(MessageModel(text: payloadParser.payload.title, timeInterval: Date().timeIntervalSince1970))
        
        if application.applicationState != .active {
            if backgroundTaskIdentifier != .invalid {
                application.endBackgroundTask(backgroundTaskIdentifier)
                backgroundTaskIdentifier = .invalid;
            }
        }
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
        let parser = PayloadParser(content: notification.request.content, countMessagesInStorage: messageService.obtainModels().count)
        messageService.storeModel(MessageModel(text: parser.payload.title, timeInterval: Date().timeIntervalSince1970))
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
