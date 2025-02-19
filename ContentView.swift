import SwiftUI
import QuartzCore

struct ObservingFoxView: View {
    let onLongPress: () -> Void
    @State private var currentImageIndex = 12  // Starting from alert mode frame 12
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
            .onReceive(timer) { _ in
                withAnimation {
                    if currentImageIndex < 20 {
                        currentImageIndex += 1
                    } else {
                        currentImageIndex = 12  // Reset to first alert frame
                    }
                }
            }
    }
}

struct SleepingFoxView: View {
    let onTap: () -> Void
    @State private var currentImageIndex = 1  // Awake fox (1-9)
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        Image("\(currentImageIndex)")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .onTapGesture {
                onTap()
            }
            .onReceive(timer) { _ in
                withAnimation {
                    if currentImageIndex < 9 {
                        currentImageIndex += 1
                    } else {
                        currentImageIndex = 1
                    }
                }
            }
    }
}

struct ContentView: View {
    @State private var isAwake = false
    @State private var isTransitioning = false
    @State private var showSpeechBubble = false
    @State private var speechMessage = ""
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                // Switch between night and day background images
                if isAwake {
                    Image("dayBG")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                        .position(x: geometry.size.width/2, y: geometry.size.height/2)
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
                        .position(x: geometry.size.width/2, y: geometry.size.height/2)
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
                
                // Stars overlay with opacity animation
                ForEach(0..<50) { _ in
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
                        .animation(.easeInOut(duration: 0.6), value: isAwake)
                }
                
                // Enhanced Moon/Sun with more diffused glow
                ZStack {
                    if isAwake {
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
                    } else {
                        // Moon layers with pulsating effect
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color.white.opacity(0.15),
                                        Color.white.opacity(0.1),
                                        Color.white.opacity(0.05),
                                        Color.clear
                                    ],
                                    center: .center,
                                    startRadius: 30,
                                    endRadius: 180
                                )
                            )
                            .frame(width: 360, height: 360)
                            .blur(radius: 30)
                            .scaleEffect(1 + (isTransitioning ? 0.05 : 0))
                            .animation(Animation.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isTransitioning)
                            .onAppear { isTransitioning = true }
                        
                        // Middle soft glow with pulsating
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color.white.opacity(0.3),
                                        Color.white.opacity(0.2),
                                        Color.white.opacity(0.1),
                                        Color.clear
                                    ],
                                    center: .center,
                                    startRadius: 25,
                                    endRadius: 120
                                )
                            )
                            .frame(width: 240, height: 240)
                            .blur(radius: 20)
                            .scaleEffect(1 + (isTransitioning ? 0.03 : 0))
                            .animation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isTransitioning)
                        
                        // Inner bright glow
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color.white.opacity(0.8),
                                        Color.white.opacity(0.6),
                                        Color.white.opacity(0.4),
                                        Color.clear
                                    ],
                                    center: .center,
                                    startRadius: 15,
                                    endRadius: 60
                                )
                            )
                            .frame(width: 120, height: 120)
                            .blur(radius: 10)
                        
                        // Moon core
                        Circle()
                            .fill(Color.white)
                            .frame(width: 60, height: 60)
                            .blur(radius: 2)
                    }
                }
                .position(
                    x: isAwake ? geometry.size.width * 0.8 : geometry.size.width * 0.2,
                    y: geometry.size.height * 0.2
                )
            }
            .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                
                // Speech bubble
                if showSpeechBubble {
                    SpeechBubbleView(message: speechMessage)
                        .transition(.scale.combined(with: .opacity))
                } else if !isAwake {
                    // Initial instruction in speech bubble
                    SpeechBubbleView(message: "Hey! 👋 Tap me to wake me up and I'll guard your space! 🦊")
                        .transition(.scale.combined(with: .opacity))
                }
                
                // Fox with enhanced shadow
                ZStack {
                    // Enhanced shadow
                    Ellipse()
                        .fill(Color.black.opacity(0.5))
                        .frame(width: 140, height: 25)
                        .blur(radius: 5)
                        .offset(y: 65)
                    
                    if isAwake {
                        ObservingFoxView(onLongPress: sleepFox)
                            .frame(width: 160, height: 165)
                            .offset(y: 30)
                            .onAppear {
                                // Show sleep instruction after initial messages
                                DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
                                    speechMessage = "When you need a break, just long press me to let me rest! 😊"
                                    withAnimation {
                                        showSpeechBubble = true
                                    }
                                    
                                    // Hide the instruction after a few seconds
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                        withAnimation {
                                            showSpeechBubble = false
                                        }
                                    }
                                }
                            }
                    } else {
                        SleepingFoxView(onTap: awakeFox)
                            .frame(width: 160, height: 165)
                            .offset(y: 30)
                    }
                }
                .frame(height: 180)
                .padding(.bottom, 100)
                
                Spacer()
                    .frame(height: 40) // Consistent bottom spacing
            }
        }
    }
    
    private func awakeFox() {
        withAnimation {
            isAwake = true
            
            // Show welcome message
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                speechMessage = "I'm awake and ready to guard! I'll keep my ears perked for any sounds! 🎧"
                withAnimation {
                    showSpeechBubble = true
                }
                
                // Hide message after delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                    withAnimation {
                        showSpeechBubble = false
                    }
                }
            }
        }
    }
    
    private func sleepFox() {
        withAnimation {
            isAwake = false
            speechMessage = "Time for me to rest! Just tap me whenever you need me again! 😴"
            showSpeechBubble = true
            
            // Hide sleep message after delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation {
                    showSpeechBubble = false
                }
            }
        }
    }
}

// Speech Bubble View remains the same
struct SpeechBubbleView: View {
    let message: String
    
    var body: some View {
        Text(message)
            .padding(15)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.95))
                    .overlay(
                        Path { path in
                            path.move(to: CGPoint(x: 100, y: 0))
                            path.addLine(to: CGPoint(x: 120, y: 20))
                            path.addLine(to: CGPoint(x: 140, y: 0))
                            path.closeSubpath()
                        }
                        .fill(Color.white.opacity(0.95))
                        .offset(y: 35)
                    )
            )
            .foregroundColor(.black)
            .font(.system(size: 16, weight: .medium))
            .frame(maxWidth: 280)
            .padding(.bottom, 40)
    }
}

#Preview {
    ContentView()
}
