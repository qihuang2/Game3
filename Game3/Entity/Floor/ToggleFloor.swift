//
//  ToggleFloor.swift
//  Game2
//
//  Created by Qi Feng Huang on 7/24/15.
//  Copyright (c) 2015 Qi Feng Huang. All rights reserved.
//

import SpriteKit

class ToggleFloor: Floor {
    static let TOGGLE_SOUND:SKAction = SKAction.playSoundFileNamed("toggle.wav", waitForCompletion: false)
    
    override init(activeTexture:SKTexture, coord: CGPoint) {
        super.init(activeTexture: activeTexture, coord: coord)
        self.name = "floor"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func floorEffectOnHero(hero:Hero)->SKAction?{
        if !self.beenTouched(){
            let buttonAction:SKAction = SKAction.runBlock({self.toggleNeighbors(hero)})
            return GAME_CONSTANTS.gameSoundEffectOn ? SKAction.sequence([ToggleFloor.TOGGLE_SOUND, buttonAction]) : buttonAction
            
        }
        return nil
    }
    
    func toggleNeighbors(hero: Hero){
        let gameGrid = hero.getHeroGameGrid()
        var teleportFloorBeenToggled = [Bool](count: 5, repeatedValue: false) //true if partner been toggled
        for i in 0...7 {
            if let tile = gameGrid.getNodeAtCoordinate(getCoordinateForDirection(DirectionType(rawValue: i)!, self.coordinate)){
                if let teleFloor = tile as? TeleportFloor{
                    if teleportFloorBeenToggled[teleFloor.floorPairIndex]{
                        continue
                    }
                    else {
                        teleportFloorBeenToggled[teleFloor.floorPairIndex] = true
                    }
                }
                tile.toggleByHero()
            }
        }
    }
}
