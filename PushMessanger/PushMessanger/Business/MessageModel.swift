//
//  MessageModel.swift
//  PushMessanger
//
//  Created by ksmirnov on 29.04.2020.
//  Copyright © 2020 ksmirnov. All rights reserved.
//

import Foundation

struct MessageModel: Codable, Hashable {
    let text: String
    let date: Date
}

extension MessageModel: Comparable {
    static func < (lhs: MessageModel, rhs: MessageModel) -> Bool {
        return lhs.date < rhs.date
    }
}

extension MessageModel: CustomStringConvertible {
    var description: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM, hh:mm"
        return "message: \(text), date: \(dateFormatter.string(from: date))"
    }
}
