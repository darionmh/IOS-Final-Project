//
//  ClassPickerScene.swift
//  KeyToMadness
//
//  Created by Alexis Forbes on 11/13/15.
//  Copyright © 2015 Alexis Forbes. All rights reserved.
//

import SpriteKit


class HelpScene: SKScene {
    var firstTime = false
    
    override func didMoveToView(view: SKView) {
        backgroundColor = UIColor.blackColor()
        var bgImage = SKSpriteNode()
        bgImage = SKSpriteNode(imageNamed: "help")
        bgImage.size.width = self.frame.width
        bgImage.size.height = self.frame.height
        bgImage.position = CGPointMake(self.size.width/2, self.size.height/2)
        bgImage.zPosition = -100
        self.addChild(bgImage)
        let back:SKLabelNode = SKLabelNode()
        if(!firstTime){
            back.text = "Back"
        }else{
            back.text = "Continue"
        }
        back.position = CGPointMake(CGRectGetMaxX(self.frame)*0.05, CGRectGetMaxY(self.frame)*0.02)
        back.name = "backBTN"
        back.fontColor = UIColor.greenColor()
        back.fontSize = 22
        back.fontName = "AvenirNext-Bold"
        back.zPosition = 100
        addChild(back)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first as UITouch!
        let location = touch.locationInNode(self)
        let touchedNode = self.nodeAtPoint(location)
        
        if touchedNode.name == "backBTN"{
            if(!firstTime){
                let transition = SKTransition.revealWithDirection(.Left, duration: 0.5)
                
                let nextScene = MainMenuScene(fileNamed: "MainMenuScene")
                nextScene!.scaleMode = .AspectFill
                
                self.scene?.view?.presentScene(nextScene!, transition: transition)
            }else{
                let transition = SKTransition.revealWithDirection(.Left, duration: 0.5)
                
                let nextScene = ClassPickerScene(fileNamed: "ClassPickerScene")
                nextScene!.scaleMode = .AspectFill
                
                self.scene?.view?.presentScene(nextScene!, transition: transition)
            }
        }
    }
    
    deinit {
        print("Class Picker Deleted")
    }
}