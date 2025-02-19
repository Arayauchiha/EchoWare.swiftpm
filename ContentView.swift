import SwiftUI
import QuartzCore

struct ObservingFoxView: View {
    let onLongPress: () -> Void
    @State private var currentImageIndex = 12  // Alert mode frames are 12–20
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        Image("\(currentImageIndex)")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .gesture(
                LongPressGesture(minimumDuration: 0.5)
                    .onEnded { _ in
                        onLongPress()
                    }
            )
            // Update image frames WITHOUT an animation block so that the frame change is immediate.
            .onReceive(timer) { _ in
                if currentImageIndex < 20 {
                    currentImageIndex += 1
                } else {
                    currentImageIndex = 12
                }
            }
    }
}

struct SleepingFoxView: View {
    let onTap: () -> Void
    @State private var currentImageIndex = 1  // Awake fox frames are 1–9
    let timer = Timer.publish(every: 0.15, on: .main, in: .common).autoconnect()
    
    var body: some View {
        Image("\(currentImageIndex)")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .onTapGesture { onTap() }
            // Update image frames immediately (no withAnimation here) for smooth frame transitions.
            .onReceive(timer) { _ in
                if currentImageIndex < 9 {
                    currentImageIndex += 1
                } else {
                    currentImageIndex = 1
                }
            }
    }
}

struct ContentView: View {
    @State private var isAwake = false
    @State private var isTransitioning = false
    @State private var showSpeechBubble = false
    @State private var speechMessage = ""
    @State private var isFirstTime = true
    @State private var pendingMessageWork: DispatchWorkItem?
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                // Background images
                if isAwake {
                    Image("dayBG")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                        .transition(.opacity)
                        .overlay(
                            // Daytime atmosphere enhancement
                            LinearGradient(
                                colors: [
                                    Color(red: 0.6, green: 0.8, blue: 1.0).opacity(0.3),
                                    Color(red: 0.7, green: 0.9, blue: 1.0).opacity(0.2),
                                    Color.clear
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .overlay(
                            // Additional vibrancy layer
                            LinearGradient(
                                colors: [
                                    Color(red: 1.0, green: 0.95, blue: 0.8).opacity(0.2),
                                    Color(red: 0.95, green: 0.9, blue: 0.7).opacity(0.15),
                                    Color.clear
                                ],
                                startPoint: .topTrailing,
                                endPoint: .bottomLeading
                            )
                        )
                } else {
                    Image("pixelcut-export")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                        .transition(.opacity)
                        .overlay(
                            // Night atmosphere enhancement
                            LinearGradient(
                                colors: [
                                    Color(red: 0.1, green: 0.2, blue: 0.4).opacity(0.3),
                                    Color(red: 0.1, green: 0.2, blue: 0.3).opacity(0.2),
                                    Color.clear
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }
                
                // Day/Night overlay with enhanced colors
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                isAwake ? Color(red: 0.95, green: 0.8, blue: 0.6).opacity(0.2) : Color.black.opacity(0.4),
                                isAwake ? Color(red: 0.9, green: 0.7, blue: 0.5).opacity(0.15) : Color.black.opacity(0.3)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .animation(.easeInOut(duration: 0.6), value: isAwake)
                
                // Simple static stars
                ForEach(0..<50, id: \.self) { _ in
                    let size = CGFloat.random(in: 1...3)
                    Circle()
                        .fill(Color.white)
                        .frame(width: size, height: size)
                        .blur(radius: 0.2)
                        .position(
                            x: CGFloat.random(in: 0...geometry.size.width),
                            y: CGFloat.random(in: 0...geometry.size.height * 0.6)
                        )
                        .opacity(isAwake ? 0 : Double.random(in: 0.3...0.8))
                }
                .animation(.none, value: showSpeechBubble) // Prevent stars from moving when bubble appears
                
                // Sun/Moon with transition animation
                ZStack {
                    // Moon and Sun container
                    ZStack {
                        // Moon
                        Group {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 60, height: 60)
                                .blur(radius: 2)
                                .overlay(
                                    Circle()
                                        .fill(
                                            RadialGradient(
                                                colors: [
                                                    Color.white.opacity(0.6),
                                                    Color.white.opacity(0.2),
                                                    Color.clear
                                                ],
                                                center: .center,
                                                startRadius: 5,
                                                endRadius: 50
                                            )
                                        )
                                        .frame(width: 100, height: 100)
                                        .blur(radius: 10)
                                )
                        }
                        .opacity(isAwake ? 0 : 1)
                        
                        // Sun
                        Group {
                            // Sun rays animation
                            ForEach(0..<8) { index in
                                let angle = Double(index) * .pi / 4
                                Rectangle()
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 1, green: 0.85, blue: 0.4).opacity(0.4),
                                                Color(red: 1, green: 0.85, blue: 0.4).opacity(0.2),
                                                Color.clear
                                            ],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .frame(width: 15, height: 200)
                                    .rotationEffect(.radians(angle))
                                    .blur(radius: 15)
                            }
                            
                            // Outer sun glow
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [
                                            Color(red: 1, green: 0.8, blue: 0.3).opacity(0.5),
                                            Color(red: 1, green: 0.7, blue: 0.2).opacity(0.3),
                                            Color(red: 1, green: 0.6, blue: 0.1).opacity(0.1),
                                            Color.clear
                                        ],
                                        center: .center,
                                        startRadius: 30,
                                        endRadius: 150
                                    )
                                )
                                .frame(width: 300, height: 300)
                                .blur(radius: 20)
                            
                            // Inner sun glow
                            Circle()
                                .fill(
                                    RadialGradient(
                                        colors: [
                                            Color(red: 1, green: 0.95, blue: 0.8),
                                            Color(red: 1, green: 0.9, blue: 0.4),
                                            Color(red: 1, green: 0.8, blue: 0.3)
                                        ],
                                        center: .center,
                                        startRadius: 0,
                                        endRadius: 40
                                    )
                                )
                                .frame(width: 80, height: 80)
                                .blur(radius: 5)
                            
                            // Sun core
                            Circle()
                                .fill(Color(red: 1, green: 0.95, blue: 0.6))
                                .frame(width: 70, height: 70)
                        }
                    }
                    .opacity(isAwake ? 1 : 0)
                }
                .position(
                    x: isAwake ? geometry.size.width * 0.8 : geometry.size.width * 0.2,
                    y: geometry.size.height * 0.2
                )
                .animation(.easeInOut(duration: 0.6), value: isAwake)
            }
            .edgesIgnoringSafeArea(.all)
            
