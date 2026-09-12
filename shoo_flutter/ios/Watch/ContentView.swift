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
        if let animal = WatchAnimal.allAnimals.first(where: { $0.id == quickRepelAnimalId }),
           !animal.isProOnly {
            return animal
        }
        return WatchAnimal.allAnimals.first(where: { !$0.isProOnly })
    }

    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                scrollContent(proxy: proxy)
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

    // MARK: - Scroll Content

    @ViewBuilder
    private func scrollContent(proxy: ScrollViewProxy) -> some View {
        ScrollView {
            VStack(spacing: 12) {
                quickRepelButton
                animalCategories
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 20)
        }
    }

    // MARK: - Quick Repel Button

    @ViewBuilder
    private var quickRepelButton: some View {
        Button {
            guard let animal = quickRepelAnimal else { return }
            if audioPlayer.isPlaying && audioPlayer.playingAnimalId == animal.id {
                audioPlayer.stopSound()
            } else {
                audioPlayer.playSound(animalId: animal.id, soundFile: animal.topSoundFile, soundName: animal.topSoundName)
            }
        } label: {
            HStack(spacing: 8) {
                let isActive = audioPlayer.isPlaying && audioPlayer.playingAnimalId == quickRepelAnimal?.id
                if isActive {
                    Image(systemName: "stop.fill")
                        .font(.title3)
                } else if let animal = quickRepelAnimal {
                    Text(animal.emoji)
                        .font(.title2)
                }
                quickRepelLabel
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(quickRepelBackground, in: RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
        .id("top")
    }

    @ViewBuilder
    private var quickRepelLabel: some View {
        Text(L10n.quickRepel)
            .font(.headline)
            .fontWeight(.bold)
    }

    private var quickRepelBackground: some ShapeStyle {
        let isActive = audioPlayer.isPlaying && audioPlayer.playingAnimalId == quickRepelAnimal?.id
        if isActive {
            return Color.orange.gradient
        }
        return Color.red.gradient
    }

    // MARK: - Animal Categories

    @ViewBuilder
    private var animalCategories: some View {
        ForEach(Array(WatchAnimal.categorized.enumerated()), id: \.element.name) { catIndex, category in
            VStack(spacing: 6) {
                categoryHeader(category: category, index: catIndex)
                animalRows(category: category, catIndex: catIndex)
            }
        }
    }

    @ViewBuilder
    private func categoryHeader(category: (name: String, emoji: String, animals: [WatchAnimal]), index: Int) -> some View {
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
        .id("cat_\(index)")
    }

    @ViewBuilder
    private func animalRows(category: (name: String, emoji: String, animals: [WatchAnimal]), catIndex: Int) -> some View {
        ForEach(category.animals) { animal in
            animalRow(animal: animal)
        }
    }

    @ViewBuilder
    private func animalRow(animal: WatchAnimal) -> some View {
        let isPlaying = audioPlayer.isPlaying && audioPlayer.playingAnimalId == animal.id
        let isQuickRepel = !animal.isProOnly && quickRepelAnimalId == animal.id
        Button {
            if isPlaying {
                audioPlayer.stopSound()
            } else {
                if animal.isProOnly && !purchaseStatus.isProActive {
                    showPurchaseAlert = true
                    return
                }
                audioPlayer.playSound(animalId: animal.id, soundFile: animal.topSoundFile, soundName: animal.topSoundName)
                if !animal.isProOnly {
                    quickRepelAnimalId = animal.id
                }
            }
        } label: {
            HStack(spacing: 10) {
                Text(animal.emoji)
                    .font(.title2)
                    .frame(width: 36, height: 36)

                animalInfo(animal: animal, isQuickRepel: isQuickRepel)

                Spacer()

                let iconColor: Color = isPlaying ? .red : (animal.isProOnly && !purchaseStatus.isProActive ? .gray : .orange)
                Image(systemName: isPlaying ? "stop.fill" : "play.fill")
                    .font(.title3)
                    .foregroundStyle(iconColor)
                    .padding(.trailing, 2)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color.gray.opacity(isQuickRepel ? 0.15 : 0.08), in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
        .id("animal_\(animal.id)")
    }

    @ViewBuilder
    private func animalInfo(animal: WatchAnimal, isQuickRepel: Bool) -> some View {
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
