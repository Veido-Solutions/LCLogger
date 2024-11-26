//
//  File.swift
//  LCLogger
//
//  Created by Kostia Karakai on 26.11.2024.
//

import UIKit
import Combine

class LCLoggerViewController: UITableViewController {
    
    private var subscriptions = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        LCLogger
            .logs
            .throttle(for: .seconds(1), scheduler: DispatchQueue.main, latest: true)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.tableView.reloadData() }
            .store(in: &subscriptions)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        LCLogger.logs.value.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = LCLogger.logs.value[indexPath.row]
        cell.textLabel?.numberOfLines = 0
        return cell
    }
}
