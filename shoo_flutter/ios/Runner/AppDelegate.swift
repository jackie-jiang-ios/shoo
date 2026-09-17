import UIKit
import Flutter
import AVFoundation
import MediaPlayer

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
    
    private var ultrasonicPlayer: AVAudioPlayer?
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // 仅设置基础 category，激活时机交给 Flutter 侧 audio_session 管理，
        // 避免启动阶段与插件初始化竞争音频会话。
        configureAudioSession()
        
        // 注意：使用 UIScene 生命周期时，不再在这里手动调用
        // GeneratedPluginRegistrant.register(with: self)。
        // 插件注册和平台通道设置移到 didInitializeImplicitFlutterEngine 中完成。
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    // MARK: - FlutterImplicitEngineDelegate
    
    func didInitializeImplicitFlutterEngine(_ engineBridge: any FlutterImplicitEngineBridge) {
        // 在 Flutter 引擎初始化完成后注册插件
        GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

        // 使用 applicationRegistrar 的 messenger 设置平台通道
        let messenger = engineBridge.applicationRegistrar.messenger()
        setupPlatformChannel(messenger: messenger)
        setupNativeLogChannel(messenger: messenger)
        setupBackgroundChannel(messenger: messenger)
        setupScreenshotChannel(messenger: messenger)
        setupVolumeChannel(messenger: messenger)
        if #available(iOS 15.0, *) {
            PurchaseChannel.setup(messenger: messenger)
        }
    }
    
    // MARK: - 音频会话配置
    
    private func configureAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(
                .playback,
                mode: .default,
                options: [.mixWithOthers]
            )
            
            // Skip eager activation during launch; audio_session will activate
            // the shared session when playback actually needs it.
        } catch {
            print("Failed to set audio session: \(error)")
        }
    }
    
    // MARK: - 平台通道
    
    private func setupPlatformChannel(messenger: FlutterBinaryMessenger) {
        let platformChannel = FlutterMethodChannel(
            name: "com.shoo.app/platform",
            binaryMessenger: messenger
        )
        
        platformChannel.setMethodCallHandler { [weak self] (call, result) in
            switch call.method {
            case "isUltrasonicSupported":
                result(true)
                
            case "playUltrasonic":
                guard let args = call.arguments as? [String: Any],
                      let frequency = args["frequency"] as? Double,
                      let volume = args["volume"] as? Double else {
                    result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments", details: nil))
                    return
                }
                let success = self?.playUltrasonic(frequency: frequency, volume: volume) ?? false
                result(success)
                
            case "stopUltrasonic":
                self?.stopUltrasonic()
                result(nil)
                
            case "startBackgroundService":
                result(false) // TODO: 实现后台播放
                
            case "stopBackgroundService":
                result(nil)
                
            case "getDeviceMaxVolume":
                result(1.0)
                
            case "setDeviceVolume":
                result(nil)
                
            case "requestPermissions":
                // 请求音频权限
                AVAudioSession.sharedInstance().requestRecordPermission { granted in
                    result(granted)
                }
                
            case "checkPermissions":
                let granted = AVAudioSession.sharedInstance().recordPermission == .granted
                result(granted)
                
            case "getScreenshotPage":
                // 返回截图模式下需要显示的页面
                let defaults = UserDefaults.standard
                if defaults.bool(forKey: "ScreenshotMode") {
                    let page = defaults.string(forKey: "ScreenshotPage") ?? "home"
                    result(page)
                } else {
                    result(nil)
                }

            case "getLaunchConfig":
                // 启动时一次性读取所有启动参数（录制模式等）
                // 优先从 ProcessInfo.arguments 读取（方式一：launch --args 传入）
                let processArgs = ProcessInfo.processInfo.arguments
                var config: [String: Any] = [:]
                var foundRecord = false
                var foundLang = ""

                // 解析命令行参数，格式为 -Key Value
                var i = 0
                while i < processArgs.count {
                    let arg = processArgs[i]
                    if arg == "-RecordMode" && i + 1 < processArgs.count {
                        foundRecord = (processArgs[i + 1] == "1" || processArgs[i + 1].lowercased() == "true")
                        i += 2
                        continue
                    }
                    if arg == "-Lang" && i + 1 < processArgs.count {
                        foundLang = processArgs[i + 1]
                        i += 2
                        continue
                    }
                    i += 1
                }

                // 方式二：从 UserDefaults 读取（兜底，用于调试）
                if !foundRecord {
                    let defaults = UserDefaults.standard
                    foundRecord = defaults.bool(forKey: "RecordMode")
                    if foundRecord && foundLang.isEmpty {
                        foundLang = defaults.string(forKey: "Lang") ?? ""
                    }
                }

                if foundRecord {
                    config["recordMode"] = true
                    config["lang"] = foundLang.isEmpty ? "en" : foundLang
                }
                result(config)

            case "shareApp":
                // 弹出系统分享面板
                guard let args = call.arguments as? [String: Any],
                      let text = args["text"] as? String else {
                    result(FlutterError(code: "INVALID_ARGS", message: "Invalid arguments", details: nil))
                    return
                }
                let urlString = args["url"] as? String
                self?.presentShareSheet(text: text, urlString: urlString, result: result)

            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    private func setupNativeLogChannel(messenger: FlutterBinaryMessenger) {
        let nativeLogChannel = FlutterMethodChannel(
            name: "com.shoo.app/native_log",
            binaryMessenger: messenger
        )

        nativeLogChannel.setMethodCallHandler { call, result in
            guard call.method == "log" else {
                result(FlutterMethodNotImplemented)
                return
            }

            guard let args = call.arguments as? [String: Any] else {
                result(
                    FlutterError(
                        code: "INVALID_ARGS",
                        message: "Missing log arguments",
                        details: nil
                    )
                )
                return
            }

            let scope = args["scope"] as? String ?? "flutter"
            let level = args["level"] as? String ?? "info"
            let message = args["message"] as? String ?? ""
            let timestamp = args["timestamp"] as? String ?? ""
            let data = args["data"] as? [String: Any] ?? [:]

            let dataText: String
            if let jsonData = try? JSONSerialization.data(withJSONObject: data, options: [.sortedKeys]),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                dataText = jsonString
            } else {
                dataText = "\(data)"
            }

            NSLog("[Shoo][%@][%@] %@ %@ %@", level.uppercased(), scope, timestamp, message, dataText)
            result(nil)
        }
    }
    
    private func setupBackgroundChannel(messenger: FlutterBinaryMessenger) {
        let backgroundChannel = FlutterMethodChannel(
            name: "com.shoo.app/background",
            binaryMessenger: messenger
        )

        backgroundChannel.setMethodCallHandler { (call, result) in
            switch call.method {
            case "startBackgroundPlayback":
                result(false) // TODO: BGTaskScheduler
            case "updateNotification":
                result(nil)
            case "stopBackgroundPlayback":
                result(nil)
            case "isBackgroundPlaybackRunning":
                result(false)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    // MARK: - 截图通道

    private func setupScreenshotChannel(messenger: FlutterBinaryMessenger) {
        let screenshotChannel = FlutterMethodChannel(
            name: "com.shoo.app/screenshot",
            binaryMessenger: messenger
        )

        screenshotChannel.setMethodCallHandler { (call, result) in
            guard call.method == "saveScreenshot" else {
                result(FlutterMethodNotImplemented)
                return
            }

            guard let args = call.arguments as? [String: Any],
                  let data = args["data"] as? FlutterStandardTypedData,
                  let filename = args["filename"] as? String else {
                result(FlutterError(
                    code: "INVALID_ARGS",
                    message: "Missing data or filename argument",
                    details: nil
                ))
                return
            }

            // 保存到 Documents/screenshots/ 目录
            do {
                let fileManager = FileManager.default
                guard let docsURL = fileManager.urls(
                    for: .documentDirectory,
                    in: .userDomainMask
                ).first else {
                    result(FlutterError(
                        code: "NO_DOCUMENTS",
                        message: "Cannot access Documents directory",
                        details: nil
                    ))
                    return
                }

                let screenshotsDir = docsURL.appendingPathComponent("screenshots", isDirectory: true)
                try fileManager.createDirectory(
                    at: screenshotsDir,
                    withIntermediateDirectories: true,
                    attributes: nil
                )

                let fileURL = screenshotsDir.appendingPathComponent(filename)
                try data.data.write(to: fileURL)
                result(fileURL.path)
            } catch {
                result(FlutterError(
                    code: "WRITE_FAILED",
                    message: "Failed to write screenshot: \(error.localizedDescription)",
                    details: nil
                ))
            }
        }
    }
    
    // MARK: - 系统音量控制

    private var volumeView: MPVolumeView?
    private var volumeObservation: NSKeyValueObservation?

    private func setupVolumeChannel(messenger: FlutterBinaryMessenger) {
        let volumeChannel = FlutterMethodChannel(
            name: "com.yangshiqin.shoo/volume",
            binaryMessenger: messenger
        )

        volumeChannel.setMethodCallHandler { [weak self] (call, result) in
            guard let self = self else {
                result(FlutterMethodNotImplemented)
                return
            }

            switch call.method {
            case "setShowSystemUI":
                // iOS 无法直接控制系统音量 UI 显示，忽略
                result(nil)

            case "getVolume":
                let volume = AVAudioSession.sharedInstance().outputVolume
                result(Float(volume))

            case "setVolume":
                guard let args = call.arguments as? [String: Any],
                      let volume = args["volume"] as? Double else {
                    result(FlutterError(code: "INVALID_ARGS", message: "Invalid volume argument", details: nil))
                    return
                }
                self.setSystemVolume(Float(min(max(volume, 0.0), 1.0)))
                result(nil)

            case "startVolumeListener":
                self.startVolumeObservation(messenger: messenger)
                result(nil)

            case "stopVolumeListener":
                self.stopVolumeObservation()
                result(nil)

            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }

    private func setSystemVolume(_ volume: Float) {
        // 使用 MPVolumeView 的 slider 来设置系统音量（不显示 UI）
        if volumeView == nil {
            volumeView = MPVolumeView(frame: CGRect(x: -1000, y: -1000, width: 1, height: 1))
            if let window = UIApplication.shared.windows.first {
                window.addSubview(volumeView!)
            }
        }

        if let slider = volumeView?.subviews.first(where: { $0 is UISlider }) as? UISlider {
            DispatchQueue.main.async {
                slider.value = volume
            }
        }
    }

    private func startVolumeObservation(messenger: FlutterBinaryMessenger) {
        stopVolumeObservation()

        let audioSession = AVAudioSession.sharedInstance()
        volumeObservation = audioSession.observe(\.outputVolume, options: [.new]) { [weak self] (session, change) in
            guard let self = self else { return }
            let volume = session.outputVolume
            let methodChannel = FlutterMethodChannel(name: "com.yangshiqin.shoo/volume", binaryMessenger: messenger)
            methodChannel.invokeMethod("onVolumeChanged", arguments: volume)
        }
    }

    private func stopVolumeObservation() {
        volumeObservation?.invalidate()
        volumeObservation = nil
    }

    // MARK: - 超声波播放
    
    private func playUltrasonic(frequency: Double, volume: Double) -> Bool {
        // 生成超声波 WAV 数据
        let sampleRate: Double = 44100
        let duration: Double = 30.0
        let numSamples = Int(sampleRate * duration)
        
        var pcmData = [Int16]()
        for i in 0..<numSamples {
            let t = Double(i) / sampleRate
            var envelope: Double = 1.0
            let fadeSamples = Int(sampleRate * 0.01)
            
            if i < fadeSamples {
                envelope = Double(i) / Double(fadeSamples)
            } else if i > numSamples - fadeSamples {
                envelope = Double(numSamples - i) / Double(fadeSamples)
            }
            
            let sample = volume * envelope * sin(2.0 * .pi * frequency * t)
            pcmData.append(Int16(clamping: Int(sample * 32767)))
        }
        
        // 转为 WAV 数据
        let wavData = createWavFile(pcmData: pcmData, sampleRate: Int(sampleRate))
        
        do {
            ultrasonicPlayer = try AVAudioPlayer(data: wavData)
            ultrasonicPlayer?.numberOfLoops = -1 // 循环播放
            ultrasonicPlayer?.volume = Float(volume)
            ultrasonicPlayer?.play()
            return true
        } catch {
            print("Failed to play ultrasonic: \(error)")
            return false
        }
    }
    
    private func stopUltrasonic() {
        ultrasonicPlayer?.stop()
        ultrasonicPlayer = nil
    }
    
    private func createWavFile(pcmData: [Int16], sampleRate: Int) -> Data {
        let dataSize = pcmData.count * 2
        var data = Data()
        
        // WAV header
        data.append(contentsOf: [0x52, 0x49, 0x46, 0x46]) // RIFF
        let fileSize = UInt32(36 + dataSize)
        data.append(contentsOf: withUnsafeBytes(of: fileSize.littleEndian) { Array($0) })
        data.append(contentsOf: [0x57, 0x41, 0x56, 0x45]) // WAVE
        data.append(contentsOf: [0x66, 0x6D, 0x74, 0x20]) // fmt
        data.append(contentsOf: withUnsafeBytes(of: UInt32(16).littleEndian) { Array($0) })
        data.append(contentsOf: withUnsafeBytes(of: UInt16(1).littleEndian) { Array($0) }) // PCM
        data.append(contentsOf: withUnsafeBytes(of: UInt16(1).littleEndian) { Array($0) }) // mono
        data.append(contentsOf: withUnsafeBytes(of: UInt32(sampleRate).littleEndian) { Array($0) })
        data.append(contentsOf: withUnsafeBytes(of: UInt32(sampleRate * 2).littleEndian) { Array($0) }) // byte rate
        data.append(contentsOf: withUnsafeBytes(of: UInt16(2).littleEndian) { Array($0) }) // block align
        data.append(contentsOf: withUnsafeBytes(of: UInt16(16).littleEndian) { Array($0) }) // bits per sample
        data.append(contentsOf: [0x64, 0x61, 0x74, 0x61]) // data
        data.append(contentsOf: withUnsafeBytes(of: UInt32(dataSize).littleEndian) { Array($0) })
        
        // PCM data
        for sample in pcmData {
            data.append(contentsOf: withUnsafeBytes(of: sample.littleEndian) { Array($0) })
        }
        
        return data
    }

    // MARK: - 系统分享

    private func presentShareSheet(text: String, urlString: String?, result: @escaping FlutterResult) {
        guard let window = UIApplication.shared.windows.first,
              let rootViewController = window.rootViewController else {
            result(FlutterError(code: "NO_VIEW", message: "No root view controller", details: nil))
            return
        }

        var items: [Any] = [text]
        if let urlString = urlString, let url = URL(string: urlString) {
            items.append(url)
        }

        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)

        // iPad 需要设置 popover 位置
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = rootViewController.view
            popover.sourceRect = CGRect(x: rootViewController.view.bounds.midX,
                                        y: rootViewController.view.bounds.midY,
                                        width: 0, height: 0)
            popover.permittedArrowDirections = []
        }

        // 找到最顶层的 ViewController 来 present
        var topController = rootViewController
        while let presentedController = topController.presentedViewController {
            topController = presentedController
        }

        topController.present(activityVC, animated: true) {
            result(true)
        }
    }
}
