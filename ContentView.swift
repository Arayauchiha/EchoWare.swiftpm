import Foundation
import AVFoundation
import SoundAnalysis
import Combine
import SwiftUI

class AudioRecorder: ObservableObject {
    private var audioEngine = AVAudioEngine()
    private var streamAnalyzer: SNAudioStreamAnalyzer?
    private var resultsObserver: ResultsObserver?
    
    @Published var isDoorBellDetected: Bool = false
    @Published var doorbellConfidence: Double = 0.0
    
    // Inner class to handle sound classification results
    private class ResultsObserver: NSObject, SNResultsObserving {
        weak var parent: AudioRecorder?
        
        func request(_ request: SNRequest, didProduce result: SNResult) {
            guard let result = result as? SNClassificationResult else { return }
            
            // Look for doorbell classifications
            let doorbellResult = result.classification(forIdentifier: "door_bell")
            print(doorbellResult)
            if let doorbellResult = doorbellResult {
                DispatchQueue.global().async {
                    self.parent?.doorbellConfidence = doorbellResult.confidence
                    self.parent?.isDoorBellDetected = doorbellResult.confidence > 0.8
                    print(doorbellResult.confidence)
                }
            }
        }
        
        func request(_ request: SNRequest, didFailWithError error: Error) {
            print("Sound classification failed: \(error.localizedDescription)")
        }
        
        func requestDidComplete(_ request: SNRequest) {
            print("Sound classification completed")
        }
    }
    
    func getListOfRecognizedSounds() throws -> [String] {
        let request = try SNClassifySoundRequest(classifierIdentifier: .version1)
        return request.knownClassifications
    }

    func startListening() {
        try? print(getListOfRecognizedSounds())
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .default)
            try audioSession.setActive(true)
        } catch {
            print("Failed to set up audio session: \(error.localizedDescription)")
            return
        }
        
        // Create analyzer and request
        let inputFormat = audioEngine.inputNode.outputFormat(forBus: 0)
        streamAnalyzer = SNAudioStreamAnalyzer(format: inputFormat)
        
        do {
            let request = try SNClassifySoundRequest(classifierIdentifier: .version1)
            resultsObserver = ResultsObserver()
            resultsObserver?.parent = self
            
            try streamAnalyzer?.add(request, withObserver: resultsObserver!)
        } catch {
            print("Failed to create sound classification request: \(error.localizedDescription)")
            return
        }
        
        // Install tap and start audio engine
        audioEngine.inputNode.installTap(onBus: 0,
                                       bufferSize: 8192,
                                       format: inputFormat) { [weak self] buffer, time in
            self?.streamAnalyzer?.analyze(buffer,
                                        atAudioFramePosition: time.sampleTime)
        }
        
        do {
            try audioEngine.start()
            print("Audio engine started successfully")
        } catch {
            print("Failed to start audio engine: \(error.localizedDescription)")
            stopListening()
        }
    }
    
    func stopListening() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        streamAnalyzer = nil
        resultsObserver = nil
        
        do {
            try AVAudioSession.sharedInstance().setActive(false)
        } catch {
            print("Failed to deactivate audio session: \(error.localizedDescription)")
        }
        
        print("Audio recording stopped")
    }
}

struct ObservingFoxView: View {
    let onLongPress: () -> Void
    @State private var currentImageIndex = 12
    @State private var isListening = false
    @State private var pulseColor = Color.blue.opacity(0.8)
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Image("\(currentImageIndex)")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .gesture(
                    LongPressGesture(minimumDuration: 0.5)
                        .onEnded { _ in
                            onLongPress()
                        }
                )
                .overlay(
                    // Sound wave indicators near ears
                    ZStack {
                        // Left ear waves - Reversed sizes
//                        ForEach(0..<3) { index in
//                            Arc(startAngle: .degrees(360), endAngle: .degrees(90))
//                                .stroke(pulseColor, lineWidth: 2)
//                                .frame(width: 55 - CGFloat(index * 8), height: 55 - CGFloat(index * 8))
//                                .offset(x: -45, y: -65)
//                                .scaleEffect(isListening ? 1.2 : 0.6) // Normal scale effect
//                                .opacity(isListening ? 0 : 0.8) // Fade out as it gets bigger
//                        }
                        
                        // Right ear waves - Reversed sizes
                        ForEach(0..<3) { index in
                            Arc(startAngle: .degrees(90), endAngle: .degrees(180))
                                .stroke(pulseColor, lineWidth: 2)
                                .frame(width: 55 - CGFloat(index * 8), height: 55 - CGFloat(index * 8))
                                .offset(x: 35, y: -65)
                                .scaleEffect(isListening ? 1.2 : 0.6) // Normal scale effect
                                .opacity(isListening ? 0 : 0.8) // Fade out as it gets bigger
                        }
                    }
                    .animation(.easeIn(duration: 0.6).repeatForever(), value: isListening)
                )
                .onReceive(timer) { _ in
                    if currentImageIndex < 20 {
                        currentImageIndex += 1
                    } else {
                        currentImageIndex = 12
                    }
                    
                    withAnimation(.easeInOut(duration: 0.8)) {
                        isListening.toggle()
                        pulseColor = isListening ? Color.blue.opacity(0.6) : Color.cyan.opacity(0.6)
                    }
                }
        }
    }
}

