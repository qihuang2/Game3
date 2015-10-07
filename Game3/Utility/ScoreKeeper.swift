//
//  ScoreKeeper.swift
//  Game2
//
//  Created by Qi Feng Huang on 6/24/15.
//  Copyright (c) 2015 Qi Feng Huang. All rights reserved.
//

import Foundation

//MARK: - SCORE KEEPER
//Score keeper is archived to save game progress and prevent cheating

class ScoreKeeper: NSObject {
    private var levelsUnlocked:Int = 1  //if levelsUnlocked = numberOfLevels +1, player beat all levels
    private var numberOfLevels: Int
    private var timeAttackLevelsCompleted: Int = 0
    
    
    func encodeWithCoder(aCoder: NSCoder!){
        aCoder.encodeInteger(self.levelsUnlocked, forKey: "levelsUnlocked")
        aCoder.encodeInteger(self.numberOfLevels, forKey: "numberOfLevels")
        aCoder.encodeInteger(self.timeAttackLevelsCompleted, forKey: "timeAttackLevelsCompleted")
    }
    
    
    required init(coder aDecoder: NSCoder!){
        self.levelsUnlocked = aDecoder.decodeIntegerForKey("levelsUnlocked")
        self.numberOfLevels = aDecoder.decodeIntegerForKey("numberOfLevels")
        self.timeAttackLevelsCompleted = aDecoder.decodeIntegerForKey("timeAttackLevelsCompleted")
    }
    
    
    func resetLevelsUnlocked(){
        self.levelsUnlocked = 1
    }
    
    func getTimeAttackLevelsCompleted()->Int{
        return self.timeAttackLevelsCompleted
    }
    
    func incrementTimeAttackLevelsCompleted(){
        self.timeAttackLevelsCompleted++
    }
    
    func resetTimeAttackLevelsCompleted(){
        self.timeAttackLevelsCompleted = 0
    }
    
    func getNumberOfLevels()->Int{
        return self.numberOfLevels
    }
    
    init(numberOfLevels: Int = 0){
        self.numberOfLevels = numberOfLevels
        super.init()
    }
    
    func getLevelsUnlocked()->Int{
        return self.levelsUnlocked
    }
    
    func incrementLevelsUnlocked(){
        if (self.levelsUnlocked < self.numberOfLevels+1){
            self.levelsUnlocked++
        }
        
    }
    
    
    //DELETE AFTERWARDS
    func setLevelsUnlocked(num:Int){
        self.levelsUnlocked = num
    }

    
}

//MARK: - SAVE
//archives score keeper
class SaveHighScore:NSObject {
    
    let documentDirectories = getPrivateDocsDir()
    let filePath = getPrivateDocsDir().stringByAppendingPathComponent("scoreKeeper.archive")
    
    func archiveHighScore(#scoreKeeper: ScoreKeeper) {
        if NSKeyedArchiver.archiveRootObject(scoreKeeper, toFile: self.filePath) {
            print("Success writing to file!")
        } else {
            print("Unable to write to file!")
        }
    }
    
    func retrieveHighScore(#numberOfLevels: Int) -> NSObject {
        if let data = NSKeyedUnarchiver.unarchiveObjectWithFile(filePath) as? ScoreKeeper {
            checkScoreKeeperSize(data, numOfLevels: numberOfLevels)
            return data
        }
        else{
          return ScoreKeeper(numberOfLevels: numberOfLevels)
        }
    }
    
    func checkScoreKeeperSize(scoreKeeper: ScoreKeeper, numOfLevels: Int){
        
        // If number of levels is changed, create new array with correct num. of levels
        if (scoreKeeper.numberOfLevels != numOfLevels){
            if scoreKeeper.numberOfLevels > numOfLevels{
                //if we decrease number of level in game, levels unlocked will reset to prevent bugs
                //MAKE SURE YOU DON'T DECREASE NUMBER OF LEVELS
                scoreKeeper.resetLevelsUnlocked()
            }
            
            scoreKeeper.numberOfLevels = numOfLevels
            SaveHighScore().archiveHighScore(scoreKeeper: scoreKeeper)
        }
    }
}


//MARK: - DIRECTORY FUNCTION
//returns dir of private file with saved game information
func getPrivateDocsDir() -> String {
    let paths = NSSearchPathForDirectoriesInDomains(.LibraryDirectory, .UserDomainMask, true)
    let documentsDirectory = paths[0].stringByAppendingPathComponent("Private Documents")
    var error: NSError?
    NSFileManager.defaultManager().createDirectoryAtPath( documentsDirectory, withIntermediateDirectories: true, attributes: nil, error: &error)
    return documentsDirectory
}


