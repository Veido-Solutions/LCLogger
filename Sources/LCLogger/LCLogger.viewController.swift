//
//  File.swift
//  LCLogger
//
//  Created by Kostia Karakai on 26.11.2024.
//

import UIKit
import Combine

@available(iOS 14.0, *)
class LCLoggerViewController: UITableViewController, UISearchBarDelegate {

    private var searchBar = UISearchBar()

    @Published private var allItems: [LCLoggerLog] = []
    @Published private var items: [LCLoggerLog] = []
    @Published private var searchText = ""
    
    private var shouldScrollToBottom = true
    
    private var subscriptions = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        bind()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? LCLoggerCell else { return UITableViewCell() }
        guard indexPath.row < items.count else { return cell }
        let item = items[indexPath.row]
        cell.data.send(item)
        cell.searchText.send(searchText)
        cell.onLongPress
            .sink { [weak self] in
                guard let self else { return }
                searchBar.text = item.place.smallPrefix
                searchText = item.place.smallPrefix
            }
            .store(in: &cell.actionsSubscriptions)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard indexPath.row < items.count else { return }
        UIPasteboard.general.string = items[indexPath.row].formattedMessage
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.isTracking else { return }
        shouldScrollToBottom = scrollView.frame.height + scrollView.contentOffset.y > scrollView.contentSize.height
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        shouldScrollToBottom = scrollView.frame.height + scrollView.contentOffset.y > scrollView.contentSize.height
    }
}

// MARK: - Private Methods
@available(iOS 14.0, *)
private extension LCLoggerViewController {
    func bind() {
        LCLogger
            .logs
            .assign(to: &$allItems)
        
        Publishers
            .CombineLatest($allItems, $searchText)
            .sink { [weak self] allItems, searchText in
                guard let self else { return }
                items = searchText.isEmpty ? allItems : allItems.filter { $0.formattedMessage.lowercased().contains(searchText.lowercased()) }
            }
            .store(in: &subscriptions)
        
        $items
            .throttle(for: .seconds(1), scheduler: DispatchQueue.main, latest: false)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                guard let self else { return }
                guard self.shouldScrollToBottom else { return }
                tableView.reloadData {
                    guard !self.items.isEmpty else { return }
                    guard self.shouldScrollToBottom else { return }
                    guard let indexPath = self.tableView.indexPathForLastRow else { return }
                    self.tableView.safeScrollToRow(at: indexPath, at: .bottom, animated: true)
                }
            }
            .store(in: &subscriptions)
    }
    
    func setupUI() {
        tableView.register(LCLoggerCell.self, forCellReuseIdentifier: "cell")
        
        searchBar.delegate = self
        searchBar.placeholder = "Filter"
        searchBar.showsCancelButton = true
        searchBar.returnKeyType = .done
        navigationItem.titleView = searchBar

        let closeButton = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(closeTapped))
        navigationItem.leftBarButtonItem = closeButton
    }
    
    @objc func closeTapped() {
        dismiss(animated: true)
    }
}

// MARK: - UISearchBarDelegate
@available(iOS 14.0, *)
extension LCLoggerViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        shouldScrollToBottom = true
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        shouldScrollToBottom = true
        searchBar.resignFirstResponder()
    }
}

private extension UITableView {
    func reloadData(_ completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0, animations: {
            self.reloadData()
        }, completion: { _ in
            completion()
        })
    }
    
    var indexPathForLastRow: IndexPath? {
        guard let lastSection else { return nil }
        return indexPathForLastRow(inSection: lastSection)
    }
    
    var lastSection: Int? {
        numberOfSections > 0 ? numberOfSections - 1 : nil
    }
    
    func indexPathForLastRow(inSection section: Int) -> IndexPath? {
        guard numberOfSections > 0, section >= 0 else { return nil }
        guard numberOfRows(inSection: section) > 0 else {
            return IndexPath(row: 0, section: section)
        }
        return IndexPath(row: numberOfRows(inSection: section) - 1, section: section)
    }
    
    func safeScrollToRow(at indexPath: IndexPath, at scrollPosition: UITableView.ScrollPosition, animated: Bool) {
        guard indexPath.section < numberOfSections else { return }
        guard indexPath.row < numberOfRows(inSection: indexPath.section) else { return }
        scrollToRow(at: indexPath, at: scrollPosition, animated: animated)
    }
}
