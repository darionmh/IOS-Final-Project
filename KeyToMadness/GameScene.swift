//
//  GameScene.swift
//  KeyToMadness
//
//  Created by Alexis Forbes on 10/8/15.
//  Copyright (c) 2015 Alexis Forbes. All rights reserved.
//

import SpriteKit

let kAnalogStickdiameter: CGFloat = 200

enum BodyType: UInt32 {
    case player = 1
    case door = 2
    case item = 4
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var appleNode: SKSpriteNode?
    var removed: Bool = false
    let roomName = SKLabelNode(text: "")
    var door:Int = 0
    let app:IOSApp = IOSApp()
    var doorX:CGFloat = 0
    var doorY:CGFloat = 0
    
    private var _isSetJoystickStickImage = false, _isSetJoystickSubstrateImage = false
    
    var isSetJoystickStickImage: Bool {
        
        get { return _isSetJoystickStickImage }
        
        set {
            
            _isSetJoystickStickImage = newValue
            let image = UIImage(named: "magic_ball")
            moveAnalogStick.stickImage = image
            //rotateAnalogStick.stickImage = image
        }
    }
    
    var isSetJoystickSubstrateImage: Bool {
        
        get { return _isSetJoystickSubstrateImage }
        
        set {
            
            _isSetJoystickSubstrateImage = newValue
            let image = newValue ? UIImage(named: "jSubstrate") : nil
            moveAnalogStick.substrateImage = image
            //rotateAnalogStick.substrateImage = image
        }
    }
    
    var joysticksdiameters: CGFloat {
        
        //get { return max(moveAnalogStick.diameter, rotateAnalogStick.diameter) }
        get { return moveAnalogStick.diameter }
        
        set(newdiameter) {
            
            moveAnalogStick.diameter = newdiameter
            //rotateAnalogStick.diameter = newdiameter
        }
    }
    
    let moveAnalogStick = AnalogStick(diameter: kAnalogStickdiameter)
    //let rotateAnalogStick = AnalogStick(diameter: kAnalogStickdiameter)
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        showInstructions(self)
        
        SKTAudio.sharedInstance().playBackgroundMusic("theme.wav")
        
        
        
        backgroundColor = UIColor.greenColor()
        addChild(addRoom())
        let jRadius = kAnalogStickdiameter / 2
        
        
        moveAnalogStick.diameter = kAnalogStickdiameter
        //moveAnalogStick.position = CGPointMake(jRadius + 75, jRadius + 150)
        moveAnalogStick.position = CGPointMake(CGRectGetMaxX(self.frame) - jRadius - 75, jRadius + 150)
        moveAnalogStick.trackingHandler = { analogStick in
            
            guard let aN = self.appleNode else { return }
            
            aN.position = CGPointMake(aN.position.x + (analogStick.data.velocity.x * 0.12), aN.position.y + (analogStick.data.velocity.y * 0.12))
        }
        moveAnalogStick.name = "AnalogStick"
        addChild(moveAnalogStick)
        
        /*rotateAnalogStick.diameter = kAnalogStickdiameter
        rotateAnalogStick.position = CGPointMake(CGRectGetMaxX(self.frame) - jRadius - 75, jRadius + 150)
        rotateAnalogStick.trackingHandler = { analogStick in
            
            self.appleNode?.zRotation = analogStick.data.angular
        }*/
        
        //addChild(rotateAnalogStick)
        
