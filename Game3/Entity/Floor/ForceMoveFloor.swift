//
//  ForceMoveFloor.swift
//  Game2
//
//  Created by Qi Feng Huang on 5/26/15.
//  Copyright (c) 2015 Qi Feng Huang. All rights reserved.
//

import SpriteKit

class ForceMoveFloor:Floor {
    let forceHeroToCoordinate:CGPoint
    private var active:Bool = false     //prevent infinite loop
    
    init(activeTexture: SKTexture, coord: CGPoint, direction: DirectionType){
        self.forceHeroToCoordinate = ForceMoveFloor.getForceToCoordinate(direction, coord: coord)!
        
        super.init(activeTexture: activeTexture,coord: coord)
        self.name = "floor"
        self.zRotation = ForceMoveFloor.getRotationAngle(direction)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func floorEffectOnHero(hero:Hero)->SKAction?{
        if !self.beenTouched() &&  !active{
            self.active = true
            return hero.getMoveHeroToCoordinateAction(self.forceHeroToCoordinate,speed: 0.2)
        }
        return nil
    }
    
    static func getForceToCoordinate(direction: DirectionType, coord: CGPoint)->CGPoint?{
        switch direction{
        case .Up:
            return coordinateOfFloorAbove(coord)
        case .Down:
            return coordinateOfFloorBelow(coord)
        case .Left:
            return coordinateOfFloorLeft(coord)
        case .Right:
            return coordinateOfFloorRight(coord)
        default:
            return nil
        }
    }
    
    static func getRotationAngle(direction: DirectionType)->CGFloat{
        switch direction{
        case .Up:
            return 0
        case .Down:
            return CGFloat(M_PI)
        case .Right:
            return CGFloat(-M_PI_2)
        case .Left:
            return CGFloat(M_PI_2)
        default:
            return 0
        }
    }
    
    override func untouchedByHero() {
        super.untouchedByHero()
        self.active = false
    }
}


