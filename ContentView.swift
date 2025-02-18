import SwiftUI
import QuartzCore

struct ContentView: View {
    @State private var isAwake = false
    @State private var isTransitioning = false
    @State private var drawingPath = Path()
    @State private var points: [CGPoint] = []
    @State private var breathingScale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            // Magical background
            RadialGradient(
                colors: [
                    isAwake ? .orange.opacity(0.3) : .blue.opacity(0.2),
                    .black
                ],
                center: .center,
                startRadius: 5,
                endRadius: 300
            )
            .ignoresSafeArea()
            
            // Drawing path for circle gesture
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
            
            // Glowing ring beneath fox (keeps its breathing animation)
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            isAwake ? .orange.opacity(0.3) : .blue.opacity(0.2),
                            .clear
                        ],
                        center: .center,
                        startRadius: 5,
                        endRadius: 100
                    )
                )
                .frame(width: 200, height: 200)
                .scaleEffect(breathingScale)
            
            // Fox animation:
            // In the sleeping state, tapping the fox triggers awakeFox().
            // In the observing state, a long press will trigger sleepFox() to revert back.
            if isAwake {
                ObservingFoxView(onLongPress: sleepFox)
                    .frame(width: 200, height: 200)
            } else {
                SleepingFoxView(onTap: awakeFox)
                    .frame(width: 200, height: 200)
            }
            
            // Status text
            VStack {
                Spacer()
                Text(isAwake ? "Listening for sounds..." : "Tap the fox or draw a circle to awaken")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.bottom, 50)
            }
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
        .onAppear {
            startBreathingAnimation() // Only the glowing ring still "breathes"
        }
    }
    
    private func awakeFox() {
        // Transition from sleeping to observing state
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            isTransitioning = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                isAwake = true
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
            withAnimation { isTransitioning = false }
        }
    }
    
    private func sleepFox() {
        // Transition back from observing to sleeping state when long pressed.
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            isAwake = false
        }
    }
    
    private func startBreathingAnimation() {
        // This animation only affects the glowing ring.
        withAnimation(
            .easeInOut(duration: 2)
                .repeatForever(autoreverses: true)
        ) {
            breathingScale = 1.05
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

// SleepingFoxView animates frames 1–11 (from asset names "1", "2", … "11") and triggers onTap to awaken.
struct SleepingFoxView: View {
    var onTap: () -> Void
    @State private var currentFrame = 1
    private let totalFrames = 11
    // Run updates every 0.1 seconds (10 FPS) for smooth animation.
    private let animationTimer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        Image("\(currentFrame)")  // Using asset names "1", "2", ..., "11"
            .resizable()
            .scaledToFit()
            .frame(width: 120, height: 120)
            .onTapGesture { onTap() }
            .onReceive(animationTimer) { _ in
                currentFrame = currentFrame < totalFrames ? currentFrame + 1 : 1
            }
    }
}

// ObservingFoxView animates frames 12–20 (using asset names "12", "13", ... "20") and triggers onLongPress to sleep.
struct ObservingFoxView: View {
    var onLongPress: () -> Void
    @State private var currentFrame = 12
    private let totalFrames = 20
    // Run updates every 0.1 seconds (10 FPS) for smooth animation.
    private let animationTimer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        Image("\(String(format: "%02d", currentFrame))")
            .resizable()
            .scaledToFit()
            .frame(width: 120, height: 120)
            .onReceive(animationTimer) { _ in
                currentFrame = currentFrame < totalFrames ? currentFrame + 1 : 12
            }
            .onLongPressGesture(minimumDuration: 0.5) {
                onLongPress()
            }
    }
}

// Helper shape for ears and nose (if needed elsewhere in your views)
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// Helper extensions
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
