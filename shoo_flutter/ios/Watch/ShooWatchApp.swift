import SwiftUI

@main
struct ShooWatchApp: App {
    @State private var showSettings = false
    
    init() {
        // 截图模式：启动参数 -WatchPage settings 直接进入设置页
        let args = ProcessInfo.processInfo.arguments
        if args.contains("-WatchPage") {
            if let idx = args.firstIndex(of: "-WatchPage"), idx + 1 < args.count {
                let page = args[idx + 1]
                UserDefaults.standard.set(page, forKey: "WatchPage")
            }
        }
        if ProcessInfo.processInfo.environment["WATCH_PAGE"] != nil {
            UserDefaults.standard.set(ProcessInfo.processInfo.environment["WATCH_PAGE"]!, forKey: "WatchPage")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}

struct MainView: View {
    @State private var showSettings = false
    
    private var forcedPage: String? {
        UserDefaults.standard.string(forKey: "WatchPage")
    }
    
    var body: some View {
        Group {
            if forcedPage == "settings" {
                SettingsView()
            } else {
                ContentView()
            }
        }
    }
}
