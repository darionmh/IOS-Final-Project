//
//  MainApp.swift
//  KeyToMadness
//
//  Created by Alexis Forbes on 10/8/15.
//  Copyright © 2015 Alexis Forbes. All rights reserved.
//

import Foundation

public class IOSApp {
    var houseLayout:Array<Array<Room?>> = Array<Array<Room?>>()
    var hasWon:Bool = false
    var currentRoom:Room
    var player:Player
    var itemCount:Int = 0
    var roomCount:Int = 0
    var happeningCount:Int = 0
    var newEffects:[Effect] = []
    var rooms:[String]
    var happenings:Array<Array<AnyObject>>
    var items:Array<Array<String>>
    var roomCounter:Int = 0
    var monstersInGame:[Monster]
    var unopenedDoors:Int = 0
    
    init(){
        let path = NSBundle.mainBundle().pathForResource("gameData", ofType: "plist")
        let properties = NSDictionary(contentsOfFile: path!)
        self.rooms = properties!.objectForKey("Room") as! [String]
        self.roomCount = self.rooms.count
        self.happenings = properties!.objectForKey("Happening") as! Array<Array<AnyObject>>
        self.happeningCount = self.happenings.count
        self.items = properties!.objectForKey("Item") as! Array<Array<String>>
        self.itemCount = self.items.count
        // empty 15x15 room matrix
        for(var column = 0; column < 15; column++) {
            houseLayout.append(Array(count:15, repeatedValue:nil))
        }
        self.player = Player()
        let start:Room = Room(name: "Start")
        self.currentRoom = start
        let x:Int = currentRoom.location.x+7
        var y:Int = currentRoom.location.y+7
        houseLayout[y][x] = start
        for(var i = y; i>0;i--){
            houseLayout[--y][x] = Room()
        }
        monstersInGame = []
        unopenedDoors = 3
    }
    
    // function to take standard input
    func Input() -> NSString {
        let keyboard = NSFileHandle.fileHandleWithStandardInput()
        return NSString(data:keyboard.availableData, encoding:NSUTF8StringEncoding)!.stringByReplacingOccurrencesOfString("\n", withString: "")
    }
    
    func calcLocation() -> Point {
        var x:Int = currentRoom.location.x
        var y:Int = currentRoom.location.y
        let heading:Int = player.headingNum
        if(heading == 0){
            y++
        }else if(heading == 1){
            x++
        }else if(heading == 2){
            y--
        }else{
            x--
        }
        return Point(x: x, y: y)
    }
    
    func createRoom(door:Int) {
        print("in create room")
        let room:Int = Int(arc4random_uniform(UInt32(roomCount)))
        print("room")
        let openedRoom = Room(name: rooms[room] ,previousRoom: currentRoom ,item: generateItem(), happening: generateHappening(), heading: player.headingNum)
        print("generated room")
        houseLayout[openedRoom.location.y+7][openedRoom.location.x+7] = openedRoom
        print("placed room")
        currentRoom.setAttachedRoom(door, room: openedRoom)
        print("attached room")
        currentRoom = openedRoom
        print("updated current room")
        roomCounter++
        print("room counter inc")
        unopenedDoors += openedRoom.numAttachedRooms
        print("adding \(openedRoom.numAttachedRooms) to doors")
    }
    
    func generateItem() -> Item? {
        print("gen item")
        var item:Item?
        var luck:UInt32 = 0
        if(20-player.skills["Luck"]! <= 0){luck = 1}
        else{luck = UInt32(20-player.skills["Luck"]!)} // subtracting luck increases chance of items
        let chance:Int = Int(arc4random_uniform(luck))
        if(chance < 3 || true){
            var itemData:Array<String>
            repeat{
                let itemNumber:Int = Int(arc4random_uniform(UInt32(itemCount)))
                itemData = items[itemNumber]
                item = Item(name: itemData[0], description: itemData[1], effect: Effect(description: itemData[2]), type: itemData[3])
            }while((player.items.indexOf(item!) != nil || item!.type == "Other" || (itemData[0] == "Key" && roomCounter < 10)))
            if(player.items.indexOf(item!) == nil || item!.type == "Other") {
                print("checking item")
                print("\(item!.description) \(item!.name) \(item!.effect.description) \(item!.type)")
                if(item!.type == "Other"){
                    if(item!.name == "Key"){
                        if(roomCounter >= 10){
                            player.items.append(item!)
                            newEffects.append(Effect(description: itemData[2]))
                            player.hasKey = true
                        }else{
                            // to early for key!
                            item = nil
                        }
                    }
                    else if(item!.name == "Extra Bag"){
                        player.inventorySpace += 3
                        player.items.append(item!)
                        newEffects.append(Effect(description: itemData[2]))
                    }
                    else if(item!.effect.description[0] == "+" && item!.effect.description[3...8] == "Health"){
                        //health item
                        player.skills["Health"]! += Int.init(item!.effect.description[1])!
                    }
                }
            }else if(player.items.indexOf(item!) != nil){
                print("Already recieved that item")
                item = nil
                
            }
        }
        return item
    }
    
