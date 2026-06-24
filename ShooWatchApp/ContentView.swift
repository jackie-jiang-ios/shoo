import SwiftUI

/// 主界面 - 上下滑动列表 + 一键驱赶按钮
/// 完全独立的 Watch App，本地播放音频，不依赖 iPhone
struct ContentView: View {
    @EnvironmentObject var audioPlayer: AudioPlayer

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 8) {
                    // 一键驱赶按钮（置顶）
                    NavigationLink {
                        PlayingView()
                            .environmentObject(audioPlayer)
                    } label: {
                        EmergencyLabel()
                    }
                    .buttonStyle(.plain)
                    .simultaneousGesture(TapGesture().onEnded {
                        audioPlayer.emergency()
                    })

                    // 按分类分组的动物列表
                    ForEach(WatchAnimal.categorized, id: \.name) { category in
                        CategorySection(
                            name: category.name,
                            emoji: category.emoji,
                            animals: category.animals,
                            playingAnimalId: audioPlayer.playingAnimalId,
                            isPlaying: audioPlayer.isPlaying,
                            onPlay: { animal in
                                audioPlayer.playSound(
                                    animalId: animal.id,
                                    soundFile: animal.topSoundFile
                                )
                            },
                            onStop: {
                                audioPlayer.stopSound()
                            }
                        )
                    }
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 20)
            }
            .navigationTitle(L10n.appName)
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - 一键驱赶按钮

struct EmergencyLabel: View {
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "bolt.trianglebadge.exclamationmark.fill")
                .font(.title3)
            Text(L10n.quickRepel)
                .font(.headline)
                .fontWeight(.bold)
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(.red.gradient, in: RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: - 分类区块

struct CategorySection: View {
    let name: String
    let emoji: String
    let animals: [WatchAnimal]
    let playingAnimalId: String?
    let isPlaying: Bool
    let onPlay: (WatchAnimal) -> Void
    let onStop: () -> Void

    var body: some View {
        VStack(spacing: 6) {
            HStack {
                Text(emoji)
                    .font(.caption)
                Text(name)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            .padding(.leading, 4)
            .padding(.top, 4)

            ForEach(animals) { animal in
                AnimalCard(
                    animal: animal,
                    isPlaying: isPlaying && playingAnimalId == animal.id,
                    onPlay: { onPlay(animal) },
                    onStop: onStop
                )
            }
        }
    }
}

// MARK: - 动物卡片

struct AnimalCard: View {
    let animal: WatchAnimal
    let isPlaying: Bool
    let onPlay: () -> Void
    let onStop: () -> Void

    var body: some View {
        Button(action: {
            if isPlaying {
                onStop()
            } else {
                onPlay()
            }
        }) {
            HStack(spacing: 10) {
                Text(animal.emoji)
                    .font(.title2)
                    .frame(width: 36, height: 36)

                VStack(alignment: .leading, spacing: 2) {
                    Text(animal.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                    Text(animal.topSoundName)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if isPlaying {
                    Image(systemName: "stop.fill")
                        .font(.title3)
                        .foregroundStyle(.red)
                        .padding(.trailing, 2)
                } else {
                    Image(systemName: "play.fill")
                        .font(.title3)
                        .foregroundStyle(.orange)
                        .padding(.trailing, 2)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                isPlaying
                    ? Color.orange.opacity(0.15)
                    : Color.gray.opacity(0.08),
                in: RoundedRectangle(cornerRadius: 12)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - 播放中全屏页

struct PlayingView: View {
    @EnvironmentObject var audioPlayer: AudioPlayer
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 16) {
            // 播放中动画
            Image(systemName: audioPlayer.isPlaying ? "speaker.wave.3.fill" : "speaker.slash.fill")
                .font(.system(size: 40))
                .foregroundStyle(audioPlayer.isPlaying ? .orange : .gray)
                .symbolEffect(.pulse, options: .repeating, isActive: audioPlayer.isPlaying)

            // 动物名 / 一键驱赶
            if let animalId = audioPlayer.playingAnimalId {
                if animalId == "emergency" {
                    Text("🔥")
                        .font(.system(size: 36))
                    Text(L10n.repelling)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(.red)
                } else if let animal = WatchAnimal.allAnimals.first(where: { $0.id == animalId }) {
                    Text(animal.emoji)
                        .font(.system(size: 36))
                    Text(animal.name)
                        .font(.title3)
                        .fontWeight(.bold)
                } else {
                    Text("🔊")
                        .font(.system(size: 36))
                    Text(L10n.playing)
                        .font(.title3)
                        .fontWeight(.bold)
                }
            }

            // 声音名
            if let soundName = audioPlayer.playingSoundName {
                Text(soundName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // 大停止按钮
            Button(action: {
                audioPlayer.stopSound()
                dismiss()
            }) {
                Image(systemName: "stop.fill")
                    .font(.title)
                    .foregroundStyle(.white)
                    .frame(width: 80, height: 80)
                    .background(.red.gradient, in: Circle())
            }
            .buttonStyle(.plain)

            Text(L10n.stop)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .navigationTitle(L10n.playing)
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .environmentObject(AudioPlayer())
}
