//
//  Buttons.swift
//  Block Party
//
//  Created by Qi Feng Huang on 2/16/15.
//  Copyright (c) 2015 Qi Feng Huang. All rights reserved.
//

import SpriteKit

//buttons
class Button:SKSpriteNode {
    private var maxAlpha:CGFloat = 1.0
    private let sceneAction:SKAction
    static let TOUCH_SOUND:SKAction = SKAction.playSoundFileNamed("pop.wav", waitForCompletion: false)
    
    init(buttonTexture: SKTexture, sceneFunction: (()->Void)){
        self.sceneAction = SKAction.runBlock(sceneFunction)
        super.init(texture: buttonTexture, color: UIColor.clearColor(), size: buttonTexture.size())
    }
    
    required init(coder aDecoder : NSCoder){
        fatalError("NSCoding not supported")
    }
    
    
    func getSceneAction()->SKAction{
        return self.sceneAction
    }
    
    func select(){
        self.alpha = 0.5
    }
    
    func deselect(){
        self.alpha = maxAlpha
    }
    
    func getMaxAlpha()->CGFloat{
        return self.maxAlpha
    }
    
    func setMaxAlpha(alpha: CGFloat){
        self.maxAlpha = alpha
    }
}
