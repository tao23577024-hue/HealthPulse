import SwiftUI

@main
struct HealthPulseApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .preferredColorScheme(.none)
                .tint(.hpAccent)
        }
    }
}
