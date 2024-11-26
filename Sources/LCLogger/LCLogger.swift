import UIKit
import Combine

public protocol LCLoggerErrorProtocol {
    var errorDescription: String { get }
}

public final class LCLogger {
    
    internal static let logs = CurrentValueSubject<[String], Never>([])
    
    public var enabled: Bool = true {
        didSet { outputStream.enabled = enabled }
    }
    private var outputStream: OutputStream
    private var countOfInit = 0
    private var countOfDeinit = 0
    
    private init(prefix: String?, suffix: String?) {
        outputStream = OutputStream(
            prefix: prefix,
            suffix: suffix
        )
    }
    
    public func construct(_ message: Any? = nil, type: String = "", filePath: String = #file) {
        let place = filePath.getPlace(type: type)
        let m = String(format: "%.3d    INIT \(place.prefix)", getInitCount())
        let message = m + (message == nil ? "" : " (" + "\(message!)" + ")")
        outputStream.write(message)
    }
    
    public func destruct(_ message: Any? = nil, type: String = "", filePath: String = #file) {
        let place = filePath.getPlace(type: type)
        let m = String(format: "%.3d  DEINIT \(place.prefix)", getDeinitCount())
        let message = m + (message == nil ? "" : " (" + "\(message!)" + ")")
        outputStream.write(message)
    }
    
    public func log(_ message: Any, type: String = "", filePath: String = #file) {
        let place = filePath.getPlace(type: type)
        let message = "\(currentTime) ===" + place.smallPrefix + " " + "\(message)" + " ==="
        outputStream.write(message)
        guard enabled else { return }
        let logs = LCLogger.logs.value + [message]
        LCLogger.logs.send(logs)
    }
    
    public func error(_ error: Error, type: String = "", filePath: String = #file) {
        let message = "‼️ Error: \((error as? LCLoggerErrorProtocol)?.errorDescription ?? error.localizedDescription)"
        log(message, type: type, filePath: filePath)
    }
    
    public func showDebug(on viewController: UIViewController?) {
        guard let viewController else { return }
        let vc = LCLoggerViewController()
        viewController.present(vc, animated: true)
    }
}

// MARK: - Shared
public extension LCLogger {
    private static func sharedInstance(prefix: String?, suffix: String?) -> LCLogger {
        let instance = LCLogger(prefix: prefix, suffix: suffix)
        return instance
    }
    
    static func shared(prefix: String? = nil, suffix: String? = nil) -> LCLogger {
        sharedInstance(prefix: prefix, suffix: suffix)
    }
}

// MARK: - Private Methods
private extension LCLogger {
    func getInitCount() -> Int {
        countOfInit += 1
        return countOfInit
    }
    
    func getDeinitCount() -> Int {
        countOfDeinit += 1
        return countOfDeinit
    }
    
    var currentTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: Date())
    }
}

// MARK: - OutputStream
private struct OutputStream {
    public var enabled: Bool = true
    
    let prefix: String?
    let suffix: String?
    
    func write(_ message: String) {
        guard enabled else { return }
        var message = message
        if let prefix { message = "\(prefix) - \(message)" }
        if let suffix { message.append(" \(suffix)") }
#if DEBUG
        print(message)
#endif
    }
}

// MARK: - Place
private struct Place {
    let value: String
    let type: String
    
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
        String(format: " %@ %@ ===", icon, rawValue)
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
    
    func getPlace(type: String) -> Place {
        let type = type.isEmpty ? "" : "(\(type))"
        return Place(value: lastPathComponent.fileName, type: type)
    }
}
