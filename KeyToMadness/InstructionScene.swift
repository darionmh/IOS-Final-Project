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
        
        let label1:SKLabelNode = SKLabelNode(text: "The goal is simple… Escape.")
        let label2:SKLabelNode = SKLabelNode(text: "You start inside the entryway of the manor. You try to open the front door… Locked.")
        let label3:SKLabelNode = SKLabelNode(text: "The goal is a little bit more complicated.")
        let label4:SKLabelNode = SKLabelNode(text: "To escape you need the Key, which is hidden somewhere within the manor.")
        let label5:SKLabelNode = SKLabelNode(text: "Find the key and get back to the start to escape.")
        let label6:SKLabelNode = SKLabelNode(text: "Pick up items - they help you survive. ")
        let label7:SKLabelNode = SKLabelNode(text: "Avoid happenings - they are not good for your well-being.")
        let label8:SKLabelNode = SKLabelNode(text: "Avoid the monsters - oh yeah, monsters live here.")
        let label9:SKLabelNode = SKLabelNode(text: "Good Luck!")
        
        label1.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame)*0.6)
        label1.fontSize = 20
        label1.fontName = "AvenirNext-Bold"
        label1.fontColor = UIColor.whiteColor()
        addChild(label1)
        
        label2.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame)*0.57)
        label2.fontSize = 20
        label2.fontName = "AvenirNext-Bold"
        label2.fontColor = UIColor.whiteColor()
        addChild(label2)
        
        label3.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame)*0.54)
        label3.fontSize = 20
        label3.fontName = "AvenirNext-Bold"
        label3.fontColor = UIColor.whiteColor()
        addChild(label3)
        
        label4.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame)*0.51)
        label4.fontSize = 20
        label4.fontName = "AvenirNext-Bold"
        label4.fontColor = UIColor.whiteColor()
        addChild(label4)
        
        label5.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame)*0.48)
        label5.fontSize = 20
        label5.fontName = "AvenirNext-Bold"
        label5.fontColor = UIColor.whiteColor()
        addChild(label5)
        
        label6.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame)*0.45)
        label6.fontSize = 20
        label6.fontName = "AvenirNext-Bold"
        label6.fontColor = UIColor.whiteColor()
        addChild(label6)
        
        label7.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame)*0.42)
        label7.fontSize = 20
        label7.fontName = "AvenirNext-Bold"
        label7.fontColor = UIColor.whiteColor()
        addChild(label7)
        
        label8.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame)*0.39)
        label8.fontSize = 20
        label8.fontName = "AvenirNext-Bold"
        label8.fontColor = UIColor.whiteColor()
        addChild(label8)
        
        label9.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame)*0.36)
        label9.fontSize = 20
        label9.fontName = "AvenirNext-Bold"
        label9.fontColor = UIColor.whiteColor()
        addChild(label9)
        
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
            let defaults = NSUserDefaults.standardUserDefaults()
            let isPreloaded = defaults.boolForKey("isPreloaded")
            if(!isPreloaded){
                defaults.setBool(true, forKey: "isPreloaded")
                
                let transition = SKTransition.revealWithDirection(.Down, duration: 0.5)
                
                let nextScene = HelpScene(fileNamed: "HelpScene")
                nextScene!.firstTime = true
                nextScene!.scaleMode = .AspectFill
                removeAllChildren()
                scene?.view?.presentScene(nextScene!, transition: transition)
            }else{
                let transition = SKTransition.revealWithDirection(.Down, duration: 0.5)
                
                let nextScene = ClassPickerScene(fileNamed: "ClassPickerScene")
                nextScene!.scaleMode = .AspectFill
                removeAllChildren()
                scene?.view?.presentScene(nextScene!, transition: transition)
            }
        }
    }
}