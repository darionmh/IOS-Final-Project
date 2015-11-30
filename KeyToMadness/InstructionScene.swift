//
//  InstructionScene.swift
//  KeyToMadness
//
//  Created by Alexis Forbes on 11/30/15.
//  Copyright © 2015 Alexis Forbes. All rights reserved.
//

import SpriteKit

class InstructionScene: SKScene {
    
    override func didMoveToView(view: SKView) {
        backgroundColor = UIColor.blackColor()
        
        let mainLBL:SKLabelNode = SKLabelNode(text: "Welcome to the Madness Manor")
        mainLBL.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame)*0.8)
        mainLBL.fontSize = 65
        mainLBL.fontName = "AvenirNext-Bold"
        addChild(mainLBL)
        
        
        //let position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame)*0.6)
        let instructions:SKMultilineLabel = SKMultilineLabel(text: "The goal is simple. Escape\nYou are in the entry of the house. To escape you need to find the key. It is hidden in one of the rooms in this house. Find it. Avoid the monsters. Pick up items. Some rooms you will experience happenings. They are not good, avoid them the best you can.\nGood luck", labelWidth: 600, pos: CGPoint(x: 0, y: 0))
        instructions.fontColor = UIColor.whiteColor()
        let instructionBackground = SKSpriteNode(color: UIColor.blackColor(), size: CGSizeMake(CGRectGetMaxX(self.frame)*0.7, CGRectGetMaxY(self.frame)*0.5))
        instructionBackground.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMaxY(self.frame)*0.7)
        instructionBackground.addChild(instructions)
        addChild(instructionBackground)
        instructions.fontSize = 35
        instructions.leading = 35
        
        let playBTN:SKLabelNode = SKLabelNode(text: "Start Game")
        playBTN.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame)*0.2)
        playBTN.fontSize = 65
        playBTN.name = "playBTN"
        playBTN.fontName = "AvenirNext-Bold"
        playBTN.fontColor = UIColor.greenColor()
        addChild(playBTN)

    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first as UITouch!
        let location = touch.locationInNode(self)
        let touchedNode = self.nodeAtPoint(location)
        
        if touchedNode.name == "playBTN"{
            let transition = SKTransition.revealWithDirection(.Down, duration: 0.5)
            
            let nextScene = ClassPickerScene(fileNamed: "ClassPickerScene")
            nextScene!.scaleMode = .AspectFill
            removeAllChildren()
            scene?.view?.presentScene(nextScene!, transition: transition)
        }
    }
}