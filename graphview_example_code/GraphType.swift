//
//  GraphType.swift
//  GraphView
//
//  Created by Kelly Roach on 8/18/18.
//

// The type of the current graph we are showing.
enum GraphType {
    case simple
    case multiOne
    case multiTwo
    case dark
    case bar
    case dot
    case pink
    case blueOrange
    
    mutating func next() {
        switch(self) {
        case .simple:
            self = GraphType.multiOne
        case .multiOne:
            self = GraphType.multiTwo
        case .multiTwo:
            self = GraphType.dark
        case .dark:
            self = GraphType.bar
        case .bar:
            self = GraphType.dot
        case .dot:
            self = GraphType.pink
        case .pink:
            self = GraphType.blueOrange
        case .blueOrange:
            self = GraphType.simple
        }
    }
}
