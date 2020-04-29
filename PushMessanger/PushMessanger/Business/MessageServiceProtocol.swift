//
//  MessageServiceProtocol.swift
//  PushMessanger
//
//  Created by ksmirnov on 29.04.2020.
//  Copyright © 2020 ksmirnov. All rights reserved.
//

import Foundation

protocol MessageServiceProtocol {
    func obtainModels() -> [MessageModel]
    func storeModel(_ model: MessageModel)
}

