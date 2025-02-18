import SwiftUI

struct ListeningScreen: View {
    @State private var isNotificationActive = false
    @State private var pillWidth: CGFloat = 60

    var body: some View {
        ZStack(alignment: .top) {
            Color.white
                .ignoresSafeArea()

            VStack {
                Spacer() // Push content down

                // Animated Notification Pill - Trying offset for precise vertical alignment
                RoundedRectangle(cornerRadius: 20)
                    .fill(.black.opacity(0.8))
                    .frame(width: pillWidth, height: 40)
                    .overlay(
                        Text(isNotificationActive ? "Listening for sounds..." : "")
                            .foregroundColor(.white)
                            .font(.system(size: 16, weight: .semibold))
                            .opacity(isNotificationActive ? 1 : 0)
                    )
                    .shadow(radius: 5)
                    .offset(y: 0) // Experiment with vertical offset - start with 0, then try negative values

                Spacer() // Push content up

                Button("Toggle Notification") {
                    withAnimation {
                        isNotificationActive.toggle()
                        pillWidth = isNotificationActive ? 220 : 60
                    }
                }
                .padding(.bottom, 50)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .edgesIgnoringSafeArea(.all)
        .navigationBarHidden(true)
    }
}
