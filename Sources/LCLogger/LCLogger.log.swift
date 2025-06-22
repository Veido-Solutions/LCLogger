//
//  File.swift
//  LCLogger
//
//  Created by Kostia Karakai on 27.11.2024.
//

import Foundation

internal struct LCLoggerLog {
    enum LogType {
        case debug, construct(Int), desctruct(Int)
    }
    let message: String
    let place: Place
    let date: String
    private let logType: LogType
    
    init(message: Any?, type: String, filePath: String, line: Int, logType: LogType = .debug) {
        self.message = message == nil ? "" : "\(message!)"
        self.place = filePath.getPlace(type: type, line: line)
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        self.date = Date().formatted
        self.logType = logType
    }
    
    var formattedMessage: String {
        let m = message.isEmpty ? "" : " (\(message))"
        switch logType {
            case .debug:
                return "\(date) ===\(place.smallPrefix) \(message) ==="
            case .construct(let value):
                return "\(value)    INIT \(place.prefix)" + m
            case .desctruct(let value):
                return "\(value)  DEINIT \(place.prefix)" + m
        }
    }
}

internal struct Place {
    let value: String
    let type: String
    let line: Int
    
    var rawValue: String { value + type }
    var icon: String { Icon.allCases.first(where: { value.lowercased().contains($0.rawValue.lowercased()) } )?.icon ?? "===" }
    
    var prefix: String {
        var length = icon.count + rawValue.count + 5
        if icon == "===" { length -= 1 }
        let spacesCount = max(50 - length, 1)
        let text = String(format: " %@ %@%@===", icon, rawValue, String(repeating: " ", count: spacesCount))
        return text
    }
    
    var smallPrefix: String {
        String(format: " %@ %@:%i ===", icon, rawValue, line)
    }
    
    enum Icon: String, CaseIterable {
        case diContainer
        case tabBarController
        case viewController
        case overlayController
        case navigationController
        case rootView
        case viewModel
        case repository
        case userSession
        case session
        case configuration
        case customization
        case keychain
        case useCase
        case textField
        case factory
        case coder
        case manager
        case otherView = "view"
        case cell
        case helper
        case button
        case database
        case tabBar
        case node
        case engine
        
        var icon: String {
            switch self {
                case .diContainer: return "🫙"
                case .tabBarController, .viewController, .overlayController: return "🎥"
                case .tabBar: return "🗂️"
                case .rootView: return "📺"
                case .otherView: return "🏙️"
                case .cell: return "🏙️"
                case .viewModel: return "🧠"
                case .session: return "💼"
                case .configuration: return "🧾"
                case .customization: return "👕"
                case .keychain: return "🔐"
                case .repository: return "🗄"
                case .useCase: return "🎞"
                case .textField: return "✍️"
                case .userSession: return "🧔🏻‍♂️"
                case .factory: return "🏭"
                case .coder: return "👨‍💻"
                case .navigationController: return "🧭"
                case .manager: return "🤖"
                case .helper: return "🙏"
                case .button: return "⏺️"
                case .database: return "📀"
                case .node: return "🏙️"
                case .engine: return "🔧"
            }
        }
    }
}

// MARK: - String Extensions
private extension String {
    var lastPathComponent: String {
        if #available(iOS 16.0, *) {
            URL(filePath: self).lastPathComponent
        } else {
            URL(fileURLWithPath: self).lastPathComponent
        }
    }
    
    var deletingPathExtension: String {
        return NSString(string: self).deletingPathExtension
    }
    
    var fileName: String {
        let parts = deletingPathExtension.components(separatedBy: ".")
        guard !parts.isEmpty else { return self }
        var string = ""
        for (index, value) in parts.enumerated() {
            guard let first = value.first else { continue }
            if index == 0 {
                string.append(value)
            } else {
                string.append(first.uppercased() + value.dropFirst())
            }
        }
        return string
    }
    
    func getPlace(type: String, line: Int) -> Place {
        let type = type.isEmpty ? "" : "(\(type))"
        return Place(value: lastPathComponent.fileName, type: type, line: line)
    }
}

private extension Date {
    var formatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: self)
    }
}