// Add this shape for the curved sound waves
struct Arc: Shape {
    let startAngle: Angle
    let endAngle: Angle
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addArc(center: CGPoint(x: rect.midX, y: rect.midY),
                   radius: rect.width / 2,
                   startAngle: startAngle,
                   endAngle: endAngle,
                   clockwise: false)
        return path
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

struct Star: Identifiable {
    let id = UUID()
    let x: CGFloat
    let y: CGFloat
    let size: CGFloat
    let opacity: Double
    
    static func random(in rect: CGRect) -> Star {
        Star(
            x: .random(in: 0...rect.width),
            y: .random(in: 0...(rect.height * 0.6)), // Only use top 60% of height
            size: .random(in: 1...3),
            opacity: .random(in: 0.5...1.0)
        )
    }
}

struct StarFieldView: View {
    let stars: [Star]
    @State private var twinkleState = false
    
    var body: some View {
        Canvas { context, size in
            for star in stars {
                let opacity = twinkleState ? star.opacity : star.opacity * 0.5
                context.opacity = opacity
                context.fill(
                    Path(ellipseIn: CGRect(
                        x: star.x,
                        y: star.y,
                        width: star.size,
                        height: star.size
                    )),
                    with: .color(.white)
                )
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever()) {
                twinkleState.toggle()
            }
        }
    }
}

struct ContentView: View {
    var audioRecorder = AudioRecorder()
    @AppStorage("alertStyle") private var alertStyle = 0
    @State private var isAwake = false
    @State private var isTransitioning = false
    @State private var showSpeechBubble = false
    @State private var speechMessage = ""
    @State private var isFirstTime = true
    @State private var pendingMessageWork: DispatchWorkItem?
    @State private var showPlayer = false
    @State private var indicatorOpacity: Double = 0
    @State private var stars: [Star] = []
    
    var body: some View {
        NavigationView {
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
                    } else {
                        ZStack {
                            Image("pixelcut-export")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: geometry.size.width, height: geometry.size.height)
                                .clipped()
                                .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                                .transition(.opacity)
                            
                            StarFieldView(stars: stars)
                                .frame(width: geometry.size.width, height: geometry.size.height)
                                .clipShape(
                                    Rectangle()
                                        .size(
                                            width: geometry.size.width,
                                            height: geometry.size.height * 0.6
                                        )
                                )
                            
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
                        }
                    }
                    