    func generateHappening() -> Happening? {
        print("gen happening")
        var happening:Happening?
        var sanity:UInt32 = 0
        if(player.skills["Sanity"]!+5 <= 0){sanity = 1}
        else{sanity = UInt32(player.skills["Sanity"]!+5) }// adding sanity decreases chance of happening
        let chance:Int = Int(arc4random_uniform(sanity))
        if(chance == 0){
            let happeningNum:Int = Int(arc4random_uniform(UInt32(happeningCount)))
            var happeningData:Array<AnyObject> = happenings[happeningNum]
            let effect:String = happeningData[2] as! String
            happening = Happening(name: happeningData[0] as! String, description: happeningData[1] as! String, effect: Effect(description: effect))
            player.currentHappenings.append(happening!)
            newEffects.append(Effect(description: effect))
            
        }
        return happening
    }
    
    func processEffects() {
        for effect in newEffects {
            let parts:[String] = effect.description.componentsSeparatedByString(" ")
            print(parts)
            let skill:String = parts[1]
            let char:String = parts[0][0]
            var num:String = ""
            if(parts[0].characters.count > 1){
                num = parts[0][1]
            }
            let buff:Bool = char == "+"
            let deBuff:Bool = char == "-"
            if(buff){
                let x:Int = (player.skills[skill])!+(Int.init(num))!
                player.skills[skill] = x
            }else if(deBuff){
                let x:Int = (player.skills[skill])!-(Int.init(num))!
                player.skills[skill] = x
            }
            player.currentEffects.append(effect)
        }
        newEffects.removeAll()
    }
    
    func updateFalseDoor(door:Int){
        currentRoom.setAttachedRoom(door, room: Room())
    }
    
    func applyVisitedRoom(visitingRoom:Room, door:Int){
        visitingRoom.setAttachedRoom(player.headingNum, room: currentRoom)
        currentRoom.setAttachedRoom(door, room: visitingRoom)
        currentRoom = visitingRoom
    }
    
    func showDirections() {
        print("*******************************")
        print("****** The Haunted House ******")
        print("*******************************")
        print("* The goal is simple. Escape  *")
        print("* You are in the entry of the *")
        print("** house. To escape you need **")
        print("*** to find the key. It is ****")
        print("** hidden in one of the rooms *")
        print("*** in this house. Find it. ***")
        print("* Avoid the monsters. Pick up *")
        print("** items. Some rooms you will *")
        print("* experience happenings. Good *")
        print("***** , bad, or otherwise. ****")
        print("********** Good luck **********")
        print("*******************************")
        print("\n")
        print("\n")
    }
    
    func printLayout() -> String{
        var map = ""
        var mon:Bool = false
        for(var i = houseLayout.count-1; i >= 0; i--){
            print("[", terminator:"")
            map += "["
            for(var j = 0; j < houseLayout[i].count; j++){
                if(houseLayout[i][j] != nil){
                    for monster in monstersInGame{
                        let x:Int = monster.location.location.x
                        let y:Int = monster.location.location.y
                        if(x == j && y == i){
                            print("M", terminator:"")
                            map += "M"
                            mon = true
                        }else{
                            
                        }
                    }
                    if(!mon){
                        if(currentRoom.location.x+7 == j && currentRoom.location.y+7 == i){
                            // player location
                            print("P", terminator:"")
                            map += "P"
                        }else if(i == 7 && j == 7){
                            // starting room
                            print("S", terminator:"")
                            map += "S"
                        }else{
                            print("X", terminator:"")
                            map += "X"
                        }
                    }
                }else{
                    print("_", terminator:"")
                    map += "_"
                }
                if(j < houseLayout[i].count-1){
                    print(",", terminator:"")
                    map += ","
                }
                mon = false
            }
            print("]")
            map += "]\n"
        }
        return map
    }
    
    func getPlayerMenu(menu:String) {
        switch(menu){
        case "stats":
            print("-- Player \(menu) --")
            for (key, value) in player.skills {
                print("\(key): \(value)\n")
            }
            if(player.skills.count == 0){
                print("None\n")
            }
        case "items":
            print("-- Player \(menu) --")
            for item in player.items {
                print(item.toString())
            }
            if(player.items.count == 0){
                print("None\n")
            }
        case "happenings":
            print("-- Player \(menu) --")
            for happening in player.currentHappenings {
                print(happening.toString())
            }
            if(player.currentHappenings.count == 0){
                print("None\n")
            }
        case "effects":
            print("-- Player \(menu) --")
            for effect in player.currentEffects{
                print(effect.toString())
            }
            if(player.currentEffects.count == 0){
                print("None\n")
            }
        case "exit":
            print("You give into the madness attempting to escape the house.")
            exit(0)
        case "layout":
            printLayout()
        default:
            print("\nNot a valid command!\n")
        }
        
    }
    
