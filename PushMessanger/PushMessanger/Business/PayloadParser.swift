//
//  PayloadParser.swift
//  PushMessanger
//
//  Created by ksmirnov on 30.04.2020.
//  Copyright © 2020 ksmirnov. All rights reserved.
//

import Foundation
import UserNotifications

struct PayloadParser {
    
    var payload: Payload = Payload()
    
    init(userInfo: [AnyHashable : Any]) {
        guard let aps = userInfo["aps"] as? [AnyHashable : Any] else { return }
        
        var contentAvailableInt: Int?
        if let contentAvailableStr = aps["content-available"] as? String {
            contentAvailableInt = Int(contentAvailableStr)
        } else if let contentAvailableIntFromAps = aps["content-available"] as? Int {
            contentAvailableInt = contentAvailableIntFromAps
        }
        guard let contentAvailable = contentAvailableInt else { return }
        print("\(#function), content-available int value:\(contentAvailable) [PushManager]")
        
        guard contentAvailable > 0 else { return }
            
        var titleStr: String?
        if let titleFromUserInfo = userInfo["title"] as? String {
            titleStr = titleFromUserInfo
        } else if let alertFromUserInfo = userInfo["alert"] as? String {
            titleStr = alertFromUserInfo
        } else if let titleFromUserInfo = aps["title"] as? String {
            titleStr = titleFromUserInfo
        } else if let alertFromUserInfo = aps["alert"] as? String {
            titleStr = alertFromUserInfo
        } else if let data = userInfo["data"] as? [AnyHashable: Any], let alertFromUserInfo = data["alert"] as? String {
            titleStr = alertFromUserInfo
        } else if let data = userInfo["data"] as? [AnyHashable: Any], let alertFromUserInfo = data["title"] as? String {
            titleStr = alertFromUserInfo
        }
        guard let title = titleStr else { return }
        print("\(#function), title:\(title) [PushManager]")
        
        self.payload = Payload(title: title)
    }
    
    init(content: UNNotificationContent, countMessagesInStorage: Int) {
        self.payload = Payload(title: "У вас \(countMessagesInStorage + 1) новых сообщений [modified]")
    }
    
}
