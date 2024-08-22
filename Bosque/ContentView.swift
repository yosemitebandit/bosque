//
//  ContentView.swift
//  Bosque
//
// TODO
// - persist between opening the app
// - use app outside of xcode
//

import SwiftUI

struct Tree: Identifiable {
    let id = UUID()
    let position: CGPoint
    var emoji: String
}

struct ContentView: View {
    @State private var isTimerRunning = false
    @State private var isTimerPaused = false
    @State private var trees: [Tree] = []
    @State private var remainingTime: Int
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let timerDuration = 5
    
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
    }
    
    var body: some View {
        ZStack {
            
            ForEach(trees) { tree in
                Text(tree.emoji)
                    .font(.system(size:50))
                    .position(tree.position)
            }
            
            VStack {
                HStack {
                    Button("Start", action: {
                        isTimerRunning = true
                        isTimerPaused = false
                        remainingTime = timerDuration  // reset timer
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
        .background(
            GeometryReader { geometry in
                Color.clear
                    .onAppear {
                        zStackFrame = geometry.frame(in: .global)
                    }
                    .onChange(of: geometry.frame(in: .global)) { newFrame in
                        trees = trees.map { tree in
                            let newX = tree.position.x / zStackFrame.width * newFrame.width
                            let newY = tree.position.y / zStackFrame.height * newFrame.height
                            return Tree(position: CGPoint(x: newX, y: newY), emoji: tree.emoji)
                        }
                        zStackFrame = newFrame
                    }
            }
        )

    }
    
    func addSeedling() {
        // Access the ZStack's frame using the GeometryProxy and NSWindow
        if let window = NSApplication.shared.windows.first {
            let zStackFrame = window.contentView!.frame
            
            trees.append(Tree(position: CGPoint(
                x: CGFloat.random(in: 0..<zStackFrame.width),
                y: CGFloat.random(in: 0..<zStackFrame.height)
                ), emoji: "🌱"))
        } else {
            print("Window not found.")
        }
    }
    
    func growTree() {
        let randomEmoji = emojis.randomElement() ?? "🌳"

        if let lastTreeIndex = trees.lastIndex(where: { $0.emoji == "🌱" }) {
            trees[lastTreeIndex].emoji = randomEmoji
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
        }
    }
}

#Preview {
    ContentView()
}
