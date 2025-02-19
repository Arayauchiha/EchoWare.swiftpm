import UIKit

@MainActor
class HapticManager {
    static let shared = HapticManager()
    
    private init() { }
    
    func playSuccess() {
        Task { @MainActor in
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
    }
    
    func playWarning() {
        Task { @MainActor in
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.warning)
        }
    }
    
    func playSelection() {
        Task { @MainActor in
            let generator = UISelectionFeedbackGenerator()
            generator.selectionChanged()
        }
    }
    
    func playLightTap() {
        Task { @MainActor in
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }
    }
    
    func playMediumImpact() {
        Task { @MainActor in
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        }
    }
} 