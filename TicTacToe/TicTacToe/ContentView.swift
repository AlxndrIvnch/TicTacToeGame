//
//  ContentView.swift
//  TicTacToe
//
//  Created by Aleksandr on 22.08.2022.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var game = Game()
    @State private var mySymbolSetting: Symbol = .circle
    @State private var opponentSetting: Opponent = .HardBot
    @State private var percentage: CGFloat = .zero
    @State private var buttonScale = false
    @GestureState private var dragPosition: (start: CGPoint, current: CGPoint) = (.zero, .zero)
    private var vsBot: Bool {
        switch opponentSetting {
        case .Human: return false
        case .EasyBot, .HardBot: return true
        }
    }
    private var isSettingsSame: Bool {
        game.opponent == opponentSetting && game.mySymbol == mySymbolSetting
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            Text("TicTacToe")
                .font(.largeTitle.monospaced())
                .fontWeight(.medium)
            Spacer()
            HStack(spacing: 15) {
                Label(": \(game.score.X)", systemImage: "xmark")
                Label(": \(game.score.drow)", systemImage: "xmark.circle")
                Label(": \(game.score.O)", systemImage: "circle")
            }
            Spacer()
            ZStack { //board
                createDividersGrid()
                createCellsGrid()
                
                if let lineType = game.winner?.line {
                    Line(type: lineType)
                        .trim(from: .zero, to: percentage)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clipped()
                        .animation(.easeOut(duration: 1), value: percentage)
                        .onAppear {
                            percentage = 1.0
                        }
                }
            }
            .padding(20)
            .font(.largeTitle.bold())
            .aspectRatio(1, contentMode: .fit)
            .frame(maxWidth: .infinity, alignment: .center)
            .overlay(RoundedRectangle(cornerRadius: 20)
                .strokeBorder(.foreground, lineWidth: 2)
                .shadow(radius: 3))
            .padding([.leading, .trailing], 20)
            
            Spacer()
            HStack {
                Spacer()
                VStack(spacing: 0) {
                    Button(action: restart) {
                        HStack {
                            isSettingsSame ? Text("Continue") : Text("Restart")
                            isSettingsSame ? Image(systemName: "play") : Image(systemName: "gobackward")
                        }
                    }
                    .frame(maxWidth: 100)
                    .buttonStyle(.none)
                    .padding()
                    .foregroundStyle(.white)
                    .font(Font.body)
                    .background(.black)
                    .clipShape(Capsule(style: .continuous))
                    .background(GeometryReader { dragObserver($0) })
                    .shadow(radius: 5)
                    .scaleEffect(buttonScale ? 0.9 : 1.0)
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 0, coordinateSpace: .global)
                            .updating($dragPosition, body: { value, state, _ in
                                state.start = value.startLocation
                                state.current = value.location
                            }))
                    if vsBot {
                        Text("Your symbol")
                            .padding(.top, 10)
                            .frame(maxHeight: .infinity, alignment: .center)
                            .font(.subheadline)
                            .transition(.move(edge: .top))
                    }
                }
                Spacer()
                VStack(spacing: 0) {
                    Spacer()
                    Text("VS")
                        .font(.title2)
                        .foregroundColor(.white)
                        .shadow(radius: 2)
                        .shadow(radius: 5)
                        .shadow(radius: 10)
                        .shadow(radius: 10)
                        .padding(.leading, 20)
                    Spacer()
                    if vsBot {
                        Spacer()
                        Spacer()
                        Spacer()
                    }
                }
                Spacer()
                VStack(spacing: 0) {
                    Menu {
                        Picker("vs", selection: $opponentSetting) {
                            ForEach(Opponent.allCases, id: \.self) { opponent in
                                Text(opponent.rawValue).tag(opponent)
                            }
                        }
                        
                    } label: {
                        createOpponentLable()
                    }
                    .frame(minWidth: 80 ,maxHeight: .infinity, alignment: .center)
                    .padding()
                    .background(Color(UIColor.systemBackground))
                    
                    if vsBot {
                        Picker("Your symbol: ", selection: $mySymbolSetting) {
                            ForEach(Symbol.allCases, id: \.self) { symbol in
                                Image(systemName: symbol.rawValue)
                                    .tag(symbol)
                            }
                        }
                        .pickerStyle(.segmented)
                        .fixedSize()
                        .frame(maxHeight: .infinity, alignment: .center)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
                Spacer()
            }
            .animation(.spring(), value: vsBot)
            .frame(height: 100)
            Spacer()
        }
    }
    
    private func createOpponentLable() -> some View {
        let text: String
        switch opponentSetting {
        case .Human: text = "👤"
        case .EasyBot: text = "🤖"
        case .HardBot: text = "🦾"
        }
        return Text(text)
        .font(.title.bold())
    }
    
    private func createCellsGrid() -> some View {
        GridStack(rows: 3, columns: 3) { row, column in
            if let imageName = game.board[row][column].symbol?.rawValue {
                Image(systemName: imageName)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .imageScale(.large)
                    .transition(.scale.animation(.linear(duration: 0.25)))
            } else {
                Button(
                    action: {
                        game.makeMove(on: row, and: column)
                    },
                    label: {
                        Color.clear
                    })
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
        }
        .onAppear(perform: {
            game.makeBotMove()
        })
    }
    
    private func createDividersGrid() -> some View {
        GridStack(rows: 3, columns: 3) { row, column in
            VStack(alignment: .trailing ,spacing: 0) {
                Spacer()
                    .frame(maxHeight: column > 1 ? .infinity : 0)
                HStack(alignment: .bottom ,spacing: 0)  {
                    Spacer()
                    if column <= 1 {
                        Divider()
                    }
                }
                if row <= 1 {
                    Divider()
                }
            }
        }
        .shadow(radius: 5)
    }
    
    private func dragObserver(_ geo: GeometryProxy) -> some View {
        
        if geo.frame(in: .global).contains(dragPosition.current) && geo.frame(in: .global).contains(dragPosition.start) {
            DispatchQueue.main.async {
                withAnimation(.spring().speed(2)) {
                    buttonScale = true
                }
            }
        } else if buttonScale {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
                withAnimation(.interpolatingSpring(stiffness: 20, damping: 4).speed(2)) {
                    buttonScale = false
                }
            }
        }
        
        return Color.clear
    }
    
    private func restart() {
        percentage = 0.0
        if isSettingsSame {
            game.restart()
        } else {
            game.restart(opponent: opponentSetting, mySymbol: mySymbolSetting)
        }
    }
}

// MARK: ContentView_Previews
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
                .preferredColorScheme(.light)
        }
    }
}
