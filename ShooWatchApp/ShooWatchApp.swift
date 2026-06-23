import SwiftUI

@main
struct ShooWatchApp: App {
    @StateObject private var audioPlayer = AudioPlayer()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(audioPlayer)
        }
    }
}
