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
    case room = 8
}

class GameScene: SKScene, SKPhysicsContactDelegate, UIAlertViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var appleNode: SKSpriteNode?
    var removed: Bool = false
    let roomName = SKLabelNode(text: "")
    let unopenedDoors = SKLabelNode(text: "")
    let livesText = SKLabelNode(text: "0")
    let console = SKMultilineLabel(text: "Welcome to Madness Manor", labelWidth: 600, pos: CGPoint(x: 0, y: 0))
    var door:Int = 0
    var app:IOSApp = IOSApp()
    var doorX:CGFloat = 0
    var doorY:CGFloat = 0
    var activeMonster:Monster?
    var fightOver:Bool = false
    var fight:Bool = false
    var run:Bool = false
    var currentItem:Item?
    var selectedDropItem:Int = 0
    var stats: SKSpriteNode?
    
    private var _isSetJoystickStickImage = false, _isSetJoystickSubstrateImage = false
    
    var isSetJoystickStickImage: Bool {
        
        get { return _isSetJoystickStickImage }
        
        set {
            
            _isSetJoystickStickImage = newValue
            let image = UIImage(named: "magic_ball")
            moveAnalogStick.stickImage = image
        }
    }
    
    var isSetJoystickSubstrateImage: Bool {
        
        get { return _isSetJoystickSubstrateImage }
        
        set {
            
            _isSetJoystickSubstrateImage = newValue
            let image = newValue ? UIImage(named: "jSubstrate") : nil
            moveAnalogStick.substrateImage = image
        }
    }
    
    var joysticksdiameters: CGFloat {
        
        get { return moveAnalogStick.diameter }
        
        set(newdiameter) {
            
            moveAnalogStick.diameter = newdiameter
        }
    }
    
    let moveAnalogStick = AnalogStick(diameter: kAnalogStickdiameter)
    
    override func didMoveToView(view: SKView) {
        self.view?.viewWithTag(1)?.hidden = true
        self.view?.viewWithTag(2)?.hidden = true
        self.view?.viewWithTag(3)?.hidden = true
        self.view?.viewWithTag(4)?.hidden = true
        self.view?.viewWithTag(5)?.hidden = true
        /* Setup your scene here */
        showInstructions(self)
        backgroundColor = UIColor.blackColor()
        
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if(defaults.boolForKey("Music")){
            SKTAudio.sharedInstance().playBackgroundMusic("theme.wav")
        }
        
        addChild(addRoom())
        let jRadius = kAnalogStickdiameter / 2
        
        
        moveAnalogStick.diameter = kAnalogStickdiameter
        
        let lefty = defaults.boolForKey("Lefty")
        var x = CGRectGetMaxX(self.frame) - jRadius - 25
        if(lefty){
            x = jRadius+25
        }
        addChild(addLives(lefty))
        addChild(addConsole())
        addChild(addPlayerStats(lefty))
        moveAnalogStick.position = CGPointMake(x, jRadius+25)
        moveAnalogStick.trackingHandler = { analogStick in
            
            guard let aN = self.appleNode else { return }
            
            aN.position = CGPointMake(aN.position.x + (analogStick.data.velocity.x * 0.08), aN.position.y + (analogStick.data.velocity.y * 0.08))
            aN.zRotation = analogStick.data.angular
        }
        moveAnalogStick.name = "AnalogStick"
        addChild(moveAnalogStick)
        
        appleNode = appendAppleToPoint(CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)))
        insertChild(appleNode!, atIndex: 0)
        physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        
        isSetJoystickStickImage = _isSetJoystickStickImage
        isSetJoystickSubstrateImage = _isSetJoystickSubstrateImage
        
        addChild(addDoor(CGPointMake(CGRectGetMidX(self.frame),CGRectGetMaxY(self.frame) * 0.25),value: 1))
        addChild(addDoor(CGPointMake(CGRectGetMaxX(self.frame) * 0.25, CGRectGetMidY(self.frame)),value: 2))
        addChild(addDoor(CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame) * 0.75),value: 3))
        addChild(addDoor(CGPointMake(CGRectGetMaxX(self.frame) * 0.75, CGRectGetMidY(self.frame)),value: 4))
        
        addChild(addBattleButton())
        addChild(addRunButton())
        addChild(addAttackButton())
        addChild(addDefenseButton())
        
        for b in addMenuButtons(lefty){
            addChild(b)
        }
        
        physicsWorld.contactDelegate = self
        setupLabels()
    }
    
    func addLives(lefty:Bool) -> SKSpriteNode{
        let livesImage = UIImage(named: "lives")
        let texture = SKTexture(image: livesImage!)
        let lives = SKSpriteNode(texture: texture)
        lives.size.width = 100
        lives.size.height = 100
        var x:CGFloat = 0
        if(lefty){
            x = 60
        }else{
            x = CGRectGetMaxX(self.frame)-CGFloat(60)
        }
        lives.position = CGPoint(x: x, y: CGRectGetMaxY(self.frame)-60)
        livesText.text = "\(app.player.skills["Health"]!)"
        livesText.fontColor = UIColor.blackColor()
        livesText.fontSize = 50
        livesText.zPosition = 2
        livesText.position = CGPoint(x:0, y:-10)
        lives.addChild(livesText)
        return lives
    }
    
    func addPlayerStats(lefty:Bool) -> SKSpriteNode {
        stats = SKSpriteNode(color: UIColor.blackColor(), size: CGSizeMake(CGRectGetMaxX(self.frame)*0.25, CGRectGetMaxY(self.frame)*0.35))
        var x:CGFloat = 0
        if(lefty){
            x = CGRectGetMaxX(self.frame)*0.1
        }else{
            x = CGRectGetMaxX(self.frame)*0.9
        }
        stats!.position = CGPoint(x: x, y: CGRectGetMaxY(self.frame)*0.6)
        var skills = app.player.skills
        let attackSkill = SKLabelNode(text: "Attack: \(skills["Attack"]!)")
        let defenseSkill = SKLabelNode(text: "Defense: \(skills["Defense"]!)")
        let luckSkill = SKLabelNode(text: "Luck: \(skills["Luck"]!)")
        let sanitySkill = SKLabelNode(text: "Sanity: \(skills["Sanity"]!)")
        let stealthSkill = SKLabelNode(text: "Stealth: \(skills["Stealth"]!)")
        let evasionSkill = SKLabelNode(text: "Evasion: \(skills["Evasion"]!)")
        attackSkill.fontColor = UIColor.whiteColor()
        defenseSkill.fontColor = UIColor.whiteColor()
        luckSkill.fontColor = UIColor.whiteColor()
        sanitySkill.fontColor = UIColor.whiteColor()
        stealthSkill.fontColor = UIColor.whiteColor()
        evasionSkill.fontColor = UIColor.whiteColor()
        attackSkill.fontSize = 30
        defenseSkill.fontSize = 30
        stealthSkill.fontSize = 30
        evasionSkill.fontSize = 30
        luckSkill.fontSize = 30
        sanitySkill.fontSize = 30
        attackSkill.position = CGPoint(x: 0, y: 0+stats!.size.height/2-70)
        defenseSkill.position = CGPoint(x: 0, y: 0+stats!.size.height/2-100)
        luckSkill.position = CGPoint(x: 0, y: 0+stats!.size.height/2-130)
        sanitySkill.position = CGPoint(x: 0, y: 0+stats!.size.height/2-160)
        stealthSkill.position = CGPoint(x: 0, y: 0+stats!.size.height/2-190)
        evasionSkill.position = CGPoint(x: 0, y: 0+stats!.size.height/2-220)
        stats!.addChild(attackSkill)
        stats!.addChild(defenseSkill)
        stats!.addChild(luckSkill)
        stats!.addChild(sanitySkill)
        stats!.addChild(stealthSkill)
        stats!.addChild(evasionSkill)
        return stats!
    }
    
    func addConsole() -> SKSpriteNode{
        console.fontColor = UIColor.whiteColor()
        let consoleBackground = SKSpriteNode(color: UIColor.blackColor(), size: CGSizeMake(CGRectGetMaxX(self.frame)*0.7, CGRectGetMaxY(self.frame)*0.15))
        consoleBackground.position = CGPoint(x: CGRectGetMaxX(self.frame)*0.5, y: CGRectGetMaxY(self.frame)*0.95)
        consoleBackground.addChild(console)
        return consoleBackground
    }
    
    func appendAppleToPoint(position: CGPoint) -> SKSpriteNode {
        
        let playerImage = UIImage(named: "character")
        
        precondition(playerImage != nil, "Please set right image")
        
        let texture = SKTexture(image: playerImage!)
        
        let player = SKSpriteNode(texture: texture)
        player.physicsBody = SKPhysicsBody(texture: texture, size: player.size)
        player.physicsBody!.affectedByGravity = false
        player.position = position
        player.physicsBody?.categoryBitMask = BodyType.player.rawValue
        player.physicsBody?.contactTestBitMask = BodyType.door.rawValue
        player.physicsBody?.collisionBitMask = BodyType.room.rawValue
        
        return player
    }
    
    func addRoom() -> SKSpriteNode {
        let roomImage = UIImage(named: "room")
        let texture = SKTexture(image: roomImage!)
        let room = SKSpriteNode(texture: texture)
        room.position = CGPoint(x: CGRectGetMidX(self.frame), y: CGRectGetMidY(self.frame))
        room.zPosition = -3
        room.physicsBody = SKPhysicsBody(edgeLoopFromRect: CGRect(x: 0-room.size.width/2, y: 0-room.size.height/2, width: room.size.width, height: room.size.height))
        room.physicsBody!.affectedByGravity = false
        room.physicsBody?.categoryBitMask = BodyType.room.rawValue
        room.physicsBody?.contactTestBitMask = BodyType.player.rawValue
        room.physicsBody?.collisionBitMask = BodyType.player.rawValue
        
        
        
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
            print("Handling door")
            let validDoor = handleDoor(door)
            generateDoors()
            let heading = app.player.heading
            var newPos = CGPointZero
            if(validDoor){
                if(heading == "North"){
                    newPos = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMaxY(self.frame) * 0.25 + UIImage(named: "penguin")!.size.height)
                }else if(heading == "East"){
                    newPos = CGPointMake(CGRectGetMaxX(self.frame) * 0.25 + UIImage(named: "penguin")!.size.width, CGRectGetMidY(self.frame))
                }else if(heading == "South"){
                    newPos = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame) * 0.75 - UIImage(named: "penguin")!.size.height)
                }else{
                    newPos = CGPointMake(CGRectGetMaxX(self.frame) * 0.75 - UIImage(named: "penguin")!.size.width, CGRectGetMidY(self.frame))
                }
            }else{
                if(Int(door.value) == 3){
                    newPos = CGPointMake(appleNode!.position.x, appleNode!.position.y * 0.9)
                }else if(Int(door.value) == 4){
                    newPos = CGPointMake(appleNode!.position.x * 0.9, appleNode!.position.y)
                }else if(Int(door.value) == 1){
                    newPos = CGPointMake(appleNode!.position.x, appleNode!.position.y * 1.1)
                }else{
                    newPos = CGPointMake(appleNode!.position.x * 1.1, appleNode!.position.y)
                }
            }
            generateDoors()
            appleNode!.position = newPos
            insertChild(appleNode!, atIndex: 0)
            physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
            removed = false;
        }
    }
    
    func setupLabels() {
        roomName.position = CGPoint(x: frame.size.width/2, y: frame.size.height * 0.10)
        roomName.fontColor = UIColor.whiteColor();
        roomName.fontSize = 40
        roomName.text = app.currentRoom.name
        addChild(roomName)
        unopenedDoors.position = CGPoint(x: frame.size.width/2, y: frame.size.height * 0.05)
        unopenedDoors.fontColor = UIColor.whiteColor()
        unopenedDoors.fontSize = 40
        unopenedDoors.text = "Unopened Doors: \(app.unopenedDoors)"
        addChild(unopenedDoors)
    }
    
    func showInstructions(controller: GameScene) {
        let alert = UIAlertView(title: "Instructions:", message: "", delegate: self, cancelButtonTitle: "OK")
        alert.message = "Enter \"exit\" to quit.\nEnter \"stats\" to show player stats.\nEnter \"items\" to show current items.\nEnter \"happenings\" to show current happenings.\nEnter \"effects\" to show current effects.\nEnter \"layout\" to show house layout"
        alert.show()
    }
    
    func addMenuButtons(lefty: Bool) -> [SKSpriteNode]{
        let size = CGSize(width: CGRectGetMaxX(self.frame)/8, height: CGRectGetMaxX(self.frame)/8)
        var x = CGRectGetMaxX(self.frame) * 0.01 + size.width/2
        
        if(lefty){
            x = CGRectGetMaxX(self.frame) * 0.99 - size.width/2
        }
        
        let mapButton = SKSpriteNode(color: UIColor.grayColor(), size: size)
        mapButton.position = CGPoint(x: x, y: CGRectGetMaxY(self.frame) * 0.99 - size.height)
        mapButton.name = "MapButton"
        
        let instructionsButton = SKSpriteNode(color: UIColor.greenColor(), size: size)
        instructionsButton.position = CGPoint(x: mapButton.frame.midX, y: mapButton.frame.minY - CGRectGetMaxX(self.frame) * 0.01 - size.height/2)
        instructionsButton.name = "InstructionsButton"
        
        return [mapButton, instructionsButton]
    }
    
    func addBattleButton() -> SKSpriteNode {
        let attackImage = UIImage(named: "sword")
        let texture = SKTexture(image: attackImage!)
        let attackButton = SKSpriteNode(texture: texture)
        
        attackButton.size.width = CGRectGetMaxX(self.frame)/10
        attackButton.size.height = attackButton.size.width
        
        attackButton.position = CGPoint(x: CGRectGetMaxX(self.frame) * 0.05 + (attackImage!.size.width), y: CGRectGetMaxY(self.frame) * 0.1 + (attackImage!.size.height))
        attackButton.zPosition = 3
        attackButton.name = "BattleButton"
        attackButton.hidden = true
        
        return attackButton
    }
    
    func addRunButton() -> SKSpriteNode {
        let runImage = UIImage(named: "run")
        let texture = SKTexture(image: runImage!)
        let runButton = SKSpriteNode(texture: texture)
        
        runButton.size.width = CGRectGetMaxX(self.frame)/10
        runButton.size.height = runButton.size.width
        
        runButton.position = CGPoint(x: CGRectGetMaxX(self.frame) * 0.05 + (runImage!.size.width) * 2, y: CGRectGetMaxY(self.frame) * 0.1 + (runImage!.size.height))
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
    
    func addAttackButton() -> SKSpriteNode{
        let attackImage = UIImage(named: "sword")
        let texture = SKTexture(image: attackImage!)
        let attackButton = SKSpriteNode(texture: texture)
        attackButton.size.width = CGRectGetMaxX(self.frame)/10
        attackButton.size.height = attackButton.size.width
        
        attackButton.position = CGPoint(x: CGRectGetMaxX(self.frame) * 0.05 + (attackImage!.size.width), y: CGRectGetMaxY(self.frame) * 0.1 + (attackImage!.size.height))
        attackButton.zPosition = 3
        attackButton.name = "AttackButton"
        attackButton.hidden = true
        
        return attackButton
    }
    
    func addDefenseButton() -> SKSpriteNode{
        let defenseImage = UIImage(named: "DefenseButton")
        let texture = SKTexture(image: defenseImage!)
        let defenseButton = SKSpriteNode(texture: texture)
        defenseButton.size.width = CGRectGetMaxX(self.frame)/10
        defenseButton.size.height = defenseButton.size.width
        
        defenseButton.position = CGPoint(x: 400, y: 200)
        defenseButton.zPosition = 3
        defenseButton.name = "DefenseButton"
        defenseButton.hidden = true
        
        return defenseButton
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        touches.forEach { (touch) -> () in
            let pos = touch.locationInNode(self)
            let node = self.nodeAtPoint(pos)
            if let name = node.name
            {
                if name == "BattleButton"
                {
                    tryToAttack = true
                    // battle
                    fight = app.promptMonsterFightIOS(activeMonster!, run: false)
                    print("Battle \(fight)")
                }
                else if name == "RunButton"
                {
                    tryToRun = true
                    // run away
                    fight = app.promptMonsterFightIOS(activeMonster!, run: true)
                    run = true
                    print("RUUUNNN")
                    print(app.currentRoom.toString())
                    roomName.text = app.currentRoom.name
                    generateDoors()
                }
                else if name == "AttackButton"
                {
                    fightOver = app.fightMonsterIOS(activeMonster!, attack: true)
                    livesText.text = "\(app.player.skills["Health"]!)"
                }
                else if name == "DefenseButton"
                {
                    fightOver = app.fightMonsterIOS(activeMonster!, attack: false)
                    livesText.text = "\(app.player.skills["Health"]!)"
                }
                else if name == "MapButton"
                {
                    displayMap()
                }
            }
            // start battle
            if(fight){
                print("handle attack")
                handleAttack()
            }
            if(run){
                print("handle run")
                handleRun()
            }
            // end of battle
            if(fightOver){
                print("battle over \(fight) \(fightOver)")
                battleDone()
            }
        }
    }
    
    func displayMap(){
        let alert = UIAlertView(title: "Map:", message: "", delegate: self, cancelButtonTitle: "Done")
        let message = UILabel()
        message.font = UIFont(name: "Courier New", size: 13)
        message.numberOfLines = 0
        message.text = app.printLayout()
        message.textAlignment = .Center
        alert.setValue(message, forKey: "accessoryView")
        alert.show()
    }
    
    func handleDoor(door: Int) -> Bool{
        var validDoor = true
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
                    let newRoom:Room = app.houseLayout[location.y+7][location.x+7]! as Room
                    swapItem(newRoom)
                    if(newRoom.happening != nil){
                        console.text = "\(newRoom.happening!.name): \(newRoom.happening!.description), \(newRoom.happening!.effect.description)"
                    }else{
                       console.text = "No Happening"
                    }
                    app.processEffects()
                    activeMonster = app.generateMonster()
                    app.unopenedDoors--
                }else{
                    // a room exists at this location
                    let roomAtLocation:Room = app.houseLayout[location.y+7][location.x+7]!
                    if(roomAtLocation.name == "EMPTY" || (roomAtLocation.attachedRooms[(door+2)%4] != nil && roomAtLocation.attachedRooms[(door+2)%4]!.name == "EMPTY")){
                        // not a valid room placement like (0,-1) or this door is a false door
                        print("The door will not opens, weird")
                        console.text = "The door will not opens, weird"
                        app.updateFalseDoor(door-1)
                        validDoor = false
                        app.unopenedDoors--
                    }else{
                        // room has been visited and is not a special room
                        app.applyVisitedRoom(roomAtLocation, door: door-1)
                        print("This room looks oddly familiar.")
                        activeMonster = app.checkForMonsters()
                        console.text = "This room looks oddly familiar"
                        app.unopenedDoors--
                    }
                }
            }else{
                // outside of range of house
                print("The door opens... to a brick wall.")
                console.text = "The door opens... to a brick wall."
                app.updateFalseDoor(door-1)
                validDoor = false
                app.unopenedDoors--
            }
            activeMonster = app.moveMonsters()
        }else if(app.currentRoom.attachedRooms[door-1]!.name == "EMPTY"){
            print("Not a valid door!")
            console.text = "Not a valid door"
            validDoor = false
        }else if(app.currentRoom.attachedRooms[door-1]!.name == "Exit"){
            if(app.player.hasKey){
                app.hasWon = true
                victory()
            }else{
                print("The door is locked and will not open.")
                console.text = "The door is locked and will not open."
                validDoor = false
            }
        }else{
            // room already discovered
            app.currentRoom = app.currentRoom.attachedRooms[door-1]!
            app.player.headingNum = (door+1)%4
            app.player.setHeading()
            activeMonster = app.checkForMonsters()
            console.text = ""
        }
        if(activeMonster != nil){
            handleMonster()
        }
        if(app.unopenedDoors == 0){
            print("out of doors!")
            // need to redo map
            restartGame()
        }
        print(app.currentRoom.toString())
        roomName.text = app.currentRoom.name
        generateDoors()
        updateSkills()
        unopenedDoors.text = "Unopened Doors: \(app.unopenedDoors)"
        return validDoor
    }
    
    func handleAttack(){
        let battleButton = self.childNodeWithName("BattleButton")
        let runButton = self.childNodeWithName("RunButton")
        battleButton?.hidden = true
        runButton?.hidden = true
        
        let attackButton = self.childNodeWithName("AttackButton")
        let defenseButton = self.childNodeWithName("DefenseButton")
        attackButton?.hidden = false
        defenseButton?.hidden = false
        
    }
    
    func updateSkills(){
        (stats!.children[0] as! SKLabelNode).text = "Attack: \(app.player.skills["Attack"]!)"
        (stats!.children[1] as! SKLabelNode).text = "Defense: \(app.player.skills["Defense"]!)"
        (stats!.children[2] as! SKLabelNode).text = "Luck: \(app.player.skills["Luck"]!)"
        (stats!.children[3] as! SKLabelNode).text = "Sanity: \(app.player.skills["Sanity"]!)"
        (stats!.children[4] as! SKLabelNode).text = "Stealth: \(app.player.skills["Stealth"]!)"
        (stats!.children[5] as! SKLabelNode).text = "Evasion: \(app.player.skills["Evasion"]!)"
    }
    
    func handleRun(){
        let battleButton = self.childNodeWithName("BattleButton")
        let runButton = self.childNodeWithName("RunButton")
        let monster = self.childNodeWithName("Monster")
        battleButton?.hidden = true
        runButton?.hidden = true
        monster?.hidden = true
        monster?.removeFromParent()
        
        tryToAttack = false
        tryToRun = false
        run = false
        app.monstersInGame.append(activeMonster!)
        activeMonster = nil
        
        moveAnalogStick.hidden = false
        moveAnalogStick.trackingHandler = { analogStick in
            
            guard let aN = self.appleNode else { return }
            
            aN.position = CGPointMake(aN.position.x + (analogStick.data.velocity.x * 0.08), aN.position.y + (analogStick.data.velocity.y * 0.08))
            aN.zRotation = analogStick.data.angular
            
        }
    }
    
    var tryToAttack = false
    var tryToRun = false
    func handleMonster(){
        moveAnalogStick.trackingHandler = { analogStick in
            
            guard let aN = self.appleNode else { return }
            
            aN.position = aN.position
        }
        moveAnalogStick.hidden = true
        tryToAttack = false
        tryToRun = false
        let attackButton = self.childNodeWithName("BattleButton")
        let runButton = self.childNodeWithName("RunButton")
        attackButton?.hidden = false
        runButton?.hidden = false
        
        addChild(addMonster())
        print("prompting for monster")
        print(activeMonster!.toString())
        
    }
    
    func battleDone(){
        moveAnalogStick.hidden = false
        moveAnalogStick.trackingHandler = { analogStick in
            
            guard let aN = self.appleNode else { return }
            
            aN.position = CGPointMake(aN.position.x + (analogStick.data.velocity.x * 0.08), aN.position.y + (analogStick.data.velocity.y * 0.08))
            aN.zRotation = analogStick.data.angular
            
        }
        let attackButton = self.childNodeWithName("AttackButton")
        let defenseButton = self.childNodeWithName("DefenseButton")
        let monster = self.childNodeWithName("Monster")
        let battleButton = self.childNodeWithName("BattleButton")
        let runButton = self.childNodeWithName("RunButton")
        battleButton?.hidden = true
        runButton?.hidden = true

        attackButton?.hidden = true
        defenseButton?.hidden = true
        monster?.hidden = true
        monster?.removeFromParent()
        
        tryToAttack = false
        tryToRun = false
        fight = false
        fightOver = false
        run = false
        activeMonster = nil
        if(!app.player.isPlayerAlive()){
            victory()
        }
    }
    
    func victory(){
        print("GAME OVER")
        self.removeAllChildren();
        self.view?.viewWithTag(1)?.hidden = false
        self.view?.viewWithTag(2)?.hidden = false
        self.view?.viewWithTag(3)?.hidden = false
        self.view?.viewWithTag(4)?.hidden = false
        self.view?.viewWithTag(5)?.hidden = false
        
        if(app.hasWon){
            print("----- YOU WIN! -----")
            (self.view?.viewWithTag(4) as? UILabel)?.text = "----- YOU WIN! -----"
            print("Thank you for playing!")
            (self.view?.viewWithTag(5) as? UILabel)?.text = "Thank you for playing!"
        }else if(app.player.hasKey){
            print("You die attempting to escape the house.")
            (self.view?.viewWithTag(4) as? UILabel)?.text = "----- YOU LOSE -----"
            print("----- YOU LOSE -----")
            (self.view?.viewWithTag(5) as? UILabel)?.text = "You die attempting to escape the house."
        }else{
            print("You die searching. Maybe the key was never there.")
            (self.view?.viewWithTag(4) as? UILabel)?.text = "----- YOU LOSE -----"
            print("----- YOU LOSE -----")
            (self.view?.viewWithTag(5) as? UILabel)?.text = "You die searching. Maybe the key was never there."
        }
    }
    
    func swapItem(room:Room){
        // prompt user for item pickup if room contains item
        currentItem = room.item
        if(currentItem != nil){
            let alert:UIAlertView
            print(app.player.currentItems.count)
            if(app.player.currentItems.count >= app.player.inventorySpace && currentItem!.type != "Other"){
                // must drop an item
                alert = UIAlertView(title: "Item Found!", message: "", delegate: self, cancelButtonTitle: "Drop", otherButtonTitles: "Keep")
                alert.tag = 999
                let v:UIView = UIView()
                let itemImage:UIImageView = UIImageView(frame: CGRectMake(0, 0, 50, 50))
                let itemName:UILabel = UILabel(frame: CGRectMake(55,0,200,24))
                let itemEffect:UILabel = UILabel(frame: CGRectMake(55,30,200,24))
                itemImage.image = UIImage(named: "apple")
                itemImage.sizeToFit()
                itemName.text = currentItem!.name
                itemName.sizeToFit()
                itemEffect.text = currentItem!.effect.description
                itemEffect.lineBreakMode = .ByWordWrapping
                itemEffect.numberOfLines = 0
                itemEffect.sizeToFit()
                v.addSubview(itemImage)
                v.addSubview(itemName)
                v.addSubview(itemEffect)
                v.translatesAutoresizingMaskIntoConstraints = true
                v.sizeToFit()
                alert.setValue(v, forKey: "accessoryView")
            }else{
                alert = UIAlertView(title: "Item Found!", message: "", delegate: self, cancelButtonTitle: "OK" )
                let v:UIView = UIView()
                let itemImage:UIImageView = UIImageView(frame: CGRectMake(0, 0, 50, 50))
                let itemName:UILabel = UILabel(frame: CGRectMake(60,0,200,24))
                let itemEffect:UILabel = UILabel(frame: CGRectMake(60,30,200,24))
                itemImage.image = UIImage(named: "apple")
                itemImage.sizeToFit()
                itemName.text = currentItem!.name
                itemName.sizeToFit()
                itemEffect.text = currentItem!.effect.description
                itemEffect.lineBreakMode = .ByWordWrapping
                itemEffect.numberOfLines = 0
                itemEffect.sizeToFit()
                v.addSubview(itemImage)
                v.addSubview(itemName)
                v.addSubview(itemEffect)
                v.sizeToFit()
                v.translatesAutoresizingMaskIntoConstraints = true
                alert.setValue(v, forKey: "accessoryView")
                if(currentItem!.type != "Other"){
                    app.player.currentItems.append(currentItem!)
                }
                app.player.items.append(currentItem!)
                app.newEffects.append(currentItem!.effect)
                currentItem = nil
                livesText.text = "\(app.player.skills["Health"]!)"
                
            }
            alert.show()
        }
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int){
        if(alertView.tag == 999){
            if(buttonIndex == 0){
                // drop button -- doesn't keep new item
                print("Item discarded")
                app.currentRoom.item = nil
                currentItem = nil
            }else{
                // keep button -- must discard an item
                let alert = UIAlertView(title: "Inventory", message: "Discard an item", delegate: self, cancelButtonTitle: "Drop")
                let picker = UIPickerView()
                picker.delegate = self
                app.player.currentItems.append(currentItem!)
                app.player.items.append(currentItem!)
                app.newEffects.append(currentItem!.effect)
                picker.dataSource = self
                alert.setValue(picker, forKey: "accessoryView")
                alert.tag = 888
                alert.show()
            }
                print(buttonIndex)
        }else if(alertView.tag == 888){
            print(selectedDropItem)
            print(app.player.currentItems)
            print(app.player.currentItems[selectedDropItem]?.toString())
            let removedItem:Item = app.player.currentItems[selectedDropItem]!
            app.player.currentItems.removeAtIndex(selectedDropItem)
            let index:Int? = app.player.items.indexOf(removedItem)
            print(index)
            if(index != nil){app.player.items.removeAtIndex(index!)}
            let effectIndex:Int? = app.player.currentEffects.indexOf(removedItem.effect)
            print(effectIndex)
            if(effectIndex != nil){
                let effect:Effect = app.player.currentEffects[effectIndex!]
                app.player.currentEffects.removeAtIndex(effectIndex!)
                app.player.skills[removedItem.type]! -= Int.init(effect.description.componentsSeparatedByString("")[1])!
            }
            currentItem = nil
            updateSkills()
        }
    }
    
    func numberOfComponentsInPickerView(colorPicker: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return app.player.currentItems.count
    }
    
