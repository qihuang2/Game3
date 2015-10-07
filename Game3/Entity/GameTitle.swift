//
//  GameTitle.swift
//  Game2
//
//  Created by Qi Feng Huang on 8/16/15.
//  Copyright © 2015 Qi Feng Huang. All rights reserved.
//

import SpriteKit

//Title for main menu scene
class GameTitle: SKNode {
    let backgroundLayer = SKNode()
    let innerCircle:SKSpriteNode
    let outerCircle:SKSpriteNode
    
    override init(){
        innerCircle = SKSpriteNode(imageNamed: "tHero_in")
        outerCircle = SKSpriteNode(imageNamed: "tHero_out")
        let titleSprite = SKSpriteNode(imageNamed: "title")
        
        super.init()
        
        backgroundLayer.addChild(innerCircle)
        backgroundLayer.addChild(outerCircle)
        backgroundLayer.zPosition = -25
        
        self.addChild(titleSprite)
        self.addChild(backgroundLayer)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //adds a rotating effect
    func animateTitle(speed: NSTimeInterval){
        let rotateClockwise = SKAction.rotateByAngle(CGFloat(M_2_PI), duration: speed)
        let rotateCounterClockwise = SKAction.rotateByAngle(CGFloat(-M_2_PI), duration: speed)
        innerCircle.runAction(SKAction.repeatActionForever(rotateClockwise))
        outerCircle.runAction(SKAction.repeatActionForever(rotateCounterClockwise))
    }
}
