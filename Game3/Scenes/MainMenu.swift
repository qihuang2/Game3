//
//  MainMenu.swift
//  Game2
//
//  Created by Qi Feng Huang on 6/24/15.
//  Copyright (c) 2015 Qi Feng Huang. All rights reserved.
//

import SpriteKit

class MainMenu:SKScene {
    let SCALE_CONSTANT:CGFloat
    let textureAtlas = SKTextureAtlas(named: "mainMenu")
    private let buttonLayer: SKNode = SKNode()
    private let aboutLayer: SKNode = SKNode()               //my info
    let highestLevelText:SKLabelNode = SKLabelNode(fontNamed: GAME_CONSTANTS.GAME_FONT!.fontName)
    let bestTimeAttackLabel:SKLabelNode = SKLabelNode(fontNamed: GAME_CONSTANTS.GAME_FONT!.fontName)
    let totalScoreLabel = SKLabelNode(fontNamed: GAME_CONSTANTS.GAME_FONT!.fontName)

    
    let WAIT_TIME:NSTimeInterval = 1.0
    
    override init(size: CGSize){
        SCALE_CONSTANT = size.width / (UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad ? 1250 : 1000)
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToView(view: SKView){
        self.backgroundColor = COLORS_USED.ANTI_FLASH
        
        setUpTitle()
        setUpButtons()
        setUpRecordText()
        setUpAboutLayer()
        self.addChild(buttonLayer)
        buttonLayer.alpha = 0
        
        
        buttonLayer.runAction(SKAction.fadeInWithDuration(1.25))
    }
    
    //game title
    func setUpTitle(){
        let titleSprite = GameTitle()
        titleSprite.position = CGPoint(x: self.size.width / 2, y: self.size.height * 0.88)
        titleSprite.setScale(SCALE_CONSTANT)
        self.addChild(titleSprite)
        titleSprite.animateTitle(6)
    }
    
    
    //MARK: - BUTTONS
    //buttons for play, time attack, info, sound, and high score
    func setUpButtons(){
        
        let xMidPoint = self.size.width / 2
        
        let levelSelectButton: TouchesMovedButton = TouchesMovedButton(buttonTexture: textureAtlas.textureNamed("play"), sceneFunction: moveToLevelSelect)
        levelSelectButton.setScale(SCALE_CONSTANT*0.9)
        levelSelectButton.position = CGPoint(x: xMidPoint, y: self.size.height * 0.57)
        levelSelectButton.name = "play"
        buttonLayer.addChild(levelSelectButton)
        
        
        let timeAttButton = TouchesMovedButton(buttonTexture: textureAtlas.textureNamed("time"), sceneFunction: goToTimeAttack)
        timeAttButton.setScale(SCALE_CONSTANT)
        timeAttButton.position = CGPoint(x: xMidPoint, y: levelSelectButton.position.y - levelSelectButton.size.height * 1.1)
        buttonLayer.addChild(timeAttButton)
        
        let highScoresButton = TouchesMovedButton(buttonTexture: textureAtlas.textureNamed("high"), sceneFunction: goToHiScore)
        highScoresButton.setScale(SCALE_CONSTANT)
        highScoresButton.position = CGPoint(x: xMidPoint, y: timeAttButton.position.y - timeAttButton.size.height * 1.1)
        buttonLayer.addChild(highScoresButton)
    
        let soundButton = ToggleButton(onTexture: textureAtlas.textureNamed("soundOn"), offTexture: textureAtlas.textureNamed("soundOff"), clearTexture: textureAtlas.textureNamed("soundBack"), buttonAction: GAME_CONSTANTS.toggleSound)
        
        if !GAME_CONSTANTS.gameSoundEffectOn{
            soundButton.turnOff()
        }
        
        soundButton.setScale(SCALE_CONSTANT)
        soundButton.position = CGPoint(x: timeAttButton.position.x - (timeAttButton.size.width - soundButton.size.width) * 0.5 , y: highScoresButton.position.y)
        buttonLayer.addChild(soundButton)
        
        let aboutButton = TouchesMovedButton(buttonTexture: textureAtlas.textureNamed("info"), sceneFunction: showAbout)
        aboutButton.setScale(SCALE_CONSTANT)
        aboutButton.position = CGPoint(x: timeAttButton.position.x + (timeAttButton.size.width - soundButton.size.width) * 0.5, y: soundButton.position.y)
        buttonLayer.addChild(aboutButton)
    }
    
    private func moveToLevelSelect(){
        self.scene?.removeFromParent()
        let trans = SKTransition.moveInWithDirection(SKTransitionDirection.Right, duration: 0.3)
        let newScene = LevelSelect(size: self.size)
        newScene.scaleMode = .AspectFill
        view!.presentScene(newScene, transition: trans)
    }
    
    private func goToTimeAttack(){
        self.scene?.removeFromParent()
        let trans = SKTransition.moveInWithDirection(SKTransitionDirection.Right, duration: 0.4)
        let newScene = TimeAttack(size: self.size)
        newScene.scaleMode = .AspectFill
        view!.presentScene(newScene, transition: trans)
    }
    
    //shows high scores
    private func goToHiScore(){
        GameKitHelper.sharedInstance.showGKGameCenterViewController(self.view!.window!.rootViewController as! GameViewController)
        return
    }
    
    func setUpAboutLayer(){
        aboutLayer.alpha = 0
        
        let creditLabel = SKLabelNode(fontNamed: GAME_CONSTANTS.GAME_FONT!.fontName)
        creditLabel.fontSize = 75
        creditLabel.setScale(SCALE_CONSTANT)
        creditLabel.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.7)
        creditLabel.text = "CREDITS"
        creditLabel.fontColor = COLORS_USED.BLACK
        aboutLayer.addChild(creditLabel)
        
        let codeLabel = SKLabelNode(fontNamed: GAME_CONSTANTS.GAME_FONT!.fontName)
        codeLabel.fontSize = 60
        codeLabel.setScale(SCALE_CONSTANT)
        codeLabel.position = CGPoint(x: creditLabel.position.x, y: creditLabel.position.y - 3.5 * creditLabel.frame.size.height)
        codeLabel.text = "Code and game design"
        codeLabel.fontColor = COLORS_USED.BLACK
        aboutLayer.addChild(codeLabel)
        
        let authorLabel = SKLabelNode(fontNamed: GAME_CONSTANTS.GAME_FONT!.fontName)
        authorLabel.fontSize = 40
        authorLabel.setScale(SCALE_CONSTANT)
        authorLabel.position = CGPoint(x: codeLabel.position.x, y: codeLabel.position.y - 2 * codeLabel.frame.size.height)
        authorLabel.text = "Qi Feng Huang"
        authorLabel.fontColor = COLORS_USED.BLACK
        aboutLayer.addChild(authorLabel)
        
        let contactLabel = SKLabelNode(fontNamed: GAME_CONSTANTS.GAME_FONT!.fontName)
        contactLabel.fontSize = 40
        contactLabel.setScale(SCALE_CONSTANT)
        contactLabel.position = CGPoint(x: authorLabel.position.x, y: authorLabel.position.y - 2 * authorLabel.frame.size.height)
        contactLabel.text = "Email :  game3creator@gmail.com"
        contactLabel.fontColor = COLORS_USED.BLACK
        aboutLayer.addChild(contactLabel)
        
        let okayButton = TouchesMovedButton(buttonTexture: textureAtlas.textureNamed("okay"), sceneFunction: hideAboutLayer)
        okayButton.setScale(SCALE_CONSTANT)
        okayButton.position = CGPoint(x: self.size.width / 2, y: self.size.height * 0.25)
        aboutLayer.addChild(okayButton)
    }
    
