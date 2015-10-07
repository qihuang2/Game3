//
//  GridLayer.swift
//  swiper
//
//  Created by Qi Feng Huang on 1/30/15.
//  Copyright (c) 2015 Qi Feng Huang. All rights reserved.
//

import SpriteKit

class GridLayer:SKNode {
    private var tileSize: CGSize = CGSize(width: 100, height: 100)     //size of tile; original 100x100
    let tileScale:CGFloat
    let gridLineSize: CGFloat //space between squares
    let gridSize: CGSize
    let layerSize: CGSize //total map points
    let startPoint: CGPoint
    private var numOfActiveFloorTiles:Int = 0  //tiles not touched by hero
    let floorAtlas:SKTextureAtlas
    
    required init?(coder aDecoder: NSCoder){
        fatalError("NSCoding not supported")
    }
    
    
    init(gridSize: CGSize, screenSize: CGSize, textureAtlas: SKTextureAtlas){
        self.gridSize = gridSize
        floorAtlas = textureAtlas
        
        //calculations to scale the tiles to fit screen properly
        //different scale if using iPad
        let divideConstant:CGFloat = (screenSize.width > 600) ? 135 : 115
        self.tileScale = screenSize.width / (divideConstant * gridSize.width)
        
        self.tileSize = CGSize(width: Int(tileSize.width * tileScale), height: Int(tileSize.height * tileScale))
        self.gridLineSize = 6 * tileScale
        let spaceBetWid = gridLineSize * (gridSize.width+1)
        let spaceBetHei = gridLineSize * (gridSize.height+1)
        self.layerSize = CGSize(width: (gridSize.width * tileSize.width) + spaceBetWid,
            height: (gridSize.height * tileSize.height) + spaceBetHei)
        
        //calculate where the bottom left tile goes: coordinate (0,0)
        self.startPoint = CGPoint(x: CGFloat((screenSize.width-layerSize.width+tileSize.width)/2)+gridLineSize,
            y: CGFloat((screenSize.height - layerSize.height + tileSize.height) * 0.75 + gridLineSize) - screenSize.height / 6)
        super.init()
    }
    
    convenience init(tileCodes:[String], screenSize:CGSize, textureAtlas: SKTextureAtlas) {
        self.init(gridSize: CGSize(width: count(tileCodes[0]), height: tileCodes.count), screenSize: screenSize, textureAtlas: textureAtlas)
        //sets up tiles
        for row in 0..<tileCodes.count {
            let line = tileCodes[row]
            for (col,code) in enumerate(line){
                if let tile = nodeForCode(code, row: row,col: col){
                    tile.setScale(tileScale * 0.5)
                    self.addChild(tile)
                    if tile.isKindOfClass(Floor){
                        self.numOfActiveFloorTiles++
                    }
                }
            }
        }
    }
    
    //MARK: - NODE FOR CODE
    //changes code for tile
    private func nodeForCode(tileCode: Character, row: Int, col: Int) -> SKSpriteNode? {
        let coordinate:CGPoint = CGPoint(x: row, y: col)
        switch tileCode {
        //floor tiles
            case "o":
                return makeDefaultFloor(CGPoint(x: row, y: col))
            case ".":
                return nil
            case "u":
                return makeForceFloor(DirectionType.Up, floorCoord: coordinate)
            case "d":
                return makeForceFloor(DirectionType.Down, floorCoord: coordinate)
            case "r":
                return makeForceFloor(DirectionType.Right, floorCoord: coordinate)
            case "l":
                return makeForceFloor(DirectionType.Left, floorCoord: coordinate)
            case "a":
                return makeTeleportFloor(coordinate, floorIndex: 0)
            case "b":
                return makeTeleportFloor(coordinate, floorIndex: 1)
            case "c":
                return makeTeleportFloor(coordinate, floorIndex: 2)
            case "e":
                return makeTeleportFloor(coordinate, floorIndex: 3)
            case "f":
                return makeTeleportFloor(coordinate, floorIndex: 4)
            case "2":
                return makeMultiTouchFloor(coordinate, numOfTouches: 2)
            case "3":
                return makeMultiTouchFloor(coordinate, numOfTouches: 3)
            case "!":
                return makeToggleFloor(coordinate)
            default:
                print("Unkown tile code \(tileCode)")
        }
        
        return nil
    }
    
    
    //MARK: - FLOOR SETUP
    //max of 5 teleport tile pairs
    private var teleportFloorArrayCoor = [CGPoint](count: 5, repeatedValue: CGPoint(x: -1, y: -1))
    
