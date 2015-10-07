//
//  Floor.swift
//  Game2
//
//  Created by Qi Feng Huang on 5/23/15.
//  Copyright (c) 2015 Qi Feng Huang. All rights reserved.
//
import SpriteKit

class Floor: SKSpriteNode{
    let coordinate:CGPoint!  //x = row , y = column
    private var touched: Bool = false
    let activeSprite:SKSpriteNode
    
    init(activeTexture: SKTexture, coord: CGPoint){
        self.coordinate = coord
        activeSprite = SKSpriteNode(texture: activeTexture)
        super.init(texture: nil, color: UIColor.clearColor(), size: activeTexture.size())
        
        activeSprite.zPosition = -25
        self.addChild(activeSprite)
        self.name = "floor"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func beenTouched()->Bool{
        return self.touched
    }
    
    func touchedByHero(){
        if self.hasActions(){
            self.removeAllActions()
        }
        self.touched = true
        fadeFloor()
        decrementActiveTiles()
    }
    
    func decrementActiveTiles(){
        let gameGrid = self.parent as! GridLayer
        gameGrid.decrementActiveTiles()
    }
    
    func incrementActiveTiles(){
        let gameGrid = self.parent as! GridLayer
        gameGrid.incrementActiveTiles()
    }
    
    func floorEffectOnHero(hero:Hero)->SKAction?{
        return nil
    }
    
    func fadeFloor(){
        self.runAction(SKAction.fadeAlphaTo(0.35, duration: 0.75))
    }
    
    func hideActiveSprite(){
        activeSprite.runAction(SKAction.fadeOutWithDuration(0.5))
    }
    
    func showActiveSprite(){
        activeSprite.alpha = 1
    }
    
    func untouch(){
        self.touched = false
    }
    
    func untouchedByHero(){
        //problem if touch and untouch happen right away.
        // solved if previous action is removed first
        if self.hasActions(){
            self.removeAllActions()
        }
        untouch()
        self.runAction(SKAction.fadeInWithDuration(0.5))
        incrementActiveTiles()
    }
    
    func toggleByHero(){
        if touched {
            untouchedByHero()
        }
        else  {
            touchedByHero()
        }
    }
}