        appleNode = appendAppleToPoint(CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)))
        insertChild(appleNode!, atIndex: 0)
        physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        
        isSetJoystickStickImage = _isSetJoystickStickImage
        isSetJoystickSubstrateImage = _isSetJoystickSubstrateImage
        //let x = CGFloat(arc4random_uniform(UInt32(CGRectGetMidX(self.frame)+400))+50)
        //let y = CGFloat(arc4random_uniform(UInt32(CGRectGetMidY(self.frame)+160))+110)
        
        addChild(addDoor(CGPointMake(CGRectGetMidX(self.frame),CGRectGetMaxY(self.frame) * 0.25),value: 1))
        addChild(addDoor(CGPointMake(CGRectGetMaxX(self.frame) * 0.25, CGRectGetMidY(self.frame)),value: 2))
        addChild(addDoor(CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame) * 0.75),value: 3))
        addChild(addDoor(CGPointMake(CGRectGetMaxX(self.frame) * 0.75, CGRectGetMidY(self.frame)),value: 4))
        
        addChild(addAttackButton())
        addChild(addRunButton())
        
        physicsWorld.contactDelegate = self
        setupLabels()
    }
    
    func appendAppleToPoint(position: CGPoint) -> SKSpriteNode {
        
        let playerImage = UIImage(named: "penguin")
        
        precondition(playerImage != nil, "Please set right image")
        
        let texture = SKTexture(image: playerImage!)
        
        let player = SKSpriteNode(texture: texture)
        player.physicsBody = SKPhysicsBody(texture: texture, size: player.size)
        player.physicsBody!.affectedByGravity = false
        player.position = position
        player.physicsBody?.categoryBitMask = BodyType.player.rawValue
        player.physicsBody?.contactTestBitMask = BodyType.door.rawValue
        player.physicsBody?.collisionBitMask = 0
        
        return player
    }
    
    func addRoom() -> SKSpriteNode {
        let roomImage = UIImage(named: "room")
        let texture = SKTexture(image: roomImage!)
        let room = SKSpriteNode(texture: texture)
        room.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        room.zPosition = -3
        
       return room
    }
    
    func addDoor(position: CGPoint, value: Int) -> SKSpriteNode {
        let doorImage = UIImage(named: "apple")
        let texture = SKTexture(image: doorImage!)
        let door = SKSpriteNode(texture: texture)
        door.physicsBody = SKPhysicsBody(texture: texture, size: door.size)
        door.position = position
        door.physicsBody?.allowsRotation = false
        door.physicsBody?.affectedByGravity = false
        door.physicsBody?.categoryBitMask = BodyType.door.rawValue
        door.physicsBody?.contactTestBitMask = BodyType.player.rawValue
        door.physicsBody?.collisionBitMask = 0
        door.name = "\(value)"
        return door
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
                                app.generateMonster()
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
                                    app.checkForMonsters()
                                }
                            }
                        }else{
                            // outside of range of house
                            print("The door opens... to a brick wall.")
                            app.updateFalseDoor(door!-1)
                        }
                        app.moveMonsters()
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
                        app.checkForMonsters()
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
    
    func didBeginContact(contact: SKPhysicsContact) {
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        switch(contactMask){
        case BodyType.player.rawValue | BodyType.door.rawValue:
            let firstNode = contact.bodyA.node
            let secondNode = contact.bodyB.node
            if(contact.bodyA.categoryBitMask == BodyType.player.rawValue){
                secondNode?.removeFromParent()
                door = Int((secondNode?.name!)!)!
                doorX = (secondNode?.position.x)!
                doorY = (secondNode?.position.y)!
                firstNode?.removeFromParent()
            }else{
                firstNode?.removeFromParent()
                door = Int((firstNode?.name!)!)!
                doorX = (firstNode?.position.x)!
                doorY = (firstNode?.position.y)!
                secondNode?.removeFromParent()
            }
            removed = true;
        default:
            return
        }
    }
    
    override func didFinishUpdate() {
        if(removed){
            //let x = CGFloat(arc4random_uniform(UInt32(CGRectGetMidX(self.frame)+400))+50)
            //let y = CGFloat(arc4random_uniform(UInt32(CGRectGetMidY(self.frame)+160))+110)
            print("Handling door")
            handleDoor(door)
            addChild(addDoor(CGPointMake(doorX, doorY),value: door))
            appleNode!.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame))
            insertChild(appleNode!, atIndex: 0)
            physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
            removed = false;
        }
    }
    
    func setupLabels() {
        roomName.position = CGPoint(x: frame.size.width/2, y: frame.size.height * 0.15)
        roomName.fontColor = UIColor.whiteColor();
        roomName.fontSize = 40
        roomName.text = app.currentRoom.name
        addChild(roomName)
    }
    
    func showInstructions(controller: GameScene) {
        let alert = UIAlertView(title: "Instructions:", message: "", delegate: self, cancelButtonTitle: "OK")
        let scroll = UIScrollView(frame: CGRectMake(0, 0, frame.size.width * 0.8, frame.size.height * 0.8) )
        let field = UITextView()
        field.frame = CGRectMake(0, 0, frame.size.width, frame.size.height * 0.6)
        field.editable = false
        field.userInteractionEnabled = false
        field.text = "Enter \"exit\" to quit.\nEnter \"stats\" to show player stats.\nEnter \"items\" to show current items.\nEnter \"happenings\" to show current happenings.\nEnter \"effects\" to show current effects.\nEnter \"layout\" to show house layout."
        scroll.addSubview(field)
        alert.setValue(scroll, forKey: "accessoryView")
        alert.show()
    }
    
    func addAttackButton() -> SKSpriteNode {
        let attackImage = UIImage(named: "sword")
        let texture = SKTexture(image: attackImage!)
        let attackButton = SKSpriteNode(texture: texture)
        attackButton.position = CGPoint(x: CGRectGetMaxX(self.frame) * 0.1 + (attackImage!.size.width), y: CGRectGetMaxY(self.frame) * 0.1 + (attackImage!.size.height))
        attackButton.zPosition = 3
        attackButton.name = "AttackButton"
        attackButton.hidden = true
        
        return attackButton
    }
    
    func addRunButton() -> SKSpriteNode {
        let runImage = UIImage(named: "run")
        let texture = SKTexture(image: runImage!)
        let runButton = SKSpriteNode(texture: texture)
        runButton.position = CGPoint(x: CGRectGetMaxX(self.frame) * 0.2 + (runImage!.size.width), y: CGRectGetMaxY(self.frame) * 0.1 + (runImage!.size.height))
        runButton.zPosition = 3
        runButton.name = "RunButton"
        runButton.hidden = true
        
        return runButton
    }
    
    func addMonster() -> SKSpriteNode{
        let monsterImage = UIImage(named: "Spaceship")
        let texture = SKTexture(image: monsterImage!)
        let monster = SKSpriteNode(texture: texture)
        monster.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        monster.name = "Monster"
        monster.size = CGSize(width: monster.size.width/2, height: monster.size.height/2)
        
        return monster
    }
    
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        touches.forEach { (touch) -> () in
            let pos = touch.locationInNode(self)
            let node = self.nodeAtPoint(pos)
            
            if let name = node.name
                {
                    if name == "AttackButton"
                    {
                        tryToAttack = true
                        monsterDone()
                        print("Touched")
                    }
                    
                    if name == "RunButton"
                    {
                        tryToRun = true
                        monsterDone()
                        print("RUUUNNN")
                    }
            }
        }
    }
    
    func handleDoor(door: Int){
        if(app.currentRoom.attachedRooms[door-1] == nil){
            // door is value
            app.player.headingNum = (door+1)%4
            app.player.setHeading()
            let location:Point = app.calcLocation()
            if(location.x <= 7 && location.x >= -7 && location.y <= 7 && location.y >= -7){
                // inside the house layout
                if(app.houseLayout[location.y+7][location.x+7] == nil){
                    // door leads to undiscovered room
                    app.createRoom(door-1)
                    app.processEffects()
                    app.generateMonster()
                    if(app.foundMonster){
                        handleMonster()
                    }
                }else{
                    // a room exists at this location
                    let roomAtLocation:Room = app.houseLayout[location.y+7][location.x+7]!
                    if(roomAtLocation.name == "EMPTY" || (roomAtLocation.attachedRooms[(door+2)%4] != nil && roomAtLocation.attachedRooms[(door+2)%4]!.name == "EMPTY")){
                        // not a valid room placement like (0,-1) or this door is a false door
                        print("The door will not opens, weird")
                        app.updateFalseDoor(door-1)
                    }else{
                        // room has been visited and is not a special room
                        app.applyVisitedRoom(roomAtLocation, door: door-1)
                        print("This room looks oddly familiar.")
                        app.checkForMonsters()
                        if(app.foundMonster){
                            handleMonster()
                        }
                    }
                }
            }else{
                // outside of range of house
                print("The door opens... to a brick wall.")
                app.updateFalseDoor(door-1)
            }
            app.moveMonsters()
        }else if(app.currentRoom.attachedRooms[door-1]!.name == "EMPTY"){
            print("Not a valid door!")
        }else if(app.currentRoom.attachedRooms[door-1]!.name == "Exit"){
            if(app.player.hasKey){
                app.hasWon = true
            }else{
                print("The door is locked and will not opens.")
            }
        }else{
            // room already discovered
            app.currentRoom = app.currentRoom.attachedRooms[door-1]!
            app.player.headingNum = (door+1)%4
            app.player.setHeading()
            app.checkForMonsters()
            if(app.foundMonster){
                handleMonster()
            }
        }
        print(app.currentRoom.toString())
        roomName.text = app.currentRoom.name
    }
    
    var tryToAttack = false
    var tryToRun = false
    var goBackToPos = CGPoint(x: 0,y: 0)
    func handleMonster(){
        goBackToPos = appleNode!.position
        appleNode!.paused = true
        tryToAttack = false
        tryToRun = false
        let attackButton = self.childNodeWithName("AttackButton")
        let runButton = self.childNodeWithName("RunButton")
        let analogStick = self.childNodeWithName("AnalogStick")
        attackButton?.hidden = false
        runButton?.hidden = false
        analogStick?.hidden = true
        
        
        addChild(addMonster())
        //addChild(moveAnalogStick)
        //moveAnalogStick.hidden = true
        print("defned")
        
    }
    
    //Temporary function to make sure buttons work
    func monsterDone(){
        appleNode!.paused = false
        appleNode!.position = goBackToPos
        let attackButton = self.childNodeWithName("AttackButton")
        let runButton = self.childNodeWithName("RunButton")
        let analogStick = self.childNodeWithName("AnalogStick")
        let monster = self.childNodeWithName("Monster")

        attackButton?.hidden = true
        runButton?.hidden = true
        analogStick?.hidden = false
        monster!.removeFromParent()
        
        tryToAttack = false
        tryToRun = false
    }
}

extension UIColor {
    
    static func random() -> UIColor {
        
        return UIColor(red: CGFloat(drand48()), green: CGFloat(drand48()), blue: CGFloat(drand48()), alpha: 1)
    }
}