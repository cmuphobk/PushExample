//
//  ViewController.swift
//  PushMessanger
//
//  Created by ksmirnov on 29.04.2020.
//  Copyright © 2020 ksmirnov. All rights reserved.
//

import UIKit

final class ViewController: UIViewController {
    
    private enum Constants {
        static let cellReuseIdentifier: String = "kMessageCellIndentifier"
    }
    
    // MARK: - Stored state
    
    private let messageService: MessageServiceProtocol = MessageService()
    
    // MARK: - Creating subviews
    
    override func loadView() {
        let view: UIView = {
            let view = UIView(frame: .zero)
            view.backgroundColor = .systemBackground
            return view
        }()
        self.view = view
        
        let tableView: UITableView = {
            let tableView = UITableView(frame: .zero)
            tableView.translatesAutoresizingMaskIntoConstraints = false
            tableView.dataSource = self
            tableView.delegate = self
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.cellReuseIdentifier)
            return tableView
        }()
        self.view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: self.view.layoutMarginsGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.view.layoutMarginsGuide.bottomAnchor),
            
            tableView.leadingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.trailingAnchor)
        ])
    }

}

// MARK: - UITableViewDataSource

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageService.obtainModels().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: Constants.cellReuseIdentifier) else {
            return UITableViewCell(style: .default, reuseIdentifier: Constants.cellReuseIdentifier)
        }
        cell.textLabel?.text = "Message \(indexPath.row): \(messageService.obtainModels()[indexPath.row])"
        return cell
    }
    
}

// MARK: - UITableViewDelegate

extension ViewController: UITableViewDelegate {
    
}