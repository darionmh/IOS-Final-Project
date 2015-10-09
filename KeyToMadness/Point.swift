//
//  Point.swift
//  KeyToMadness
//
//  Created by Alexis Forbes on 10/8/15.
//  Copyright © 2015 Alexis Forbes. All rights reserved.
//

import Foundation

public class Point {
    var x:Int
    var y:Int
    
    init(x:Int, y:Int) {
        self.x = x
        self.y = y
    }
    
    func toString() -> String {
        return "(\(x), \(y))"
    }
}