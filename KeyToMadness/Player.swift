//
//  Player.swift
//  KeyToMadness
//
//  Created by Alexis Forbes on 10/8/15.
//  Copyright © 2015 Alexis Forbes. All rights reserved.
//

import Foundation

public class Player {
    var skills:Dictionary<String, Int>
    var currentEffects:[Effect]
    var items:[Item]
    var currentItems:Array<Item?>
    var currentHappenings:[Happening]
    var itemImmunity:Bool
    var hasKey:Bool
    var headingNum:Int
    var heading:String
    var fightMultiplier:Int
    var inventorySpace:Int
    
    init() {
        self.skills = Dictionary<String, Int>()
        skills["Attack"] = 0  // attacking monsters
        skills["Defense"] = 0 // defending monster attacks
        skills["Luck"] = 0    // finding items
        skills["Sanity"] = 0  // generation of happenings
        skills["Stealth"] = 0 // avoiding monsters
        skills["Evasion"] = 0 // escaping monsters
        skills["Health"] = 8
        self.currentEffects = []
        self.items = []
        self.currentHappenings = []
        self.itemImmunity = false
        self.hasKey = false
        self.headingNum = 0
        self.heading = "North"
        self.fightMultiplier = 1
        self.currentItems = []
        self.inventorySpace = 5
    }
    
    func isPlayerAlive() -> Bool {
        return skills["Health"] > 0
    }
    
    func setHeading() {
        if(headingNum == 0){
            heading = "North"
        }else if(headingNum == 1){
            heading = "East"
        }else if(headingNum == 2){
            heading = "South"
        }else if(headingNum == 3){
            heading = "West"
        }
    }
    
}