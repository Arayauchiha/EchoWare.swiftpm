import SwiftUI
import AVFoundation

struct PlayerView: View {
    @Environment(\.dismiss) private var dismiss  // Add this line
    @Binding var shouldPauseFromDetection: Bool
    @State private var isPlaying = false
    @State private var progress: Double = 0
    @State private var volume: Double = 0.5
    @State private var currentTime: TimeInterval = 0
    @State private var duration: TimeInterval = 180 // 3 minutes demo duration
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        NavigationView {  // Add this NavigationView
            VStack(spacing: 30) {
                // Album Art
                ZStack {
                    Circle()
                        .fill(Color.purple.opacity(0.1))
                        .frame(width: 250, height: 250)
                    
                    Image(systemName: "music.note")
                        .font(.system(size: 100))
                        .foregroundColor(.purple)
                }
                .padding(.top, 40)
                
                // Song Info
                VStack(spacing: 8) {
                    Text("Test Sound")
                        .font(.title2)
                        .bold()
                    Text("Background Music")
                        .foregroundColor(.secondary)
                }
                
                // Progress Bar
                VStack(spacing: 8) {
                    Slider(value: $progress)
                        .tint(.purple)
                    
                    HStack {
                        Text(formatTime(currentTime))
                        Spacer()
                        Text(formatTime(duration))
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                
                // Playback Controls
                HStack(spacing: 40) {
                    Button(action: {}) {
                        Image(systemName: "backward.fill")
                            .font(.title)
                    }
                    
                    Button(action: {
                        withAnimation {
                            if (!shouldPauseFromDetection) {
                                isPlaying.toggle()
                            }
                        }
                    }) {
                        Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 65))
                    }
                    
                    Button(action: {}) {
                        Image(systemName: "forward.fill")
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
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Test Sounds")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .onChange(of: shouldPauseFromDetection) { shouldPause in
            if shouldPause {
                withAnimation {
                    isPlaying = false
                    currentTime = 0
                    progress = 0
                }
            }
        }
        .onReceive(timer) { _ in
            if isPlaying && !shouldPauseFromDetection {
                currentTime = min(currentTime + 1, duration)
                progress = currentTime / duration
            }
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}