//
//  TouchesMovedButton.swift
//  Game2
//
//  Created by Qi Feng Huang on 6/20/15.
//  Copyright (c) 2015 Qi Feng Huang. All rights reserved.
//

import SpriteKit

class TouchesMovedButton: Button {
    private var otherButton:TouchesMovedButton!
    private var selected:Bool = false
    
    
    override init(buttonTexture: SKTexture, sceneFunction: (()->Void)){
        super.init(buttonTexture: buttonTexture, sceneFunction: sceneFunction)
        self.userInteractionEnabled = true
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        // if selectable, darkens, if not, nothign happens
        self.select()
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        let touch: UITouch = touches.first as! UITouch
        let location: CGPoint = touch.locationInNode(parent!)
        
        //if self contains point
        if self.containsPoint(location){
            //if contains point, but wanst already selected, darkens
            if !selected{
                self.select()
            }
            //if self contains, then other button loosens
            if (otherButton != nil) && otherButton.selected{
                otherButton.deselect()
            }
        }
            //self doesnt contain point
        else{
            //if was selected, loosens
            if self.selected{
                self.deselect()
            }
            //other button nil, sets otherbutton
            if otherButton == nil{
                if let node = parent?.nodeAtPoint(location) as? TouchesMovedButton{
                    otherButton = node
                    otherButton.select()
                }
            }
                
                //if not nil, changes otherbutton
            else {
                if !otherButton.containsPoint(location){
                    if otherButton.selected{
                        otherButton.deselect()
                    }
                    
                    if let node1 = parent?.nodeAtPoint(location) as? TouchesMovedButton{
                        otherButton = node1
                        otherButton.select()
                    }
                }
                else {
                    if !otherButton.selected{
                        otherButton.select()
                    }
                }
            }
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        // if selected, so fingers on top. run button action
        if self.selected{
            let buttonAction:SKAction = SKAction.sequence([self.getSceneAction(), SKAction.runBlock(deselect)])
            self.runAction(GAME_CONSTANTS.gameSoundEffectOn ? SKAction.sequence([Button.TOUCH_SOUND, buttonAction]) : buttonAction)
        }
        //other button selected, so fingers are on top of other button. run otherbutton's action
        else if (otherButton != nil){
            if otherButton.selected{
                let buttonAction:SKAction = SKAction.sequence([otherButton.getSceneAction(), SKAction.runBlock(otherButton.deselect)])
                self.runAction(GAME_CONSTANTS.gameSoundEffectOn ? SKAction.sequence([Button.TOUCH_SOUND, buttonAction]): buttonAction)
            }
        }
    }
    
    //fingers on top of button
    override func select(){
        self.selected = true
        super.select()
    }
    
    //fingers let go
    override func deselect(){
        self.selected = false
        super.deselect()
    }
    
}