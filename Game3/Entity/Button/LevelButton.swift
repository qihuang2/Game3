//
//  LevelButton.swift
//  Game2
//
//  Created by Qi Feng Huang on 7/3/15.
//  Copyright (c) 2015 Qi Feng Huang. All rights reserved.
//




/*NOTE: NOT INHERITED FROM BUTTONS */
import SpriteKit


enum LevelButtonType: Int {
    case HighestUnlocked = 0
    case Unlocked
    case Locked
}
class LevelButton: SKSpriteNode{
    let level: Int
    private var locked: Bool = false
    private var selected:Bool = false
    
    init(textureAtlas: SKTextureAtlas,level: Int, type: LevelButtonType){
        self.level = level
        let textureName:SKTexture
        switch type {
            //picks color depending on if it's locked or not
        case .HighestUnlocked:
            textureName = textureAtlas.textureNamed("highest")
            break
        case .Unlocked:
            textureName = textureAtlas.textureNamed("unlocked")
            break
        case .Locked:
            textureName = textureAtlas.textureNamed("locked")
            break
        }
        
        let buttonSprite = SKSpriteNode(texture: textureName)
        buttonSprite.zPosition = -25
        super.init(texture: nil, color: UIColor.clearColor(), size: textureName.size())
        
        if type != .Locked {
            setUpLabel()
        }
        
        self.addChild(buttonSprite)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getLevel()->Int{
        return self.level
    }
    
    private func setUpLabel(){
        let label:SKLabelNode = SKLabelNode(fontNamed: GAME_CONSTANTS.GAME_FONT!.fontName)
        label.verticalAlignmentMode = SKLabelVerticalAlignmentMode.Center
        label.fontSize = 80
        label.fontColor = COLORS_USED.WHITE
        label.zPosition = -10
        label.text = "\(self.level)"
        label.name = "levelLabel"
        self.addChild(label)
    }
    
    func isSelected()->Bool{
        return self.selected
    }
    
    func select() {
        self.selected = true
        self.alpha = 0.7
    }
    
    func deselect() {
        self.selected = false
        self.alpha = 1
    }
    
    func lockButton(){
        self.locked = true
    }
    
    func isLocked()->Bool{
        return self.locked
    }
}
