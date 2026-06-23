import AVFoundation
import WatchKit

/// Watch 本地音频播放控制器
/// 完全独立运行，不依赖 iPhone，直接在手表上播放音频
@MainActor
class AudioPlayer: ObservableObject {

    // MARK: - Published State

    /// 是否正在播放
    @Published var isPlaying = false

    /// 当前播放的动物 ID
    @Published var playingAnimalId: String?

    /// 当前播放的声音组名称（用于 UI 显示）
    @Published var playingSoundGroup: String?

    // MARK: - Private

    private var player: AVAudioPlayer?

    init() {
        configureAudioSession()
    }

    nonisolated deinit {
        let session = AVAudioSession.sharedInstance()
        try? session.setActive(false)
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
    func playSound(animalId: String, soundGroup: String) {
        stopSound()

        guard let url = Bundle.main.url(forResource: soundGroup, withExtension: "mp3") else {
            NSLog("[ShooWatch] Sound file not found: \(soundGroup).mp3")
            return
        }

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = -1  // 循环播放，持续驱赶
            player?.volume = 1.0        // 最大音量
            player?.play()

            isPlaying = true
            playingAnimalId = animalId
            playingSoundGroup = soundGroup

            // 触觉反馈 — 让用户知道播放已开始
            WKInterfaceDevice.current().play(.click)

            NSLog("[ShooWatch] ▶ Playing: \(soundGroup) for \(animalId)")
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
        playingSoundGroup = nil

        NSLog("[ShooWatch] ⏹ Stopped")
    }

    /// 紧急求救 — 播放最强力的虎啸声
    func emergency() {
        playSound(animalId: "emergency", soundGroup: "tiger")
    }
}
