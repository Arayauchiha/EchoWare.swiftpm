import SwiftUI
import AVFoundation

struct PlayerView: View {
    @State private var isPlaying = false
    @State private var progress: Double = 0
    @State private var currentTime: TimeInterval = 0
    @State private var duration: TimeInterval = 0
    @State private var volume: Double = 0.5
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Album Art / Visualization
                ZStack {
                    Circle()
                        .fill(Color.purple.opacity(0.1))
                        .frame(width: 250, height: 250)
                    
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
                    Button(action: {
                        // Previous
                    }) {
                        Image(systemName: "backward.fill")
                            .font(.title)
                    }
                    
                    Button(action: {
                        isPlaying.toggle()
                    }) {
                        Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 65))
                    }
                    
                    Button(action: {
                        // Next
                    }) {
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
            .navigationTitle("Player")
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