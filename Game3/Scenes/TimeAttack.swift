//
//  TimeAttack.swift
//  Game2
//
//  Created by Qi Feng Huang on 8/4/15.
//  Copyright (c) 2015 Qi Feng Huang. All rights reserved.
//

import SpriteKit

class TimeAttack: GameScene {
    static var currentScore:Int = 0
    private let currentTimeLabel:SKLabelNode = SKLabelNode(fontNamed: GAME_CONSTANTS.GAME_FONT!.fontName)
    private static var startingBestScore:Int = GAME_CONSTANTS.GAME_SCORE_KEEPER.getTimeAttackLevelsCompleted()
    static var timeLeft:Int = 25
    
    init(size: CGSize) {
        TimeAttack.currentScore = 0
        TimeAttack.timeLeft = 25        //25 seconds to beat level
        TimeAttack.changeInTime = -0.2 //give player a little time to adjust
        TimeAttack.startingBestScore = GAME_CONSTANTS.GAME_SCORE_KEEPER.getTimeAttackLevelsCompleted()
        super.init(size: size, level: Int(arc4random_uniform(26)+2))
    }
    
    override init(size: CGSize, level: Int) {
        super.init(size: size, level: level)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - SETUP SCORE HUD
    
    override func setUpScoreHUD() {
        let retryButton: SKNode = buttonLayer.childNodeWithName("retry")!
        currentTimeLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        currentTimeLabel.text = String(TimeAttack.timeLeft)
        currentTimeLabel.fontSize = (85)
        currentTimeLabel.setScale(SCALE_CONSTANT)
        currentTimeLabel.fontColor = COLORS_USED.RED
        currentTimeLabel.position = CGPoint(x: self.size.width * 0.5, y: retryButton.position.y - retryButton.frame.height * 0.8)
        scoreHUD.addChild(currentTimeLabel)
        
        
        let bestScoreLabel = SKLabelNode(fontNamed: GAME_CONSTANTS.GAME_FONT!.fontName)
        bestScoreLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        bestScoreLabel.text = "\(TimeAttack.startingBestScore)"
        bestScoreLabel.fontSize = (60)
        bestScoreLabel.setScale(SCALE_CONSTANT)
        bestScoreLabel.fontColor = COLORS_USED.BLUE
        bestScoreLabel.position = CGPoint(x: currentTimeLabel.position.x + 2 * currentTimeLabel.frame.size.width, y:  currentTimeLabel.position.y)
        scoreHUD.addChild(bestScoreLabel)
        
        let currScoreLabel = SKLabelNode(fontNamed: GAME_CONSTANTS.GAME_FONT!.fontName)
        currScoreLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        currScoreLabel.text = "\(TimeAttack.currentScore)"
        currScoreLabel.fontSize = (60)
        currScoreLabel.setScale(SCALE_CONSTANT)
        currScoreLabel.fontColor = COLORS_USED.GREEN
        currScoreLabel.position = CGPoint(x: currentTimeLabel.position.x - 2 * currentTimeLabel.frame.size.width, y:  currentTimeLabel.position.y)
        scoreHUD.addChild(currScoreLabel)

    }
    
    //back and retry buttons
    override func setUpInGameButtons(){
        let retryButton = TouchesMovedButton(buttonTexture: textureAtlas.textureNamed("retry"), sceneFunction: restartGame)
        let backButton = TouchesMovedButton(buttonTexture: textureAtlas.textureNamed("back"), sceneFunction: mainMenu)
        
        backButton.position = CGPoint(x: self.size.width * 0.15, y: self.size.height * 0.92)
        backButton.setScale(SCALE_CONSTANT*0.65)
        
        retryButton.position = CGPoint(x: self.size.width * 0.85, y: backButton.position.y)
        retryButton.setScale(SCALE_CONSTANT*0.65)
        retryButton.name = "retry"
        
        buttonLayer.addChild(backButton)
        buttonLayer.addChild(retryButton)
    }
    
    
    //MARK: - UPDATE FUNCTIONS; CHECK WIN OR LOSE
    //ticks the clock down
    private var startTime:NSTimeInterval!
    static var changeInTime:NSTimeInterval = 0
    override func update(currentTime: NSTimeInterval) {
        if getGameState() == .Playing{
            
            //out of time
            if TimeAttack.timeLeft == 0{
                changeToLoseState()
                runGameplayStopped()
                if GAME_CONSTANTS.gameSoundEffectOn {
                    self.runAction(GameScene.POP_SOUND)
                }
            }
                
            //still playing
            else {
                if startTime == nil {
                    startTime = currentTime
                }
                else {
                    //if change in time greater than 1, decrement time
                    TimeAttack.changeInTime += (currentTime - startTime)
                    startTime = currentTime
                    if TimeAttack.changeInTime >= 1 {
                        TimeAttack.changeInTime = 0
                        currentTimeLabel.text = String(--TimeAttack.timeLeft)
                    }
                }
                if didWin(){
                    //go to new scene
                    winAction()
                }
                else if didLose(){
                    //restart current level
                    restartGame()
                }
            }
        }
    }

    //presents next level
    private func winAction(){
        changeToWinState()
        TimeAttack.timeLeft += (Int(currentLevel / 27) + 1) * 8 //add time depending on difficulty
        checkBestScore() //saves new best if new record achieved
        let currScene = self.scene!
        currScene.removeFromParent()
        let trans = SKTransition.moveInWithDirection(SKTransitionDirection.Down, duration: 0.5)
        
        let newScene = TimeAttack(size: self.size,level: getNextLevel())
        newScene.scaleMode = .AspectFill
        view!.presentScene(newScene, transition: trans)
    }
    
    //saves score if new record achieved
    private func checkBestScore(){
        if ++TimeAttack.currentScore > GAME_CONSTANTS.GAME_SCORE_KEEPER.getTimeAttackLevelsCompleted() {
            GAME_CONSTANTS.GAME_SCORE_KEEPER.incrementTimeAttackLevelsCompleted()
            SaveHighScore().archiveHighScore(scoreKeeper: GAME_CONSTANTS.GAME_SCORE_KEEPER)
            reportScoreToHighScore()
        }
    }
    
    //make level harder as player progresses
    private func getNextLevel()->Int{
        let levelConstant:UInt32
        
        if TimeAttack.currentScore > 12{
            levelConstant = 174
        }
        else if TimeAttack.currentScore > 9{
            levelConstant = 149
        }
        else if TimeAttack.currentScore > 6{
            levelConstant = 99
        }
        else if TimeAttack.currentScore > 4{
            levelConstant = 74
        }
        else if TimeAttack.currentScore > 2{
            levelConstant = 49
        }
        else{
            levelConstant = 24
        }
        
        
        return Int(arc4random_uniform(levelConstant)) + 2
    }
    
    
    //MARK: - GAMEPLAY STOPPED FUNCTIONS
    
    
    //set up scene for when game ends
    override func setUpGameplayStoppedHUD() {
        gameplayStoppedTextTop.position = CGPoint(x: self.size.width * 0.5 , y: self.size.height * 0.75)
        gameplayStoppedTextTop.fontSize = (self.size.height / 20)
        gameplayStoppedTextTop.fontColor = COLORS_USED.RED
        
        gameplayStoppedTextBottom.fontSize = (gameplayStoppedTextTop.fontSize * 2)
        gameplayStoppedTextBottom.fontColor = COLORS_USED.BLACK
        
        gameplayStoppedHUD.addChild(gameplayStoppedTextBottom)
        gameplayStoppedHUD.addChild(gameplayStoppedTextTop)
        gameplayStoppedHUD.zPosition = 200
        gameplayStoppedHUD.addChild(stoppedButtonLayer)
        stoppedButtonLayer.zPosition = 300
    }
    
    //run game over
    override func runGameplayStopped(){
        setUpLoseScene()
        
        gameplayStoppedTextTop.text = TimeAttack.currentScore > TimeAttack.startingBestScore ?
            "NEW BEST" : "Best : \(TimeAttack.startingBestScore)"
        
        gameplayStoppedTextBottom.position = CGPoint(x: gameplayStoppedTextTop.position.x, y: (gameplayStoppedTextTop.position.y - 3 * gameplayStoppedTextTop.frame.height))
        gameplayStoppedTextBottom.text = "\(TimeAttack.currentScore)"
        gameplayStoppedHUD.alpha = 0
        setUpGameOverButtons()
        self.addChild(gameplayStoppedHUD)
        
        gameplayStoppedHUD.runAction(SKAction.fadeInWithDuration(0.5))
        setScreenShot()
    }
    
    private func setUpLoseScene(){
        fadeGameLayer()
        removeButtonLayer()
        scoreHUD.removeFromParent()
    }
    
    //game ended buttons
    override func setUpGameOverButtons(){
        let stoppedAtlas = SKTextureAtlas(named: "gameOverButtons")
        
        let retryLevelButton = TouchesMovedButton(buttonTexture: stoppedAtlas.textureNamed("retry1"), sceneFunction: startNewGame)
        retryLevelButton.setScale(SCALE_CONSTANT*1.5)
        retryLevelButton.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.3)
        stoppedButtonLayer.addChild(retryLevelButton)
        
        let mainMenuButton = TouchesMovedButton(buttonTexture: stoppedAtlas.textureNamed("home1"), sceneFunction: mainMenu)
        mainMenuButton.setScale(SCALE_CONSTANT*1.5)
        mainMenuButton.position = CGPoint(x: retryLevelButton.position.x + retryLevelButton.size.width / 2 - mainMenuButton.size.width / 2 , y: retryLevelButton.position.y + retryLevelButton.size.height * 1.1)
        stoppedButtonLayer.addChild(mainMenuButton)
        
        let controller = self.view!.window!.rootViewController as! GameViewController
        let shareButton = TouchesMovedButton(buttonTexture: stoppedAtlas.textureNamed("share1"), sceneFunction: {controller.shareButtonPressed(self.getGameScreenShot())})
        shareButton.setScale(SCALE_CONSTANT * 1.5)
        shareButton.position = CGPoint(x: mainMenuButton.position.x - retryLevelButton.size.width / 2, y: mainMenuButton.position.y)
        stoppedButtonLayer.addChild(shareButton)
    }
    
    //retry the level; more time available
    override func restartGame() {
        changeToLoseState()
        let currScene = self.scene!
        currScene.removeFromParent()
        let trans = SKTransition.crossFadeWithDuration(0.4)
        let newScene = TimeAttack(size: self.size, level: self.currentLevel)
        newScene.scaleMode = .AspectFill
        if GAME_CONSTANTS.gameSoundEffectOn {
            self.runAction(GameScene.POP_SOUND)
        }
        view!.presentScene(newScene, transition: trans)
    }
    
    
    //restart game from beginning
    func startNewGame(){
        let currScene = self.scene!
        currScene.removeFromParent()
        let trans = SKTransition.moveInWithDirection(SKTransitionDirection.Down, duration: 0.75)
        let newScene = TimeAttack(size: self.size)
        newScene.scaleMode = .AspectFill
        view!.presentScene(newScene, transition: trans)
    }
    
    //MARK: - PAUSE UNPAUSE GAMES
    
    //used when game paused so change in time gets corrected
    private func resetStartTime(){
        if startTime != nil{
            self.startTime = nil
        }
    }
    
    
    override func pauseGame() {
        super.pauseGame()
        resetStartTime()
    }
}