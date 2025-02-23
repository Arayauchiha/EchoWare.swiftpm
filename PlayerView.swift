import SwiftUI
import AVFoundation

@MainActor
final class AudioPlayerManager: ObservableObject, @unchecked Sendable {
    static let shared = AudioPlayerManager()
    @Published var isPlaying = false
    @Published var wasPlayingBeforePause = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 180 // 3 minutes demo duration
    
    private var timer: Timer?
    
    private init() {
        // Start playing by default when initialized
        startPlaying()
    }
    
    func startPlaying() {
        isPlaying = true
        startTimer()
    }
    
    func pauseForNotification() {
        if isPlaying {
            wasPlayingBeforePause = true
            isPlaying = false
            stopTimer()
        }
    }
    
    func resumeIfNeeded() {
        if wasPlayingBeforePause {
            isPlaying = true
            wasPlayingBeforePause = false
            startTimer()
        }
    }
    
    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                if self.isPlaying {
                    self.currentTime += 1
                    if self.currentTime >= self.duration {
                        self.currentTime = 0 // Loop back to start
                    }
                }
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // Nonisolated cleanup that doesn't directly access timer property
    nonisolated private func cleanup() {
        Task { @MainActor [weak self] in
            self?.stopTimer()
        }
    }
    
    deinit {
        cleanup()
    }
}

struct PlayerView: View {
    @StateObject private var playerManager = AudioPlayerManager.shared
    @State private var volume: Double = 0.5
    @State private var showResumePrompt = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Album Art / Visualization
                ZStack {
                    Circle()
                        .fill(Color.purple.opacity(0.1))
                        .frame(width: 250, height: 250)
                    
                    if playerManager.isPlaying {
                        // Add pulsing animation when playing
                        Circle()
                            .stroke(Color.purple.opacity(0.3), lineWidth: 2)
                            .frame(width: 260, height: 260)
                            .scaleEffect(playerManager.isPlaying ? 1.2 : 1.0)
                            .opacity(playerManager.isPlaying ? 0 : 1)
                            .animation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: false), value: playerManager.isPlaying)
                    }
                    
                    Image(systemName: "music.note")
                        .font(.system(size: 100))
                        .foregroundColor(.purple)
                }
                .padding(.top, 40)
                
                // Song Title and Artist
                VStack(spacing: 8) {
                    Text("Test Sound")
                        .font(.title2)
                        .bold()
                    Text("Background Music")
                        .foregroundColor(.secondary)
                }
                
                // Progress Bar
                VStack(spacing: 8) {
                    Slider(
                        value: .init(
                            get: { playerManager.currentTime },
                            set: { newValue in
                                playerManager.currentTime = newValue
                            }
                        ),
                        in: 0...playerManager.duration
                    )
                    .tint(.purple)
                    
                    HStack {
                        Text(formatTime(playerManager.currentTime))
                        Spacer()
                        Text(formatTime(playerManager.duration))
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                
                // Playback Controls
                HStack(spacing: 40) {
                    Button(action: {
                        playerManager.currentTime = max(0, playerManager.currentTime - 10)
                    }) {
                        Image(systemName: "gobackward.10")
                            .font(.title)
                    }
                    
                    Button(action: {
                        if playerManager.isPlaying {
                            playerManager.pauseForNotification()
                        } else {
                            playerManager.startPlaying()
                        }
                    }) {
                        Image(systemName: playerManager.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 65))
                    }
                    
                    Button(action: {
                        playerManager.currentTime = min(playerManager.duration, playerManager.currentTime + 10)
                    }) {
                        Image(systemName: "goforward.10")
                            .font(.title)
                    }
                }
                .foregroundColor(.purple)
                
                // Volume Control
                HStack {
                    Image(systemName: "speaker.fill")
                        .foregroundColor(.secondary)
                    Slider(value: $volume)
                        .tint(.purple)
                    Image(systemName: "speaker.wave.3.fill")
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                
                // Warning Message
                VStack {
                    Text("⚠️ Important Note")
                        .font(.headline)
                    Text("Sound detection works best with earphones")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 12)
                    .fill(Color.purple.opacity(0.1)))
                .padding()
                
                Spacer()
            }
            .navigationTitle("Player")
            .onAppear {
                playerManager.startPlaying()
            }
        }
        .alert("Resume Music?", isPresented: $showResumePrompt) {
            Button("Resume") {
                playerManager.resumeIfNeeded()
            }
            Button("Keep Paused", role: .cancel) {
                playerManager.wasPlayingBeforePause = false
            }
        } message: {
            Text("Would you like to resume your music?")
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

#Preview {
    PlayerView()
}