//    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
//    {
//        return "\(app.player.currentItems[row]!.name): \(app.player.currentItems[row]!.effect.toString())"
//    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print("row selected: \(row)")
        selectedDropItem = row
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        var v:UIView
        if((view) != nil){
            v = view!
        }else{
            v = UIView()
            let itemImage:UIImageView = UIImageView(frame: CGRectMake(0, 0, 50, 50))
            itemImage.tag = 333
            let itemName:UILabel = UILabel(frame: CGRectMake(60,0,320,24))
            itemName.tag = 111
            let itemEffect:UILabel = UILabel(frame: CGRectMake(60,24,320,24))
            itemEffect.tag = 222
            v.addSubview(itemImage)
            v.addSubview(itemName)
            v.addSubview(itemEffect)
            v.translatesAutoresizingMaskIntoConstraints = true
        }
        let itemImage:UIImageView = v.viewWithTag(333) as! UIImageView
        itemImage.image = UIImage(named: "apple")
        
        let itemName:UILabel = v.viewWithTag(111) as! UILabel
        itemName.text = app.player.currentItems[row]!.name
        
        let itemEffect:UILabel = v.viewWithTag(222) as! UILabel
        itemEffect.text = app.player.currentItems[row]!.effect.description
        
        v.sizeToFit()
        
        return v
    }
    
    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 50
    }
    
    func restartGame(){
        let player = app.player
        app = IOSApp()
        app.player = player
        console.text = "You lay down to rest, and wake up to find the rooms rearranged."
        app.player.headingNum = 0
        app.player.heading = "North"
        app.unopenedDoors = 3
    }
    
    func generateDoors(){
        for child in self.children as [SKNode] {
            if (child.name == "1" || child.name == "2" || child.name == "3" || child.name == "4") {
                self.removeChildrenInArray([child])
            }
        }
        if(app.currentRoom.attachedRooms[0] == nil || app.currentRoom.attachedRooms[0]!.name != "EMPTY"){
            addChild(addDoor(CGPointMake(CGRectGetMidX(self.frame),CGRectGetMaxY(self.frame) * 0.25),value: 1))
        }
        if(app.currentRoom.attachedRooms[1] == nil || app.currentRoom.attachedRooms[1]!.name != "EMPTY"){
            addChild(addDoor(CGPointMake(CGRectGetMaxX(self.frame) * 0.25, CGRectGetMidY(self.frame)),value: 2))
        }
        if(app.currentRoom.attachedRooms[2] == nil || app.currentRoom.attachedRooms[2]!.name != "EMPTY"){
            addChild(addDoor(CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame) * 0.75),value: 3))
        }
        if(app.currentRoom.attachedRooms[3] == nil || app.currentRoom.attachedRooms[3]!.name != "EMPTY"){
            addChild(addDoor(CGPointMake(CGRectGetMaxX(self.frame) * 0.75, CGRectGetMidY(self.frame)),value: 4))
        }
    }
}

extension UIColor {
    
    static func random() -> UIColor {
        
        return UIColor(red: CGFloat(drand48()), green: CGFloat(drand48()), blue: CGFloat(drand48()), alpha: 1)
    }
}