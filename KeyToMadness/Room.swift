//
//  Room.swift
//  KeyToMadness
//
//  Created by Alexis Forbes on 10/8/15.
//  Copyright © 2015 Alexis Forbes. All rights reserved.
//

import Foundation

public class Room {
    var name:String
    var attachedRooms:[Room?]
    var numAttachedRooms:Int
    var previousRoom:Room?
    var item:Item?
    var happening:Happening?
    var location:Point
    
    init() {
        self.name = "EMPTY"
        self.attachedRooms = [nil]
        self.numAttachedRooms = 0
        self.previousRoom = nil
        self.item = nil
        self.happening = nil
        self.location = Point(x: -100, y: -100)
    }
    
    init(name:String){
        if(!name.isEqual("Exit")){
            self.previousRoom = Room(name: "Exit")
        }else{
            self.previousRoom = nil
        }
        self.name = name
        self.item = nil
        self.happening = nil
        self.attachedRooms = [Room?](count:4, repeatedValue:nil)
        self.location = Point(x: 0, y: 0)
        self.numAttachedRooms = 3
        self.attachedRooms[0] = previousRoom
    }
    
    init(name:String, previousRoom:Room, item:Item?, happening:Happening?, heading:Int) {
        self.name = name
        self.previousRoom = previousRoom
        self.item = item
        self.happening = happening
        self.numAttachedRooms = (Int(arc4random_uniform(7))+1)/2
        self.attachedRooms = [Room?](count: 4, repeatedValue: nil)
        if(numAttachedRooms == 1){
            var emptyRoom1:Int
            var emptyRoom2:Int
            repeat{
                emptyRoom1 = Int(arc4random_uniform(4))
            }while(emptyRoom1 == heading)
            repeat{
                emptyRoom2 = Int(arc4random_uniform(4))
            }while(emptyRoom2 == emptyRoom1 || emptyRoom2 == heading)
            self.attachedRooms[emptyRoom1] = Room()
            self.attachedRooms[emptyRoom2] = Room()
        }else if(numAttachedRooms == 2){
            var emptyRoom1:Int
            repeat{
                emptyRoom1 = Int(arc4random_uniform(4))
            }while(emptyRoom1 == heading)
            self.attachedRooms[emptyRoom1] = Room()
        }else if(numAttachedRooms == 0){
            for(var i = 0; i<attachedRooms.count; i++){
                if(i != heading){
                    attachedRooms[i] = Room()
                }
            }
        }
        attachedRooms[heading] = previousRoom
        var x:Int = previousRoom.location.x
        var y:Int = previousRoom.location.y
        if(heading == 0){
            y++
        }else if(heading == 1){
            x++
        }else if(heading == 2){
            y--
        }else{
            x--
        }
        self.location = Point(x: x, y: y)
        if(x == 7 && attachedRooms[3] == nil){
            // door 4 is out of bounds
            numAttachedRooms--
            attachedRooms[3] = Room()
        }
        if(x == -7 && attachedRooms[1] == nil){
            // door 2 is out of bounds
            numAttachedRooms--
            attachedRooms[1] = Room()
        }
        if(y == 7 && attachedRooms[2] == nil){
            // door 3 is out of bounds
            numAttachedRooms--
            attachedRooms[2] = Room()
            
        }
        if(y == -7 && attachedRooms[0] == nil){
            // door 1 is out of bounds
            numAttachedRooms--
            attachedRooms[0] = Room()
            
        }
        if(x == 1 && y < 0 && attachedRooms[1] == nil){
            // pathway out of house, cant go there
            numAttachedRooms--
            attachedRooms[1] = Room()
        }
        if(x == -1 && y < 0 && attachedRooms[3] == nil){
            // pathway out of house, cant go there
            numAttachedRooms--
            attachedRooms[3] = Room()
        }
    }
    
    func setAttachedRoom(index:Int, room:Room){
        attachedRooms[index] = room;
    }
    
    func toString() -> String {
        var toString:String = ""
        toString += "-------------"
        toString += "\nRoom: \(name)"
        toString += "\nPosition: \(location.toString())"
        toString += "\nDoors: \(numAttachedRooms+1)"
        toString += "\nAttachedRooms: \(getAttachedRoomsString())"
        toString += "\nPrevious Room: \(previousRoom!.name)"
        if(item == nil){
            toString += "\nItem: None"
        }else{
            toString += "\(item!.toString())"
        }
        if(happening == nil){
            toString += "\nHappening: None"
        }else{
            toString += "\(happening!.toString())"
        }
        toString += "\n-------------\n"
        return toString
    }
    
    func getAttachedRoomsString() -> String {
        var rooms:String = "["
        for(var room = 0; room<attachedRooms.count;room++){
            rooms += "\(room+1): "
            if(attachedRooms[room] != nil){
                rooms += "\(attachedRooms[room]!.name)"
            }else{
                rooms += "Undiscovered"
            }
            if(room<attachedRooms.count-1){
                rooms += ", "
            }
        }
        rooms += "]"
        return rooms
    }
}