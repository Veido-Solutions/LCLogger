//
//  File.swift
//  LCLogger
//
//  Created by Kostia Karakai on 27.11.2024.
//

import UIKit
import Combine

final class LCLoggerCell: UITableViewCell {
    
    let data = PassthroughSubject<LCLoggerLog, Never>()
    let searchText = PassthroughSubject<String, Never>()
    
    var onTap: AnyPublisher<Void, Never> {
        onTapPublisher.eraseToAnyPublisher()
    }
    private let onTapPublisher = PassthroughSubject<Void, Never>()
    var onLongPress: AnyPublisher<Void, Never> {
        onLongPressPublisher.eraseToAnyPublisher()
    }
    private let onLongPressPublisher = PassthroughSubject<Void, Never>()
    
    private let titleLable = UILabel()
    private let subtitleLabel = UILabel()
    private let dateLabel = UILabel()
    private let titlesStackView = UIStackView()
    private let stackView = UIStackView()
    
    private var subscriptions = Set<AnyCancellable>()
    var actionsSubscriptions = Set<AnyCancellable>()
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        constructHierarchy()
        activateConstraints()
        styleView()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        actionsSubscriptions.removeAll()
    }
}

// MARK: - Private Methods
private extension LCLoggerCell {
    func bind() {
        data
            .map(\.date)
            .assign(to: \.text, on: dateLabel)
            .store(in: &subscriptions)
        
        Publishers
            .CombineLatest(data, searchText)
            .map { ($0.place.smallPrefix, $1) }
            .map {
                let attributedString = NSMutableAttributedString(string: $0, attributes: [.font : UIFont.boldSystemFont(ofSize: 14)])
                if !$1.isEmpty {
                    let range = ($0 as NSString).range(of: $1, options: .caseInsensitive)
                    if range.location != NSNotFound {
                        attributedString.addAttributes([.foregroundColor: UIColor.systemBlue], range: range)
                    }
                }
                return attributedString
            }
            .assign(to: \.attributedText, on: titleLable)
            .store(in: &subscriptions)
        
        Publishers
            .CombineLatest(data, searchText)
            .map { ($0.message, $1) }
            .map {
                let attributedString = NSMutableAttributedString(string: $0, attributes: [.font : UIFont.systemFont(ofSize: 14)])
                if !$1.isEmpty {
                    let range = ($0 as NSString).range(of: $1, options: .caseInsensitive)
                    if range.location != NSNotFound {
                        attributedString.addAttributes([.font : UIFont.boldSystemFont(ofSize: 14), .foregroundColor: UIColor.systemBlue], range: range)
                    }
                }
                return attributedString
            }
            .assign(to: \.attributedText, on: subtitleLabel)
            .store(in: &subscriptions)
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(_:)))
        addGestureRecognizer(longPress)
    }
    
    func constructHierarchy() {
        contentView.addSubview(stackView)
        stackView.addArrangedSubview(titlesStackView)
        stackView.addArrangedSubview(dateLabel)
        titlesStackView.addArrangedSubview(titleLable)
        titlesStackView.addArrangedSubview(subtitleLabel)
    }
    
    func activateConstraints() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12).isActive = true
        stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12).isActive = true
        stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12).isActive = true
        stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12).isActive = true
    }
    
    func styleView() {
        titleLable.numberOfLines = 0
        subtitleLabel.numberOfLines = 0
        dateLabel.font = .systemFont(ofSize: 12)
        dateLabel.setContentHuggingPriority(.required, for: .horizontal)
        dateLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        stackView.spacing = 8
        stackView.axis = .horizontal
        stackView.alignment = .top
        titlesStackView.axis = .vertical
        titlesStackView.spacing = 4
    }
    
    @objc func didLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        onLongPressPublisher.send()
    }
}
