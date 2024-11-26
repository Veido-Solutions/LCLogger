//
//  File.swift
//  LCLogger
//
//  Created by Kostia Karakai on 26.11.2024.
//

import UIKit
import Combine

class LCLoggerViewController: UITableViewController {
    
    private var logs: [String] = []
    
    private var subscriptions = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        LCLogger
            .logs
            .throttle(for: .seconds(1), scheduler: DispatchQueue.main, latest: true)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] logs in
                guard let self else { return }
                self.logs = logs
                tableView.reloadData()
                let indexPath = IndexPath(row: logs.count - 1, section: 0)
                guard tableView.indexPathsForVisibleRows?.contains(indexPath) ?? false else { return }
                tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
            .store(in: &subscriptions)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.scrollToRow(at: IndexPath(row: logs.count - 1, section: 0), at: .bottom, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        logs.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        guard indexPath.row < logs.count else { return cell }
        cell.textLabel?.text = logs[indexPath.row]
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.font = .systemFont(ofSize: 14)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard indexPath.row < logs.count else { return }
        UIPasteboard.general.string = logs[indexPath.row]
    }
}
