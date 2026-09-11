import XCTest

final class WatchScreenshotTests: XCTestCase {
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
    }
    
    func testCaptureHomePage() throws {
        let languages = [
            ("en", "en-US"), ("en-AU", "en-AU"), ("en-CA", "en-CA"), ("en-GB", "en-GB"),
            ("zh-Hans", "zh-Hans"), ("zh-Hant", "zh-Hant"),
            ("ja", "ja"), ("ko", "ko"), ("fr", "fr-FR"), ("fr-CA", "fr-CA"),
            ("de", "de-DE"), ("es", "es-ES"), ("es-MX", "es-MX"),
            ("ru", "ru"), ("pt", "pt-BR"), ("th", "th"), ("ar", "ar-SA"),
            ("id", "id"), ("it", "it"), ("ms", "ms"), ("nl", "nl-NL"),
            ("pl", "pl"), ("tr", "tr"), ("vi", "vi"),
            ("hi", "hi"), ("da", "da"), ("fi", "fi"), ("gu", "gu-IN"),
            ("ca", "ca"), ("cs", "cs"), ("kn", "kn-IN"), ("hr", "hr"),
            ("ro", "ro"), ("mr", "mr-IN"), ("ml", "ml-IN"), ("bn", "bn-BD"),
            ("no", "no"), ("pa", "pa-IN"), ("sv", "sv"), ("sk", "sk"),
            ("sl", "sl-SI"), ("te", "te-IN"), ("ta", "ta-IN"), ("uk", "uk"),
            ("ur", "ur-PK"), ("or", "or-IN"), ("el", "el"), ("he", "he"), ("hu", "hu")
        ]
        
        for (langCode, dirName) in languages {
            app.launchArguments += ["-AppleLanguages", "(\(langCode))", "-AppleLocale", langCode, "-WatchPage", "home"]
            app.launch()
            
            // Wait for Home page to load
            sleep(2)
            
            let screenshot = app.screenshot()
            let outputDir = "fastlane/screenshots_watch/\(dirName)"
            
            // Save screenshot as 01_Home.png
            let outputURL = URL(fileURLWithPath: "\(outputDir)/01_Home.png")
            try? FileManager.default.createDirectory(at: outputURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            try? screenshot.pngRepresentation.write(to: outputURL)
            
            app.terminate()
        }
    }
}
