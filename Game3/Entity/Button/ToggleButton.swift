//
//  ToggleButton.swift
//  Game2
//
//  Created by Qi Feng Huang on 7/5/15.
//  Copyright (c) 2015 Qi Feng Huang. All rights reserved.
//

import SpriteKit

//buttons that can be toogled on and off

class ToggleButton: TouchesMovedButton {
    private var isOn:Bool
    let onSprite:SKSpriteNode
    let offSprite:SKSpriteNode
    
    
    init(onTexture: SKTexture, offTexture:SKTexture, clearTexture:SKTexture, buttonAction: (()->Void)){
        self.isOn = true
        onSprite = SKSpriteNode(texture: onTexture)
        offSprite = SKSpriteNode(texture: offTexture)
        offSprite.hidden = true
        onSprite.zPosition = -25
        offSprite.zPosition = -25
        super.init(buttonTexture: clearTexture, sceneFunction: buttonAction)
        
        self.addChild(onSprite)
        self.addChild(offSprite)
        self.zPosition = 25
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //toggle on
    func turnOn(){
        offSprite.hidden = true
        onSprite.hidden = false
        self.isOn = true
    }
    
    //toggle off
    func turnOff(){
        self.isOn = false
        onSprite.hidden = true
        offSprite.hidden = false
    }
    
    //if currentlt on, toggle off
    //else toggle off
    override func getSceneAction() -> SKAction {
        let toggledEffect:SKAction = (isOn ? SKAction.runBlock(turnOff) : SKAction.runBlock(turnOn))
        return SKAction.sequence([toggledEffect, super.getSceneAction()])
    }
    
    
}

