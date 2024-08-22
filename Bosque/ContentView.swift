//
//  ContentView.swift
//  Bosque
//
// TODO
// - wonkiness when timer is running and window is resized
// - make timer length a better var
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
    @State private var remainingTime: Int = 5
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
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
                        remainingTime = 5  // reset timer
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
                    .onChange(of: geometry.frame(in: .global)) { newFrame in
                        if isTimerRunning {
                            // Recalculate treePosition if the timer is running and the frame changes
                            trees = trees.map { _ in
                                Tree(position: CGPoint(
                                    x: CGFloat.random(in: 0..<newFrame.width),
                                    y: CGFloat.random(in: 0..<newFrame.height)
                                ))
                            }
                        }
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
