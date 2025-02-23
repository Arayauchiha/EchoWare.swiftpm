import AVFoundation

@MainActor
final class AudioInputManager: ObservableObject {
    static let shared = AudioInputManager()
    
    @Published var isHeadphonesConnected = false
    @Published var currentInputDevice: String = "Unknown"
    @Published var availableInputs: [AVAudioSessionPortDescription] = []
    
    private var audioSession: AVAudioSession
    private var notificationObserver: NSObjectProtocol?
    
    private init() {
        self.audioSession = AVAudioSession.sharedInstance()
        setupAudioSession()
        setupNotifications()
    }
    
    private func setupAudioSession() {
        do {
            // Configure audio session for recording
            try audioSession.setCategory(.playAndRecord, 
                                      mode: .default,
                                      options: [.allowBluetooth, .allowBluetoothA2DP, .defaultToSpeaker])
            try audioSession.setActive(true)
            updateAudioInputs()
        } catch {
            print("⚠️ Audio session setup failed: \(error.localizedDescription)")
        }
    }
    
    private func setupNotifications() {
        // Monitor audio route changes (e.g., headphones connected/disconnected)
        notificationObserver = NotificationCenter.default.addObserver(
            forName: AVAudioSession.routeChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            self?.handleRouteChange(notification)
        }
    }
    
    private func handleRouteChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSessionRouteChangeReason(rawValue: reasonValue) else {
            return
        }
        
        // Update inputs when route changes
        updateAudioInputs()
        
        switch reason {
        case .newDeviceAvailable:
            print("🎧 New audio device connected")
        case .oldDeviceUnavailable:
            print("🎧 Audio device disconnected")
        default:
            break
        }
    }
    
    func updateAudioInputs() {
        // Get all available inputs
        availableInputs = audioSession.availableInputs ?? []
        
        // Check if headphones are connected
        let headphonesConnected = audioSession.currentRoute.outputs.contains { output in
            [.headphones, .bluetoothA2DP, .bluetoothHFP].contains(output.portType)
        }
        
        // Update state
        isHeadphonesConnected = headphonesConnected
        currentInputDevice = audioSession.currentRoute.inputs.first?.portType.rawValue ?? "Unknown"
        
        // Print current audio setup
        print("🎤 Current input: \(currentInputDevice)")
        print("🎧 Headphones connected: \(isHeadphonesConnected)")
    }
    
    func preferBuiltInMicWhenPossible() {
        guard let builtInMic = availableInputs.first(where: { $0.portType == .builtInMic }) else {
            print("⚠️ Built-in microphone not available")
            return
        }
        
        do {
            try audioSession.setPreferredInput(builtInMic)
            print("✅ Set preferred input to built-in microphone")
            updateAudioInputs()
        } catch {
            print("⚠️ Failed to set preferred input: \(error.localizedDescription)")
        }
    }
    
    func preferHeadphoneMicWhenPossible() {
        // Look for headphone or bluetooth mic
        guard let headphoneMic = availableInputs.first(where: { input in
            [.headphones, .bluetoothHFP].contains(input.portType)
        }) else {
            print("⚠️ Headphone microphone not available")
            return
        }
        
        do {
            try audioSession.setPreferredInput(headphoneMic)
            print("✅ Set preferred input to headphone microphone")
            updateAudioInputs()
        } catch {
            print("⚠️ Failed to set preferred input: \(error.localizedDescription)")
        }
    }
    
    deinit {
        if let observer = notificationObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}
