import SwiftUI

/// 动物数据模型（Watch 端独立版）
/// topSoundFile 必须对应 Sounds 文件夹中的 mp3 文件名（含编号，不含扩展名）
struct WatchAnimal: Identifiable, Hashable {
    let id: String
    let emoji: String
    let category: String
    let categoryEmoji: String
    let topSoundNameKey: String    // 本地化 key
    let topSoundFile: String       // 对应 Sounds/*.mp3 的文件名（含编号）
    let rating: Int

    /// 动物本地化名称
    var name: String { L10n.tr("animal_\(id)") }

    /// 推荐声音本地化名称
    var topSoundName: String { L10n.tr(topSoundNameKey) }

    static let allAnimals: [WatchAnimal] = [
        // ============ 猛兽威胁 ============
        WatchAnimal(id: "wild_dog", emoji: "🐕", category: "beast", categoryEmoji: "🦁", topSoundNameKey: "sound_tiger", topSoundFile: "tiger_1", rating: 5),
        WatchAnimal(id: "wild_boar", emoji: "🐗", category: "beast", categoryEmoji: "🦁", topSoundNameKey: "sound_lion", topSoundFile: "lion_1", rating: 5),
        WatchAnimal(id: "bear", emoji: "🐻", category: "beast", categoryEmoji: "🦁", topSoundNameKey: "sound_gunshot", topSoundFile: "gunshot_1", rating: 5),
        WatchAnimal(id: "wolf", emoji: "🐺", category: "beast", categoryEmoji: "🦁", topSoundNameKey: "sound_wolf", topSoundFile: "wolf_1", rating: 5),
        WatchAnimal(id: "fox", emoji: "🦊", category: "beast", categoryEmoji: "🦁", topSoundNameKey: "sound_dog", topSoundFile: "dog_1", rating: 5),
        // ============ 爬行类 ============
        WatchAnimal(id: "snake", emoji: "🐍", category: "reptile", categoryEmoji: "🐍", topSoundNameKey: "sound_rooster", topSoundFile: "rooster_1", rating: 5),
        // ============ 灵长类 ============
        WatchAnimal(id: "monkey", emoji: "🐒", category: "primate", categoryEmoji: "🐒", topSoundNameKey: "sound_eagle", topSoundFile: "eagle_1", rating: 5),
        // ============ 啮齿类 ============
        WatchAnimal(id: "mouse", emoji: "🐭", category: "rodent", categoryEmoji: "🐭", topSoundNameKey: "sound_cat", topSoundFile: "cat_1", rating: 5),
        WatchAnimal(id: "rabbit", emoji: "🐰", category: "rodent", categoryEmoji: "🐭", topSoundNameKey: "sound_dog", topSoundFile: "dog_2", rating: 5),
        // ============ 昆虫类 ============
        WatchAnimal(id: "spider", emoji: "🕷️", category: "insect", categoryEmoji: "🐛", topSoundNameKey: "sound_vibration", topSoundFile: "vibration_1", rating: 5),
        WatchAnimal(id: "wasp", emoji: "🐝", category: "insect", categoryEmoji: "🐛", topSoundNameKey: "sound_low_freq", topSoundFile: "low_freq_1", rating: 5),
        // ============ 鸟类 ============
        WatchAnimal(id: "crow", emoji: "🐦‍⬛", category: "bird", categoryEmoji: "🦅", topSoundNameKey: "sound_eagle", topSoundFile: "eagle_2", rating: 5),
    ]

    /// 按分类分组
    static var categorized: [(name: String, emoji: String, animals: [WatchAnimal])] {
        let categories: [(String, String, String)] = [
            ("beast", "🦁", "category_beast"),
            ("reptile", "🐍", "category_reptile"),
            ("primate", "🐒", "category_primate"),
            ("rodent", "🐭", "category_rodent"),
            ("insect", "🐛", "category_insect"),
            ("bird", "🦅", "category_bird"),
        ]

        return categories.compactMap { catId, catEmoji, catNameKey in
            let animals = allAnimals.filter { $0.category == catId }
            if animals.isEmpty { return nil }
            return (name: L10n.tr(catNameKey), emoji: catEmoji, animals: animals)
        }
    }
}
