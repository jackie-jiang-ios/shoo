import SwiftUI

/// 主界面
struct ContentView: View {
    @AppStorage("quickRepelAnimalId") private var quickRepelAnimalId: String = "wild_dog"
    @StateObject private var audioPlayer = AudioPlayer()
    @ObservedObject private var purchaseStatus = PurchaseStatus.shared
    @State private var showPurchaseAlert = false
    @State private var purchaseMessage: String?
    @State private var showPurchaseResult = false

    /// 获取 Quick Repel 对应的动物
    private var quickRepelAnimal: WatchAnimal? {
        // 保存的动物必须是免费的；如果是 Pro 专属，回退到默认免费动物
        if let animal = WatchAnimal.allAnimals.first(where: { $0.id == quickRepelAnimalId }),
           !animal.isProOnly {
            return animal
        }
        // 默认取第一个免费动物
        return WatchAnimal.allAnimals.first(where: { !$0.isProOnly })
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    // 一键驱赶按钮
                    Button {
                        guard let animal = quickRepelAnimal else { return }
                        if audioPlayer.isPlaying && audioPlayer.playingAnimalId == animal.id {
                            audioPlayer.stopSound()
                        } else {
                            audioPlayer.playSound(animalId: animal.id, soundFile: animal.topSoundFile, soundName: animal.topSoundName)
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: (audioPlayer.isPlaying && audioPlayer.playingAnimalId == quickRepelAnimal?.id) ? "stop.fill" : "bolt.trianglebadge.exclamationmark.fill")
                                .font(.title3)
                            VStack(spacing: 1) {
                                Text(L10n.quickRepel)
                                    .font(.headline)
                                    .fontWeight(.bold)
                                if let animal = quickRepelAnimal {
                                    Text(animal.name)
                                        .font(.caption2)
                                        .opacity(0.85)
                                }
                            }
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background((audioPlayer.isPlaying && audioPlayer.playingAnimalId == quickRepelAnimal?.id) ? Color.orange.gradient : Color.red.gradient, in: RoundedRectangle(cornerRadius: 14))
                    }
                    .buttonStyle(.plain)

                    // 动物列表
                    ForEach(WatchAnimal.categorized, id: \.name) { category in
                        VStack(spacing: 6) {
                            HStack {
                                Text(category.emoji)
                                    .font(.caption)
                                Text(category.name)
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.secondary)
                                Spacer()
                            }
                            .padding(.leading, 4)
                            .padding(.top, 4)

                            ForEach(category.animals) { animal in
                                let isThisPlaying = audioPlayer.isPlaying && audioPlayer.playingAnimalId == animal.id
                                let isQuickRepel = !animal.isProOnly && quickRepelAnimalId == animal.id
                                HStack(spacing: 10) {
                                    Text(animal.emoji)
                                        .font(.title2)
                                        .frame(width: 36, height: 36)

                                    VStack(alignment: .leading, spacing: 2) {
                                        HStack(spacing: 4) {
                                            Text(animal.name)
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                            if isQuickRepel {
                                                Image(systemName: "bolt.fill")
                                                    .font(.caption2)
                                                    .foregroundStyle(.red)
                                            }
                                        }
                                        Text(animal.topSoundName)
                                            .font(.caption2)
                                            .foregroundStyle(.secondary)
                                    }

                                    Spacer()

                                    Button {
                                        if isThisPlaying {
                                            audioPlayer.stopSound()
                                        } else {
                                            // Pro 专属且未购买 → 提示购买
                                            if animal.isProOnly && !purchaseStatus.isProActive {
                                                showPurchaseAlert = true
                                                return
                                            }
                                            audioPlayer.playSound(animalId: animal.id, soundFile: animal.topSoundFile, soundName: animal.topSoundName)
                                            // 记录用户选择（仅免费动物可作为 Quick Repel 默认）
                                            if !animal.isProOnly {
                                                quickRepelAnimalId = animal.id
                                            }
                                        }
                                    } label: {
                                        Image(systemName: isThisPlaying ? "stop.fill" : "play.fill")
                                            .font(.title3)
                                            .foregroundStyle(isThisPlaying ? .red : (animal.isProOnly && !purchaseStatus.isProActive ? .gray : .orange))
                                            .padding(.trailing, 2)
                                    }
                                    .buttonStyle(.plain)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 10)
                                .background(Color.gray.opacity(isQuickRepel ? 0.15 : 0.08), in: RoundedRectangle(cornerRadius: 12))
                            }
                        }
                    }
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 20)
            }
            .navigationTitle(L10n.appName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                }
            }
            .alert(L10n.upgradeToPro, isPresented: $showPurchaseAlert) {
                if SimulatorDetector.isSimulator {
                    Button(L10n.stop, role: .cancel) {}
                } else {
                    Button(L10n.purchaseButton) {
                        Task {
                            await purchaseStatus.purchasePro()
                            if purchaseStatus.isProActive {
                                purchaseMessage = "✅ Pro 已激活"
                                showPurchaseResult = true
                            } else if let err = purchaseStatus.lastError {
                                purchaseMessage = "❌ \(err)"
                                showPurchaseResult = true
                            }
                        }
                    }
                    Button(L10n.restorePurchases) {
                        Task {
                            await purchaseStatus.restorePurchases()
                            if purchaseStatus.isProActive {
                                purchaseMessage = "✅ 购买已恢复"
                                showPurchaseResult = true
                            }
                        }
                    }
                    Button(L10n.stop, role: .cancel) {}
                }
            } message: {
                if SimulatorDetector.isSimulator {
                    Text(L10n.errorSimulatorNotSupported)
                } else {
                    Text(L10n.proFeatureUnlockAnimals)
                }
            }
            .alert("提示", isPresented: $showPurchaseResult) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(purchaseMessage ?? "")
            }
        }
    }
}

// MARK: - 设置页
struct SettingsView: View {
    @ObservedObject private var purchaseStatus = PurchaseStatus.shared

    var body: some View {
        List {
            Section {
                HStack {
                    Image(systemName: "crown.fill")
                        .foregroundStyle(.orange)
                    Text(L10n.proVersion)
                    Spacer()
                    if purchaseStatus.isProActive {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    }
                }
            }

            if !purchaseStatus.isProActive {
                Section {
                    if SimulatorDetector.isSimulator {
                        Text(L10n.errorSimulatorNotSupported)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        Button {
                            Task { await purchaseStatus.purchasePro() }
                        } label: {
                            HStack {
                                Text(L10n.upgradeToPro)
                                Spacer()
                                if purchaseStatus.isPurchasing {
                                    ProgressView()
                                } else {
                                    Text(purchaseStatus.proPrice)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .disabled(purchaseStatus.isPurchasing)

                        Button {
                            Task { await purchaseStatus.restorePurchases() }
                        } label: {
                            Text(L10n.restorePurchases)
                                .font(.caption)
                        }
                    }
                }
            }

            Section {
                Text("Version 4.0.0")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .navigationTitle(L10n.appName)
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}
