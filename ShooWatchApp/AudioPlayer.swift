import AVFoundation
import WatchKit

/// Watch 本地音频播放控制器
/// 完全独立运行，不依赖 iPhone，直接在手表上播放音频
class AudioPlayer: ObservableObject {

    // MARK: - Published State

    /// 是否正在播放
    @Published var isPlaying = false

    /// 当前播放的动物 ID
    @Published var playingAnimalId: String?

    /// 当前播放的声音名称（用于 UI 显示，如"虎啸声"）
    @Published var playingSoundName: String?

    // MARK: - Private

    private var player: AVAudioPlayer?

    init() {
        configureAudioSession()
    }

    deinit {
        player?.stop()
        player = nil
    }

    // MARK: - Audio Session

    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.duckOthers])
            try session.setActive(true)
        } catch {
            NSLog("[ShooWatch] Audio session error: \(error.localizedDescription)")
        }
    }

    // MARK: - Playback Control

    /// 播放指定动物的声音
    /// - Parameters:
    ///   - animalId: 动物唯一标识
    ///   - soundFile: 声音文件名（不含 .mp3 扩展名），如 "tiger_1"
    ///   - soundName: 声音显示名，如 "虎啸声"
    func playSound(animalId: String, soundFile: String, soundName: String? = nil) {
        stopSound()

        guard let url = Bundle.main.url(forResource: soundFile, withExtension: "mp3", subdirectory: "Sounds") else {
            NSLog("[ShooWatch] Sound file not found: Sounds/\(soundFile).mp3")
            return
        }

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = -1  // 循环播放，持续驱赶
            player?.volume = 1.0        // 最大音量
            player?.play()

            isPlaying = true
            playingAnimalId = animalId
            playingSoundName = soundName ?? soundFile

            // 触觉反馈 — 让用户知道播放已开始
            WKInterfaceDevice.current().play(.click)

            NSLog("[ShooWatch] ▶ Playing: \(soundFile) for \(animalId)")
        } catch {
            NSLog("[ShooWatch] Play error: \(error.localizedDescription)")
        }
    }

    /// 停止播放
    func stopSound() {
        player?.stop()
        player = nil

        isPlaying = false
        playingAnimalId = nil
        playingSoundName = nil

        NSLog("[ShooWatch] ⏹ Stopped")
    }

    /// 一键驱赶 — 播放最强力的虎啸声
    func emergency() {
        playSound(animalId: "emergency", soundFile: "tiger_1", soundName: L10n.quickRepelSound)
    }
}
