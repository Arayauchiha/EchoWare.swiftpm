import SwiftUI
import QuartzCore

struct ContentView: View {
    @State private var isAwake = false
    @State private var isTransitioning = false
    @State private var drawingPath = Path()
    @State private var points: [CGPoint] = []
    
    var body: some View {
        ZStack {
            // Background image with centered positioning
            GeometryReader { geometry in
                Image("pixelcut-export")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                    .position(x: geometry.size.width/2, y: geometry.size.height/2)
                
                // Stars overlay
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
                        .opacity(Double.random(in: 0.3...0.8))
                }
                
                // Moon/Sun with animation
                ZStack {
                    // Outer glow
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    (isAwake ? Color.yellow : Color.white).opacity(0.3),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 20,
                                endRadius: 60
                            )
                        )
                        .frame(width: 120, height: 120)
                    
                    // Inner glow
                    Circle()
                        .fill((isAwake ? Color.yellow : Color.white).opacity(0.7))
                        .frame(width: 50, height: 50)
                        .blur(radius: 5)
                    
                    // Celestial body
                    Circle()
                        .fill(isAwake ? Color.yellow : Color.white)
                        .frame(width: 40, height: 40)
                }
                .position(
                    x: isAwake ? geometry.size.width * 0.8 : geometry.size.width * 0.2,
                    y: geometry.size.height * 0.2
                )
                .animation(.spring(response: 0.6, dampingFraction: 0.7), value: isAwake)
            }
            .edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                
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
                            .frame(width: 160, height: 160)
                            .offset(y: 30)
                    } else {
                        SleepingFoxView(onTap: awakeFox)
                            .frame(width: 160, height: 160)
                            .offset(y: 30)
                    }
                }
                .frame(height: 180)
                .padding(.bottom, 70)
                
                Text(isAwake ? "Listening for sounds..." : "Tap the fox or draw a circle to awaken")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.bottom, 40)
            }
            
            // Drawing path overlay
            drawingPath
                .stroke(
                    LinearGradient(
                        colors: [.blue.opacity(0.5), .purple.opacity(0.5)],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 2, lineCap: .round)
                )
                .opacity(points.isEmpty ? 0 : 0.7)
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    let point = value.location
                    points.append(point)
                    
                    drawingPath = Path { path in
                        guard let firstPoint = points.first else { return }
                        path.move(to: firstPoint)
                        for point in points.dropFirst() {
                            path.addLine(to: point)
                        }
                    }
                }
                .onEnded { _ in
                    if isCircular(points) && !isAwake {
                        awakeFox()
                    }
                    withAnimation {
                        points.removeAll()
                        drawingPath = Path()
                    }
                }
        )
    }
    
    private func awakeFox() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            isTransitioning = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                isAwake = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            withAnimation {
                isTransitioning = false
            }
        }
    }
    
    private func sleepFox() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            isAwake = false
        }
    }
    
    private func isCircular(_ points: [CGPoint]) -> Bool {
        guard points.count >= 20 else { return false }
        
        let center = points.reduce(.zero) { $0 + $1 } / CGFloat(points.count)
        let avgRadius = points.map { $0.distance(to: center) }
            .reduce(0, +) / CGFloat(points.count)
        
        return points.allSatisfy { point in
            let distance = point.distance(to: center)
            return abs(distance - avgRadius) < 30
        }
    }
}

// MARK: - Background Views and Shapes

struct CherryBlossomTree: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        
        // Trunk
        path.addRect(CGRect(x: width * 0.45,
                           y: height * 0.5,
                           width: width * 0.1,
                           height: height * 0.5))
        
        // Main branches
        path.move(to: CGPoint(x: width * 0.5, y: height * 0.5))
        path.addLine(to: CGPoint(x: width * 0.3, y: height * 0.3))
        path.move(to: CGPoint(x: width * 0.5, y: height * 0.5))
        path.addLine(to: CGPoint(x: width * 0.7, y: height * 0.3))
        path.move(to: CGPoint(x: width * 0.5, y: height * 0.4))
        path.addLine(to: CGPoint(x: width * 0.2, y: height * 0.2))
        path.move(to: CGPoint(x: width * 0.5, y: height * 0.4))
        path.addLine(to: CGPoint(x: width * 0.8, y: height * 0.2))
        
        return path
    }
}

struct ParkBench: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        
        // Seat
        path.addRect(CGRect(x: width * 0.1, 
                           y: height * 0.3,
                           width: width * 0.8,
                           height: height * 0.15))
        
        // Backrest
        path.addRect(CGRect(x: width * 0.1,
                           y: height * 0.1,
                           width: width * 0.8,
                           height: height * 0.1))
        
        // Left legs
        path.addRect(CGRect(x: width * 0.15,
                           y: height * 0.3,
                           width: width * 0.08,
                           height: height * 0.6))
        
        // Right legs
        path.addRect(CGRect(x: width * 0.77,
                           y: height * 0.3,
                           width: width * 0.08,
                           height: height * 0.6))
        
        return path
    }
}

