//
//  Payload.swift
//  PushMessanger
//
//  Created by ksmirnov on 30.04.2020.
//  Copyright © 2020 ksmirnov. All rights reserved.
//

import Foundation

struct Payload {
    let title: String
    init(title: String = "New message") {
        self.title = title
    }
}
