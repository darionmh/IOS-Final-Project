//
//  Happening.swift
//  KeyToMadness
//
//  Created by Alexis Forbes on 10/8/15.
//  Copyright © 2015 Alexis Forbes. All rights reserved.
//

import Foundation

public class Happening: Equatable {
    var name:String
    var description:String
    var effect:Effect
    
    init(name:String, description:String, effect:Effect) {
        self.name = name
        self.description = description
        self.effect = effect
    }
    
    func toString() -> String {
        var toString:String = ""
        toString += "\n--Happening--"
        toString += "\nName: \(name)"
        toString += "\nDescription: \(description)"
        toString += "\(effect.toString())"
        return toString
    }
}


public func ==(lhs: Happening, rhs: Happening) -> Bool {
    return lhs.name == rhs.name && lhs.description == rhs.description && lhs.effect == rhs.effect
}
