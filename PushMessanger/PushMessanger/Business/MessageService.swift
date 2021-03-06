//
//  MessageService.swift
//  PushMessanger
//
//  Created by ksmirnov on 29.04.2020.
//  Copyright © 2020 ksmirnov. All rights reserved.
//

import Foundation

final class MessageService: MessageServiceProtocol {
    
    private enum Constants {
        static let messagesKey: String = "kMessagesKey"
    }
    
    private let storage: UserDefaults
    private let repository: CRUDKeyValueRepository<MessageModel>
    
    init() {
        storage = UserDefaults(suiteName: "group.com.ksmirnov.PushMessangerNSE") ?? UserDefaults.standard
        repository = CRUDKeyValueRepository<MessageModel>(key: Constants.messagesKey, storage: storage)
    }
    
    func obtainModels() -> [MessageModel] {
        return repository.readAll().sorted { $0 < $1 }
    }
    
    func storeModel(_ model: MessageModel) {
        repository.create(model: model)
    }
    
}
