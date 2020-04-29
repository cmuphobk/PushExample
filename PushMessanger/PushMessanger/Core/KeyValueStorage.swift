//
//  KeyValueStorage.swift
//  PushMessanger
//
//  Created by ksmirnov on 29.04.2020.
//  Copyright © 2020 ksmirnov. All rights reserved.
//

import Foundation

public protocol KeyValueStorageProtocol {
    func value(forKey key: String) -> Any?
    func setValue(_ value: Any?, forKey key: String)
}
