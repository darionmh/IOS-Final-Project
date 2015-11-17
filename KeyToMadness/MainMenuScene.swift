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
    
    override func didMoveToView(view: SKView) {
        backgroundColor = UIColor.blackColor()
        let start:SKLabelNode = SKLabelNode(text: "Play Game")
        start.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMaxY(self.frame)*0.8)
        start.fontSize = 75
        start.fontName = "AvenirNext-Bold"
        start.name = "playButton"
        addChild(start)
        
        leftySwitch.frame = CGRectMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame)*0.8, 0, 0)
        leftySwitch.on = defaults.boolForKey("Lefty")
        leftySwitch.tag = 27
        leftySwitch.addTarget(self, action: "switches:", forControlEvents: .ValueChanged)
        self.view!.addSubview(leftySwitch)
        let leftyLabel = SKLabelNode(text: "Left Mode: ")
        leftyLabel.position = CGPoint(x: CGRectGetMidX(self.frame)-leftySwitch.frame.width*2, y:CGRectGetMaxY(self.frame)*0.2-leftySwitch.frame.height)
        addChild(leftyLabel)
        
        musicSwitch.frame = CGRectMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame)*0.4, 0, 0)
        musicSwitch.on = defaults.boolForKey("Music")
        musicSwitch.tag = 25
        musicSwitch.addTarget(self, action: "switches:", forControlEvents: .ValueChanged)
        self.view!.addSubview(musicSwitch)
        let musicLabel = SKLabelNode(text: "Music: ")
        musicLabel.position = CGPoint(x: CGRectGetMidX(self.frame)-musicSwitch.frame.width*2, y:CGRectGetMaxY(self.frame)*0.6-musicSwitch.frame.height)
        addChild(musicLabel)
        
        soundSwitch.frame = CGRectMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame)*0.6, 0, 0)
        soundSwitch.on = defaults.boolForKey("Sounds")
        soundSwitch.tag = 26
        soundSwitch.addTarget(self, action: "switches:", forControlEvents: .ValueChanged)
        self.view!.addSubview(soundSwitch)
        let soundLabel = SKLabelNode(text: "Sounds: ")
        soundLabel.position = CGPoint(x: CGRectGetMidX(self.frame)-soundSwitch.frame.width*2, y:CGRectGetMaxY(self.frame)*0.4 - soundSwitch.frame.height )
        addChild(soundLabel)
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
            let transition = SKTransition.revealWithDirection(.Down, duration: 0.5)
            
            let nextScene = ClassPickerScene(fileNamed: "ClassPickerScene")
            nextScene!.scaleMode = .AspectFill
            
            scene?.view?.presentScene(nextScene!, transition: transition)
            removeAllChildren()
            leftySwitch.removeFromSuperview()
            musicSwitch.removeFromSuperview()
            soundSwitch.removeFromSuperview()
        }
    }
    
    deinit {
        print("Main Menu Scene Deleted")
    }
    
}