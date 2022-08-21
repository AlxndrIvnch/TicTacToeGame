//
//  Symbol.swift
//  FirstSwiftUIProject
//
//  Created by Aleksandr on 18.08.2022.
//

enum Symbol: String, CaseIterable, Equatable {
    case xmark
    case circle
    
    var opposite: Symbol {
        self == .xmark ? .circle : .xmark
    }
    
    mutating func toggle() {
        self = self.opposite
    }
    
}
