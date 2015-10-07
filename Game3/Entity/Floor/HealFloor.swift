//
//  HealFloor.swift
//  Game2
//
//  Created by Qi Feng Huang on 8/25/15.
//  Copyright © 2015 Qi Feng Huang. All rights reserved.
//

import SpriteKit

class HealFloor: Floor {
    let isHorizontalHeal:Bool //if not horizontal, vertical heal
    
    init(activeTexture: SKTexture, coord: CGPoint, horizontalHeal: Bool) {
        self.isHorizontalHeal = horizontalHeal
        super.init(activeTexture: activeTexture, coord: coord)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func floorEffectOnHero(hero: Hero) -> SKAction? {
        if !self.beenTouched(){
            return SKAction.runBlock({self.healTiles(hero.getHeroGameGrid())})
        }
        return nil
    }
    
    private func healTiles(grid:GridLayer){
        if self.isHorizontalHeal{
            if let leftTile = getLeftTile(grid){
                if leftTile.beenTouched(){
                    leftTile.untouchedByHero()
                }
            }
            if let rightTile = getRightTile(grid){
                if rightTile.beenTouched(){
                    rightTile.untouchedByHero()
                }
            }
        }
        else{
            if let topTile = getTopTile(grid){
                if topTile.beenTouched(){
                    topTile.untouchedByHero()
                }
            }
            if let bottomTile = getBottomFloor(grid){
                if bottomTile.beenTouched(){
                    bottomTile.untouchedByHero()
                }
            }
        }
    }
    
    func getLeftTile(grid:GridLayer)->Floor?{
        return grid.getNodeAtCoordinate(getCoordinateForDirection(DirectionType.Left, self.coordinate))
    }
    
    func getRightTile(grid:GridLayer)->Floor?{
        return grid.getNodeAtCoordinate(getCoordinateForDirection(DirectionType.Right, self.coordinate))
    }
    
    func getTopTile(grid:GridLayer)->Floor?{
        return grid.getNodeAtCoordinate(getCoordinateForDirection(DirectionType.Up, self.coordinate))
    }
    
    func getBottomFloor(grid:GridLayer)->Floor?{
        return grid.getNodeAtCoordinate(getCoordinateForDirection(DirectionType.Down, self.coordinate))
    }
}


