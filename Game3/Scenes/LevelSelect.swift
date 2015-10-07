//
//  LevelSelect.swift
//  Game2
//
//  Created by Qi Feng Huang on 6/24/15.
//  Copyright (c) 2015 Qi Feng Huang. All rights reserved.
//

import SpriteKit

class LevelSelect: SKScene {
    private let MAX_SCENE_INDEX:Int             //number of level button huds
    private var BUTTON_START_POSITION:CGPoint
    private let ROW_COLUMN_NUMBER:Int = 5       //number of rows/columns
    private let SPACE_BETWEEN_CONSTANT:CGFloat = 1.07   //space between buttons
    
    private let miscButtonLayer: SKNode = SKNode()
    
    let levelButtonLayer:SKNode = SKNode()
    //if on first set and swipe detected, create second layer and slide to new button set
    let firstButtonSet:SKNode = SKNode()
    let secondButtonSet:SKNode = SKNode()
    private var onFirstButtonSet:Bool = true
    
    private let SCALE_CONSTANT:CGFloat

    private var currentSceneIndex:Int       //scene of highest unlocked level; starts at 0
    
    private let currentSceneHUD: CurrentSceneHUDSprite
    private var hasSwiped:Bool = false
    let buttonAtlas:SKTextureAtlas = SKTextureAtlas(named: "levelSelect")
    
    
    override init (size: CGSize){
        
        //scale constant is different if on ipad
        SCALE_CONSTANT = size.width / (UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad ? 1200 : 1000)
        
        let levelPerScene: Int = ROW_COLUMN_NUMBER * ROW_COLUMN_NUMBER
        self.MAX_SCENE_INDEX = (GAME_CONSTANTS.GAME_SCORE_KEEPER.getNumberOfLevels()-1) / levelPerScene  //starts at 0
        
        
        self.currentSceneIndex = GAME_CONSTANTS.GAME_SCORE_KEEPER.getLevelsUnlocked() > GAME_CONSTANTS.GAME_SCORE_KEEPER.getNumberOfLevels() ?   (GAME_CONSTANTS.GAME_SCORE_KEEPER.getNumberOfLevels()-1) / levelPerScene : (GAME_CONSTANTS.GAME_SCORE_KEEPER.getLevelsUnlocked()-1) / levelPerScene
        
        self.BUTTON_START_POSITION = CGPointZero
        
        self.currentSceneHUD = CurrentSceneHUDSprite(numberOfScenes: self.MAX_SCENE_INDEX+1, activeCircle: self.currentSceneIndex)
        
        self.MIN_DISTANCE_TO_SWIPE = 150 * self.SCALE_CONSTANT
        super.init(size: size)
    }
    

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func didMoveToView(view: SKView){
        self.backgroundColor = COLORS_USED.ANTI_FLASH
        setUpMiscButtons()
        setUpLevelButtons(currentSceneIndex, buttonSet: firstButtonSet)
        setUpCurrentSceneHUD()
        levelButtonLayer.position = CGPointZero
        self.addChild(miscButtonLayer)
        
        levelButtonLayer.addChild(firstButtonSet)
        levelButtonLayer.addChild(secondButtonSet)
        self.addChild(levelButtonLayer)
        self.addChild(currentSceneHUD)
        levelButtonLayer.name = "levelButtonLayer"
        
    }
    
    //MARK: - TOUCH FUNCTIONS
    //move to next group of levels if swipe fast enough and meet min swippe distance
    private let MIN_DISTANCE_TO_SWIPE:CGFloat
    private let MAX_SWIPE_TIME:NSTimeInterval = 0.2
    private var activeLevelButton:LevelButton!
    private var startLocation:CGPoint!
    private var startTouchTime:NSTimeInterval!
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        if (touches.count > 1) {return}
        let touch = touches.first as! UITouch
        self.startTouchTime = touch.timestamp
        self.startLocation = touch.locationInNode(levelButtonLayer)
        