struct PerspectiveBackground: View {
    let isAwake: Bool
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Night sky gradient with deeper blues
                LinearGradient(
                    colors: [
                        Color(red: 0.05, green: 0.1, blue: 0.2),    // Deep blue
                        Color(red: 0.1, green: 0.2, blue: 0.35),    // Mid blue
                        Color(red: 0.15, green: 0.3, blue: 0.45)    // Light blue horizon
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                // Stars with varying sizes and glows
                ForEach(0..<80) { _ in
                    let size = CGFloat.random(in: 2...4)
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.5))
                            .frame(width: size * 1.5, height: size * 1.5)
                            .blur(radius: 1)
                        
                        Circle()
                            .fill(Color.white)
                            .frame(width: size, height: size)
                    }
                    .position(
                        x: CGFloat.random(in: 0...geometry.size.width),
                        y: CGFloat.random(in: 0...geometry.size.height * 0.6)
                    )
                    .opacity(Double.random(in: 0.5...1.0))
                }
                
                // Glowing moon
                ZStack {
                    // Outer glow
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.white.opacity(0.3),
                                    Color.white.opacity(0.0)
                                ],
                                center: .center,
                                startRadius: 30,
                                endRadius: 100
                            )
                        )
                        .frame(width: 200, height: 200)
                    
                    // Inner glow
                    Circle()
                        .fill(Color.white.opacity(0.6))
                        .frame(width: 100, height: 100)
                        .blur(radius: 10)
                    
                    // Moon body
                    Circle()
                        .fill(Color.white)
                        .frame(width: 80, height: 80)
                }
                .position(x: geometry.size.width * 0.75, y: geometry.size.height * 0.25)
                
                // Curved snowy ground
                Path { path in
                    path.move(to: CGPoint(x: 0, y: geometry.size.height * 0.65))
                    path.addCurve(
                        to: CGPoint(x: geometry.size.width, y: geometry.size.height * 0.65),
                        control1: CGPoint(x: geometry.size.width * 0.3, y: geometry.size.height * 0.6),
                        control2: CGPoint(x: geometry.size.width * 0.7, y: geometry.size.height * 0.7)
                    )
                    path.addLine(to: CGPoint(x: geometry.size.width, y: geometry.size.height))
                    path.addLine(to: CGPoint(x: 0, y: geometry.size.height))
                    path.closeSubpath()
                }
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.2, green: 0.4, blue: 0.5),  // Lighter snow
                            Color(red: 0.1, green: 0.2, blue: 0.35)  // Darker snow shadow
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                
                // Layered pine trees
                ForEach(0..<3) { row in
                    ForEach(-6...6, id: \.self) { index in
                        CurvedPineTree()
                            .fill(Color(red: 0.1, green: 0.15, blue: 0.25))
                            .frame(
                                width: 60 - CGFloat(row) * 10,
                                height: 120 - CGFloat(row) * 20
                            )
                            .position(
                                x: geometry.size.width * (0.5 + Double(index) * (0.1 - Double(row) * 0.02)),
                                y: geometry.size.height * (0.55 + Double(row) * 0.05)
                            )
                            .opacity(1.0 - Double(row) * 0.2)
                    }
                }
            }
        }
    }
}

struct CurvedPineTree: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        
        // Trunk
        path.addRect(CGRect(x: width * 0.45,
                           y: height * 0.7,
                           width: width * 0.1,
                           height: height * 0.3))
        
        // Curved triangle sections for more natural look
        for i in 0..<4 {
            let sectionHeight = height * 0.25
            let yOffset = height * CGFloat(i) * 0.2
            let sectionWidth = width * (1.0 - CGFloat(i) * 0.15)
            
            path.move(to: CGPoint(x: width/2, y: yOffset))
            
            // Left curve
            path.addCurve(
                to: CGPoint(x: (width - sectionWidth)/2, y: yOffset + sectionHeight),
                control1: CGPoint(x: width/2 - sectionWidth/4, y: yOffset + sectionHeight/3),
                control2: CGPoint(x: (width - sectionWidth)/2, y: yOffset + sectionHeight/2)
            )
            
            // Right curve
            path.addCurve(
                to: CGPoint(x: width/2, y: yOffset),
                control1: CGPoint(x: (width + sectionWidth)/2, y: yOffset + sectionHeight),
                control2: CGPoint(x: width/2 + sectionWidth/4, y: yOffset + sectionHeight/3)
            )
        }
        
        return path
    }
}

// MARK: - Fox Animation Views

struct SleepingFoxView: View {
    var onTap: () -> Void
    @State private var currentFrame = 1
    private let totalFrames = 11
    private let animationTimer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        Image("\(currentFrame)")
            .resizable()
            .scaledToFit()
            .onTapGesture { onTap() }
            .onReceive(animationTimer) { _ in
                currentFrame = currentFrame < totalFrames ? currentFrame + 1 : 1
            }
    }
}

struct ObservingFoxView: View {
    var onLongPress: () -> Void
    @State private var currentFrame = 12
    private let totalFrames = 20
    private let animationTimer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        Image("\(String(format: "%02d", currentFrame))")
            .resizable()
            .scaledToFit()
            .onReceive(animationTimer) { _ in
                currentFrame = currentFrame < totalFrames ? currentFrame + 1 : 12
            }
            .onLongPressGesture(minimumDuration: 0.5) {
                onLongPress()
            }
    }
}

// MARK: - Helper Extensions

extension CGPoint {
    static func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    
    static func /(lhs: CGPoint, rhs: CGFloat) -> CGPoint {
        CGPoint(x: lhs.x / rhs, y: lhs.y / rhs)
    }
    
    func distance(to point: CGPoint) -> CGFloat {
        sqrt(pow(x - point.x, 2) + pow(y - point.y, 2))
    }
}

#Preview {
    ContentView()
}
