import SwiftUI

class AlertManager: ObservableObject {
    private let queue = DispatchQueue(label: "com.echofox.alertmanager")
    @Published var showingSoundAlert = false
    @Published var currentAlertMessage = ""
    @Published var isProcessingAlert = false
    @AppStorage("alertStyle") private var alertStyle = 0
    
    func showAlert(for category: SoundCategory) {
        queue.async { [weak self] in
            guard let self = self else { return }
            
            // Only show alert if no alert is currently showing
            if !self.showingSoundAlert {
                DispatchQueue.main.async {
                    self.currentAlertMessage = "\(category.icon) \(category.alertMessage)"
                    self.showingSoundAlert = true
                    self.isProcessingAlert = true
                    
                    if self.alertStyle != 0 {
                        Task { @MainActor in
                            await HapticManager.shared.playWarning()
                        }
                    }
                }
            }
        }
    }
    
    func dismissAlert() {
        queue.async { [weak self] in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isProcessingAlert = false
                self.showingSoundAlert = false
            }
        }
    }
}