        if let tempButton = levelButtonLayer.nodeAtPoint(startLocation) as? LevelButton{
            if !tempButton.isLocked(){
                activeLevelButton = tempButton
                activeLevelButton.select()
            }
        }
    }
    
    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        if !hasSwiped{
            let touch = touches.first as! UITouch
            let position:CGPoint = touch.locationInNode(levelButtonLayer)
            let xDiff:CGFloat = position.x - startLocation.x
            
            //if distance met, swipes
            if underTimeMaximum(touch.timestamp) && reachedMinDistance(xDistance: xDiff){
                self.hasSwiped = true
                runSwipeFunction(xDiff)
                if activeLevelButton != nil && activeLevelButton.isSelected(){
                    activeLevelButton.deselect()
                }
            }
                
                //else checks for another button.
            else {
                
                if let tempButton = levelButtonLayer.nodeAtPoint(position) as? LevelButton{
                    if activeLevelButton != nil {
                        //not the same
                        if activeLevelButton != tempButton{
                            activeLevelButton.deselect()
                        }
                            //same
                        else{
                            if !activeLevelButton.isSelected(){
                                activeLevelButton.select()
                            }
                            return //same button so return
                        }
                    }
                    //new button found
                    if !tempButton.isLocked(){
                        activeLevelButton = tempButton
                        activeLevelButton.select()
                    }
                    return
                }
                    
                    //no button found
                else if (activeLevelButton != nil && activeLevelButton.isSelected()) {
                    activeLevelButton.deselect()
                    activeLevelButton = nil
                }
            }
        }
    }
    
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        if hasSwiped{
            hasSwiped = false
        }
        else if activeLevelButton != nil && activeLevelButton.isSelected(){
            if activeLevelButton.getLevel() <= GAME_CONSTANTS.GAME_SCORE_KEEPER.getLevelsUnlocked(){
                let deactivateAction = SKAction.runBlock({activeLevelButton.deselect})
                
                let transitionAction = SKAction.runBlock({self.transitionToLevel(self.activeLevelButton.getLevel())})
                
                let buttonAction = SKAction.sequence([transitionAction,deactivateAction])
                self.runAction(GAME_CONSTANTS.gameSoundEffectOn ? SKAction.sequence([Button.TOUCH_SOUND, buttonAction]): buttonAction)
            }
        }
    }
    
    //transition to game scene
    private func transitionToLevel(level: Int){
        self.scene?.removeFromParent()
        let trans = SKTransition.moveInWithDirection(SKTransitionDirection.Right, duration: 0.4)
        
        //if level 1 button, go to tutorial
        let newScene = level == 1 ? Tutorial(size: self.size) : GameScene(size: self.size, level: level)
        newScene.scaleMode = .AspectFill
        view!.presentScene(newScene, transition: trans)
    }
    
    override func touchesCancelled(touches: Set<NSObject>!, withEvent event: UIEvent!) {
        if activeLevelButton != nil && activeLevelButton.isSelected(){
            activeLevelButton.deselect()
        }
        if hasSwiped {
            hasSwiped = false
        }
    }
    
    //reached min distance for group of levels change
    private func reachedMinDistance(#xDistance:CGFloat)->Bool{
        return fabs(xDistance) > MIN_DISTANCE_TO_SWIPE
    }
    
    //change groups of levels
    private func runSwipeFunction(xDistance:CGFloat){
        getSwipeDirection(xDistance: xDistance) == DirectionType.Left ? swipedLeft() : swipedRight()
    }
    
    //direction swiped
    private func getSwipeDirection(#xDistance:CGFloat)->DirectionType {
        return xDistance > 0 ? DirectionType.Right : DirectionType.Left
    }
    
    private func underTimeMaximum(currentTime:NSTimeInterval)->Bool{
        return (currentTime - self.startTouchTime) < MAX_SWIPE_TIME
    }
    
    private let LEVEL_BUTTON_LAYER_SPEED:NSTimeInterval = 0.2
    
    private func swipedRight(){
        if !levelButtonLayer.hasActions(){
            if (currentSceneIndex > 0){         //more buttons to the left side
                
                //determine curr and new button set
                let newButtonSet:SKNode
                let currButtonSet:SKNode
                if onFirstButtonSet {
                    newButtonSet = secondButtonSet
                    currButtonSet = firstButtonSet
                }
                else {
                    newButtonSet = firstButtonSet
                    currButtonSet = secondButtonSet
                }
                setUpLevelButtons(--currentSceneIndex, buttonSet: newButtonSet)
                currentSceneHUD.changeActivatedCircle(currentSceneIndex) //change HUD
                
                //put in position
                newButtonSet.position = CGPoint(x: currButtonSet.position.x - self.size.width, y: currButtonSet.position.y)
                
                let removeBlock = SKAction.runBlock({currButtonSet.removeAllChildren()})
                let layerMove = SKAction.moveByX(self.size.width, y: 0, duration: LEVEL_BUTTON_LAYER_SPEED)
                
                //move layer
                levelButtonLayer.runAction(SKAction.sequence([layerMove, removeBlock]))
                onFirstButtonSet = !onFirstButtonSet
            }
                //at the first scene index, move right, then back left
            else {
                let moveBy = self.size.width * 0.05
                let layerMove = SKAction.moveByX(moveBy, y: 0, duration: LEVEL_BUTTON_LAYER_SPEED * 0.3)
                let layerMoveBack = SKAction.moveByX(-moveBy, y: 0, duration: LEVEL_BUTTON_LAYER_SPEED * 0.3)
                levelButtonLayer.runAction(SKAction.sequence([layerMove, layerMoveBack]))
            }
        }
    }
    
    private func swipedLeft(){
        if !levelButtonLayer.hasActions(){
            if (currentSceneIndex < MAX_SCENE_INDEX){ //can go to next level button group
                
                //set new and current layer
                let newButtonSet:SKNode
                let currButtonSet:SKNode
                if onFirstButtonSet {
                    newButtonSet = secondButtonSet
                    currButtonSet = firstButtonSet
                }
                else {
                    newButtonSet = firstButtonSet
                    currButtonSet = secondButtonSet
                }
                
                setUpLevelButtons(++currentSceneIndex, buttonSet: newButtonSet)
                currentSceneHUD.changeActivatedCircle(currentSceneIndex) //change HUD
                
                newButtonSet.position = CGPoint(x: currButtonSet.position.x + self.size.width, y: currButtonSet.position.y)
                
                let removeBlock = SKAction.runBlock({currButtonSet.removeAllChildren()})
                let layerMove = SKAction.moveByX(-self.size.width, y: 0, duration: LEVEL_BUTTON_LAYER_SPEED)
                
                //move layer
                levelButtonLayer.runAction(SKAction.sequence([layerMove, removeBlock]))
                onFirstButtonSet = !onFirstButtonSet
            }
            
            //at the last scene index, move right, then back left
            else {
                let moveBy = self.size.width * 0.05
                let layerMove = SKAction.moveByX(-moveBy, y: 0, duration: LEVEL_BUTTON_LAYER_SPEED * 0.3)
                let layerMoveBack = SKAction.moveByX(moveBy, y: 0, duration: LEVEL_BUTTON_LAYER_SPEED * 0.3)
                levelButtonLayer.runAction(SKAction.sequence([layerMove, layerMoveBack]))
            }
        }
    }
    
    
    
    //MARK: - SETUP MISC AND LEVEL BUTTONS
    private func setUpMiscButtons(){
        let homeButton = TouchesMovedButton(buttonTexture: buttonAtlas.textureNamed("back"), sceneFunction: mainMenu)
        homeButton.position = CGPoint(x: self.size.width * 0.14, y: self.size.height * 0.9)
        homeButton.setScale(SCALE_CONSTANT*0.7)
        miscButtonLayer.addChild(homeButton)
    }
    
    //go to main menu
    private func mainMenu(){
        self.scene?.removeFromParent()
        let trans = SKTransition.moveInWithDirection(SKTransitionDirection.Left, duration: 0.4)
        let newScene = MainMenu(size: size)
        newScene.scaleMode = .AspectFill
        view!.presentScene(newScene, transition: trans)
    }
    
    //shows group of level buttons for player to choose from
    private var buttonLayerWidth:CGFloat!
    private func setUpLevelButtons(sceneNumber:Int, buttonSet:SKNode){
        let levelsPerScene: Int = ROW_COLUMN_NUMBER * ROW_COLUMN_NUMBER
        var level: Int = sceneNumber * levelsPerScene //smallest level on scene
        let levelsUnlocked: Int = GAME_CONSTANTS.GAME_SCORE_KEEPER.getLevelsUnlocked()
        let stopAtLevel:Int = level + levelsPerScene
        while (level < stopAtLevel){
            let button:LevelButton
            if (level < levelsUnlocked){                //level is unlocked
                if(level+1 == levelsUnlocked){           //make most recent unlocked level different color
                    button = LevelButton(textureAtlas: self.buttonAtlas, level: level+1, type: LevelButtonType.HighestUnlocked)
                }
                else {
                    button = LevelButton(textureAtlas: self.buttonAtlas, level: level+1, type: LevelButtonType.Unlocked)
                }
            }
            
            else {                                  //level not unlocked
                button = LevelButton(textureAtlas: self.buttonAtlas, level: level+1, type: LevelButtonType.Locked)
                button.lockButton()
            }
            
            button.setScale(SCALE_CONSTANT*0.8)
            
            //set button start position
            if BUTTON_START_POSITION == CGPointZero {
                buttonLayerWidth = button.frame.size.width * CGFloat(ROW_COLUMN_NUMBER) * SPACE_BETWEEN_CONSTANT - (SPACE_BETWEEN_CONSTANT - 1) * button.frame.size.width
                BUTTON_START_POSITION = CGPoint(x: (self.size.width - buttonLayerWidth) / 2 + button.frame.size.width / 2, y: self.size.height * 0.75)
            }
            
            
            button.position = getButtonPosition(startPosition: BUTTON_START_POSITION, level: level, buttonWidth: button.frame.size.width)
            button.name = "levelButton"
            buttonSet.addChild(button)
            ++level
        }
    }
    
    
    //MARK: - SETUP CURRENTSCENEHUD
    private func setUpCurrentSceneHUD(){
        self.currentSceneHUD.setScale(SCALE_CONSTANT*1.2)
        self.currentSceneHUD.position = CGPoint(x: self.size.width / 2 , y: self.size.height * 0.7 - 1.1 * buttonLayerWidth)
    }
    
    
    //MARK: - POSITION FUNCTIONS
    
    //get position of button
    //each scene is 5x5, 25 levels per scene
    func getButtonPosition(#startPosition: CGPoint, level: Int, buttonWidth: CGFloat)->CGPoint{
        let row = getRow(level)
        let column = getColumn(level)
        return CGPoint(x: (startPosition.x) + (buttonWidth * CGFloat(column) * SPACE_BETWEEN_CONSTANT), y: (startPosition.y) -
            (buttonWidth * CGFloat(row) * 1.15 * SPACE_BETWEEN_CONSTANT))
    }
    
    private func getColumn(level: Int)->Int{
        return level % ROW_COLUMN_NUMBER
    }

    private func getRow(level: Int)->Int{
        return (level / ROW_COLUMN_NUMBER) % ROW_COLUMN_NUMBER
    }
}

