//
//  ContentView.swift
//  Bosque
//
// TODO
// - use app outside of xcode
//

import SwiftUI

struct Tree: Identifiable, Codable {
    var id = UUID()
    let gridIndex: Int
    var emoji: String
    var isHighlighted: Bool = false
    
    enum CodingKeys: String, CodingKey {
        case id
        case gridIndex
        case emoji
    }
}

struct ContentView: View {
    @State private var isTimerRunning = false
    @State private var isTimerPaused = false
    @State private var trees: [Tree] = []  {
        didSet {
            saveTrees()
        }
    }
    @State private var remainingTime: Int
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let timerDuration = 3
    
    let gridColumns = 100
    let gridRows = 100
    let emojiScalingFactor: CGFloat = 7.0
    
    @State private var zStackFrame: CGRect = .zero
    @State private var cancellableTask: DispatchWorkItem?
    
    let emojis = [
        "🌳","🌳","🌳","🌳","🌳","🌳","🌳","🌳","🌳","🌳","🌳","🌳","🌳","🌳","🌳","🌳","🌳","🌳","🌳",
        "🌲","🌲","🌲","🌲","🌲","🌲","🌲","🌲","🌲","🌲","🌲","🌲","🌲","🌲","🌲","🌲","🌲","🌲","🌲",
        "🌴","🌴","🌴","🌴","🌴","🌴","🌴","🌴","🌴","🌴","🌴","🌴","🌴","🌴","🌴",
        "🌵","🌵","🌵","🌵","🌵","🌵","🌵","🌵","🌵","🌵","🌵","🌵",
        "🌿","🌿","🌿","🌿","🌿","🌿","🌿",
        "🌾","🌾","🌾","🌾","🌾","🌾","🌾",
        "🪷",
        "🪻",
        "🌺",
        "🐛",
        "🐝",
        "🦋",
        "🐿️",
        "🦔",
        "🦨",
        "🐞",
        "🐢",
        "🦉",
        "🪺",
        "⛲",
    ]
    
    init() {
        _remainingTime = State(initialValue: timerDuration)
        _trees = State(initialValue: loadTrees())
    }
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                let cellSize = CGSize(
                    width: geometry.size.width / CGFloat(gridColumns),
                    height: geometry.size.height / CGFloat(gridRows)
                )
                
                ForEach(trees) { tree in
                    let row = tree.gridIndex / gridColumns
                    let col = tree.gridIndex % gridColumns
                    let x = CGFloat(col) * cellSize.width + cellSize.width / 2
                    let y = CGFloat(row) * cellSize.height + cellSize.height / 2
                    
                    Text(tree.emoji)
                        .font(.system(size: min(cellSize.width, cellSize.height) * emojiScalingFactor))
                        .frame(width: cellSize.width * emojiScalingFactor, height: cellSize.height * emojiScalingFactor)
                        .background(Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(tree.isHighlighted ? Color.red : Color.clear, lineWidth: 2)
                        )
                        .position(x: x, y: y)
                        .onTapGesture {
                            if let index = trees.firstIndex(where: { $0.id == tree.id }) {
                                trees[index].isHighlighted.toggle()
                            }
                        }
                    
                }
                .drawingGroup()
            }
            
            VStack {
                HStack {
                    Button("Start", action: {
                        isTimerRunning = true
                        isTimerPaused = false
                        remainingTime = timerDuration
                        addSeedling()
                        startTimer()
                    })
                    .disabled(isTimerRunning)
                    
                    Button(isTimerPaused ? "Resume" : "Pause") {
                        isTimerPaused.toggle()
                        if isTimerPaused {
                            cancellableTask?.cancel()
                        } else {
                            startTimer()
                        }
                    }
                    .disabled(!isTimerRunning)
                    
                    Button("Stop") {
                        stopTimer()
                    }
                    .disabled(!isTimerRunning)
                    
                    Text("\(remainingTime / 60):\(String(format: "%02d", remainingTime % 60))")
                    
                    if let highlightedTreeIndex = trees.firstIndex(where: { $0.isHighlighted }) {
                        Button("Remove") {
                            trees.remove(at: highlightedTreeIndex)
                        }
                    }

                }

                .padding()


                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .onReceive(timer) { _ in
            if isTimerRunning && !isTimerPaused {
                if remainingTime > 0 {
                    remainingTime -= 1
                }
            }
        }
        .onDisappear {
            saveTrees()
        }
    }
    
    
    func addSeedling() {
        let emptyIndices = Array(0..<(gridColumns * gridRows)).filter { index in
            trees.first(where: { $0.gridIndex == index }) == nil
        }
        if let randomIndex = emptyIndices.randomElement() {
            trees.append(Tree(gridIndex: randomIndex, emoji: "🌱"))
        } else {
            print("no empty space for a seedling")
        }
    }
    
    func growTree() {
        let randomEmoji = emojis.randomElement() ?? "🌳"

        if let lastTreeIndex = trees.lastIndex(where: { $0.emoji == "🌱" }) {
            DispatchQueue.main.async {
                trees[lastTreeIndex].emoji = randomEmoji
                saveTrees()
            }
        } else {
            print("No seedling found to grow.")
        }

        remainingTime = timerDuration
    }
    
    func startTimer() {
        cancellableTask?.cancel()
        
        cancellableTask = DispatchWorkItem {
            isTimerRunning = false
            growTree()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(remainingTime), execute: cancellableTask!)
    }
    
    func stopTimer() {
        isTimerRunning = false
        isTimerPaused = false
        cancellableTask?.cancel()
        remainingTime = timerDuration
        // Remove only the seedling if it exists
        if let lastTreeIndex = trees.lastIndex(where: { $0.emoji == "🌱" }) {
            trees.remove(at: lastTreeIndex)
            saveTrees()
        }
    }
    
    func saveTrees() {
        if let encoded = try? JSONEncoder().encode(trees) {
            UserDefaults.standard.set(encoded, forKey: "savedTrees")
        }
    }

    func loadTrees() -> [Tree] {
        if let data = UserDefaults.standard.data(forKey: "savedTrees"),
           let decoded = try? JSONDecoder().decode([Tree].self, from: data) {
            return decoded
        } else {
            return []
        }
    }
}

#Preview {
    ContentView()
}
