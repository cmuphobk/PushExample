//
//  CRUDKeyValueRepository.swift
//  PushMessanger
//
//  Created by ksmirnov on 29.04.2020.
//  Copyright © 2020 ksmirnov. All rights reserved.
//

import Foundation

final class CRUDKeyValueRepository<Entity: Codable & Hashable> {
    typealias Model = Entity

    private(set) var storage: KeyValueStorageProtocol
    private(set) var key: String
    
    init(key: String, storage: KeyValueStorageProtocol) {
        self.key = key
        self.storage = storage
    }
}

// MARK: - Repository

extension CRUDKeyValueRepository: RepositoryProtocol {
    
    func create(model: Entity) {
        update(model: model)
    }
    
    func create(models: [Entity]) {
        update(models: models)
    }
    
    func exists(model: Entity) -> Bool {
        let storedModels = obtainModels()
        return storedModels[model.hashValue] != nil
    }
    
    func readAll() -> [Entity] {
        return obtainModels().map { $0.value }
    }
    
    func update(model: Entity) {
        var storedModels = obtainModels()
        storedModels[model.hashValue] = model
        storeModels(storedModels)
    }
    
    func update(models: [Entity]) {
        var storedModels = obtainModels()
        for model in models {
            storedModels[model.hashValue] = model
        }
        storeModels(storedModels)
    }
    
    func delete(model: Entity) {
        var storedModels = obtainModels()
        storedModels.removeValue(forKey: model.hashValue)
    }
    
    func deleteAll() {
        storeModels([:])
    }
    
}

// MARK: - Helper's

extension CRUDKeyValueRepository {
    
    private func obtainModels() -> [Int: Entity] {
        guard let data = storage.value(forKey: key) as? Data else { return [:] }
        do {
            let result = try JSONDecoder().decode([Int: Entity].self, from: data)
            return result
        } catch {
            print("\(#function), error: \(error.localizedDescription) [PushManager]")
            return [:]
        }
    }
    
    private func storeModels(_ models: [Int: Entity]) {
        do {
            let data = try JSONEncoder().encode(models)
            storage.setValue(data, forKey: key)
        } catch {
            print("\(#function), error: \(error.localizedDescription) [PushManager]")
        }
        
    }
    
}
