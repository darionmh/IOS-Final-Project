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
    //var properties
    var player:Player
    var itemCount:Int = 0
    var goodEffectCount:Int = 0
    var badEffectCount:Int = 0
    var roomEffectCount:Int = 0
    var roomCount:Int = 0
    var happeningCount:Int = 0
    var newEffects:[Effect] = []
    var rooms:[String]
    var happenings:Array<Array<AnyObject>>
    var goodEffects:[String]
    var badEffects:[String]
    var roomEffects:[String]
    var items:Array<Array<String>>
    
    init(){
        //let path = NSBundle.mainBundle().pathForResource("test", ofType: "plist")
        let path1 = NSSearchPathForDirectoriesInDomains(.DownloadsDirectory, .UserDomainMask, true)[0]
        //print(path)
        let properties = NSDictionary(contentsOfFile: path1+"/AndrewIOS/IOSAppConsole/IOSAppConsole/test.plist")
        self.rooms = properties!.objectForKey("Room") as! [String]
        self.roomCount = self.rooms.count
        self.happenings = properties!.objectForKey("Happening") as! Array<Array<AnyObject>>
        self.happeningCount = self.happenings.count
        self.goodEffects = properties!.objectForKey("GoodEffect") as! [String]
        self.goodEffectCount = self.goodEffects.count
        self.badEffects = properties!.objectForKey("BadEffect") as! [String]
        self.badEffectCount = self.badEffects.count
        self.roomEffects = properties!.objectForKey("RoomEffect") as! [String]
        self.roomEffectCount = self.roomEffects.count
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
        for(var i = y; i>=0;i--){
            houseLayout[y--][x] = Room()
        }
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
        let room:Int = Int(arc4random_uniform(UInt32(roomCount)))+1
        let openedRoom = Room(name: rooms[room] ,previousRoom: currentRoom ,item: generateItem(), happening: generateHappening(), effect: generateRoomEffect(), heading: player.headingNum)
        houseLayout[openedRoom.location.y+7][openedRoom.location.x+7] = openedRoom
        currentRoom.setAttachedRoom(door, room: openedRoom)
        currentRoom = openedRoom
    }
    
    func generateItem() -> Item? {
        var item:Item?
        let chance:Int = Int(arc4random_uniform(20))
        if(chance < 3){
            var itemData:Array<String>
            var count:Int = 0
            repeat{
                let itemNumber:Int = Int(arc4random_uniform(UInt32(itemCount))+1)
                itemData = items[itemNumber]
                item = Item(name: itemData[0], description: itemData[1], effect: Effect(description: itemData[2]))
                count--
            }while(player.items.indexOf(item!) != nil && count > 0)
            if(player.items.indexOf(item!) == nil && !(player.itemImmunity && itemData[2].componentsSeparatedByString("")[0] == "-")) {
                player.items.append(item!)
                newEffects.append(Effect(description: itemData[2]))
                if(item!.name == "Key"){
                    player.hasKey = true
                }else if(item!.name == "Ring"){
                    player.itemImmunity = true
                }
            }
        }
        return item
    }
    
    func generateHappening() -> Happening? {
        var happening:Happening?
        let chance:Int = Int(arc4random_uniform(5))
        if(chance == 0){
            let happeningNum:Int = Int(arc4random_uniform(UInt32(happeningCount)))+1
            var happeningData:Array<AnyObject> = happenings[happeningNum]
            let effect:String = happeningData[3] as! String
            happening = Happening(good: happeningData[0] as! Bool, name: happeningData[1] as! String, description: happeningData[2] as! String, effect: Effect(description: effect))
            player.currentHappenings.append(happening!)
            newEffects.append(Effect(description: effect))
            
        }
        return happening
    }
    
    func generateRoomEffect() -> Effect? {
        var effect:Effect?
        let chance:Int = Int(arc4random_uniform(10));
        if(chance == 0){
            let effectNumber = Int(arc4random_uniform(UInt32(roomEffectCount)))+1
            let effectData:String = roomEffects[effectNumber]
            effect = Effect(description: effectData)
            newEffects.append(effect!)
        }
        return effect
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
    
    func printLayout() {
        for(var i = houseLayout.count-1; i >= 0; i--){
            print("[", terminator:"")
            for(var j = 0; j < houseLayout[i].count; j++){
                if(houseLayout[i][j] != nil){
                    if(currentRoom.location.x+7 == j && currentRoom.location.y+7 == i){
                        // player location
                        print("P", terminator:"")
                    }else if(i == 7 && j == 7){
                        // starting room
                        print("S", terminator:"")
                    }else{
                        print("X", terminator:"")
                    }
                }else{
                    print(" ", terminator:"")
                }
                if(j < houseLayout[i].count-1){
                    print(",", terminator:"")
                }
            }
            print("]")
        }
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
}