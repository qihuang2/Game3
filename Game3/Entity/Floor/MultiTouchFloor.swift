//
//  MultiTouchFloor.swift
//  Game2
//
//  Created by Qi Feng Huang on 5/28/15.
//  Copyright (c) 2015 Qi Feng Huang. All rights reserved.
//

import SpriteKit

class MultiTouchFloor: Floor{
    private let maxTouches:Int
    private var touchesLeft:Int
    private var spriteArray:[SKSpriteNode] = [SKSpriteNode]()
    
    init(activeTexture: [SKTexture], coord: CGPoint, touches: Int) {
        
        self.maxTouches = touches
        self.touchesLeft = touches
        super.init(activeTexture: activeTexture[touches-1], coord: coord)
        for i in 0..<touches-1{
            let sprite = SKSpriteNode(texture: activeTexture[i])
            sprite.hidden = true
            spriteArray.append(sprite)
            sprite.zPosition = -30
            addChild(sprite)
        }
        self.name = "floor"
    }
    
    func getTouchesLeft()->Int{
        return self.touchesLeft
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchedByHero() {
        if (touchesLeft == maxTouches){
            self.hideActiveSprite()
            --touchesLeft
            spriteArray[touchesLeft-1].hidden = false
            spriteArray[touchesLeft-1].alpha = 1
        }
        else if (touchesLeft == 1){
            super.touchedByHero()
        }
        else{
            --touchesLeft
            spriteArray[touchesLeft-1].hidden = false
            spriteArray[touchesLeft].runAction(SKAction.fadeOutWithDuration(0.5))
        }
    }
    
    override func untouchedByHero() {
        if touchesLeft != maxTouches {
            spriteArray[touchesLeft - 1].hidden = true
            showActiveSprite()
            touchesLeft = maxTouches
        }
        super.untouchedByHero()
        
    }
    
    override func toggleByHero() {
        if self.beenTouched(){
            self.untouchedByHero()
        }
        else {
            super.touchedByHero()
        }
    }
}
