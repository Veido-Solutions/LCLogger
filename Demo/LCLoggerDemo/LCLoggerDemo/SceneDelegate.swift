//
//  SceneDelegate.swift
//  LCLoggerDemo
//
//  Created by Kostia Karakai on 19.06.2024.
//

import UIKit
import LCLogger
import Combine

let lcLogger = LCLogger.shared()

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    private var subscriptions = Set<AnyCancellable>()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        lcLogger.construct()
        lcLogger.log("Test")
        lcLogger.log(1)
        lcLogger.log(2)
        lcLogger.spacer()
        lcLogger.destruct()
        
        func randomString(length: Int) -> String {
          let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
          return String((0..<length).map{ _ in letters.randomElement()! })
        }
        
        for _ in 0...10 {
            lcLogger.log(randomString(length: Int.random(in: 90...100)))
        }
        
        Timer
            .publish(every: 0.3, on: .main, in: .default)
            .autoconnect()
            .sink { _ in lcLogger.log(randomString(length: Int.random(in: 90...100))) }
            .store(in: &subscriptions)
        
        let window = UIWindow(windowScene: windowScene)
        let vc = UIViewController()
        vc.view.backgroundColor = .cyan
        window.rootViewController = vc
        window.makeKeyAndVisible()
        self.window = window
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            lcLogger.showDebug(on: vc)
        }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

