//
//  ContentView.swift
//  Bosque
//
// TODO
// - persist between opening the app
// - different icons
// - use app outside of xcode
// - pause timer
// - reset timer
// - app icon
//

import SwiftUI

struct Tree: Identifiable {
    let id = UUID()
    let position: CGPoint
}

struct ContentView: View {
    @State private var isTimerRunning = false
    @State private var trees: [Tree] = []
    @State private var remainingTime: Int
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let timerDuration = 5
    
    @State private var zStackFrame: CGRect = .zero
    
    init() {
        _remainingTime = State(initialValue: timerDuration)
    }
    
    var body: some View {
        ZStack {
            
            ForEach(trees) { tree in
                Text("🌳")
                    .font(.system(size:50))
                    .position(tree.position)
            }
            
            VStack {
                HStack {
                    Button("Start", action: {
                        isTimerRunning = true
                        remainingTime = timerDuration  // reset timer
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                            isTimerRunning = false
                            addTree()
                        }
                    })
                    .disabled(isTimerRunning)
                    
                    if isTimerRunning {
                        Text("\(remainingTime / 60):\(String(format: "%02d", remainingTime % 60))")
                    }
                }
                .padding()
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .onReceive(timer) { _ in
            if isTimerRunning {
                if remainingTime > 0 {
                    remainingTime -= 1
                } else {
                    isTimerRunning = false
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
                            return Tree(position: CGPoint(x: newX, y: newY))
                        }
                        zStackFrame = newFrame
                    }
            }
        )

    }
    
    func addTree() {
        // Access the ZStack's frame using the GeometryProxy and NSWindow
        if let window = NSApplication.shared.windows.first {
            let zStackFrame = window.contentView!.frame
            trees.append(Tree(position: CGPoint(
                x: CGFloat.random(in: 0..<zStackFrame.width),
                y: CGFloat.random(in: 0..<zStackFrame.height)
            )))
        } else {
            print("Window not found.")
        }
    }
}

#Preview {
    ContentView()
}
