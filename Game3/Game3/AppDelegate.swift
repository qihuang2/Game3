//
//  AppDelegate.swift
//  Game2
//
//  Created by Qi Feng Huang on 5/23/15.
//  Copyright (c) 2015 Qi Feng Huang. All rights reserved.
//

import UIKit
import SpriteKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        //sound effect
        if (NSUserDefaults.standardUserDefaults().objectForKey("soundEffect") != nil){
            GAME_CONSTANTS.gameSoundEffectOn = NSUserDefaults.standardUserDefaults().objectForKey("soundEffect") as! Bool
        }
        else {
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "soundEffect")
        }
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        if let view = window?.rootViewController?.view as? SKView {
            //pause game
            if let game = view.scene as? GameScene{
                game.pauseGame()
            }
            view.scene?.paused = true
        }
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
        if let view = window?.rootViewController?.view as? SKView {
            //unpause game
            view.scene?.paused = false
            if let game = view.scene as? GameScene{
                game.unpauseGame()
            }
        }
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

