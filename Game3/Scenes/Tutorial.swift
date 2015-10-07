//
//  Tutorial.swift
//  Game2
//
//  Created by Qi Feng Huang on 9/5/15.
//  Copyright © 2015 Qi Feng Huang. All rights reserved.
//

import SpriteKit

//first level is tutorial: has instruction on how to play

class Tutorial: GameScene {
    
    let tutorialTextLayer = SKNode()
    //text for tutorial
    let swipeText = SKLabelNode(fontNamed: GAME_CONSTANTS.GAME_FONT!.fontName)
    let toWinText = SKLabelNode(fontNamed: GAME_CONSTANTS.GAME_FONT!.fontName)
    let hintText = SKLabelNode(fontNamed: GAME_CONSTANTS.GAME_FONT!.fontName)
    
    
    init(size: CGSize){
        super.init(size: size, level: 1)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
        setUpTutorialLabels()
        self.addChild(tutorialTextLayer)
    }
    
    func setUpTutorialLabels(){
        swipeText.fontSize = 70
        toWinText.fontSize = 60
        hintText.fontSize = 45
        
        swipeText.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        toWinText.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        hintText.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        
        swipeText.setScale(SCALE_CONSTANT)
        toWinText.setScale(SCALE_CONSTANT)
        hintText.setScale(SCALE_CONSTANT)
        
        swipeText.fontColor = COLORS_USED.RED
        toWinText.fontColor = COLORS_USED.RED
        hintText.fontColor = COLORS_USED.RED
        
        swipeText.text = "SWIPE TO MOVE CIRCLE"
        toWinText.text = "TOUCH ALL SQUARE TILES TO WIN"
        hintText.text = "(hint) squares can't be retouched"
        
        toWinText.hidden = true
        hintText.hidden = true
        
        let ofLabelPosition = scoreHUD.childNodeWithName("ofLabel")!.position
        
        swipeText.position = CGPoint(x: ofLabelPosition.x, y: ofLabelPosition.y - swipeText.frame.size.height * 3.5)
        toWinText.position = swipeText.position
        hintText.position = CGPoint(x: swipeText.position.x, y: swipeText.position.y - swipeText.frame.size.height * 1.5)
        
        tutorialTextLayer.addChild(swipeText)
        tutorialTextLayer.addChild(toWinText)
        tutorialTextLayer.addChild(hintText)
    }
    
    
    //swiped, so show next step on how to play
    override func swipedRight() {
        if !swipeText.hidden{
            tutorialTextLayer.alpha = 0
            swipeText.hidden = true
            toWinText.hidden = false
            hintText.hidden = false
            tutorialTextLayer.runAction(SKAction.fadeInWithDuration(1.5))
        }
        super.swipedRight()
    }
    
    override func fadeGameLayer() {
        if tutorialTextLayer.parent != nil{
            tutorialTextLayer.removeFromParent()
        }
        super.fadeGameLayer()
    }
    
    
}
