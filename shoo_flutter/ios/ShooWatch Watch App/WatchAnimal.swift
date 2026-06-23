import SwiftUI

/// 动物数据模型（Watch 端独立版）
/// topSoundGroup 必须对应 Sounds 文件夹中的 mp3 文件名（不含扩展名）
struct WatchAnimal: Identifiable, Hashable {
    let id: String
    let name: String
    let emoji: String
    let category: String
    let categoryEmoji: String
    let topSoundName: String       // 推荐声音名称（UI 展示用）
    let topSoundGroup: String      // 对应 Sounds/*.mp3 的文件名
    let rating: Int
    
    static let allAnimals: [WatchAnimal] = [
        // ============ 猛兽威胁 ============
        WatchAnimal(id: "wild_dog", name: "野狗", emoji: "🐕", category: "beast", categoryEmoji: "🦁", topSoundName: "虎啸声", topSoundGroup: "tiger", rating: 5),
        WatchAnimal(id: "wild_boar", name: "野猪", emoji: "🐗", category: "beast", categoryEmoji: "🦁", topSoundName: "狮吼声", topSoundGroup: "lion", rating: 5),
        WatchAnimal(id: "bear", name: "熊", emoji: "🐻", category: "beast", categoryEmoji: "🦁", topSoundName: "枪声", topSoundGroup: "gunshot", rating: 5),
        WatchAnimal(id: "wolf", name: "狼", emoji: "🐺", category: "beast", categoryEmoji: "🦁", topSoundName: "狼嚎声", topSoundGroup: "wolf", rating: 5),
        WatchAnimal(id: "fox", name: "狐狸", emoji: "🦊", category: "beast", categoryEmoji: "🦁", topSoundName: "狗吠声", topSoundGroup: "dog", rating: 5),
        // ============ 爬行类 ============
        WatchAnimal(id: "snake", name: "毒蛇", emoji: "🐍", category: "reptile", categoryEmoji: "🐍", topSoundName: "雄鸡啼鸣", topSoundGroup: "rooster", rating: 5),
        // ============ 灵长类 ============
        WatchAnimal(id: "monkey", name: "猴子", emoji: "🐒", category: "primate", categoryEmoji: "🐒", topSoundName: "鹰啸声", topSoundGroup: "eagle", rating: 5),
        // ============ 啮齿类 ============
        WatchAnimal(id: "mouse", name: "老鼠", emoji: "🐭", category: "rodent", categoryEmoji: "🐭", topSoundName: "猫叫声", topSoundGroup: "cat", rating: 5),
        WatchAnimal(id: "rabbit", name: "野兔", emoji: "🐰", category: "rodent", categoryEmoji: "🐭", topSoundName: "狗吠声", topSoundGroup: "dog", rating: 5),
        // ============ 昆虫类 ============
        WatchAnimal(id: "spider", name: "毒蜘蛛", emoji: "🕷️", category: "insect", categoryEmoji: "🐛", topSoundName: "震动声", topSoundGroup: "vibration", rating: 5),
        WatchAnimal(id: "wasp", name: "马蜂", emoji: "🐝", category: "insect", categoryEmoji: "🐛", topSoundName: "低频声波", topSoundGroup: "low_freq", rating: 5),
        // ============ 鸟类 ============
        WatchAnimal(id: "crow", name: "乌鸦", emoji: "🐦‍⬛", category: "bird", categoryEmoji: "🦅", topSoundName: "鹰啸声", topSoundGroup: "eagle", rating: 5),
    ]
    
    /// 按分类分组
    static var categorized: [(name: String, emoji: String, animals: [WatchAnimal])] {
        let categories: [(String, String, String)] = [
            ("beast", "🦁", "猛兽"),
            ("reptile", "🐍", "爬行类"),
            ("primate", "🐒", "灵长类"),
            ("rodent", "🐭", "啮齿类"),
            ("insect", "🐛", "昆虫类"),
            ("bird", "🦅", "鸟类"),
        ]
        
        return categories.compactMap { catId, catEmoji, catName in
            let animals = allAnimals.filter { $0.category == catId }
            if animals.isEmpty { return nil }
            return (name: catName, emoji: catEmoji, animals: animals)
        }
    }
}
