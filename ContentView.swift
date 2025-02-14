import SwiftUI

struct ContentView: View {
    @State private var isListening = false
    @State private var animationPhase = 0.0
    @State private var waveformPhase = 0.0
    
    let backgroundColor = Color(hex: "#021826")
    let buttonColor = Color(hex: "#05BFDB")
    let auraColors = [
        Color(hex: "#0E6BA8"),
        Color(hex: "#0A9396"),
        Color(hex: "#06D6A0"),
        Color(hex: "#118AB2"),
        Color(hex: "#073B4C")
    ]
    
    let timer = Timer.publish(every: 0.016, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationView {
            ZStack {
                backgroundColor
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Settings icon
                    HStack {
                        Spacer()
                        NavigationLink(destination: Text("Settings Page")) {
                            Image(systemName: "gearshape.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .opacity(0.9)
                                .padding()
                        }
                    }
                    
                    // Label
                    Text(isListening ? "Tap to stop EchoWare" : "Tap to start EchoWare")
                        .foregroundColor(.white)
                        .font(.headline)
                        .opacity(0.9)
                        .padding(.top, 8)
                    
                    Spacer()
                    
                    // Main button and aura
                    ZStack {
                        if isListening {
                            // Outer aura layers
                            Group {
                                ForEach(0..<5) { index in
                                    AuraLayer(
                                        color: auraColors[index],
                                        scale: 1.2 + Double(index) * 0.1 + sin(animationPhase * 0.02 + Double(index) * 0.5) * 0.2,
                                        opacity: 0.15
                                    )
                                    .blur(radius: CGFloat(15 + index * 5))
                                }
                            }
                            
                            // Refined inner glow - multiple subtle layers
                            Group {
                                // Soft gradient edge
                                Circle()
                                    .stroke(
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                buttonColor.opacity(0.3),
                                                buttonColor.opacity(0)
                                            ]),
                                            startPoint: .center,
                                            endPoint: .top
                                        ),
                                        lineWidth: 0.5
                                    )
                                    .scaleEffect(1.02)
                                    .blur(radius: 2)
                                
                                // Very subtle outer ring
                                Circle()
                                    .stroke(buttonColor.opacity(0.1), lineWidth: 0.2)
                                    .scaleEffect(1.03)
                                    .blur(radius: 1)
                                
                                // Soft glow around button
                                Circle()
                                    .fill(
                                        RadialGradient(
                                            gradient: Gradient(colors: [
                                                buttonColor.opacity(0.2),
                                                buttonColor.opacity(0)
                                            ]),
                                            center: .center,
                                            startRadius: 70,
                                            endRadius: 90
                                        )
                                    )
                                    .scaleEffect(1.1)
                            }
                        }
                        
                        // Main button
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isListening.toggle()
                            }
                        }) {
                            Circle()
                                .fill(buttonColor)
                                .frame(width: 150, height: 150)
                                .overlay(
                                    Group {
                                        if isListening {
                                            // Animated waveform
                                            HStack(spacing: 4) {
                                                ForEach(0..<5) { index in
                                                    RoundedRectangle(cornerRadius: 2)
                                                        .fill(Color.white)
                                                        .frame(width: 4, height: getWaveformHeight(index: index))
                                                        .animation(
                                                            Animation.easeInOut(duration: 0.5)
                                                                .repeatForever()
                                                                .delay(Double(index) * 0.1),
                                                            value: waveformPhase
                                                        )
                                                }
                                            }
                                        } else {
                                            Image(systemName: "power")
                                                .font(.system(size: 40))
                                                .foregroundColor(.white)
                                        }
                                    }
                                )
                                .shadow(
                                    color: buttonColor.opacity(isListening ? 0.4 : 0.2),
                                    radius: isListening ? 12 : 8
                                )
                        }
                    }
                    .frame(width: 150, height: 150)
                    
                    Spacer()
                    
                    // Navigation button to ListeningScreen
                    NavigationLink(destination: ListeningScreen()) {
                        Text("Next Screen")
                            .foregroundColor(.white)
                            .font(.headline)
                            .padding()
                            .background(
                                Capsule()
                                    .fill(buttonColor.opacity(0.3))
                            )
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationBarHidden(true)
        }
        .onReceive(timer) { _ in
            if isListening {
                withAnimation(.linear(duration: 0.016)) {
                    animationPhase += 1
                    waveformPhase += 1
                }
            }
        }
    }
    
    func getWaveformHeight(index: Int) -> CGFloat {
        let baseHeight: CGFloat = 30
        let variance: CGFloat = 20
        return baseHeight + variance * sin(waveformPhase * 0.1 + Double(index) * 0.5)
    }
}

// AuraLayer helper view
struct AuraLayer: View {
    let color: Color
    let scale: Double
    let opacity: Double
    
    var body: some View {
        Circle()
            .fill(color)
            .opacity(opacity)
            .scaleEffect(scale)
    }
}

// Color extension for hex support
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
