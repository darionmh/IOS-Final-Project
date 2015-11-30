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
        mainLBL.fontSize = 75
        mainLBL.fontName = "AvenirNext-Bold"
        addChild(mainLBL)
        
        let instructions:SKLabelNode = SKLabelNode(text: "Start Game")
        instructions.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame)*0.6)
        instructions.fontSize = 40
        instructions.text = "Madness Manor\nThe goal is simple. Escape\nYou are in the entry of the house. To escape you need to find the key. It is hidden in one of the rooms in this house. Find it. Avoid the monsters. Pick up items. Some rooms you will experience happenings. They are not good, avoid them the best you can.\nGood luck"
        instructions.name = "instructions"
        addChild(instructions)

    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
    }
}