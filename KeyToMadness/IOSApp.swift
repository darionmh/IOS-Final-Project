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
    var goodEffectCount:Int = 0
    var badEffectCount:Int = 0
    var roomCount:Int = 0
    var happeningCount:Int = 0
    var newEffects:[Effect] = []
    var rooms:[String]
    var happenings:Array<Array<AnyObject>>
    var goodEffects:[String]
    var badEffects:[String]
    var items:Array<Array<String>>
    var roomCounter:Int = 0
    var monstersInGame:[Monster]
    
    init(){
        let path = NSBundle.mainBundle().pathForResource("gameData", ofType: "plist")
        let properties = NSDictionary(contentsOfFile: path!)
        self.rooms = properties!.objectForKey("Room") as! [String]
        self.roomCount = self.rooms.count
        self.happenings = properties!.objectForKey("Happening") as! Array<Array<AnyObject>>
        self.happeningCount = self.happenings.count
        self.goodEffects = properties!.objectForKey("GoodEffect") as! [String]
        self.goodEffectCount = self.goodEffects.count
        self.badEffects = properties!.objectForKey("BadEffect") as! [String]
        self.badEffectCount = self.badEffects.count
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
        let room:Int = Int(arc4random_uniform(UInt32(roomCount)))
        let openedRoom = Room(name: rooms[room] ,previousRoom: currentRoom ,item: generateItem(), happening: generateHappening(), heading: player.headingNum)
        houseLayout[openedRoom.location.y+7][openedRoom.location.x+7] = openedRoom
        currentRoom.setAttachedRoom(door, room: openedRoom)
        currentRoom = openedRoom
        roomCounter++
    }
    
    func generateItem() -> Item? {
        var item:Item?
        let chance:Int = Int(arc4random_uniform(20))
        if(chance < 3){
            var itemData:Array<String>
            var count:Int = 0
            repeat{
                let itemNumber:Int = Int(arc4random_uniform(UInt32(itemCount)))
                itemData = items[itemNumber]
                item = Item(name: itemData[0], description: itemData[1], effect: Effect(description: itemData[2]))
                count--
            }while((player.items.indexOf(item!) != nil || (itemData[0] == "Key" && roomCounter < 10)) && count > 0)
            if(player.items.indexOf(item!) == nil && !(player.itemImmunity && itemData[2].componentsSeparatedByString("")[0] == "-")) {
                if(item!.name == "Key"){
                    if(roomCounter >= 10){
                        player.items.append(item!)
                        newEffects.append(Effect(description: itemData[2]))
                        player.hasKey = true
                    }else{
                        // to early for key!
                        item = nil
                    }
                }else if(item!.name == "Ring"){
                    player.itemImmunity = true
                    player.items.append(item!)
                    newEffects.append(Effect(description: itemData[2]))
                }else{
                    player.items.append(item!)
                    newEffects.append(Effect(description: itemData[2]))
                }
            }else if(player.itemImmunity && itemData[2].componentsSeparatedByString("")[0] == "-"){
                print("Your ring gets hot, better not take the item in this room.")
                item = nil
            }else if(player.items.indexOf(item!) != nil){
                print("Already recieved that item")
                item = nil
                
            }
        }
        return item
    }
    
    func generateHappening() -> Happening? {
        var happening:Happening?
        let chance:Int = Int(arc4random_uniform(5))
        if(chance == 0){
            let happeningNum:Int = Int(arc4random_uniform(UInt32(happeningCount)))
            var happeningData:Array<AnyObject> = happenings[happeningNum]
            let effect:String = happeningData[3] as! String
            happening = Happening(good: happeningData[0] as! Bool, name: happeningData[1] as! String, description: happeningData[2] as! String, effect: Effect(description: effect))
            player.currentHappenings.append(happening!)
            newEffects.append(Effect(description: effect))
            
        }
        return happening
    }
    
    func processEffects() {
        for effect in newEffects {
            let parts:[String] = effect.description.componentsSeparatedByString(" ")
            let skill:String = parts[1]
            let char:String = parts[0].componentsSeparatedByString("")[0]
            let buff:Bool = char == "+"
            let deBuff:Bool = char == "-"
            if(buff){
                let x:Int = (player.skills[skill])!+1
                player.skills[skill] = x
            }else if(deBuff){
                let x:Int = (player.skills[skill])!-1
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
                    print(" ", terminator:"")
                    map += " "
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
        let chance:Int = Int(arc4random_uniform(10))
        if(chance == 0){
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
    
    func fightMonsterIOS(monster:Monster, attack:Bool) -> Bool {
        var playerAction:Int
        var monsterAttack:Int
        var dodge:Bool
        print("attacking: \(attack)")
        if(attack){
            playerAction = (Int(arc4random_uniform(6)) + player.skills["Attack"]!)*player.fightMultiplier
            monsterAttack = Int(arc4random_uniform(6))
            dodge = false
        }else{
            playerAction = Int(arc4random_uniform(6)) + player.skills["Defense"]!
            monsterAttack = Int(arc4random_uniform(6))
            dodge = true
        }
        if(playerAction >= monsterAttack && dodge){
            // player dodged, no effect
            print("You dodge the attack, gaining increasing your multiplier")
            player.fightMultiplier++
        }else if(playerAction >= monsterAttack && !dodge){
            // player attacked, subtract difference from the monsters health
            monster.health = monster.health - (playerAction - monsterAttack)
            print("Monster takes \(playerAction - monsterAttack) damage")
        }else{
            // player fails to beat monsters attack, subtract difference from player health and reset multiplier
            player.skills["Health"] = player.skills["Health"]! - (monsterAttack - playerAction)
            player.fightMultiplier = 1
            print("Player takes \(monsterAttack - playerAction) damage. Multiplier reset to 1.")
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