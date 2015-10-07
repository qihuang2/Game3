//
//  Functions.swift
//  Game2
//
//  Created by Qi Feng Huang on 5/23/15.
//  Copyright (c) 2015 Qi Feng Huang. All rights reserved.
//

import SpriteKit


/*
FLOOR KEY
o    : regular floor tile
0-4  : telport tile
l    : left force floor
r    : right force floor
u    : up force floor
d    : down force floor
a    : 2 touches floor
b    : 3 touches floor
*/


//MARK: - GAME CONSTANTS

struct GAME_CONSTANTS {
    //number of levels
    static let NUMBER_OF_LEVELS:Int = 150
    
    static let GAME_SCORE_KEEPER: ScoreKeeper = SaveHighScore().retrieveHighScore(numberOfLevels: NUMBER_OF_LEVELS) as! ScoreKeeper
    
    static func resetGameScore(){
        GAME_CONSTANTS.GAME_SCORE_KEEPER.resetLevelsUnlocked()
        GAME_CONSTANTS.GAME_SCORE_KEEPER.resetTimeAttackLevelsCompleted()
        SaveHighScore().archiveHighScore(scoreKeeper: GAME_CONSTANTS.GAME_SCORE_KEEPER)
    }
    
    //game font reference
    static let GAME_FONT = UIFont(name: "Gill Sans", size: 17)
    
    
    static var gameSoundEffectOn: Bool = true
    
    static func toggleSound(){
        if GAME_CONSTANTS.gameSoundEffectOn {
            GAME_CONSTANTS.gameSoundEffectOn = false
        }
        else{
            GAME_CONSTANTS.gameSoundEffectOn = true
        }
        NSUserDefaults.standardUserDefaults().setBool(GAME_CONSTANTS.gameSoundEffectOn, forKey: "soundEffect")
    }
}




//MARK: - GAME COLORS
struct COLORS_USED {
    static let LIGHT_GREEN:UIColor = UIColor(red: 0.796, green: 0.906, blue: 0.816, alpha: 1)
    static let BLUE:UIColor = UIColor(red: 0.008, green: 0.447, blue: 0.733, alpha: 1)
    static let GREEN:UIColor = UIColor(red: 0.118, green: 0.698, blue: 0.353, alpha: 1)
    static let YELLOW:UIColor = UIColor(red: 0.992, green: 0.949, blue: 0.016, alpha: 1)
    static let RED:UIColor = UIColor(red: 0.922, green: 0.110, blue: 0.145, alpha: 1)
    static let ORANGE:UIColor = UIColor(red: 0.961, green: 0.584, blue: 0.118, alpha: 1)
    static let PURPLE:UIColor = UIColor(red: 0.843, green: 0.231, blue: 0.588, alpha: 1)
    static let SKY_BLUE:UIColor = UIColor(red: 0.663, green: 0.882, blue: 0.984, alpha: 1)
    static let WHITE:UIColor = UIColor.whiteColor()
    static let BLACK:UIColor = UIColor.blackColor()
    static let LIGHT_GREY:UIColor = UIColor.lightGrayColor()
    static let GREY:UIColor = UIColor.grayColor()
    
    static let ANTI_FLASH:UIColor = UIColor(red: 0.95, green: 0.95, blue: 0.96, alpha: 1)
}





//MARK: - ARRAY
func flipArray(code: [String]) -> [String] {
    var newArray:[String] = []
    for (var row = code.count; row > 0; row--) {
        let line = code[row-1]
        newArray.append(String(line))
    }
    return newArray
}

//MARK: - DIRECTION TYPE
 enum DirectionType: Int{
    case Up = 0
    case Right
    case Left
    case Down
    case UpperLeft
    case UpperRight
    case LowerLeft
    case LowerRight
}


//MARK: - COORDINATE FUNCTIONS
func getCoordinateForDirection(direction: DirectionType, coordinate: CGPoint)->CGPoint{
    switch direction{
    case .Up:
        return coordinateOfFloorAbove(coordinate)
    case .Down:
        return coordinateOfFloorBelow(coordinate)
    case .Left:
        return coordinateOfFloorLeft(coordinate)
    case .Right:
        return coordinateOfFloorRight(coordinate)
    case .UpperLeft:
        return coordinateOfFloorUpperLeft(coordinate)
    case .UpperRight:
        return coordinateOfFloorUpperRight(coordinate)
    case .LowerLeft:
        return coordinateOfFloorLowerLeft(coordinate)
    case .LowerRight:
        return coordinateOfFloorLowerRight(coordinate)
    }
}

func coordinateOfFloorAbove(coord:CGPoint)->CGPoint{
    return CGPoint(x: coord.x+1, y: coord.y)
}
func coordinateOfFloorBelow(coord:CGPoint)->CGPoint{
    return CGPoint(x: coord.x-1, y: coord.y)
}
func coordinateOfFloorRight(coord:CGPoint)->CGPoint{
    return CGPoint(x: coord.x, y: coord.y+1)
}
func coordinateOfFloorLeft(coord:CGPoint)->CGPoint{
    return CGPoint(x: coord.x, y: coord.y-1)
}
func coordinateOfFloorUpperLeft(coord:CGPoint)->CGPoint{
    return CGPoint(x: coord.x-1, y: coord.y+1)
}
func coordinateOfFloorUpperRight(coord:CGPoint)->CGPoint{
    return CGPoint(x: coord.x+1, y: coord.y+1)
}
func coordinateOfFloorLowerLeft(coord:CGPoint)->CGPoint{
    return CGPoint(x: coord.x-1, y: coord.y-1)
}
func coordinateOfFloorLowerRight(coord:CGPoint)->CGPoint{
    return CGPoint(x: coord.x+1, y: coord.y-1)
}
