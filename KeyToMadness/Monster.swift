//
//  Monster.swift
//  KeyToMadness
//
//  Created by Alexis Forbes on 10/8/15.
//  Copyright © 2015 Alexis Forbes. All rights reserved.
//

import Foundation

class Monster {
    var location:Room
    var name:String
    var health:Int
    var level:Int
    var strength:Int
    var encountered:Bool
    var justCreated:Bool
    
    init(location:Room){
        self.name = "Monster"
        self.health = Int(arc4random_uniform(3))+1
        self.level = health
        self.strength = level*2
        self.encountered = false
        self.location = location
        self.justCreated = true
    }
    
    func toString() -> String {
        var toString:String = ""
        toString+="--Monster--"
        toString+="Health: \(health)"
        toString+="Level: \(level)"
        toString+="Strength: \(strength)"
        return toString
    }
}