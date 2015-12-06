//
//  MainMenuScene.swift
//  KeyToMadness
//
//  Created by Alexis Forbes on 11/9/15.
//  Copyright © 2015 Alexis Forbes. All rights reserved.
//

import SpriteKit

class MainMenuScene: SKScene {
    let defaults = NSUserDefaults.standardUserDefaults()
    let leftySwitch = UISwitch()
    let musicSwitch = UISwitch()
    let soundSwitch = UISwitch()
    var bgImage = SKSpriteNode()
    var start = SKLabelNode()
    var leftyLabel = SKLabelNode()
    var musicLabel = SKLabelNode()
    var soundLabel = SKLabelNode()
    var helpLabel = SKLabelNode()
    
    override func didMoveToView(view: SKView) {
        backgroundColor = UIColor.blackColor()
        bgImage = SKSpriteNode(imageNamed: "main")
        bgImage.size.width = self.frame.width
        bgImage.size.height = self.frame.height
        bgImage.position = CGPointMake(self.size.width/2, self.size.height/2)
        bgImage.zPosition = -100
        self.addChild(bgImage)
        start = SKLabelNode(text: "Play Game")
        start.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMaxY(self.frame)*0.65)
        start.fontSize = 75
        start.fontName = "AvenirNext-Bold"
        start.name = "playButton"
        addChild(start)
        
        leftySwitch.frame = CGRectMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame)*0.53, 0, 0)
        leftySwitch.on = defaults.boolForKey("Lefty")
        leftySwitch.tag = 27
        leftySwitch.addTarget(self, action: "switches:", forControlEvents: .ValueChanged)
        self.view!.addSubview(leftySwitch)
        leftyLabel = SKLabelNode(text: "Left Mode: ")
        leftyLabel.fontName = "AvenirNext-Bold"
        leftyLabel.position = CGPoint(x: CGRectGetMidX(self.frame)-leftySwitch.frame.width*2, y:CGRectGetMaxY(self.frame)*0.475-leftySwitch.frame.height)
        addChild(leftyLabel)
        
        musicSwitch.frame = CGRectMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame)*0.46, 0, 0)
        musicSwitch.on = defaults.boolForKey("Music")
        musicSwitch.tag = 25
        musicSwitch.addTarget(self, action: "switches:", forControlEvents: .ValueChanged)
        self.view!.addSubview(musicSwitch)
        musicLabel = SKLabelNode(text: "Music: ")
        musicLabel.fontName = "AvenirNext-Bold"
        musicLabel.position = CGPoint(x: CGRectGetMidX(self.frame)-musicSwitch.frame.width*2, y:CGRectGetMaxY(self.frame)*0.55-musicSwitch.frame.height)
        addChild(musicLabel)
        
        soundSwitch.frame = CGRectMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame)*0.6, 0, 0)
        soundSwitch.on = defaults.boolForKey("Sounds")
        soundSwitch.tag = 26
        soundSwitch.addTarget(self, action: "switches:", forControlEvents: .ValueChanged)
        self.view!.addSubview(soundSwitch)
        soundLabel = SKLabelNode(text: "Sounds: ")
        soundLabel.fontName = "AvenirNext-Bold"
        soundLabel.position = CGPoint(x: CGRectGetMidX(self.frame)-soundSwitch.frame.width*2, y:CGRectGetMaxY(self.frame)*0.4 - soundSwitch.frame.height )
        addChild(soundLabel)
        
        helpLabel = SKLabelNode(text: "Help")
        helpLabel.position = CGPoint(x: CGRectGetMaxX(self.frame)*0.05, y: CGRectGetMaxY(self.frame)*0.05)
        helpLabel.fontSize = 22
        helpLabel.fontName = "AvenirNext-Bold"
        helpLabel.name = "helpButton"
        addChild(helpLabel)
    }
    
    func switches(sender:UISwitch!){
        if(sender.tag == 26){
            defaults.setBool(sender.on, forKey: "Sounds")
        }
        if(sender.tag == 25){
            defaults.setBool(sender.on, forKey: "Music")
        }
        if(sender.tag == 27){
            defaults.setBool(sender.on, forKey: "Lefty")
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first as UITouch!
        let location = touch.locationInNode(self)
        let touchedNode = self.nodeAtPoint(location)
        
        if touchedNode.name == "playButton"{
            leftySwitch.removeFromSuperview()
            musicSwitch.removeFromSuperview()
            soundSwitch.removeFromSuperview()
            leftyLabel.removeFromParent()
            musicLabel.removeFromParent()
            soundLabel.removeFromParent()
            start.removeFromParent()
            
            let action = SKAction.runBlock({
                let transition = SKTransition.revealWithDirection(.Down, duration: 0.5)
                
                let nextScene = InstructionScene(fileNamed: "InstructionScene")
                nextScene!.scaleMode = .AspectFill
                
                self.scene?.view?.presentScene(nextScene!, transition: transition)
            })

            let fadeIn = SKAction.runBlock({self.bgImage.runAction(SKAction.scaleBy(10, duration: 3.0))})
            let wait = SKAction.waitForDuration(2.0)
            let fadeOut = SKAction.runBlock({self.runAction(SKAction.fadeOutWithDuration(2.0))})
            self.runAction(SKAction.sequence([fadeIn,wait,fadeOut,wait,action]))
            
        }else if touchedNode.name == "helpButton"{
            leftySwitch.removeFromSuperview()
            musicSwitch.removeFromSuperview()
            soundSwitch.removeFromSuperview()
            leftyLabel.removeFromParent()
            musicLabel.removeFromParent()
            soundLabel.removeFromParent()
            start.removeFromParent()
            let transition = SKTransition.revealWithDirection(.Right, duration: 0.5)
            
            let nextScene = HelpScene(fileNamed: "HelpScene")
            nextScene!.scaleMode = .AspectFill
            
            self.scene?.view?.presentScene(nextScene!, transition: transition)
        }
    }
    
    deinit {
        print("Main Menu Scene Deleted")
    }
    
}