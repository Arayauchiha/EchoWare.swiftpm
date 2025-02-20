import SwiftUI

@main
struct MyApp: App {
    @StateObject private var alertManager = AlertManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(alertManager)
        }
    }
}
