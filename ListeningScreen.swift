import SwiftUI

struct ListeningScreen: View {
    @State private var showNotification = false
    @State private var notificationOffset: CGFloat = -100
    
    var body: some View {
        ZStack {
            // Background
            Color(hex: "#021826")
                .ignoresSafeArea()
            
            // Content
            VStack {
                // Dynamic Island Area
                ZStack {
                    if showNotification {
                        // Dynamic Island Notification
                        DynamicIslandNotification()
                            .offset(y: notificationOffset)
                            .animation(.spring(response: 0.5, dampingFraction: 0.7), value: notificationOffset)
                    }
                }
                
                Spacer()
                
                // Test button to trigger notification
                Button("Trigger Notification") {
                    triggerNotification()
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.blue.opacity(0.3))
                .cornerRadius(10)
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            // Automatically trigger notification after a delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                triggerNotification()
            }
        }
    }
    
    func triggerNotification() {
        withAnimation {
            showNotification = true
            notificationOffset = 20 // Show notification
        }
        
        // Hide notification after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation {
                notificationOffset = -100 // Hide notification
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showNotification = false
            }
        }
    }
}

// Dynamic Island Notification Component
struct DynamicIslandNotification: View {
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: "bell.fill")
                .font(.system(size: 24))
                .foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Doorbell Detected")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Text("Front Door")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.black)
                .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 5)
        )
        .frame(width: UIScreen.main.bounds.width - 32)
    }
}
