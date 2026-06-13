import UIKit
import Flutter
import AVFoundation

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
        setupWatchChannel(messenger: messenger)
        setupBackgroundChannel(messenger: messenger)
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
    
    private func setupWatchChannel(messenger: FlutterBinaryMessenger) {
        let watchChannel = FlutterMethodChannel(
            name: "com.shoo.app/watch",
            binaryMessenger: messenger
        )
        
        watchChannel.setMethodCallHandler { (call, result) in
            switch call.method {
            case "isWatchConnected":
                result(false) // TODO: WatchConnectivity
            case "sendCommand":
                result(false)
            default:
                result(FlutterMethodNotImplemented)
            }
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
}