                    // Moon/Sun Container with enhanced glow
                    ZStack {
                        // Base celestial body
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        isAwake ? Color.yellow : .white,
                                        isAwake ? Color.orange.opacity(0.8) : .white.opacity(0.6),
                                        .clear
                                    ],
                                    center: .center,
                                    startRadius: isAwake ? 20 : 15,
                                    endRadius: isAwake ? 100 : 60
                                )
                            )
                            .frame(width: isAwake ? 80 : 60, height: isAwake ? 80 : 60)
                            
                        // Inner glow
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        isAwake ? Color.yellow.opacity(0.8) : .white.opacity(0.8),
                                        isAwake ? Color.orange.opacity(0.4) : .white.opacity(0.4),
                                        .clear
                                    ],
                                    center: .center,
                                    startRadius: isAwake ? 10 : 5,
                                    endRadius: isAwake ? 80 : 60
                                )
                            )
                            .blur(radius: 15)
                            .frame(width: isAwake ? 140 : 120, height: isAwake ? 140 : 120)
                            
                        // Outer glow
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        isAwake ? Color.yellow.opacity(0.4) : .white.opacity(0.4),
                                        isAwake ? Color.orange.opacity(0.2) : .white.opacity(0.2),
                                        .clear
                                    ],
                                    center: .center,
                                    startRadius: isAwake ? 20 : 15,
                                    endRadius: isAwake ? 100 : 80
                                )
                            )
                            .blur(radius: 20)
                            .frame(width: isAwake ? 180 : 160, height: isAwake ? 180 : 160)
                    }
                    .position(
                        x: isAwake ? UIScreen.main.bounds.width * 0.8 : UIScreen.main.bounds.width * 0.2,
                        y: UIScreen.main.bounds.height * 0.25
                    )
                    .animation(.easeInOut(duration: 0.6), value: isAwake)
                }
                .edgesIgnoringSafeArea(.all)
                
                // Swipe gesture area with visual indicator
                if isAwake {
                    VStack {
                        Spacer()
                        // Swipe indicator
                        VStack(spacing: 4) {
                            Image(systemName: "chevron.up")
                                .font(.system(size: 20, weight: .medium))
                            Text("Swipe up for test sounds")
                                .font(.caption)
                        }
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.bottom, 8)
                        .opacity(indicatorOpacity)
                        
                        Rectangle()
                            .fill(Color.clear)
                            .frame(height: 100)
                            .contentShape(Rectangle())
                            .gesture(
                                DragGesture(minimumDistance: 50)
                                    .onEnded { gesture in
                                        if gesture.translation.height < -50 {
                                            showPlayer = true
                                        }
                                    }
                            )
                    }
                }
                
                VStack {
                    Spacer()
                    
                    // Speech bubble display
                    if showSpeechBubble {
                        if isAwake {
                            HStack {
                                Spacer()
                                SpeechBubbleView(message: speechMessage)
                                Spacer()
                            }
                            .transition(.scale.combined(with: .opacity))
                        } else {
                            HStack {
                                Spacer()
                                SpeechBubbleView(message: "Time for me to rest! 😴")
                                Spacer()
                            }
                            .transition(.scale.combined(with: .opacity))
                        }
                    } else if !isAwake && isFirstTime {
                        HStack {
                            Spacer()
                            SpeechBubbleView(message: "Hey! 👋 Tap me to wake me up and I'll guard your space! 🦊")
                            Spacer()
                        }
                        .transition(.scale.combined(with: .opacity))
                        .onAppear {
                            // Auto-dismiss first time message after 4 seconds
                            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                                withAnimation {
                                    if !isAwake && isFirstTime {
                                        isFirstTime = false
                                    }
                                }
                            }
                        }
                    }
                    
                    // Fox container
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
                    .padding(.bottom, 138)
                    .zIndex(1)
                }
            }
            .fullScreenCover(isPresented: $showPlayer) {
                NavigationView {
                    PlayerView()
                        .navigationTitle("Test Sounds")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button("Done") {
                                    showPlayer = false
                                }
                            }
                        }
                }
            }
            .navigationTitle("EchoWare")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape.fill")
                            .foregroundColor(isAwake ? .black : .white)
                    }
                }
            }
            .onAppear {
                // Generate random stars
                let screenBounds = UIScreen.main.bounds
                stars = (0..<100).map { _ in
                    Star.random(in: screenBounds)
                }
            }
        }
    }
    
    private func awakeFox() {
        audioRecorder.startListening()
        pendingMessageWork?.cancel()
        
        Task {
            HapticManager.shared.playSuccess()
        }
        
        withAnimation {
            isAwake = true
            isFirstTime = false
            
            // First message
            let workItem = DispatchWorkItem {
                speechMessage = "I'm awake and ready to guard! I'll keep my ears perked for any sounds! 🎧"
                withAnimation {
                    showSpeechBubble = true
                }
                
                // Second message about long press
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    withAnimation {
                        showSpeechBubble = false
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        speechMessage = "You can long press on me anytime to let me rest! 😴"
                        withAnimation {
                            showSpeechBubble = true
                        }
                        
                        // Third message about test sounds
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation {
                                showSpeechBubble = false
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                speechMessage = "Want to see how I detect sounds? Swipe up to try some test sounds! 🎵"
                                withAnimation {
                                    showSpeechBubble = true
                                }
                                
                                // Show the swipe indicator after the message
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    indicatorOpacity = 1
                                }
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    withAnimation {
                                        showSpeechBubble = false
                                    }
                                    
                                    // Fade out indicator after a delay
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        withAnimation {
                                            indicatorOpacity = 0
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            pendingMessageWork = workItem
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: workItem)
        }
    }
    
    private func sleepFox() {
        audioRecorder.stopListening()
        pendingMessageWork?.cancel()
        
        Task {
            HapticManager.shared.playMediumImpact()
        }
        
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
    
    private func onSoundDetected() {
        if alertStyle != 0 {
            Task {
                HapticManager.shared.playWarning()
            }
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
