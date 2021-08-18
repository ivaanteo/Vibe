//
//  AppDelegate.swift
//  Vibe
//
//  Created by Ivan Teo on 18/6/21.
//

import UIKit
import CoreHaptics

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
//    var window: UIWindow?
    var supportsHaptics: Bool = false

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
//        self.window = UIWindow(frame: UIScreen.main.bounds)

                // In project directory storyboard looks like Main.storyboard,
                // you should use only part before ".storyboard" as its name,
                // so in this example name is "Main".
//                let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
                
                // controller identifier sets up in storyboard utilities
                // panel (on the right), it is called 'Storyboard ID'
//                let viewController = storyboard.instantiateViewController(withIdentifier: "YourViewControllerIdentifier") as! TouchViewController
//                let viewController = TouchViewController()
//                self.window?.rootViewController = viewController
//                self.window?.makeKeyAndVisible()
        
        
        let hapticCapability = CHHapticEngine.capabilitiesForHardware()
        supportsHaptics = hapticCapability.supportsHaptics
        
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

