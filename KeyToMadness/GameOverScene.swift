//
//  GameOverScene.swift
//  KeyToMadness
//
//  Created by Alexis Forbes on 11/11/15.
//  Copyright © 2015 Alexis Forbes. All rights reserved.
//

import SpriteKit

class GameOverScene: SKScene {
    var message:String = ""
    var winningMessage:String = ""
    
    override func didMoveToView(view: SKView) {
        let mainMenuBTN:SKLabelNode = SKLabelNode(text: "Main Menu")
        let playAgainBTN:SKLabelNode = SKLabelNode(text: "Play Again")
        let gameOverLabel:SKLabelNode = SKLabelNode(text: "Game Over!")
        let winnerLBL:SKLabelNode = SKLabelNode(text: winningMessage)
        let messageLBL:SKLabelNode = SKLabelNode(text: message)
        
        mainMenuBTN.position = CGPointMake(CGRectGetMidX(self.frame)*0.5, CGRectGetMidY(self.frame))
        playAgainBTN.position = CGPointMake(CGRectGetMidX(self.frame)*1.5, CGRectGetMidY(self.frame))
        gameOverLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame)*0.8)
        winnerLBL.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame)*0.7)
        messageLBL.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame)*0.6)
        
        mainMenuBTN.name = "MainMenu"
        playAgainBTN.name = "PlayAgain"
        
        addChild(mainMenuBTN)
        addChild(playAgainBTN)
        addChild(gameOverLabel)
        addChild(winnerLBL)
        addChild(messageLBL)
        
        backgroundColor = UIColor.blackColor()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touch = touches.first as UITouch!
        let location = touch.locationInNode(self)
        let touchedNode = self.nodeAtPoint(location)
        
        if touchedNode.name == "MainMenu" {
            let transition = SKTransition.revealWithDirection(.Down, duration: 0.5)
            
            let nextScene = MainMenuScene(fileNamed: "MainMenuScene")
            nextScene!.scaleMode = .AspectFill
            
            scene?.view?.presentScene(nextScene!, transition: transition)
        }else if touchedNode.name == "PlayAgain" {
            let transition = SKTransition.revealWithDirection(.Down, duration: 0.5)
            
            let nextScene = GameScene(fileNamed: "GameScene")
            nextScene!.scaleMode = .AspectFill
            
            scene?.view?.presentScene(nextScene!, transition: transition)
        }
    }
    
    deinit {
        print("Game Over Scene Deleted")
    }
}