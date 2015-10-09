//
//  GameScene.swift
//  KeyToMadness
//
//  Created by Alexis Forbes on 10/8/15.
//  Copyright (c) 2015 Alexis Forbes. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        let myLabel = SKLabelNode(fontNamed:"Chalkduster")
        myLabel.text = "Hello, World!";
        myLabel.fontSize = 45;
        myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame));
        
        self.addChild(myLabel)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        
        for touch in touches {
            let location = touch.locationInNode(self)
            
            let sprite = SKSpriteNode(imageNamed:"Spaceship")
            
            sprite.xScale = 0.5
            sprite.yScale = 0.5
            sprite.position = location
            
            let action = SKAction.rotateByAngle(CGFloat(M_PI), duration:1)
            
            sprite.runAction(SKAction.repeatActionForever(action))
            
            self.addChild(sprite)
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    func main() {
        let app = IOSApp()
        //app.showDirections()
        print("Enter \"exit\" to quit.")
        print("Enter \"stats\" to show player stats")
        print("Enter \"items\" to show current items")
        print("Enter \"happenings\" to show current happenings")
        print("Enter \"effects\" to show current effects")
        print("Enter \"layout\" to show house layout")
        var door:Int?
        while(!app.hasWon){
            print("Heading: " + app.player.heading)
            print(app.currentRoom.toString())
            if(!app.player.isPlayerAlive()){
                break
            }
            print("Enter a number for a door: ")
            let userInput = app.Input() as String
            door = Int(userInput)
            if(door != nil){
                if(door >= 1 && door <= 4){
                    // move valid
                    if(app.currentRoom.attachedRooms[door!-1] == nil){
                        // door is value
                        app.player.headingNum = (door!+1)%4
                        let location:Point = app.calcLocation()
                        if(location.x <= 7 && location.x >= -7 && location.y <= 7 && location.y >= -7){
                            // inside the house layout
                            if(app.houseLayout[location.y+7][location.x+7] == nil){
                                // door leads to undiscovered room
                                app.createRoom(door!-1)
                                app.processEffects()
                            }else{
                                // a room exists at this location
                                let roomAtLocation:Room = app.houseLayout[location.y+7][location.x+7]!
                                if(roomAtLocation.name == "EMPTY" || (roomAtLocation.attachedRooms[(door!+2)%4] != nil && roomAtLocation.attachedRooms[(door!+2)%4]!.name == "EMPTY")){
                                    // not a valid room placement like (0,-1) or this door is a false door
                                    print("The door will not opens, weird")
                                    app.updateFalseDoor(door!-1)
                                }else{
                                    // room has been visited and is not a special room
                                    app.applyVisitedRoom(roomAtLocation, door: door!-1)
                                    print("This room looks oddly familiar.")
                                }
                            }
                        }else{
                            // outside of range of house
                            print("The door opens... to a brick wall.")
                            app.updateFalseDoor(door!-1)
                        }
                    }else if(app.currentRoom.attachedRooms[door!-1]!.name == "EMPTY"){
                        print("Not a valid door!")
                    }else if(app.currentRoom.attachedRooms[door!-1]!.name == "Exit"){
                        if(app.player.hasKey){
                            app.hasWon = true
                        }else{
                            print("The door is locked and will not opens.")
                        }
                    }else{
                        // room already discovered
                        app.currentRoom = app.currentRoom.attachedRooms[door!-1]!
                        app.player.headingNum = (door!+1)%4
                    }
                }else{
                    print("Not a valid door!")
                }
            }else{
                // user input a command
                app.getPlayerMenu(userInput)
            }
        }
        if(app.hasWon){
            print("----- YOU WIN! -----")
            print("Thank you for playing!")
        }else if(app.player.hasKey){
            print("You die attempting to escape the house.")
            print("----- YOU LOSE -----")
        }else{
            print("You die searching")
            print("Maybe the key was never there.")
            print("----- YOU LOSE -----")
        }
    }
}
