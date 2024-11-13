//
//  ContentView.swift
//  MemoryProject
//
//  Created by Allison Gumowitz on 10/29/24.
//

import SwiftUI

struct ContentView: View {
    
    @State private var cards = ["🐶", "🐱", "🐭", "🦊", "🐸", "🐷", "🐮", "🐵", "🐔", "🐧", "🦁", "🐯", "🐨", "🐼", "🐻", "🐙", "🦄", "🦋"]
    @State private var shuffledCards: [String] = []
    @State private var selectedCards: [Int] = []
    @State private var matchedCards: [Int] = []
    @State private var numberOfPairs = 2
    @State private var gameWon: Bool = false
    
    
    var body: some View {
        VStack {
            Picker("Number of Pairs", selection: $numberOfPairs) {
                Text("2 Pairs").tag(2)
                Text("4 Pairs").tag(4)
                Text("6 Pairs").tag(6)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            .background(Color.white.opacity(0.2))
            .cornerRadius(10)
            .onChange(of: numberOfPairs) {
                withAnimation(.easeInOut) {
                    restartGame()
                }
            }
            
            Text("Memory Card")
                .font(.largeTitle.bold())
                .foregroundColor(.white)
                .padding()
                .shadow(radius: 2)
                .transition(.scale)
            
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3)) {
                    ForEach(0..<shuffledCards.count, id: \.self) { index in
                        CardView(
                            symbol: shuffledCards[index],
                            isFlipped: selectedCards.contains(index) || matchedCards.contains(index),
                            isMatched: matchedCards.contains(index),
                            showContent: true
                        )
                        .onTapGesture {
                            withAnimation(.easeInOut) {
                                cardTapped(index: index)
                            }
                        }
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 20).stroke(Color.purple, lineWidth: 4))
                .padding()
            }

                Button("Restart") {
                    withAnimation(.smooth) {
                        self.restartGame()
                    }
                }
                .font(.title2)
                .padding()
                .background(LinearGradient(colors: [.purple, .blue], startPoint: .leading, endPoint: .trailing))
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .shadow(radius: 10)
            }
            .background(
                LinearGradient(colors: [.black, .blue.opacity(0.8)], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
            )
            .onAppear {
                shuffleCards()
            }
            
            .alert(isPresented: self.$gameWon) {
                Alert(title: Text("You Won!"),
                    message: Text("Congratulations, you have won the game!"),
                    dismissButton: .default(Text("Play again"), action: {
                        withAnimation(.easeInOut) {
                            self.restartGame()
                        }
                    })
                )
            }
        }
        //mark create functions
        func shuffleCards(){
            let pairsToShow = numberOfPairs * 3
                let chosenCards = Array(cards.prefix(pairsToShow))
                shuffledCards = (chosenCards + chosenCards).shuffled()
        }
        
        func cardTapped(index: Int){
            if selectedCards.count == 2 {
                selectedCards.removeAll()
            }
            
            if !matchedCards.contains(index) {
                selectedCards.append(index)
                if selectedCards.count == 2 {
                    checkForMatch()
                }
            }
        }
        
        func checkForMatch(){
            let firstIndex = selectedCards[0]
            let secondIndex = selectedCards[1]
            if shuffledCards[firstIndex] == shuffledCards[secondIndex] {
                matchedCards += selectedCards
                if matchedCards.count == shuffledCards.count {
                    gameWon = true
                }
            }
        }
        
        //mark restart game
        func restartGame() {
            matchedCards.removeAll()
            selectedCards.removeAll()
            shuffleCards()
        }
    }
    
   
    
    #Preview {
        ContentView()
    }
    
struct CardView: View {
    var symbol: String
    var isFlipped: Bool
    var isMatched: Bool
    var showContent: Bool // New property to conditionally show content
    
    var body: some View {
        ZStack {
            if !isMatched && showContent {
                Rectangle()
                    .fill(isFlipped ? Color.white : Color.purple)
                    .frame(width: 50, height: 70)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .shadow(radius: 5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 2)
                    )
                if isFlipped {
                    Text(symbol)
                        .font(.largeTitle)
                        .transition(.scale)
                }
            }
        }
    }
}

    
    //mark grid stack
    
struct GridStack<Content: View>: View {
    var rows: Int
    var columns: Int
    let content: (Int, Int) -> Content

    var body: some View {
        VStack(spacing: 10) {
            ForEach(0..<rows, id: \.self) { row in
                HStack(spacing: 10) {
                    ForEach(0..<columns, id: \.self) { col in
                        content(row, col) // No AnyView wrapping needed
                    }
                }
            }
        }
    }
}
