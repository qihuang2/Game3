//
//  Hero.swift
//  Game2
//
//  Created by Qi Feng Huang on 5/23/15.
//  Copyright (c) 2015 Qi Feng Huang. All rights reserved.
//

import SpriteKit

class Hero: SKSpriteNode{
    private let gameGrid: GridLayer
    private var coordinate: CGPoint //x = row , y = column
    private var movable:Bool   //if in process of move, movable = false
    private var stuck:Bool     //if no more moves left
    private let innerSprite:SKSpriteNode
    private let outerSprite:SKSpriteNode
    
    static let MOVE_SOUND:SKAction = SKAction.playSoundFileNamed("move.wav", waitForCompletion: false)
    static let FAILED_MOVE_SOUND: SKAction = SKAction.playSoundFileNamed("failure3.wav", waitForCompletion: false)
    
    init(coor: CGPoint, textureAtlas: SKTextureAtlas, grid: GridLayer){
        self.movable = true
        self.stuck = false
        self.gameGrid = grid
        self.coordinate = coor
        
        innerSprite = SKSpriteNode(texture: textureAtlas.textureNamed("hero_in"))
        outerSprite = SKSpriteNode(texture: textureAtlas.textureNamed("hero_out"))
        
        super.init(texture: nil, color: UIColor.clearColor(), size: outerSprite.size)
        
        self.position = gameGrid.getPosition(self.coordinate)
        self.zPosition = 75
        
        self.addChild(innerSprite)
        self.addChild(outerSprite)
        
        let tile = gameGrid.getNodeAtCoordinate(self.coordinate)!
        tile.touchedByHero()
    }
    

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //rotation animation
    func animateHero(speed: NSTimeInterval){
        let rotateClockwise = SKAction.rotateByAngle(CGFloat(M_2_PI), duration: speed)
        let rotateCounterClockwise = SKAction.rotateByAngle(CGFloat(-M_2_PI), duration: speed)
        innerSprite.runAction(SKAction.repeatActionForever(rotateClockwise))
        outerSprite.runAction(SKAction.repeatActionForever(rotateCounterClockwise))
    }
    
    //MARK: - MOVE HERO
    /* MOVE HERO */
    func moveHeroAndCheckIfStuck(moveToCoord: CGPoint){
        if self.movable{
            if gameGrid.isValidFloor(moveToCoord){
                if let moveAction = getMoveHeroToCoordinateAction(moveToCoord,speed: 0.05){
                    let isStuckCheck = SKAction.runBlock(checkIfStuck)
                    self.runAction(SKAction.sequence([moveAction,isStuckCheck, SKAction.runBlock(makeMovable)]))
                }
            }
            else {
                if GAME_CONSTANTS.gameSoundEffectOn {
                    self.runAction(Hero.FAILED_MOVE_SOUND)
                }
            }
        }
    }
    
    
    //get hero's movement action
    func getMoveHeroToCoordinateAction(moveToCoord: CGPoint,speed:NSTimeInterval)->SKAction?{
        if let tileNode:Floor = gameGrid.getNodeAtCoordinate(moveToCoord){
            self.movable = false
            self.coordinate = moveToCoord
            let changePositionAction = SKAction.moveTo(tileNode.position, duration: speed)
            let touchedByHeroAction:SKAction = SKAction.runBlock({self.touchedByHeroFunction(tileNode)})
            
            let moveAction: SKAction = SKAction.sequence([changePositionAction, touchedByHeroAction])
            if let tileNodeEffectAction = tileNode.floorEffectOnHero(self){
                
                let compAction:SKAction =  SKAction.sequence([moveAction, tileNodeEffectAction])
                return GAME_CONSTANTS.gameSoundEffectOn ? SKAction.sequence([Hero.MOVE_SOUND , compAction]) : compAction
                
            }
            else {
                return GAME_CONSTANTS.gameSoundEffectOn ? SKAction.sequence([Hero.MOVE_SOUND, moveAction]) : moveAction
            }
        }
        return nil
    }
    
    private func touchedByHeroFunction(tileNode: Floor){
        if !tileNode.beenTouched(){
            tileNode.touchedByHero()
        }
    }
    
    
    //MARK: - CHECK IF STUCK
    
    func isStuck()->Bool{
        return self.stuck
    }
    
    //CHECK IF STUCK
    func checkIfStuck(){
        for directionRawValue in 0...3 {  //only main directions
            let rawValueToCoord:CGPoint = getCoordinateForDirection(DirectionType(rawValue:directionRawValue)!, self.coordinate)
            if gameGrid.isValidFloor(rawValueToCoord){
                return
            }
        }
        self.stuck = true
    }
    
    //MARK: - MOVEMENT AND COORDINATE
    
    func makeMovable(){
        self.movable = true
    }
    
    func setCoordinate(coordinate: CGPoint){
        self.coordinate = coordinate
    }
    
    func getCoordinate()->CGPoint{
        return self.coordinate
    }
    
    func getHeroGameGrid()->GridLayer{
        return gameGrid
    }
}
