//
//  AppDelegate.swift
//  LocoKit Demo App
//
//  Created by Matt Greenfield on 10/07/17.
//  Copyright © 2017 Big Paua. All rights reserved.
//

import LocoKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        window = UIWindow(frame: UIScreen.main.bounds)
        
        let rootViewController = ViewController()
        let navigationController = UINavigationController(rootViewController: rootViewController);
        
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
        let superLogger = SuperLogger.sharedInstance()
        superLogger?.redirectNSLogToDocumentFolder()
        superLogger?.mailTitle = "LocoKit Demo App"
        superLogger?.mailContect = "LogFile"
        
        if (launchOptions?[.location] != nil) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                let navigationController = self.window?.rootViewController as? UINavigationController
                guard let controller = navigationController?.viewControllers[0] as? ViewController else { return }
                controller.tappedStart()
            }
        }
        
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // request "always" location permission
        LocomotionManager.highlander.requestLocationPermission(background: true)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        let navigationController = window?.rootViewController as? UINavigationController
        guard let controller = navigationController?.viewControllers[0] as? ViewController else { return }
        
        // update the UI on appear
        controller.update()
    }

}

