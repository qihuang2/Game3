//
//  GameScene.swift
//  Game2
//
//  Created by Qi Feng Huang on 5/23/15.
//  Copyright (c) 2015 Qi Feng Huang. All rights reserved.
//

import SpriteKit

enum GameState: Int{
    case Playing = 0
    case Lose
    case Win
    case Paused
}
class GameScene: SKScene {
    
    static let POP_SOUND:SKAction = SKAction.playSoundFileNamed("pop.wav", waitForCompletion: false)
    let SCALE_CONSTANT:CGFloat
    let currentLevel:Int
    private var tilesTouched: Int = 0
    private var tilesOriginally: Int!
    
    private var gameGrid:GridLayer!
    private var hero:Hero!
    
    let textureAtlas:SKTextureAtlas = SKTextureAtlas(named: "gameScene")
    
    
    private let gameLayer:SKNode = SKNode()     //gameGrid and hero live
    let optionsLayer:SKNode = SKNode()  //options buttons
    let buttonLayer:SKNode = SKNode()           //ingame buttons: back, retry, options
    let stoppedButtonLayer:SKNode = SKNode()    //buttons presented after game is won
    let gameplayStoppedHUD:SKNode = SKNode()    //win text live
    let scoreHUD:SKNode = SKNode()              //score
    let shareButtonsLayer:SKNode = SKNode()
    
