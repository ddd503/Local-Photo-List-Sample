//
//  AppDelegate.swift
//  Local-Photo-List-Sample
//
//  Created by kawaharadai on 2018/12/02.
//  Copyright © 2018 kawaharadai. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        setupStartVC()
        return true
    }
    
    func setupStartVC() {
        let window = UIWindow()
        window.rootViewController = UINavigationController(rootViewController: PhotoListViewController.makePhotoListViewController())
        self.window = window
        self.window?.makeKeyAndVisible()
        
    }
    
}

