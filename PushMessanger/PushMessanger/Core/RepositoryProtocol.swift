//
//  RepositoryProtocol.swift
//  PushMessanger
//
//  Created by ksmirnov on 29.04.2020.
//  Copyright © 2020 ksmirnov. All rights reserved.
//

import Foundation

protocol RepositoryProtocol {
    
    associatedtype Model: Hashable
    
    func create(model: Model)
    func create(models: [Model])
    
    func exists(model: Model) -> Bool
    func readAll() -> [Model]
    
    func update(model: Model)
    func update(models: [Model])
    
    func delete(model: Model)
    func deleteAll()
    
}