    private var currentGameState:GameState

    
    private let currentScoreLabel:SKLabelNode = SKLabelNode(fontNamed: GAME_CONSTANTS.GAME_FONT!.fontName)
    let gameplayStoppedTextTop: SKLabelNode = SKLabelNode(fontNamed: GAME_CONSTANTS.GAME_FONT!.fontName)
    let gameplayStoppedTextBottom: SKLabelNode = SKLabelNode(fontNamed: GAME_CONSTANTS.GAME_FONT!.fontName)
    
    
    init(size: CGSize, level: Int){
        self.currentLevel = level
        self.currentGameState = .Playing
        SCALE_CONSTANT = size.width / (UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad ?  1300 : 1000)
        super.init(size: size)
        self.name = "us"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToView(view: SKView) {
        
        self.backgroundColor = COLORS_USED.ANTI_FLASH
        setUpHeroAndGrid(self.currentLevel)
        setUpGameplayStoppedHUD()
        setUpInGameButtons()
        setUpScoreHUD()
        
        self.addChild(scoreHUD)
        self.addChild(buttonLayer)
        self.addChild(gameLayer)
        gameLayer.name = "gamelayer"
        buttonLayer.name = "buttonLayer"
        gameplayStoppedHUD.name = "gamestopped"
    }
    
    
    //reads arrays from JSON folder
    private func setUpHeroAndGrid(level: Int){
        let jsonFilePath:NSString = NSBundle.mainBundle().pathForResource("Level-\(level)", ofType: "json")!
        let jsonData:NSData = NSData(contentsOfURL: NSURL(fileURLWithPath: jsonFilePath as String)!)!
        let json = JSON(data: jsonData)
        let floor = json["floor"].arrayValue.map{$0.string!}
        self.gameGrid = GridLayer(tileCodes: flipArray(floor), screenSize: self.size, textureAtlas: textureAtlas)
        
        //game score keepers
        self.tilesOriginally = self.gameGrid.getNumberOfActiveTiles()
        self.tilesTouched = self.tilesOriginally - gameGrid.getNumberOfActiveTiles()
        
        let heroCoord = json["hero"].arrayValue.map{$0.int!}
        self.hero = Hero(coor: CGPoint(x: heroCoord[0], y: heroCoord[1]), textureAtlas: self.textureAtlas,grid: self.gameGrid)
        
        hero.setScale(gameGrid.tileScale)
        hero.name = "hero"
        
        gameLayer.addChild(hero)
        gameLayer.addChild(gameGrid)
        hero.animateHero(6)
    }
    
    //game stopped setup
    func setUpGameplayStoppedHUD(){
        gameplayStoppedTextTop.position = CGPoint(x: self.size.width * 0.5 , y: self.size.height * 0.78)
        gameplayStoppedTextTop.fontSize = (70)
        gameplayStoppedTextTop.fontColor = COLORS_USED.BLACK
        
        gameplayStoppedTextBottom.fontSize = (50)
        gameplayStoppedTextBottom.setScale(SCALE_CONSTANT*2)
        gameplayStoppedTextBottom.fontColor = COLORS_USED.BLACK
        gameplayStoppedTextTop.setScale(SCALE_CONSTANT*2)
        
        gameplayStoppedTextTop.text = "level \(self.currentLevel)"
        gameplayStoppedTextBottom.text = "COMPLETED!"
        
        gameplayStoppedTextBottom.position = CGPoint(x: gameplayStoppedTextTop.position.x, y: (gameplayStoppedTextTop.position.y - 1.5 * gameplayStoppedTextTop.frame.height))
        
        gameplayStoppedHUD.addChild(gameplayStoppedTextBottom)
        gameplayStoppedHUD.addChild(gameplayStoppedTextTop)
        gameplayStoppedHUD.zPosition = 200
    }
    
    //back and retry buttons
    func setUpInGameButtons(){
        let retryButton = TouchesMovedButton(buttonTexture: textureAtlas.textureNamed("retry"), sceneFunction: restartGame)
        let backButton = TouchesMovedButton(buttonTexture: textureAtlas.textureNamed("back"), sceneFunction: levelSelectScene)
        
        backButton.position = CGPoint(x: self.size.width * 0.15, y: self.size.height * 0.92)
        backButton.setScale(SCALE_CONSTANT*0.65)
        
        retryButton.position = CGPoint(x: self.size.width * 0.85, y: backButton.position.y)
        retryButton.setScale(SCALE_CONSTANT*0.65)
        retryButton.name = "retry"
        
        buttonLayer.addChild(backButton)
        buttonLayer.addChild(retryButton)
    }
    
    func levelSelectScene(){
        let currScene = self.scene!
        currScene.removeFromParent()
        let trans = SKTransition.moveInWithDirection(SKTransitionDirection.Left, duration: 0.4)
        let newScene = LevelSelect(size: self.size)
        newScene.scaleMode = .AspectFill
        view!.presentScene(newScene, transition: trans)
    }
    
    
    //score keeper
    internal func setUpScoreHUD(){
        
        let retryButton:SKNode = buttonLayer.childNodeWithName("retry")!
        
        let currentLevelLabel:SKLabelNode = SKLabelNode(fontNamed: currentScoreLabel.fontName)
        currentLevelLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        currentLevelLabel.fontSize = 90
        currentLevelLabel.setScale(SCALE_CONSTANT)
        currentLevelLabel.position = CGPoint(x: self.size.width / 2, y: retryButton.position.y)
        currentLevelLabel.fontColor = COLORS_USED.RED
        currentLevelLabel.text = "\(currentLevel)"
        
        let ofLabel:SKLabelNode = SKLabelNode(fontNamed: currentScoreLabel.fontName)
        ofLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        ofLabel.fontSize = (55)
        ofLabel.fontColor = COLORS_USED.BLACK
        ofLabel.setScale(SCALE_CONSTANT)
        ofLabel.position = CGPoint(x: currentLevelLabel.position.x, y: currentLevelLabel.position.y - currentLevelLabel.frame.size.height * 1.75)
        ofLabel.text = "of"
        ofLabel.name = "ofLabel"
        
        
        let totalLabel:SKLabelNode = SKLabelNode(fontNamed: currentScoreLabel.fontName)
        totalLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        totalLabel.fontSize = (65)
        totalLabel.setScale(SCALE_CONSTANT)
        totalLabel.text = "\(tilesOriginally)"
        totalLabel.position = CGPoint(x: ofLabel.position.x + totalLabel.frame.size.width * 1.7, y: ofLabel.position.y)
        totalLabel.fontColor = COLORS_USED.BLUE
        
        currentScoreLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        currentScoreLabel.fontSize = (65)
        currentScoreLabel.setScale(SCALE_CONSTANT)
        currentScoreLabel.position = CGPoint(x: ofLabel.position.x - totalLabel.frame.size.width * 1.7, y: ofLabel.position.y)
        currentScoreLabel.text = "\(tilesTouched)"
        currentScoreLabel.fontColor = COLORS_USED.GREEN
        
        scoreHUD.addChild(ofLabel)
        scoreHUD.addChild(totalLabel)
        scoreHUD.addChild(currentScoreLabel)
        scoreHUD.addChild(currentLevelLabel)
    }
    
    
    //MARK: - TOUCH AND SWIPE FUNCTIONS
    
    private var startPoint:CGPoint!     //where initially touched
    let MINIMUM_DISTANCE:CGFloat = 25
    private var hasSwiped:Bool = false
    
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        if self.currentGameState == .Playing{
            if (touches.count > 1) {return}
            let touch = touches.first as! UITouch
            self.startPoint = touch.locationInNode(self)
        }
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        if self.currentGameState == .Playing && !hasSwiped{
            let touch = touches.first as! UITouch
            runSwipeSwipeFunction(end: touch.locationInNode(self)) //run correct swipe function
        }
    }

    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        if self.currentGameState == .Playing && hasSwiped{
            hasSwiped = false
        }
    }
    
    override func touchesCancelled(touches: Set<NSObject>!, withEvent event: UIEvent!) {
        if self.currentGameState == .Playing && self.hasSwiped{
            hasSwiped = false
        }
    }
    
    //determines swipe function
    private func runSwipeSwipeFunction(#end: CGPoint){
        
        let xDistance:CGFloat = end.x - self.startPoint.x
        let yDistance:CGFloat = end.y - self.startPoint.y
        
        let absX:CGFloat = fabs(xDistance)      //change in x
        let absY:CGFloat = fabs(yDistance)      //change in y
        
        if minDistanceMet(absX) || minDistanceMet(absY){
            //if horizontal swipe
            if (isHorizontalSwipe(xChange: absX, yChange: absY)){
                xDistance > 0 ? swipedRight() : swipedLeft()    //left or right swipe
            }
            //vertical swipe
            else {
                yDistance > 0 ? swipedUp() : swipedDown()       //up or down swipe
            }
            hasSwiped = true                                //swip function has run
        }
    }
    
    private func isHorizontalSwipe(#xChange:CGFloat, yChange:CGFloat)->Bool{
        return xChange > yChange
    }
    
    private func minDistanceMet(change: CGFloat)->Bool{
        return change > MINIMUM_DISTANCE
    }
    
    //swipe action: moves hero
    func swipedRight(){
        self.runAction(SKAction.runBlock({self.hero.moveHeroAndCheckIfStuck(coordinateOfFloorRight(self.hero.getCoordinate()))}))
    }
    func swipedLeft(){
        self.runAction(SKAction.runBlock({self.hero.moveHeroAndCheckIfStuck(coordinateOfFloorLeft(self.hero.getCoordinate()))}))
        
    }
    func swipedUp(){
        self.runAction(SKAction.runBlock({self.hero.moveHeroAndCheckIfStuck(coordinateOfFloorAbove(self.hero.getCoordinate()))}))
        
    }
    func swipedDown(){
        self.runAction(SKAction.runBlock({self.hero.moveHeroAndCheckIfStuck(coordinateOfFloorBelow(self.hero.getCoordinate()))}))
    }
    
    
    
    //MARK: - UPDATE: WIN OR LOSE
    
    let WAIT_TIME_ACTION:SKAction = SKAction.waitForDuration(0.5)
    override func update(currentTime: NSTimeInterval) {
        if currentGameState == .Playing{
            
            //update score
            if ((tilesOriginally - tilesTouched) != self.gameGrid.getNumberOfActiveTiles()){
                tilesTouched = tilesOriginally - gameGrid.getNumberOfActiveTiles()
                currentScoreLabel.text = "\(tilesTouched)"
            }
            
            if !hero.hasActions(){
                //check win or lose
                if didWin() {
                    currentGameState = .Win
                    levelCompletedAction()
                    self.runAction(SKAction.sequence([WAIT_TIME_ACTION, SKAction.runBlock(runGameplayStopped)]))
                    if GAME_CONSTANTS.gameSoundEffectOn{
                        self.runAction(SKAction.sequence([WAIT_TIME_ACTION, GameScene.POP_SOUND]))
                    }
                }
                else if didLose(){
                    currentGameState = .Lose
                    self.runAction(SKAction.sequence([WAIT_TIME_ACTION, SKAction.runBlock(restartGame)]))
                    if GAME_CONSTANTS.gameSoundEffectOn{
                        self.runAction(SKAction.sequence([WAIT_TIME_ACTION, GameScene.POP_SOUND]))
                    }
                }
            }
        }
    }
    
    func didWin()->Bool{
        return gameGrid.getNumberOfActiveTiles() == 0
    }
    
    func didLose()->Bool{
        return hero.isStuck()  //no moves left
    }
    
    func restartGame(){
        let currScene = self.scene!
        currScene.removeFromParent()
        let trans = SKTransition.crossFadeWithDuration(0.5)
        let newScene = GameScene(size: self.size, level: self.currentLevel)
        newScene.scaleMode = .AspectFill
        view!.presentScene(newScene, transition: trans)
    }
    
    
    func runGameplayStopped(){
        fadeGameLayer()
        removeButtonLayer()
        scoreHUD.removeFromParent()
        
        //finished max level
        if self.currentLevel >= GAME_CONSTANTS.NUMBER_OF_LEVELS {
            gameplayStoppedTextTop.text = "YOU WIN"
            gameplayStoppedTextBottom.text = "now what?"
        }
        
        setUpGameOverButtons()
        
        gameplayStoppedHUD.addChild(stoppedButtonLayer)
        stoppedButtonLayer.zPosition = 300
        
        gameplayStoppedHUD.alpha = 0
        
        self.addChild(gameplayStoppedHUD)
        
        gameplayStoppedHUD.runAction(SKAction.fadeInWithDuration(0.5))
        setScreenShot()
    }
    
    //MARK: - SCREENSHOT FUNCTIONS
    private var gameScreenShot:UIImage!  //used when sharing game
    
    func setScreenShot(){
        UIGraphicsBeginImageContextWithOptions(UIScreen.mainScreen().bounds.size, false, 0)
        self.view!.drawViewHierarchyInRect(self.view!.bounds, afterScreenUpdates: true)
        let image:UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        gameScreenShot = image
    }
    
    func getGameScreenShot()->UIImage{
        return gameScreenShot
    }
    
    
    func fadeGameLayer(){
        gameLayer.alpha = 0.3
    }
    
    func removeButtonLayer(){
        buttonLayer.removeFromParent()
    }
    
    //MARK: - SETUP BUTTONS
    func setUpGameOverButtons(){
        let stoppedAtlas = SKTextureAtlas(named: "gameOverButtons")
        
        let controller = self.view!.window!.rootViewController as! GameViewController
        
        //share button uses a controller function to show share options
        
        let shareButton = TouchesMovedButton(buttonTexture: stoppedAtlas.textureNamed("share"), sceneFunction: {controller.shareButtonPressed(self.gameScreenShot)})
        shareButton.setScale(SCALE_CONSTANT*1.5)
        shareButton.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.57)
        shareButton.name = "share"
        stoppedButtonLayer.addChild(shareButton)
        
        let retryLevelButton = TouchesMovedButton(buttonTexture: stoppedAtlas.textureNamed("retry"), sceneFunction: restartGame)
        retryLevelButton.setScale(SCALE_CONSTANT*1.5)
        retryLevelButton.position = CGPoint(x: shareButton.position.x, y: shareButton.position.y - retryLevelButton.size.height * 1.1)
        retryLevelButton.name = "retry1"
        stoppedButtonLayer.addChild(retryLevelButton)
        
        let mainMenuButton = TouchesMovedButton(buttonTexture: stoppedAtlas.textureNamed("home"), sceneFunction: mainMenu)
        mainMenuButton.setScale(SCALE_CONSTANT*1.5)
        mainMenuButton.position = CGPoint(x: retryLevelButton.position.x + retryLevelButton.size.width / 2 - mainMenuButton.size.width / 2, y: shareButton.position.y)
        mainMenuButton.name = "main"
        stoppedButtonLayer.addChild(mainMenuButton)
        
        
        let levelSelectButton = TouchesMovedButton(buttonTexture: stoppedAtlas.textureNamed("back"), sceneFunction: goToLevelSelect)
        levelSelectButton.setScale(SCALE_CONSTANT*1.5)
        levelSelectButton.position = CGPoint(x: retryLevelButton.position.x - retryLevelButton.size.width / 2 + levelSelectButton.size.width / 2, y: shareButton.position.y)
        levelSelectButton.name = "levelSelect"
        stoppedButtonLayer.addChild(levelSelectButton)
        
        //can go to next level if we are not on last level
        if self.currentLevel < GAME_CONSTANTS.NUMBER_OF_LEVELS {
            let nextLevelButton = TouchesMovedButton(buttonTexture: stoppedAtlas.textureNamed("next"), sceneFunction: nextLevel)
            nextLevelButton.setScale(SCALE_CONSTANT*1.5)
            nextLevelButton.position = CGPoint(x: retryLevelButton.position.x, y: retryLevelButton.position.y - nextLevelButton.size.height * 1.1)
            nextLevelButton.name = "next"
            stoppedButtonLayer.addChild(nextLevelButton)
        }
    }
    
    func mainMenu(){
        let currScene = self.scene!
        currScene.removeFromParent()
        let trans = SKTransition.moveInWithDirection(SKTransitionDirection.Left, duration: 0.5)
        let newScene = MainMenu(size: self.size)
        newScene.scaleMode = .AspectFill
        view!.presentScene(newScene, transition: trans)
    }
    
    func goToLevelSelect(){
        let currScene = self.scene!
        currScene.removeFromParent()
        let trans = SKTransition.moveInWithDirection(SKTransitionDirection.Left, duration: 0.5)
        let newScene = LevelSelect(size: self.size)
        newScene.scaleMode = .AspectFill
        view!.presentScene(newScene, transition: trans)
    }
    
    private func nextLevel(){
        let currScene = self.scene!
        currScene.removeFromParent()
        let trans = SKTransition.moveInWithDirection(SKTransitionDirection.Down, duration: 0.5)
        let newScene = GameScene(size: self.size, level: self.currentLevel+1)
        newScene.scaleMode = .AspectFill
        view!.presentScene(newScene, transition: trans)
    }
    
    
    
    //MARK: - SAVING GAME FUNCTIONS
    private func levelCompletedAction(){
        //updates game progress
        if (currentLevel == GAME_CONSTANTS.GAME_SCORE_KEEPER.getLevelsUnlocked()){
            GAME_CONSTANTS.GAME_SCORE_KEEPER.incrementLevelsUnlocked()
            saveScores()
            print(GAME_CONSTANTS.GAME_SCORE_KEEPER.getLevelsUnlocked())
            reportScoreToHighScore()
        }
    }
    
    private func saveScores(){
        SaveHighScore().archiveHighScore(scoreKeeper: GAME_CONSTANTS.GAME_SCORE_KEEPER)
    }
    
    
    //MARK: - GAMESTATE FUNCTIONS
    
    func getGameState()->GameState{
        return currentGameState
    }
    
    func changeToWinState(){
        self.currentGameState = .Win
    }
    
    func changeToLoseState(){
        self.currentGameState = .Lose
    }
    
    func pauseGame(){
        if self.currentGameState == .Playing {
            self.currentGameState = .Paused
        }
    }
    
    func unpauseGame(){
        if self.currentGameState == .Paused{
            self.currentGameState = .Playing
        }
    }
    
    //reports high score to game center when level completed
    func reportScoreToHighScore(){
        if GameKitHelper.sharedInstance.gameCenterEnabled{
            let newScore = Int64(GAME_CONSTANTS.GAME_SCORE_KEEPER.getLevelsUnlocked() - 1 + GAME_CONSTANTS.GAME_SCORE_KEEPER.getTimeAttackLevelsCompleted())
            GameKitHelper.sharedInstance.reportScores(newScore, forLeaderBoardId: "grp.top_score_qi")
        }
    }

}