    //shows my info
    private func showAbout(){
        if self.buttonLayer.parent != nil{
            buttonLayer.removeFromParent()
            buttonLayer.alpha = 0
            addChild(aboutLayer)
            aboutLayer.runAction(SKAction.fadeInWithDuration(1))
        }
    }
    
    //hides my info
    private func hideAboutLayer(){
        if aboutLayer.parent != nil{
            aboutLayer.removeFromParent()
            aboutLayer.alpha = 0
            addChild(buttonLayer)
            buttonLayer.runAction(SKAction.fadeInWithDuration(1))
        }
    }

    //MARK: RECORD TEXT
    func setUpRecordText(){
        let playButton = buttonLayer.childNodeWithName("play")!
        
        highestLevelText.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        bestTimeAttackLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        totalScoreLabel.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center

        
        
        highestLevelText.text = "Completed : \(GAME_CONSTANTS.GAME_SCORE_KEEPER.getLevelsUnlocked() - 1)"
        bestTimeAttackLabel.text = "Record : \(GAME_CONSTANTS.GAME_SCORE_KEEPER.getTimeAttackLevelsCompleted())"
        totalScoreLabel.text = "Score : \(GAME_CONSTANTS.GAME_SCORE_KEEPER.getLevelsUnlocked() - 1 + GAME_CONSTANTS.GAME_SCORE_KEEPER.getTimeAttackLevelsCompleted())"
        
        highestLevelText.fontSize = 50
        bestTimeAttackLabel.fontSize = 50
        totalScoreLabel.fontSize = 50
        highestLevelText.setScale(SCALE_CONSTANT)
        bestTimeAttackLabel.setScale(SCALE_CONSTANT)
        totalScoreLabel.setScale(SCALE_CONSTANT)
        
        totalScoreLabel.fontColor = COLORS_USED.BLACK
        highestLevelText.fontColor = COLORS_USED.BLACK
        bestTimeAttackLabel.fontColor = COLORS_USED.BLACK
        
        bestTimeAttackLabel.position = CGPoint(x: playButton.position.x, y: playButton.position.y + playButton.frame.size.height * 0.84)
        highestLevelText.position = CGPoint(x: bestTimeAttackLabel.position.x, y: bestTimeAttackLabel.position.y + bestTimeAttackLabel.frame.height * 1.15)
        totalScoreLabel.position = CGPoint(x: bestTimeAttackLabel.position.x, y: bestTimeAttackLabel.position.y - bestTimeAttackLabel.frame.height * 1.15)
        
        buttonLayer.addChild(highestLevelText)
        buttonLayer.addChild(bestTimeAttackLabel)
        buttonLayer.addChild(totalScoreLabel)
    }
    
}
