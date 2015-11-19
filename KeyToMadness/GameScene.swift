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

class GameScene: SKScene, SKPhysicsContactDelegate, UIAlertViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource {
    var player: SKSpriteNode?
    var removed: Bool = false
    let roomName = SKLabelNode(text: "")
    let unopenedDoors = SKLabelNode(text: "")
    let livesText = SKLabelNode(text: "0")
    var console = SKMultilineLabel(text: "Welcome to Madness Manor", labelWidth: 600, pos: CGPoint(x: 0, y: 0))
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
    var playSounds:Bool = false
    var playerClass:String = "Basic"
    var key:SKSpriteNode = SKSpriteNode()
    var herbsAction:Bool = false
    
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
        /* Setup your scene here */
        showInstructions(self)
        backgroundColor = UIColor.blackColor()
        
        let defaults = NSUserDefaults.standardUserDefaults()
        print(defaults.boolForKey("Music"))
        if(defaults.boolForKey("Music")){
            SKTAudio.sharedInstance().playBackgroundMusic("theme.wav")
        }
        
        playSounds = defaults.boolForKey("Sounds")
        
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
            
            guard let aN = self.player else { return }
            
            aN.position = CGPointMake(aN.position.x + (analogStick.data.velocity.x * 0.08), aN.position.y + (analogStick.data.velocity.y * 0.08))
            aN.zRotation = analogStick.data.angular
        }
        moveAnalogStick.name = "AnalogStick"
        addChild(moveAnalogStick)
        
        player = addPlayer(CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)))
        insertChild(player!, atIndex: 0)
        physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        
        isSetJoystickStickImage = _isSetJoystickStickImage
        isSetJoystickSubstrateImage = _isSetJoystickSubstrateImage
        
        addChild(addDoor(CGPointMake(CGRectGetMidX(self.frame),CGRectGetMaxY(self.frame) * 0.25),value: 1, undiscovered:  false))
        addChild(addDoor(CGPointMake(CGRectGetMaxX(self.frame) * 0.3, CGRectGetMidY(self.frame)),value: 2, undiscovered:  true))
        addChild(addDoor(CGPointMake(CGRectGetMidX(self.frame),CGRectGetMaxY(self.frame) * 0.75),value: 3, undiscovered:  true))
        addChild(addDoor(CGPointMake(CGRectGetMaxX(self.frame) * 0.7, CGRectGetMidY(self.frame)),value: 4, undiscovered:  true))
        
        addChild(addBattleButton(lefty))
        addChild(addRunButton(lefty))
        addChild(addAttackButton(lefty))
        addChild(addDefenseButton(lefty))
        addChild(addKeyIcon(lefty))
        
        for b in addMenuButtons(lefty){
            addChild(b)
        }
        
        physicsWorld.contactDelegate = self
        setupLabels()
        updatePlayerClass()
    }
    
    func addCircles() {
        var count = 0;
        var remove = 0;
        let action1 = SKAction.runBlock({
            let viewMidX = self.view!.bounds.midX
            let viewMidY = self.view!.bounds.midY
            
            let currentBall = SKShapeNode(circleOfRadius: CGFloat(arc4random_uniform(90)+10))
            currentBall.fillColor = UIColor(red: CGFloat(Float(arc4random()) / Float(UINT32_MAX))*255.0/255, green: CGFloat(Float(arc4random()) / Float(UINT32_MAX))*255.0/255, blue: CGFloat(Float(arc4random()) / Float(UINT32_MAX))*255.0/255, alpha: 0.4)
            currentBall.lineWidth = 0
            
            let xPosition = self.view!.scene!.frame.midX - viewMidX + CGFloat(arc4random_uniform(UInt32(viewMidX*2)))
            let yPosition = self.view!.scene!.frame.midY - viewMidY + CGFloat(arc4random_uniform(UInt32(viewMidY*2)))
            
            currentBall.position = CGPointMake(xPosition,yPosition)
            currentBall.name = "ball\(count++)"
            self.addChild(currentBall)
            print("bubble")
            if(count == 999999999){
                count = 11;
            }
        })
        let wait = SKAction.waitForDuration(0.5)
        let action2 = SKAction.runBlock({
            if(count > 10){
                let currentBall = self.childNodeWithName("ball\(remove++)")
                currentBall!.removeFromParent()
                if(remove == 999999999){
                    remove = 11;
                }
            }
        })
        self.runAction(SKAction.repeatActionForever(SKAction.sequence([action1,wait,action2])), withKey: "herbs")
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
    
    func addPlayer(position: CGPoint) -> SKSpriteNode {
        
        let playerImage = UIImage(named: "character")
        
        precondition(playerImage != nil, "Please set right image")
        
        let texture = SKTexture(image: playerImage!)
        
        let player = SKSpriteNode(texture: texture)
        player.size = CGSize(width: player.size.width/1.5, height: player.size.height/1.5)
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
        room.physicsBody = SKPhysicsBody(edgeLoopFromRect: CGRect(x: 0-room.size.width/2*0.8, y: 0-room.size.height/2*0.8, width: room.size.width*0.8, height: room.size.height*0.8))
        room.physicsBody!.affectedByGravity = false
        room.physicsBody?.categoryBitMask = BodyType.room.rawValue
        room.physicsBody?.contactTestBitMask = BodyType.player.rawValue
        room.physicsBody?.collisionBitMask = BodyType.player.rawValue
        
        
        
       return room
    }
    
    func addDoor(position: CGPoint, value: Int, undiscovered: Bool) -> SKSpriteNode {
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
        if(undiscovered){
            door.anchorPoint = CGPointMake(0.5, 0.5)
            let glow:SKSpriteNode = door.copy() as! SKSpriteNode
            glow.size = door.size
            glow.color = UIColor.blueColor()
            glow.texture = nil
            glow.anchorPoint = door.anchorPoint
            glow.position = CGPoint(x: 0, y: 0)
            glow.alpha = 0.5
            glow.blendMode = .Add
            door.addChild(glow)
        }
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
            if(firstNode != nil && secondNode != nil){
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
                if(playSounds){
                    SKTAudio.sharedInstance().playSoundEffect("door.wav")
                }
                if(heading == "North"){
                    newPos = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMaxY(self.frame) * 0.25 + UIImage(named: "character")!.size.height)
                }else if(heading == "East"){
                    newPos = CGPointMake(CGRectGetMaxX(self.frame) * 0.25 + UIImage(named: "character")!.size.width, CGRectGetMidY(self.frame))
                }else if(heading == "South"){
                    newPos = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame) * 0.75 - UIImage(named: "character")!.size.height)
                }else{
                    newPos = CGPointMake(CGRectGetMaxX(self.frame) * 0.75 - UIImage(named: "character")!.size.width, CGRectGetMidY(self.frame))
                }
            }else{
                if(Int(door.value) == 3){
                    newPos = CGPointMake(player!.position.x, player!.position.y * 0.9)
                }else if(Int(door.value) == 4){
                    newPos = CGPointMake(player!.position.x * 0.9, player!.position.y)
                }else if(Int(door.value) == 1){
                    newPos = CGPointMake(player!.position.x, player!.position.y * 1.1)
                }else{
                    newPos = CGPointMake(player!.position.x * 1.1, player!.position.y)
                }
            }
            generateDoors()
            player!.position = newPos
            insertChild(player!, atIndex: 0)
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
        alert.message = "Madness Manor\nThe goal is simple. Escape\nYou are in the entry of the house. To escape you need to find the key. It is hidden in one of the rooms in this house. Find it. Avoid the monsters. Pick up items. Some rooms you will experience happenings. They are not good, avoid them the best you can.\nGood luck"
        alert.show()
    }
    
    func addMenuButtons(lefty: Bool) -> [SKSpriteNode]{
        let size = CGSize(width: CGRectGetMaxX(self.frame)/8, height: CGRectGetMaxX(self.frame)/8)
        var x = CGRectGetMaxX(self.frame) * 0.01 + size.width/2
        
        if(lefty){
            x = CGRectGetMaxX(self.frame) * 0.99 - size.width/2
        }
        
        let mapButton = SKSpriteNode(color: UIColor.grayColor(), size: size)
        //mapButton.position = CGPoint(x: x, y: CGRectGetMaxY(self.frame) * 0.99 - size.height)
        mapButton.position = CGPoint(x: x, y: CGRectGetMaxY(self.frame) * 0.8 - size.height)
        mapButton.name = "MapButton"
        
        let inventoryButton = SKSpriteNode(color: UIColor.greenColor(), size: size)
        //instructionsButton.position = CGPoint(x: mapButton.frame.midX, y: mapButton.frame.minY - CGRectGetMaxX(self.frame) * 0.01 - size.height/2)
        inventoryButton.position = CGPoint(x: x, y: CGRectGetMaxY(self.frame) * 0.6 - size.height)
        inventoryButton.name = "InventoryButton"
        
        let exitButton = SKSpriteNode(color: UIColor.blueColor(), size: size)
        exitButton.position = CGPoint(x: x, y: CGRectGetMaxY(self.frame) - size.height)
        exitButton.name = "ExitButton"
        
        return [mapButton, inventoryButton, exitButton]
    }
    
    func addBattleButton(lefty:Bool) -> SKSpriteNode {
        let attackImage = UIImage(named: "sword")
        let texture = SKTexture(image: attackImage!)
        let attackButton = SKSpriteNode(texture: texture)
        
        attackButton.size.width = CGRectGetMaxX(self.frame)/10
        attackButton.size.height = attackButton.size.width
        
        
        attackButton.position = CGPoint(x: CGRectGetMaxX(self.frame) - attackButton.size.width*2, y: CGRectGetMinY(self.frame) + attackButton.size.height)
        if(lefty){
           attackButton.position = CGPoint(x: CGRectGetMinX(self.frame) + attackButton.size.width, y: CGRectGetMinY(self.frame) + attackButton.size.height)
        }
        attackButton.zPosition = 3
        attackButton.name = "BattleButton"
        attackButton.hidden = true
        
        return attackButton
    }
    
    func addRunButton(lefty:Bool) -> SKSpriteNode {
        let runImage = UIImage(named: "run")
        let texture = SKTexture(image: runImage!)
        let runButton = SKSpriteNode(texture: texture)
        
        runButton.size.width = CGRectGetMaxX(self.frame)/10
        runButton.size.height = runButton.size.width
        
        runButton.position = CGPoint(x: CGRectGetMaxX(self.frame) - runButton.size.width, y: CGRectGetMinY(self.frame) + runButton.size.height)
        if(lefty){
            runButton.position = CGPoint(x: CGRectGetMinX(self.frame) + runButton.size.width*2, y: CGRectGetMinY(self.frame) + runButton.size.height)
        }
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
    
    func addKeyIcon(lefty:Bool) -> SKSpriteNode{
        let keyImage = UIImage(named: "apple")
        let texture = SKTexture(image: keyImage!)
        let keyIcon = SKSpriteNode(texture: texture)
        
        var x:CGFloat = 0
        if(lefty){
            x = 40
        }else{
            x = CGRectGetMaxX(self.frame)-CGFloat(40)
        }
        keyIcon.position = CGPoint(x: x, y: CGRectGetMaxY(self.frame)*0.85)
        keyIcon.name = "keyIcon"
        keyIcon.size = CGSize(width: keyIcon.size.width/2, height: keyIcon.size.height/2)
        key = keyIcon
        
        return keyIcon
    }
    
    func addAttackButton(lefty:Bool) -> SKSpriteNode{
        let attackImage = UIImage(named: "sword")
        let texture = SKTexture(image: attackImage!)
        let attackButton = SKSpriteNode(texture: texture)
        attackButton.size.width = CGRectGetMaxX(self.frame)/10
        attackButton.size.height = attackButton.size.width
        
        attackButton.position = CGPoint(x: CGRectGetMaxX(self.frame) - attackButton.size.width*2, y: CGRectGetMinY(self.frame) + attackButton.size.height)
        if(lefty){
            attackButton.position = CGPoint(x: CGRectGetMinX(self.frame) + attackButton.size.width, y: CGRectGetMinY(self.frame) + attackButton.size.height)
        }
        attackButton.zPosition = 3
        attackButton.name = "AttackButton"
        attackButton.hidden = true
        
        return attackButton
    }
    
    func addDefenseButton(lefty:Bool) -> SKSpriteNode{
        let defenseImage = UIImage(named: "DefenseButton")
        let texture = SKTexture(image: defenseImage!)
        let defenseButton = SKSpriteNode(texture: texture)
        defenseButton.size.width = CGRectGetMaxX(self.frame)/10
        defenseButton.size.height = defenseButton.size.width
        
        defenseButton.position = CGPoint(x: CGRectGetMaxX(self.frame) - defenseButton.size.width, y: CGRectGetMinY(self.frame) + defenseButton.size.height)
        if(lefty){
            defenseButton.position = CGPoint(x: CGRectGetMinX(self.frame) + defenseButton.size.width*2, y: CGRectGetMinY(self.frame) + defenseButton.size.height)
        }
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
                    run = !fight
                    if(!run){console.text = "You try to run, but the monster blocks your path."}
                    else{
                        // change player heading for running direction
                        app.player.headingNum = app.player.headingNum+2%4
                        app.player.setHeading()
                        let heading = app.player.heading
                        let newPos:CGPoint
                        if(heading == "South"){
                            newPos = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMaxY(self.frame) * 0.25 + UIImage(named: "character")!.size.height)
                        }else if(heading == "West"){
                            newPos = CGPointMake(CGRectGetMaxX(self.frame) * 0.25 + UIImage(named: "character")!.size.width, CGRectGetMidY(self.frame))
                        }else if(heading == "North"){
                            newPos = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame) * 0.75 - UIImage(named: "character")!.size.height)
                        }else{
                            newPos = CGPointMake(CGRectGetMaxX(self.frame) * 0.75 - UIImage(named: "character")!.size.width, CGRectGetMidY(self.frame))
                        }
                        player!.position = newPos
                    }
                    print("RUUUNNN")
                    print(app.currentRoom.toString())
                    roomName.text = app.currentRoom.name
                    generateDoors()
                }
                else if name == "AttackButton"
                {
                    let health:Int = app.player.skills["Health"]!
                    fightOver = app.fightMonsterIOS(activeMonster!, attack: true, console: console)
                    
                    //See if life changed. If it did, damamge was taken
                    if("\(app.player.skills["Health"]!)" != livesText.text){

                        if(playSounds){
                            SKTAudio.sharedInstance().playSoundEffect("damageTaken.wav")
                        }
                    }else{
                        if(playSounds){
                            SKTAudio.sharedInstance().playSoundEffect("attack.wav")
                        }
                    }
                    
                    livesText.text = "\(app.player.skills["Health"]!)"
                    if(health > app.player.skills["Health"]!){
                        let action1 = SKAction.runBlock({self.livesText.fontColor = UIColor.whiteColor()})
                        let action2 = SKAction.runBlock({self.livesText.fontColor = UIColor.blackColor()})
                        let wait = SKAction.waitForDuration(0.5)
                        livesText.runAction(SKAction.sequence([action1,wait,action2]))
                    }
                }
                else if name == "DefenseButton"
                {
                    let health:Int = app.player.skills["Health"]!
                    fightOver = app.fightMonsterIOS(activeMonster!, attack: false, console: console)
                    
                    //See if life changed. If it did, damamge was taken
                    if("\(app.player.skills["Health"]!)" != livesText.text){
                        if(playSounds){
                            SKTAudio.sharedInstance().playSoundEffect("damageTaken.wav")
                        }
                    }else{
                        if(playSounds){
                            SKTAudio.sharedInstance().playSoundEffect("defend.wav")
                        }
                    }
                    
                    livesText.text = "\(app.player.skills["Health"]!)"
                    if(health > app.player.skills["Health"]!){
                        let action1 = SKAction.runBlock({self.livesText.fontColor = UIColor.whiteColor()})
                        let action2 = SKAction.runBlock({self.livesText.fontColor = UIColor.blackColor()})
                        let wait = SKAction.waitForDuration(0.5)
                        livesText.runAction(SKAction.sequence([action1,wait,action2]))
                    }
                }
                else if name == "MapButton"
                {
                    displayMap()
                }
                else if name == "InventoryButton"
                {
                    displayInventory()
                }
                else if name == "ExitButton"
                {
                    let alert = UIAlertView(title: "Quit", message: "Are you sure you want to quit?", delegate: self, cancelButtonTitle: "No", otherButtonTitles: "Yes")
                    alert.tag = 94
                    alert.show()
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
    
    override func willMoveFromView(view: SKView) {
        scene?.removeAllActions()
        scene?.removeAllChildren()
        scene?.removeFromParent()
    }
    
    func displayMap(){
        let alert = UIAlertView(title: "Map", message: "", delegate: self, cancelButtonTitle: "Done")
        let message = UILabel()
        message.font = UIFont(name: "Courier New", size: 13)
        message.numberOfLines = 0
        message.text = app.printLayout()
        message.textAlignment = .Center
        alert.setValue(message, forKey: "accessoryView")
        alert.show()
    }
    
    func displayInventory(){
        let alert = UIAlertView(title: "Inventory", message: "", delegate: self, cancelButtonTitle: "Done")
        let tableView = UITableView(frame: CGRectMake(0, 0, 320, 200), style: .Plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        alert.setValue(tableView, forKey: "accessoryView")
        alert.show()
    }
    
    func checkForHerbs(){
        var herbs:Bool = false;
        for item in app.player.currentItems {
            if(item.name == "\"Herbs\""){
                if(!herbsAction){addCircles()}
                herbs = true
                herbsAction = true
                break
            }
        }
        if(!herbs && herbsAction){
            removeActionForKey("herbs")
            for child in children {
                if(child.name?.rangeOfString("ball") != nil){
                    child.removeFromParent()
                    let wait = SKAction.waitForDuration(0.5)
                    runAction(wait)
                    herbsAction = false
                }
            }
        }
    }
    
    func handleDoor(door: Int) -> Bool{
        print("handling door method")
        checkForHerbs()
        updateSkills()
        var validDoor = true
        if(app.currentRoom.attachedRooms[door-1] == nil){
            // door is value
            app.player.headingNum = (door+1)%4
            app.player.setHeading()
            print("")
            let location:Point = app.calcLocation()
            print("got location")
            if(location.x <= 7 && location.x >= -7 && location.y <= 7 && location.y >= -7){
                print("in house")
                // inside the house layout
                if(app.houseLayout[location.y+7][location.x+7] == nil){
                    // door leads to undiscovered room
                    print("here")// error in here
                    app.createRoom(door-1)
                    print("created room")
                    let newRoom:Room = app.houseLayout[location.y+7][location.x+7]! as Room
                    print("items?")
                    swapItem(newRoom)
                    print("done items")
                    if(newRoom.happening != nil){
                        console.text = "\(newRoom.happening!.name): \(newRoom.happening!.description) \(newRoom.happening!.effect.description)"
                        print(newRoom.happening!.effect.description)
                        if(newRoom.happening!.effect.description == "Lose an item" && app.player.currentItems.count > 0){
                            if(playSounds){
                                SKTAudio.sharedInstance().playSoundEffect("monkey.wav")
                            }
                            loseItem()
                        }
                    }else{
                       console.text = "No Happening"
                    }
                    print("effects")
                    app.processEffects()
                    updateSkills()
                    print("done effects")
                    if(app.unopenedDoors != 0){
                        activeMonster = app.generateMonster()
                    }
                    print("gen monster")
                    app.unopenedDoors--
                    print("doors changed")
                }else{
                    print("room exists")
                    // a room exists at this location
                    let roomAtLocation:Room = app.houseLayout[location.y+7][location.x+7]!
                    if(roomAtLocation.name == "EMPTY" || (roomAtLocation.attachedRooms[(door+1)%4] != nil && roomAtLocation.attachedRooms[(door+1)%4]!.name == "EMPTY")){
                        // not a valid room placement like (0,-1) or this door is a false door
                        print("The door will not open, weird")
                        console.text = "The door will not open, weird"
                        app.updateFalseDoor(door-1)
                        validDoor = false
                        app.unopenedDoors--
                    }else{
                        print("room visited")
                        // room has been visited and is not a special room
                        app.applyVisitedRoom(roomAtLocation, door: door-1)
                        print("This room looks oddly familiar.")
                        activeMonster = app.checkForMonsters()
                        console.text = "This room looks oddly familiar"
                        app.unopenedDoors-=2 // becaus they were connecting doors that had not been opened
                    }
                }
            }else{
                // outside of range of house
                print("outside house")
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
            print("already discovered 2")
            app.currentRoom = app.currentRoom.attachedRooms[door-1]!
            app.player.headingNum = (door+1)%4
            app.player.setHeading()
            activeMonster = app.checkForMonsters()
            console.text = ""
        }
        if(activeMonster != nil){
            print("monster?")
            handleMonster()
            print("after monster")
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
        print("done handling door method")
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
            
            guard let aN = self.player else { return }
            
            aN.position = CGPointMake(aN.position.x + (analogStick.data.velocity.x * 0.08), aN.position.y + (analogStick.data.velocity.y * 0.08))
            aN.zRotation = analogStick.data.angular
            
        }
    }
    
    var tryToAttack = false
    var tryToRun = false
    func handleMonster(){
        if(playSounds){
           SKTAudio.sharedInstance().playSoundEffect("monster.wav")
        }
        
        moveAnalogStick.trackingHandler = { analogStick in
            
            guard let aN = self.player else { return }
            
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
        console.text = "You encounter a monster! \(activeMonster!.toString())"
    }
    
    func battleDone(){
        moveAnalogStick.hidden = false
        moveAnalogStick.trackingHandler = { analogStick in
            
            guard let aN = self.player else { return }
            
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
        player?.removeFromParent()
        for child in self.children as [SKNode] {
            if (child.name == "1" || child.name == "2" || child.name == "3" || child.name == "4") {
                self.removeChildrenInArray([child])
            }
        }
        SKTAudio.sharedInstance().pauseBackgroundMusic()
        let transition = SKTransition.revealWithDirection(.Down, duration: 0.5)
        
        let nextScene = GameOverScene(fileNamed: "GameOverScene")
        
        if(app.hasWon){
            print("----- YOU WIN! -----")
            print("Thank you for playing!")
            nextScene?.winningMessage = "YOU WIN!"
            nextScene?.message = "Thank you for playing!"
        }else if(app.player.hasKey){
            print("You die attempting to escape the house.")
            print("----- YOU LOSE -----")
            nextScene?.winningMessage = "YOU LOSE"
            nextScene?.message = "You die attempting to escape the house."
        }else{
            print("You die searching. Maybe the key was never there.")
            print("----- YOU LOSE -----")
            nextScene?.winningMessage = "YOU LOSE"
            nextScene?.message = "You die searching. Maybe the key was never there."
        }
        
        
        nextScene!.scaleMode = .AspectFill
        
        scene?.view?.presentScene(nextScene!, transition: transition)
        
    }
    
    func swapItem(room:Room){
        // prompt user for item pickup if room contains item
        currentItem = room.item
        if(currentItem != nil){
            if(playSounds){
                SKTAudio.sharedInstance().playSoundEffect("itemFound.mp3")
            }
            
            let alert:UIAlertView
            print("Count: \(app.player.currentItems.count)")
            let type = currentItem!.type as String
            var color:UIColor = UIColor.orangeColor()
            switch(type){
                case "Attack"://red
                    color = UIColor(red: 255.0/255, green: 105.0/255, blue: 97.0/255, alpha: 1.0)
                case "Defense"://blue
                    color = UIColor(red: 174.0/255, green: 198.0/255, blue: 203.0/255, alpha: 1.0)
                case "Stealth"://grey
                    color = UIColor(red: 207.0/255, green: 207.0/255, blue: 196.0/255, alpha: 1.0)
                case "Luck"://green
                    color = UIColor(red: 119.0/255, green: 190.0/255, blue: 119.0/255, alpha: 1.0)
                case "Evasion"://purple
                    color = UIColor(red: 179.0/255, green: 158.0/255, blue: 181.0/255, alpha: 1.0)
                case "Sanity"://yellow
                    color = UIColor(red: 253.0/255, green: 253.0/255, blue: 150.0/255, alpha: 1.0)
                default://pink
                    color = UIColor(red: 255.0/255, green: 209.0/255, blue: 220.0/255, alpha: 1.0)
            }
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
                v.backgroundColor = color
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
                v.backgroundColor = color
                v.translatesAutoresizingMaskIntoConstraints = true
                alert.setValue(v, forKey: "accessoryView")
                if(currentItem!.type != "Other"){
                    app.player.currentItems.append(currentItem!)
                }
                app.player.items.append(currentItem!)
                app.newEffects.append(currentItem!.effect)
                if(currentItem!.name == "Key"){
                    keyFound()
                }
                currentItem = nil
                let health:Int = app.player.skills["Health"]!
                livesText.text = "\(app.player.skills["Health"]!)"
                if(health < app.player.skills["Health"]!){
                    let action1 = SKAction.runBlock({self.livesText.fontColor = UIColor.whiteColor()})
                    let action2 = SKAction.runBlock({self.livesText.fontColor = UIColor.blackColor()})
                    let wait = SKAction.waitForDuration(0.5)
                    livesText.runAction(SKAction.sequence([action1,wait,action2]))
                }
            }
            alert.show()
        }
    }
    
    func loseItem(){
        let alert = UIAlertView(title: "Inventory", message: "Pick an item to give up.", delegate: self, cancelButtonTitle: "Drop")
        let picker = UIPickerView()
        picker.delegate = self
        if(currentItem != nil){
            app.player.currentItems.append(currentItem!)
            app.player.items.append(currentItem!)
            app.newEffects.append(currentItem!.effect)
            app.processEffects()
            updateSkills()
        }
        picker.dataSource = self
        alert.setValue(picker, forKey: "accessoryView")
        alert.tag = 888
        alert.show()
    }
    
    func keyFound(){
        key.texture = SKTexture(image: UIImage(named: "character")!)
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
                loseItem()
            }
            updateSkills()
        }else if(alertView.tag == 888){
            print(selectedDropItem)
            print(app.player.currentItems)
            print(app.player.currentItems[selectedDropItem].toString())
            let removedItem:Item = app.player.currentItems[selectedDropItem]
            app.player.currentItems.removeAtIndex(selectedDropItem)
            let index:Int? = app.player.items.indexOf(removedItem)
            print(index)
            if(index != nil){app.player.items.removeAtIndex(index!)}
            let effectIndex:Int? = app.player.currentEffects.indexOf(removedItem.effect)
            print(effectIndex)
            if(effectIndex != nil){
                let effect:Effect = app.player.currentEffects[effectIndex!]
                print(effect)
                app.player.currentEffects.removeAtIndex(effectIndex!)
                app.player.skills[removedItem.type]! -= Int.init(effect.description.componentsSeparatedByString(" ")[0][1])!
            }
            currentItem = nil
            selectedDropItem = 0
            updateSkills()
        }else if(alertView.tag == 94){
            print("exiting?")
            if(buttonIndex == 0){
                // nothing, do not exit
            }else{
                // exiting
                SKTAudio.sharedInstance().pauseBackgroundMusic()
                let transition = SKTransition.revealWithDirection(.Down, duration: 0.5)
                
                let nextScene = MainMenuScene(fileNamed: "MainMenuScene")
                nextScene!.scaleMode = .AspectFill
                
                scene?.view?.presentScene(nextScene!, transition: transition)
            }
        }
        updateSkills()
    }
    
    func numberOfComponentsInPickerView(colorPicker: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return app.player.currentItems.count
    }
    
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
        itemName.text = app.player.currentItems[row].name
        
        let itemEffect:UILabel = v.viewWithTag(222) as! UILabel
        itemEffect.text = app.player.currentItems[row].effect.description
        
        v.sizeToFit()
        
        return v
    }
    
    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 50
    }
    
    func restartGame(){
        let action1 = SKAction.runBlock({
            self.moveAnalogStick.trackingHandler = { analogStick in
                
                guard let aN = self.player else { return }
                
                aN.position = aN.position
            }
            let cover:SKShapeNode = SKShapeNode(rect: CGRectMake(0, 0, self.frame.width, self.frame.height))
            cover.name = "cover"
            cover.fillColor = UIColor.blackColor()
            cover.zPosition = 100
            cover.alpha = 0;
            self.addChild(cover)
        })
        let action2 = SKAction.runBlock({self.removeChildrenInArray([self.childNodeWithName("cover")!])
            self.moveAnalogStick.trackingHandler = { analogStick in
                
                guard let aN = self.player else { return }
                
                aN.position = CGPointMake(aN.position.x + (analogStick.data.velocity.x * 0.08), aN.position.y + (analogStick.data.velocity.y * 0.08))
                aN.zRotation = analogStick.data.angular
            }})
        let fadeIn = SKAction.runBlock({self.childNodeWithName("cover")?.runAction(SKAction.fadeInWithDuration(0.5))})
        let wait = SKAction.waitForDuration(2.0)
        let fadeOut = SKAction.runBlock({self.childNodeWithName("cover")?.runAction(SKAction.fadeOutWithDuration(2.0))})
        self.runAction(SKAction.sequence([action1,fadeIn,wait,fadeOut,wait,action2]))
        
        let player = app.player
        app = IOSApp()
        app.player = player
        console.text = "You lay down to rest, and wake up to find the rooms rearranged."
        app.player.headingNum = 0
        app.player.heading = "North"
        app.unopenedDoors = 3
        
        
    }
    
    func generateDoors(){
        print("generating doors")
        for child in self.children as [SKNode] {
            if (child.name == "1" || child.name == "2" || child.name == "3" || child.name == "4") {
                self.removeChildrenInArray([child])
            }
        }
        if(app.currentRoom.attachedRooms[0] == nil || app.currentRoom.attachedRooms[0]!.name != "EMPTY"){
            addChild(addDoor(CGPointMake(CGRectGetMidX(self.frame),CGRectGetMaxY(self.frame) * 0.25),value: 1, undiscovered: app.currentRoom.attachedRooms[0] == nil))
        }
        if(app.currentRoom.attachedRooms[1] == nil || app.currentRoom.attachedRooms[1]!.name != "EMPTY"){
            addChild(addDoor(CGPointMake(CGRectGetMaxX(self.frame) * 0.3, CGRectGetMidY(self.frame)),value: 2, undiscovered: app.currentRoom.attachedRooms[1] == nil))
        }
        if(app.currentRoom.attachedRooms[2] == nil || app.currentRoom.attachedRooms[2]!.name != "EMPTY"){
            addChild(addDoor(CGPointMake(CGRectGetMidX(self.frame), CGRectGetMaxY(self.frame) * 0.75),value: 3, undiscovered: app.currentRoom.attachedRooms[2] == nil))
        }
        if(app.currentRoom.attachedRooms[3] == nil || app.currentRoom.attachedRooms[3]!.name != "EMPTY"){
            addChild(addDoor(CGPointMake(CGRectGetMaxX(self.frame) * 0.7, CGRectGetMidY(self.frame)),value: 4, undiscovered: app.currentRoom.attachedRooms[3] == nil))
        }
        print("Done generating")
    }
    
    func updatePlayerClass(){
        print(playerClass)
        let path = NSBundle.mainBundle().pathForResource("gameData", ofType: "plist")
        let properties = NSDictionary(contentsOfFile: path!)
        let classes = properties!.objectForKey("Classes") as! Array<Array<AnyObject>>
        var pClass = Array<AnyObject>()
        for class1 in classes{
            if(class1[0] as! String == playerClass){
                pClass = class1
                break
            }
        }
        app.player.skills["Attack"]! = Int(pClass[1] as! NSNumber)
        app.player.skills["Defense"]! = Int(pClass[2] as! NSNumber)
        app.player.skills["Stealth"]! = Int(pClass[3] as! NSNumber)
        app.player.skills["Evasion"]! = Int(pClass[4] as! NSNumber)
        app.player.skills["Luck"]! = Int(pClass[5] as! NSNumber)
        app.player.skills["Sanity"]! = Int(pClass[6] as! NSNumber)
        updateSkills()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return app.player.currentItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellIdentifier = "cell"
        
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)! as UITableViewCell
        cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: cellIdentifier)
        
        let item = app.player.currentItems[indexPath.row]
        
        cell.textLabel?.text = item.name
        cell.detailTextLabel?.text = item.effect.description
        
        let type = item.type
        var color:UIColor = UIColor.whiteColor()
        switch(type){
            case "Attack"://red
                color = UIColor(red: 255.0/255, green: 105.0/255, blue: 97.0/255, alpha: 1.0)
            case "Defense"://blue
                color = UIColor(red: 174.0/255, green: 198.0/255, blue: 203.0/255, alpha: 1.0)
            case "Stealth"://grey
                color = UIColor(red: 207.0/255, green: 207.0/255, blue: 196.0/255, alpha: 1.0)
            case "Luck"://green
                color = UIColor(red: 119.0/255, green: 190.0/255, blue: 119.0/255, alpha: 1.0)
            case "Evasion"://purple
                color = UIColor(red: 179.0/255, green: 158.0/255, blue: 181.0/255, alpha: 1.0)
            case "Sanity"://yellow
                color = UIColor(red: 253.0/255, green: 253.0/255, blue: 150.0/255, alpha: 1.0)
            default://pink
                color = UIColor(red: 255.0/255, green: 209.0/255, blue: 220.0/255, alpha: 1.0)
            
        }
        cell.backgroundColor = color
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("You selected cell #\(indexPath.row)!")
    }
    
    deinit {
        // store game?
        print("game gone")
    }
}

extension UIColor {
    
    static func random() -> UIColor {
        
        return UIColor(red: CGFloat(drand48()), green: CGFloat(drand48()), blue: CGFloat(drand48()), alpha: 1)
    }
}