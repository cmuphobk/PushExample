//
//  MessageModel.swift
//  PushMessanger
//
//  Created by ksmirnov on 29.04.2020.
//  Copyright © 2020 ksmirnov. All rights reserved.
//

import Foundation

struct MessageModel {
    let identifier: String
    let text: String
    let timeInterval: TimeInterval
    
    init(text: String, timeInterval: TimeInterval) {
        self.identifier = UUID.init().uuidString
        self.text = text
        self.timeInterval = timeInterval
    }
    
    enum CodingKeys: String, CodingKey {
        case identifier
        case text
        case timeInterval
    }
}

extension MessageModel: Encodable {
    func encode(to encoder: Encoder) throws {
        var values = encoder.container(keyedBy: CodingKeys.self)
        try values.encode(identifier, forKey: .identifier)
        try values.encode(text, forKey: .text)
        try values.encode(timeInterval, forKey: .timeInterval)
    }
}

extension MessageModel: Decodable {
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.identifier = try values.decode(String.self, forKey: .identifier)
        self.text = try values.decode(String.self, forKey: .text)
        self.timeInterval = try values.decode(TimeInterval.self, forKey: .timeInterval)
    }
}

extension MessageModel: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}

extension MessageModel: Comparable {
    static func < (lhs: MessageModel, rhs: MessageModel) -> Bool {
        return lhs.timeInterval < rhs.timeInterval
    }
}

extension MessageModel: CustomStringConvertible {
    var description: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM, hh:mm"
        return "message: \(text), date: \(dateFormatter.string(from: Date(timeIntervalSince1970: timeInterval)))"
    }
}
