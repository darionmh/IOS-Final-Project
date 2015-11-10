//
//  Item.swift
//  KeyToMadness
//
//  Created by Alexis Forbes on 10/8/15.
//  Copyright © 2015 Alexis Forbes. All rights reserved.
//

import Foundation

public class Item:Equatable {
    var name:String
    var description:String
    var type:String
    var effect:Effect
    
    init(name:String, description:String, effect:Effect, type:String) {
        self.name = name
        self.description = description
        self.effect = effect
        self.type = type
    }
    
    func toString() -> String {
        var toString:String = ""
        toString += "\n--Item--"
        toString += "\nName: \(name)"
        toString += "\nType: \(type)"
        toString += "\nDescription: \(description)"
        toString += "\(effect.toString())"
        return toString
    }
    
}

public func ==(lhs: Item, rhs: Item) -> Bool {
    return lhs.name == rhs.name && lhs.description == rhs.description && lhs.effect == rhs.effect && lhs.type == rhs.type
}