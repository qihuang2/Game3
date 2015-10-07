//
//  TeleportFloor.swift
//  Game2
//
//  Created by Qi Feng Huang on 5/26/15.
//  Copyright (c) 2015 Qi Feng Huang. All rights reserved.
//

import SpriteKit

class TeleportFloor:Floor{
    let floorPairIndex: Int
    private var targetTeleportFloor:TeleportFloor!
    static let TELE_SOUND:SKAction = SKAction.playSoundFileNamed("teleport.wav", waitForCompletion: false)
    
    init(activeTexture: SKTexture, coord: CGPoint, floorPairIndex: Int){
        self.floorPairIndex = floorPairIndex
        super.init(activeTexture: activeTexture, coord: coord)
        self.zPosition = 0
        self.name = "floor"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setTarget(targetFloor:TeleportFloor){
        self.targetTeleportFloor = targetFloor
    }
    
    func getTargetFloor()->TeleportFloor{
        return self.targetTeleportFloor
    }
    
    func teleportHero(hero: Hero){
        hero.setCoordinate(self.targetTeleportFloor.coordinate)
        hero.position = self.targetTeleportFloor.position
        targetTeleportFloor.touchedByHero()
    }
    
    override func floorEffectOnHero(hero:Hero)->SKAction?{
        if !self.beenTouched(){
            let floorAction: SKAction = SKAction.sequence([SKAction.fadeOutWithDuration(0.2), SKAction.runBlock({self.teleportHero(hero)}), SKAction.fadeInWithDuration(0.2)])
            
            if GAME_CONSTANTS.gameSoundEffectOn {
                return SKAction.sequence([TeleportFloor.TELE_SOUND, floorAction])
            }
            else {
                return floorAction
            }
        }
        return nil
    }
    
    override func toggleByHero() {
        if self.beenTouched(){
            self.untouchedByHero()
            targetTeleportFloor.untouchedByHero()
        }
        else{
            self.touchedByHero()
            targetTeleportFloor.touchedByHero()
        }
    }
}

