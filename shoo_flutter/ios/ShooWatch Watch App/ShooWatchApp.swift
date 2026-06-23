import SwiftUI

@main
struct ShooWatch_Watch_AppApp: App {
    @StateObject private var audioPlayer = AudioPlayer()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(audioPlayer)
        }
    }
}