            // Settings button positioning
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        // Add your settings action here
                    }) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                    }
                }
                .padding(.top, 60) // Adjust for status bar
                .padding(.trailing, 16) // Standard iOS margin
                Spacer()
            }
            
            VStack {
                Spacer()
                
                // Speech bubble display with day/night specific messages
                if showSpeechBubble {
                    if isAwake {
                        // Day time messages only
                        HStack {
                            Spacer()
                            SpeechBubbleView(message: speechMessage)
                            Spacer()
                        }
                        .transition(.scale.combined(with: .opacity))
                    } else {
                        // Night time messages only
                        HStack {
                            Spacer()
                            SpeechBubbleView(message: "Time for me to rest! 😴")
                            Spacer()
                        }
                        .transition(.scale.combined(with: .opacity))
                    }
                } else if !isAwake && isFirstTime {
                    // Initial greeting message (night time only)
                    HStack {
                        Spacer()
                        SpeechBubbleView(message: "Hey! 👋 Tap me to wake me up and I'll guard your space! 🦊")
                        Spacer()
                    }
                    .transition(.scale.combined(with: .opacity))
                }
                
                // Fox container with bench shadow
                ZStack {
                    Ellipse()
                        .fill(Color.black.opacity(0.5))
                        .frame(width: 140, height: 25)
                        .blur(radius: 5)
                        .offset(y: 65)
                    
                    if isAwake {
                        ObservingFoxView(onLongPress: sleepFox)
                            .frame(width: 160, height: 160)
                            .offset(y: 30)
                    } else {
                        SleepingFoxView(onTap: awakeFox)
                            .frame(width: 160, height: 160)
                            .offset(y: 30)
                    }
                }
                .frame(height: 180)
                .padding(.bottom, 100)  // Fixed bottom padding so the fox sits on the bench
                
                Spacer()
                    .frame(height: 40)
            }
        }
    }
    
    private func awakeFox() {
        pendingMessageWork?.cancel()
        
        withAnimation {
            isAwake = true
            isFirstTime = false
            
            let workItem = DispatchWorkItem {
                speechMessage = "I'm awake and ready to guard! I'll keep my ears perked for any sounds! 🎧"
                withAnimation {
                    showSpeechBubble = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation {
                        showSpeechBubble = false
                    }
                    
                    let instructionWork = DispatchWorkItem {
                        speechMessage = "When you need a break, just long press me to let me rest! 😊"
                        withAnimation {
                            showSpeechBubble = true
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation {
                                showSpeechBubble = false
                            }
                        }
                    }
                    pendingMessageWork = instructionWork
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: instructionWork)
                }
            }
            
            pendingMessageWork = workItem
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: workItem)
        }
    }
    
    private func sleepFox() {
        pendingMessageWork?.cancel()
        
        withAnimation {
            isAwake = false
            isFirstTime = false
            speechMessage = "Time for me to rest! 😴"
            showSpeechBubble = true
            
            let workItem = DispatchWorkItem {
                withAnimation {
                    showSpeechBubble = false
                }
            }
            pendingMessageWork = workItem
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: workItem)
        }
    }
}

// Speech Bubble View
struct SpeechBubbleView: View {
    let message: String
    
    var body: some View {
        Text(message)
            .padding(15)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.95))
            )
            .foregroundColor(.black)
            .font(.system(size: 16, weight: .medium))
            .frame(maxWidth: 280)
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
    }
}

#Preview {
    ContentView()
}
