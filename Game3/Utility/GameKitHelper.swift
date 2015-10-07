//
//  GameKitHelper.swift
//  Game2
//
//  Created by Qi Feng Huang on 9/9/15.
//  Copyright © 2015 Qi Feng Huang. All rights reserved.
//

import GameKit
import Foundation

let singleton = GameKitHelper()
let PresentAuthenticationViewController = "PresentAuthenticationViewController"

class GameKitHelper: NSObject, GKGameCenterControllerDelegate {
    var authenticationViewController: UIViewController?
    var lastError:NSError?
    var gameCenterEnabled:Bool

    class var sharedInstance:GameKitHelper{
        return singleton
    }
    
    override init(){
        gameCenterEnabled = true
        super.init()
    }
    
    
    func authenticateLocalPlayer(){
        let player = GKLocalPlayer.localPlayer()
        player.authenticateHandler = {(viewController,error) in
            self.lastError = error
            if viewController != nil{
                self.authenticationViewController = viewController
                NSNotificationCenter.defaultCenter().postNotificationName(PresentAuthenticationViewController, object: self)
            }
            else if player.authenticated{
                self.gameCenterEnabled = true
            }
            else {
                self.gameCenterEnabled = false
            }
        }
    }
    
    func reportScores(score:Int64, forLeaderBoardId leaderBoardId: String){
        if !gameCenterEnabled{
            print("player not authenticated")
            return
        }
        
        let scoreReporter = GKScore(leaderboardIdentifier: leaderBoardId)
        scoreReporter.value = score
        scoreReporter.context = 0
        let scores = [scoreReporter]
        
        GKScore.reportScores(scores){(error) in
            self.lastError = error
        }
    }
    
    func showGKGameCenterViewController(viewController:GameViewController!){
        let gameCenterViewController = GKGameCenterViewController()
        gameCenterViewController.gameCenterDelegate = self
        gameCenterViewController.viewState = .Leaderboards
        viewController.presentViewController(gameCenterViewController, animated: true, completion: nil)
    }
    
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
}
