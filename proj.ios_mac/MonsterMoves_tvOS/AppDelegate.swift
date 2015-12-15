//
//  AppDelegate.swift
//  MonsterMoves_tvOS_Swift
//
//  Created by Poojan Jhaveri on 11/24/15.
//  Copyright © 2015 IDEO. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import GameController

@UIApplicationMain



class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var motionDelegate: ReactToMotionEvents? = nil

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        // Start Crashlytics
        Fabric.with([Crashlytics.self])
        
        // Get notification for controllers
        let center = NSNotificationCenter.defaultCenter()
        center.addObserver(self, selector: "setupControllers:", name: GCControllerDidConnectNotification, object: nil)
        center.addObserver(self, selector: "setupControllers:", name: GCControllerDidDisconnectNotification, object: nil)
        GCController.startWirelessControllerDiscoveryWithCompletionHandler { () -> Void in
            
        }
        
        
        
        return true
    }
    
    

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    /// Sets Motion Delegate on Controller - connection
    func setupControllers(notif: NSNotification) {
        print("controller conneciton - establisted/lost")
        let controllers = GCController.controllers()
        for controller in controllers {
            controller.motion?.valueChangedHandler = { (motion: GCMotion)->() in
                if let delegate = self.motionDelegate {
                    delegate.motionUpdate(motion)
                }
            }
        }
    }
}

protocol ReactToMotionEvents {
    func motionUpdate(motion: GCMotion) -> Void
}

