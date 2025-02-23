import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("userName") private var userName = ""
    @AppStorage("notificationStyle") private var notificationStyle = 0 // 0: Visual + Haptic, 1: Visual Only
    @AppStorage("enabledSoundCategories") private var enabledSoundCategories: String = "doorbell,emergency,dog,baby,knock"
    
    private let soundCategories = [
        "doorbell": "Doorbell Sounds 🔔",
        "emergency": "Emergency Vehicles 🚨",
        "dog": "Dog Sounds 🐕",
        "baby": "Baby Sounds 👶",
        "knock": "Knocking 👋"
    ]
    
    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "pawprint.fill")
                            .foregroundColor(.orange)
                        Text("Hi there! What should I call you?")
                            .font(.headline)
                    }
                    
                    TextField("Your name", text: $userName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.words)
                    
                    if userName.isEmpty {
                        Text("Don't worry if you don't tell me, I'll just call you Friend! 🦊")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Text("Nice to meet you, \(userName)! 🦊")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
                .padding(.vertical, 8)
            }
            
            Section(header: Text("Notification Style")) {
                Picker("Notification Style", selection: $notificationStyle) {
                    Text("Visual + Haptic").tag(0)
                    Text("Visual Only").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                
                // Preview Button
                Button(action: showNotificationPreview) {
                    Text("Preview Notification")
                        .foregroundColor(.blue)
                }
            }
            
            Section(header: Text("Sound Categories to Monitor")) {
                ForEach(Array(soundCategories.keys.sorted()), id: \.self) { category in
                    Toggle(soundCategories[category] ?? category, isOn: bindingForCategory(category))
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarItems(trailing: Button("Done") {
            dismiss()
        })
        .onAppear {
            // Reset categories if it's first launch
            if enabledSoundCategories.isEmpty {
                enabledSoundCategories = "" // Ensure all toggles start off
            }
        }
    }
    
    private func bindingForCategory(_ category: String) -> Binding<Bool> {
        Binding(
            get: {
                enabledSoundCategories.contains(category)
            },
            set: { isEnabled in
                var categories = enabledSoundCategories.split(separator: ",").map(String.init)
                if isEnabled && !categories.contains(category) {
                    categories.append(category)
                } else if !isEnabled {
                    categories.removeAll { $0 == category }
                }
                enabledSoundCategories = categories.joined(separator: ",")
            }
        )
    }
    
    private func showNotificationPreview() {
        // Create a sample notification with the current style
        let title = "Hey \(userName.isEmpty ? "Friend" : userName)! 🦊"
        let message = "This is how your notifications will look!"
        
        if notificationStyle == 0 {
            // Visual + Haptic
            HapticManager.shared.playWarning()
        }
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request)
    }
}

#Preview {
    SettingsView()
}
