//
//  GameViewController.swift
//  Game2
//
//  Created by Qi Feng Huang on 5/23/15.
//  Copyright (c) 2015 Qi Feng Huang. All rights reserved.
//

import SpriteKit

class GameViewController: UIViewController{
    
    override func viewDidLoad() {
        
        
        //Check game center
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("showAuthenticationViewController"), name: PresentAuthenticationViewController, object: nil)
        GameKitHelper.sharedInstance.authenticateLocalPlayer()

        
        super.viewDidLoad()
        
        let size = self.view.bounds.size
        let scene = MainMenu(size: size)
        // Configure the view.
        let skView = self.view as! SKView
        skView.showsFPS = false
        skView.showsNodeCount = false
        /* Sprite Kit applies additional optimizations to improve rendering performance */
        skView.ignoresSiblingOrder = false
        skView.showsDrawCount = false

        /* Set the scale mode to scale to fit the window */

        scene.scaleMode = .AspectFit
        skView.presentScene(scene)
    }
    
    

    
    private var sceneView:SKView!

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    //shows share options
    func shareButtonPressed(screenShot:UIImage){
        let activity:UIActivityViewController = UIActivityViewController(activityItems: [screenShot], applicationActivities: nil)
        var excludedActivities = [UIActivityTypeAddToReadingList,UIActivityTypeAssignToContact,UIActivityTypePrint,UIActivityTypePostToVimeo]
        
        activity.excludedActivityTypes = excludedActivities
        
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.Phone {
            self.presentViewController(activity, animated: true, completion: nil)
        }
            //on ipad, need to use popover
        else {
            let popOver = UIPopoverController(contentViewController: activity)
            popOver.presentPopoverFromRect(CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height / 7 * 5, 0, 0), inView: self.view, permittedArrowDirections: UIPopoverArrowDirection.Down, animated: true)
        }
    }
    
    
    //aunthenticate player
    func showAuthenticationViewController(){
        let gameKitHelper = GameKitHelper.sharedInstance
        if let autenticationViewController = gameKitHelper.authenticationViewController{
            self.presentViewController(autenticationViewController, animated: true, completion: nil)
        }
    }

}

