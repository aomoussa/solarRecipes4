//
//  AppDelegate.swift
//  solarRecipes2
//
//  Created by Ahmed Moussa on 11/9/16.
//  Copyright © 2016 Ahmed Moussa. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FacebookCore
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        return AWSMobileClient.sharedInstance.didFinishLaunching(application, withOptions: launchOptions)
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        let fbstuff = FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: nil)
        let AWSStuff = AWSMobileClient.sharedInstance.withApplication(application, withURL: url, withSourceApplication: sourceApplication, withAnnotation: annotation as AnyObject)
        let combineFBAndAWS = fbstuff && AWSStuff
        return combineFBAndAWS
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        AppEventsLogger.activate(application)
        //FBSDKAppEvents.activateApp()
        AWSMobileClient.sharedInstance.applicationDidBecomeActive(application)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

