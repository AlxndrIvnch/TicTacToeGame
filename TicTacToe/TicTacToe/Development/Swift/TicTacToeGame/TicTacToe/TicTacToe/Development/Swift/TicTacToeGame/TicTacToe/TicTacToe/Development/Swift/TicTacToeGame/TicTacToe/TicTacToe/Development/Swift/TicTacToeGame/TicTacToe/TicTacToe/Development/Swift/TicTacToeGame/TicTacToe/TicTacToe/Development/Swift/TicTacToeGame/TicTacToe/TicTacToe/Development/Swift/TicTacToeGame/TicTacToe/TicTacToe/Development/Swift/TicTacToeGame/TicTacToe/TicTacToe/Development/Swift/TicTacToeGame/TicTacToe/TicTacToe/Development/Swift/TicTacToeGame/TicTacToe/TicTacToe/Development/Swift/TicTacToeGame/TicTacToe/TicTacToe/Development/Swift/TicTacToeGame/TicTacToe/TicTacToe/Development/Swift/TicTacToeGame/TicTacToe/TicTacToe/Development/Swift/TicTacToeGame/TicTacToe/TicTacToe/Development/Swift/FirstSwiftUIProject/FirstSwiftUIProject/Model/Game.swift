//
//  Game.swift
//  FirstSwiftUIProject
//
//  Created by Aleksandr on 17.08.2022.
//
import SwiftUI
import Foundation

class Game: ObservableObject {
    
    @Published var mySymbol: Symbol = .circle
    @Published var opponent: Opponent = .HardBot
    @Published var state: GameState = .started
    @Published var winner: Winner? = nil
    @Published var score = Score()
    
    private var vsBot: Bool {
        switch opponent {
        case .Human: return false
        case .EasyBot, .HardBot: return true
        }
    }
    
    private(set) var board: [[Cell]] = {
        var array = [[Cell]]()
        for rowIndex in 0...2 {
            var row = [Cell]()
            for columnIndex in 0...2 {
                row.append(Cell(position: Position(row: rowIndex, column: columnIndex)))
            }
            array.append(row)
        }
        return array
    }()
    
    private func bestMove(on cells: [[Cell]]) -> Cell? {
        var boardCopy = board
        var bestScore = Double(Int.min)
        var bestCell: Cell?
        
        for row in cells {
            for cell in row {
                
                boardCopy[cell.position.row][cell.position.column].symbol = mySymbol.opposite
                let score = minimax(on: &boardCopy, maximizing: false)
                boardCopy[cell.position.row][cell.position.column].symbol = nil
                
                if score > bestScore {
                    bestScore = score
                    bestCell = cell
                }
            }
        }
        return bestCell
    }
    
    private func minimax(on board: inout [[Cell]], maximizing: Bool, depth: Double = 1) -> Double {
        
        if let gameEnd = checkGameEnd(on: board) {
            switch gameEnd {
            case .draw:
                return 0
            case .win(let winner):
                return winner.symbol == mySymbol ? (-1 / depth) : (1 / depth)
            }
        }
        
        let evailbleCells = board.map { $0.filter( { $0.symbol == nil })}.filter({ !$0.isEmpty })
        
        if maximizing {
            var bestScore = Double(Int.min)
            for row in evailbleCells {
                for cell in row {
                    board[cell.position.row][cell.position.column].symbol = mySymbol.opposite
                    let score = minimax(on: &board, maximizing: false, depth: depth + 1)
                    board[cell.position.row][cell.position.column].symbol = nil
                    bestScore = max(score, bestScore)
                }
            }
            return bestScore
        } else {
            var worstScore = Double(Int.max)
            for row in evailbleCells {
                for cell in row {
                    board[cell.position.row][cell.position.column].symbol = mySymbol
                    let score = minimax(on: &board, maximizing: true, depth: depth + 1)
                    board[cell.position.row][cell.position.column].symbol = nil
                    worstScore = min(score, worstScore)
                }
            }
            return worstScore
        }
    }
    
    private func randomMove(on cells: [[Cell]]) -> Cell? {
        cells.randomElement()?.randomElement()
    }
    
