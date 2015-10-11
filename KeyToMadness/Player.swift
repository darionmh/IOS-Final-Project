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
    var currentHappenings:[Happening]
    var itemImmunity:Bool
    var hasKey:Bool
    var headingNum:Int
    var heading:String
    
    init() {
        self.skills = Dictionary<String, Int>()
        skills["Strength"] = 0
        skills["Stamina"] = 0
        skills["Smarts"] = 0
        skills["Sanity"] = 0
        skills["Health"] = 8
        self.currentEffects = []
        self.items = []
        self.currentHappenings = []
        self.itemImmunity = false
        self.hasKey = false
        self.headingNum = 0
        self.heading = "North"
    }
    
    func isPlayerAlive() -> Bool {
        //for (_, value) in skills {
        //    if(value <= 0){ return false }
        //}
        //return true
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