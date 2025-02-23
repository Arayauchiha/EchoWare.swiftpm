import SwiftUI

struct SettingsView: View {
    @AppStorage("userName") private var userName = ""
    @AppStorage("alertStyle") private var alertStyle = 0 // 0: Visual, 1: Haptic, 2: Both
    @AppStorage("enabledSoundCategories") private var enabledSoundCategories: String = "doorbell,emergency,dog,baby,knock" // Default all categories enabled
    @State private var showingNamePrompt = false
    @State private var tempUserName = ""
    @State private var showingTestAlert = false
    
    private let soundCategories = [
        "doorbell": (name: "🚪 Doorbell Sounds", description: "Doorbell and bell sounds", sounds: ["door_bell", "bell"]),
        "emergency": (name: "🚨 Emergency Vehicles", description: "Various emergency vehicle sirens", sounds: ["ambulance_siren", "emergency_vehicle", "fire_engine_siren", "police_siren", "siren"]),
        "dog": (name: "🐕 Dog Sounds", description: "Various dog sounds", sounds: ["dog", "dog_bark", "dog_bow_wow"]),
        "baby": (name: "👶 Baby Sounds", description: "Baby crying detection", sounds: ["baby_crying"]),
        "knock": (name: "👆 Knocking", description: "Knocking sounds", sounds: ["knock"])
    ]
    
    // Helper computed property to get enabled categories as array
    private var enabledCategoriesArray: [String] {
        enabledSoundCategories.split(separator: ",").map(String.init)
    }
    
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
                    ForEach(Array(soundCategories.keys.sorted()), id: \.self) { category in
                        let categoryInfo = soundCategories[category]!
                        Toggle(categoryInfo.name, isOn: Binding(
                            get: { enabledCategoriesArray.contains(category) },
                            set: { isEnabled in
                                var categories = enabledCategoriesArray
                                if isEnabled {
                                    if !categories.contains(category) {
                                        categories.append(category)
                                    }
                                } else {
                                    categories.removeAll { $0 == category }
                                }
                                enabledSoundCategories = categories.joined(separator: ",")
                            }
                        ))
                        .font(.system(.body, design: .rounded))
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