    private func makeTeleportFloor(coord:CGPoint, floorIndex: Int)->TeleportFloor{
        let tile = TeleportFloor(activeTexture: floorAtlas.textureNamed("tele\(floorIndex)"), coord: coord, floorPairIndex: floorIndex)
        tile.position = getPosition(coord)
        if (teleportFloorArrayCoor[floorIndex] == CGPoint(x: -1, y: -1)){
            teleportFloorArrayCoor[floorIndex] = coord
        }
        else{
            let otherTile = nodeAtPoint(getPosition(teleportFloorArrayCoor[floorIndex])) as! TeleportFloor
            tile.setTarget(otherTile)
            otherTile.setTarget(tile)
        }
        return tile
    }
    
    private func makeDefaultFloor(floorCoord: CGPoint)->Floor{
        let tile = Floor(activeTexture: floorAtlas.textureNamed("default"), coord: floorCoord)
        tile.position = getPosition(floorCoord)
        return tile
    }
    
    private func makeToggleFloor(floorCoord: CGPoint)->ToggleFloor{
        let tile = ToggleFloor(activeTexture: floorAtlas.textureNamed("toggle"), coord: floorCoord)
        tile.position = getPosition(floorCoord)
        return tile
    }
    
    private func makeForceFloor(direction:DirectionType, floorCoord: CGPoint)->ForceMoveFloor{
        let tile = ForceMoveFloor(activeTexture: floorAtlas.textureNamed("force"), coord: floorCoord, direction: direction)
        tile.position = getPosition(floorCoord)
        return tile
    }
    
    private func makeMultiTouchFloor(floorCoord: CGPoint, numOfTouches: Int)->Floor{
        var textureArray:[SKTexture] = [SKTexture]()
        
        for i in 0..<numOfTouches{
            textureArray.append(floorAtlas.textureNamed("multi\(i+1)"))
        }
        
        let tile = MultiTouchFloor(activeTexture:textureArray, coord: floorCoord, touches: numOfTouches)
        tile.position = getPosition(floorCoord)
        return tile
    }
    
    //MARK: - ACTIVE TILE FUNCTIONS
    func getNumberOfActiveTiles()->Int{
        return self.numOfActiveFloorTiles
    }
    
    func decrementActiveTiles(){
        self.numOfActiveFloorTiles--
    }
    
    func incrementActiveTiles(){
        self.numOfActiveFloorTiles++
    }
    
    //MARK: POSITION
    func getPosition(coord:CGPoint)->CGPoint{
        let x:CGFloat = (((tileSize.width) + gridLineSize) * CGFloat(coord.y)) + (startPoint.x)
        let y:CGFloat = (((tileSize.height) + gridLineSize) * CGFloat(coord.x)) + (startPoint.y)
        return CGPoint(x:x,y:y)
    }
    
    
    //MARK: VALID FLOOR CHECK FUNCTIONS
    //check if valid move
    func isValidFloor(coord: CGPoint)->Bool{
        let tileNode:Floor? = getNodeAtCoordinate(coord)
        if tileNode != nil && !tileNode!.beenTouched() {
            return true
        }
        return false
    }
    
    //get tile at coordinate
    func getNodeAtCoordinate(coord: CGPoint)->Floor?{
        if isValidCoordinate(coord){
            if let tile = nodeAtPoint(getPosition(coord)) as? Floor {
                return tile
            }
        }
        return nil
    }
    
    //checks if is valid coordinate
    func isValidCoordinate(coord: CGPoint)->Bool{
        if (coord.x < 0 || coord.y < 0 || coord.x >= gridSize.height || coord.y >= gridSize.width){
            return false
        }
        return true
    }
}
