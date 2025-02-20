import SwiftUI

struct SettingsView: View {
    @AppStorage("userName") private var userName = ""
    @AppStorage("alertStyle") private var alertStyle = 0 // 0: Visual, 1: Haptic, 2: Both
    @State private var selectedSoundsArray: [String] = []
    @State private var showingNamePrompt = false
    @State private var tempUserName = ""
    @State private var showingTestAlert = false
    
    private let availableSounds = [
        "doorbell": "🚪 Doorbell",
        "name": "📣 Name Called",
        "alarm": "🚨 Alarms",
        "knock": "👆 Knocking",
        "phone": "📱 Phone Ringing"
    ]
    
    var body: some View {
        NavigationView {
            List {
                // Personalization Section
                Section {
                    HStack {
                        Text("Fox calls you:")
                        Spacer()
                        Text(userName.isEmpty ? "Friend" : userName)
                            .foregroundColor(.secondary)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        tempUserName = userName
                        showingNamePrompt = true
                    }
                } header: {
                    Text("Personalization")
                } footer: {
                    Text("This is how your fox friend will address you")
                }
                
                // Sound Detection Section
                Section {
                    ForEach(Array(availableSounds.keys), id: \.self) { sound in
                        Toggle(availableSounds[sound] ?? "", isOn: Binding(
                            get: { selectedSoundsArray.contains(sound) },
                            set: { isSelected in
                                if isSelected {
                                    selectedSoundsArray.append(sound)
                                } else {
                                    selectedSoundsArray.removeAll { $0 == sound }
                                }
                            }
                        ))
                    }
                } header: {
                    Text("Sounds to Detect")
                } footer: {
                    Text("Your fox will alert you when these sounds are detected")
                }
                
                // About Section
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    Button(action: {
                        // Show tutorial again
                    }) {
                        Text("Show Tutorial")
                    }
                } header: {
                    Text("About")
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 16) {
                        Picker("Alert Style", selection: $alertStyle) {
                            Text("Visual Only").tag(0)
                            Text("Haptic Only").tag(1)
                            Text("Visual & Haptic").tag(2)
                        }
                        .pickerStyle(.segmented)
                        .onChange(of: alertStyle) { newValue in
                            demonstrateAlertStyle()
                        }
                        
                        // Description of current selection
                        Text(alertStyleDescription)
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        
                        // Test button
                        Button(action: demonstrateAlertStyle) {
                            HStack {
                                Image(systemName: "bell.fill")
                                Text("Test This Alert Style")
                            }
                        }
                        .buttonStyle(.bordered)
                        .tint(.purple)
                    }
                    .padding(.vertical, 8)
                } header: {
                    Text("Alert Preferences")
                } footer: {
                    Text("Choose how you want to be notified when sounds are detected")
                }
            }
            .navigationTitle("Settings")
            .alert("What should I call you?", isPresented: $showingNamePrompt) {
                TextField("Your name", text: $tempUserName)
                Button("OK") {
                    if !tempUserName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        userName = tempUserName
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Enter the name you'd like your fox friend to use")
            }
            .alert("Sound Detected!", isPresented: $showingTestAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("This is how visual alerts will appear")
            }
        }
    }
    
    // Helper computed property for description
    private var alertStyleDescription: String {
        switch alertStyle {
        case 0:
            return "You'll see visual notifications only"
        case 1:
            return "You'll feel haptic feedback only"
        case 2:
            return "You'll both see and feel notifications"
        default:
            return ""
        }
    }
    
    // Function to demonstrate the selected alert style
    private func demonstrateAlertStyle() {
        switch alertStyle {
        case 0: // Visual Only
            showingTestAlert = true
            
        case 1: // Haptic Only
            Task {
                await HapticManager.shared.playWarning()
            }
            
        case 2: // Both
            showingTestAlert = true
            Task {
                await HapticManager.shared.playWarning()
            }
            
        default:
            break
        }
    }
}

#Preview {
    SettingsView()
} 
