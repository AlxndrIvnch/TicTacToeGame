//
//  Line.swift
//  FirstSwiftUIProject
//
//  Created by Aleksandr on 16.08.2022.
//
import SwiftUI

struct Line: Shape {
    let type: WinLine
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        switch type {
        case .row(let number):
            let y = rect.height / 6 + (CGFloat(number) * 2 * rect.height / 6)
            path.move(to: CGPoint(x: rect.minX, y: y - 1))
            path.addLine(to: CGPoint(x: rect.minX, y: y + 1))
            path.addLine(to: CGPoint(x: rect.maxX, y: y + 1))
            path.addLine(to: CGPoint(x: rect.maxX, y: y - 1))
            path.addLine(to: CGPoint(x: rect.minX, y: y - 1))
        case .column(let number):
            let x = rect.width / 6 + (CGFloat(number) * 2 * rect.width / 6)
            path.move(to: CGPoint(x: x - 1, y: rect.minY))
            path.addLine(to: CGPoint(x: x + 1, y: rect.minY))
            path.addLine(to: CGPoint(x: x + 1, y: rect.maxY))
            path.addLine(to: CGPoint(x: x - 1, y: rect.maxY))
            path.addLine(to: CGPoint(x: x - 1, y: rect.minY))
        case .diagonal(let isReversed):
            if isReversed {
                path.move(to: CGPoint(x: rect.minX, y: rect.minY + 1))
                path.addLine(to: CGPoint(x: rect.minX + 1, y: rect.minY))
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - 1))
                path.addLine(to: CGPoint(x: rect.maxX - 1, y: rect.maxY))
                path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + 1))
            } else {
                path.move(to: CGPoint(x: rect.minX + 1, y: rect.maxY))
                path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY - 1))
                path.addLine(to: CGPoint(x: rect.maxX - 1, y: rect.minY))
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY + 1))
                path.addLine(to: CGPoint(x: rect.minX + 1, y: rect.maxY))
                
            }
        }
        return path
            
    }
}
