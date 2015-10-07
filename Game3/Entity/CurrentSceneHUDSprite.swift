//
//  CurrentSceneHUDSprite.swift
//  Game2
//
//  Created by Qi Feng Huang on 7/3/15.
//  Copyright (c) 2015 Qi Feng Huang. All rights reserved.
//

import SpriteKit


//
// USED TO SHOW WHICH SET OF LEVELS THE PLAYER IS VIEWING
//

class CurrentSceneHUDSprite: SKSpriteNode {
    private var spriteArray:[SKShapeNode] = [SKShapeNode]()
    private var currentlyActiveCircle:Int
    
    
    private let CIRCLE_RADIUS:CGFloat = 10
    private let CIRCLE_PLUS_SPACE:CGFloat = 40
    
    private let ACTIVE_COLOR:UIColor = COLORS_USED.ORANGE       //orange when on scene
    private let INACTIVE_COLOR:UIColor = COLORS_USED.LIGHT_GREY //grey when now on scene
    
    init(numberOfScenes:Int, activeCircle: Int){
        self.currentlyActiveCircle = activeCircle
        super.init(texture: nil, color: UIColor.clearColor(), size: CGSize(width: CIRCLE_PLUS_SPACE * CGFloat(numberOfScenes), height: CIRCLE_PLUS_SPACE * CGFloat(numberOfScenes)))
        
        setUpShapes(numberOfScenes)
        activateCircle(activeCircle)
    }

    
    private func setUpShapes(numOfCircles: Int){
        let backgroundWidth:CGFloat =  CIRCLE_PLUS_SPACE * CGFloat(numOfCircles)
        let midpoint = backgroundWidth / 2
        for sqNum in 0..<numOfCircles{
            
            let circle:SKShapeNode = SKShapeNode(circleOfRadius: CIRCLE_RADIUS)
            circle.fillColor = INACTIVE_COLOR
            circle.lineWidth = 0
            self.addChild(circle)
            circle.position = CGPoint(x: -midpoint + (CIRCLE_PLUS_SPACE/2) + (CGFloat(sqNum) * CIRCLE_PLUS_SPACE), y: 0)
            spriteArray.append(circle)
        }
    }
    
    private func activateCircle(index: Int){
        self.spriteArray[index].fillColor = ACTIVE_COLOR
        self.spriteArray[index].setScale(1.2)
    }
    
    private func deactiveCircle(index: Int){
        self.spriteArray[index].fillColor = INACTIVE_COLOR
        self.spriteArray[index].setScale(1)
    }
    
    func changeActivatedCircle(index: Int){
        deactiveCircle(currentlyActiveCircle)
        self.currentlyActiveCircle = index
        activateCircle(index)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
