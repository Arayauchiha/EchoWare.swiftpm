import SwiftUI

struct OnboardingView: View {
    @Binding var showOnboarding: Bool
    
    var body: some View {
        NavigationView {
            TabView {
                OnboardingPage(
                    image: "pawprint.fill",
                    title: "Welcome to EchoWare! 🦊",
                    description: "I'm your friendly fox companion, ready to help you stay aware of important sounds around you!"
                )
                
                OnboardingPage(
                    image: "ear.fill",
                    title: "Sound Detection",
                    description: "I'll listen for important sounds like doorbells, emergency vehicles, and more while you focus on other things."
                )
                
                OnboardingPage(
                    image: "bell.fill",
                    title: "Smart Notifications",
                    description: "I'll notify you when I detect important sounds, so you never miss anything important!"
                )
                
                FinalOnboardingPage(showOnboarding: $showOnboarding)
            }
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            .background(Color.white) // Add this to ensure white background
            .ignoresSafeArea()  // Add this to cover full screen
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 50) // This moves the dots up
            }
        }
        .navigationViewStyle(.stack)
    }
}

struct OnboardingPage: View {
    let image: String
    let title: String
    let description: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: image)
                .font(.system(size: 60))
                .foregroundColor(.orange)
            
            Text(title)
                .font(.title)
                .bold()
                .multilineTextAlignment(.center)
            
            Text(description)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 32)
            
            Spacer()
        }
        .padding(.top, 60)
    }
}

struct FinalOnboardingPage: View {
    @Binding var showOnboarding: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "sparkles")
                .font(.system(size: 60))
                .foregroundColor(.orange)
            
            Text("Let's Get Started!")
                .font(.title)
                .bold()
            
            Text("First, let me get to know you better and help you customize your experience.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 32)
            
            Spacer()
            
            Button(action: {
                withAnimation {
                    showOnboarding = false  // Changed from true to false to dismiss onboarding
                }
            }) {
                Text("Continue")
                    .bold()
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 50)
        }
        .background(Color.white)
    }
}