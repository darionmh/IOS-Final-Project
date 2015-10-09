//
//  Effect.swift
//  KeyToMadness
//
//  Created by Alexis Forbes on 10/8/15.
//  Copyright © 2015 Alexis Forbes. All rights reserved.
//

import Foundation

public class Effect: Equatable {
    var description:String
    
    init(description:String) {
        self.description = description
    }
    
    func toString() -> String {
        var toString:String = ""
        toString += "\n--Effect--"
        toString += "\nDescription: \(description)"
        return toString
    }
}

public func ==(lhs: Effect, rhs: Effect) -> Bool {
    return lhs.description == rhs.description
}