    func generateMonster() -> Monster? {
        var monster:Monster?
        var stealth:UInt32 = 0
        if(UInt32(player.skills["Stealth"]!+10) <= 0){stealth = 1}
        else{stealth = UInt32(player.skills["Stealth"]!+10)} // adding stealth decreases chance of a monster
        let chance:Int = Int(arc4random_uniform(stealth))
        if(chance == 0 && false){
            monster = Monster(location: currentRoom)
            monstersInGame.append(monster!)
            foundMonster = true
            print("Monster")
        }
        return monster
    }
    
    func moveMonsters() -> Monster?{
        for monster in monstersInGame{
            if(!monster.justCreated){
                var options:[Room?] = monster.location.attachedRooms
                var door:Int
                repeat{
                    door = Int(arc4random_uniform(4))
                }while(options[door] == nil || options[door]!.name == "EMPTY" || options[door]!.name == "Exit")
                monster.location = options[door]!
            }else{
                monster.justCreated = false
            }
        }
        return checkForMonsters()
    }
    
    func promptMonsterFightIOS(monster:Monster?, run:Bool) -> Bool {
        if(monster != nil && monster!.health > 0 && player.isPlayerAlive()){
            print("You encounter a monster!")
            print("You run: \(run)")
            if(run && !monster!.encountered){
                print("You escape the monster... for now")
                currentRoom = currentRoom.attachedRooms[player.headingNum%4]!//  currentRoom.previousRoom!
                let smarts:Int = player.skills["Evasion"]!
                if(smarts>0 && Int(arc4random_uniform(UInt32(smarts))) <= 0){monster!.encountered = true}
            }else if(!run){
                print("You choose to fight the monster!")
                return true
            }else if(run && monster!.encountered){
                // cannot run
                print("You try to outrun the monster, but it blocks your path.")
                return true
            }
        }
        return false
    }
    
    func fightMonsterIOS(monster:Monster, attack:Bool, console:SKMultilineLabel) -> Bool {
        var playerAction:Double
        var monsterAttack:Double
        var dodge:Bool
        print("attacking: \(attack)")
        if(attack){
            playerAction = Double((Int(arc4random_uniform(6)) + player.skills["Attack"]!*3/5))*player.fightMultiplier
            monsterAttack = Double(arc4random_uniform(6))
            dodge = false
        }else{
            playerAction = Double(Int(arc4random_uniform(6)) + player.skills["Defense"]!*3/5)
            monsterAttack = Double(arc4random_uniform(6))
            dodge = true
        }
        if(playerAction >= monsterAttack && dodge){
            // player dodged, no effect
            print("You dodge the attack, gaining increasing your multiplier")
            console.text = "You dodge the attack, gaining increasing your multiplier"
            player.fightMultiplier+=0.2
        }else if(playerAction >= monsterAttack && !dodge){
            // player attacked, subtract difference from the monsters health
            monster.health = monster.health - Int(playerAction - monsterAttack)
            print("Monster takes \(playerAction - monsterAttack) damage")
            console.text = "Monster takes \(Int(playerAction - monsterAttack)) damage"
        }else{
            // player fails to beat monsters attack, subtract difference from player health and reset multiplier
            player.skills["Health"] = player.skills["Health"]! - Int(monsterAttack - playerAction)
            player.fightMultiplier = 1
            print("Player takes \(monsterAttack - playerAction) damage. Multiplier reset to 1.")
            console.text = "Player takes \(Int(monsterAttack - playerAction)) damage. Multiplier reset to 1."
        }
        if(monster.health <= 0 || !player.isPlayerAlive()){
            print("Battle over player: \(player.isPlayerAlive()) monster: \(monster.health)")
            print("Someones dead")
            return true
        }
        return false
    }

    
    var foundMonster = false
    
    func checkForMonsters() -> Monster?{
        var count:Int = 0;
        for monster in monstersInGame{
            let x:Int = monster.location.location.x
            let y:Int = monster.location.location.y
            if(currentRoom.location.x == x && currentRoom.location.y == y){
                print("Monster")
                foundMonster = true
                monstersInGame.removeAtIndex(count)
                return monster
            }
            count++
        }
        return nil
    }
    
}

extension String {
    
    subscript (i: Int) -> Character {
        return self[self.startIndex.advancedBy(i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        return substringWithRange(Range(start: startIndex.advancedBy(r.startIndex), end: startIndex.advancedBy(r.endIndex)))
    }
}