    func makeBotMove() {
        
        let evailbleCells = board.map { $0.filter( { $0.symbol == nil })}.filter({ !$0.isEmpty })
        
        switch opponent {
        case .Human:
            break
        case .EasyBot:
            guard let cell = self.randomMove(on: evailbleCells) else { return }
            state = .botMoving
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.board[cell.position.row][cell.position.column].symbol = self.mySymbol.opposite
                self.validateGameState()
            }
        case .HardBot:
            
            if state == .started { // is first move in game check
                let row = [0, 2].randomElement() ?? 0
                let column = [0, 2].randomElement() ?? 0
                board[row][column].symbol = .xmark
                validateGameState()
                return
            }
            
            state = .botMoving
            DispatchQueue.global().async { [weak self] in
                guard let self = self else { return }
                
                let start = Date.now
                guard let cell = self.bestMove(on: evailbleCells) else { return }
                let end = Date.now
                let time = end.timeIntervalSinceReferenceDate - start.timeIntervalSinceReferenceDate
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 - time) {
                    self.board[cell.position.row][cell.position.column].symbol = self.mySymbol.opposite
                    self.validateGameState()
                }
            }
        }
    }
    
    func makeMove(on row: Int, and column: Int) {
        
        switch state {
        case .started:
            board[row][column].symbol = .xmark
        case .running(let turn):
            board[row][column].symbol = turn
        case .botMoving, .ended:
            return
        }
        validateGameState()
        
        if vsBot && state == .running(turn: mySymbol.opposite) {
            makeBotMove()
        }
    }
    
    func restart() {
        for row in 0..<board.count {
            for column in 0..<board.count{
                board[row][column].symbol = nil
            }
        }
        
        winner = nil
        state = .started
        
        if mySymbol == .circle {
            makeBotMove()
        }
    }
    
    func restart(opponent: Opponent, mySymbol: Symbol) {
        
        self.opponent = opponent
        self.mySymbol = mySymbol
        score = Score()
        
        self.restart()
    }
    
    func validateGameState() {
        if let gameEnd = checkGameEnd(on: board) {
            state = .ended(gameEnd)
        }
        
        switch state {
        case .started:
            state = .running(turn: .circle)
        case .running(let turn):
            state = .running(turn: turn.opposite)
        case .botMoving:
            state = .running(turn: mySymbol)
        case .ended(let gameEnd):
            switch gameEnd {
            case .win(let winner):
                self.winner = winner
                switch winner.symbol {
                case .xmark: score.X += 1
                case .circle: score.O += 1
                }
            case .draw:
                score.drow += 1
            }
        }
    }

    func checkGameEnd(on board: [[Cell]]) -> GameEnd? {
        
        for symbol in Symbol.allCases {
            if let row = checkRow(on: board, with: symbol) {
                return .win(Winner(symbol: symbol, line: row))
            }
            if let column = checkColumn(on: board, with: symbol) {
                return .win(Winner(symbol: symbol, line: column))
            }
            if let diagonal = checkDiagonals(on: board, with: symbol)  {
                return .win(Winner(symbol: symbol, line: diagonal))
            }
        }
        
        return checkDraw(on: board) ? .draw : nil
    }
    
    func checkDraw(on board: [[Cell]]) -> Bool {
        !board.contains { $0.contains { $0.symbol == nil }}
    }
    
    func checkLine(_ line: [Cell], with symbol: Symbol) -> Bool {
        return !line.contains(where: { $0.symbol != symbol })
    }
    
    func checkRow(on board: [[Cell]], with symbol: Symbol) -> WinLine? {
        for (index, row) in board.enumerated() {
            if checkLine(row, with: symbol) {
                return .row(number: index)
            }
        }
        return nil
    }
    
    func checkColumn(on board: [[Cell]], with symbol: Symbol) -> WinLine? {
        for index in 0..<board.count {
            var column = [Cell]()
            for row in board {
                column.append(row[index])
            }
            if checkLine(column, with: symbol) {
                return .column(number: index)
            }
        }
        return nil
    }
    
    func checkDiagonals(on board: [[Cell]], with symbol: Symbol) -> WinLine? {
        var diagonal1 = [Cell]()
        var diagonal2 = [Cell]()
        for index in 0..<board.count {
            diagonal1.append(board[index][index])
            diagonal2.append(board[index][board.count - 1 - index])
        }
        if checkLine(diagonal1, with: symbol) {
            return .diagonal(isReversed: true)
        }
        if checkLine(diagonal2, with: symbol) {
            return .diagonal(isReversed: false)
        }
        return nil
    }
}
