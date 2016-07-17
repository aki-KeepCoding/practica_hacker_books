//
//  Tags.swift
//  HackerBooks
//
//  Created by Akixe on 4/7/16.
//  Copyright © 2016 AOA. All rights reserved.
//

import Foundation

class Tag {
    
    let name : String
    var priority : Int = 1 // ToDo : pasar a enum (ALTA, BAJA, NORMAL)
    
    init (_ name: String) {
        self.name = name
    }
    convenience init(_ name: String, priority: Int) {
        self.init(name)
        self.priority = priority
    }
}

extension Tag: Hashable {
    var hashValue: Int {
        return self.name.hashValue
    }
}

extension Tag: Equatable { }
func ==(lhs: Tag, rhs: Tag) -> Bool{
    return lhs.name == rhs.name
}

extension Tag: Comparable { }
func <(lhs: Tag, rhs: Tag) -> Bool {
    
    // Si el tag LHS tiene mayor prioridad que el RHS
    //   LHS sería más grande.
    // Si RHS es igual o menor se comparan los .name
    //   alfabéticamente
    if lhs.priority == rhs.priority {
        return lhs.name < rhs.name
    } else {
        return lhs.priority > rhs.priority
    }
}