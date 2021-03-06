//
//  NotificationService.swift
//  NotificationServiceExtension
//
//  Created by ksmirnov on 29.04.2020.
//  Copyright © 2020 ksmirnov. All rights reserved.
//

import UserNotifications

final class NotificationService: UNNotificationServiceExtension {
    
    private let messageService: MessageServiceProtocol = MessageService()

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        if let bestAttemptContent = bestAttemptContent {
            print("\(#function), content:\(bestAttemptContent) [PushManager]")
            let parser = PayloadParser(content: bestAttemptContent, countMessagesInStorage: messageService.obtainModels().count)
            messageService.storeModel(MessageModel(text: bestAttemptContent.title, timeInterval: Date().timeIntervalSince1970))
            bestAttemptContent.title = parser.payload.title
            contentHandler(bestAttemptContent)
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

}
