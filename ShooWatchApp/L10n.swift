import Foundation

/// Watch App 本地化辅助
enum L10n {
    /// 获取本地化字符串
    static func tr(_ key: String) -> String {
        return NSLocalizedString(key, bundle: .main, comment: "")
    }

    // MARK: - 通用
    static let appName = tr("app_name")

    // MARK: - 一键驱赶
    static let quickRepel = tr("quick_repel")
    static let repelling = tr("repelling")
    static let quickRepelSound = tr("quick_repel_sound")

    // MARK: - 播放
    static let playing = tr("playing")
    static let stop = tr("stop")

    // MARK: - 分类
    static let categoryBeast = tr("category_beast")
    static let categoryReptile = tr("category_reptile")
    static let categoryPrimate = tr("category_primate")
    static let categoryRodent = tr("category_rodent")
    static let categoryInsect = tr("category_insect")
    static let categoryBird = tr("category_bird")

    // MARK: - 动物名
    static let animalWildDog = tr("animal_wild_dog")
    static let animalWildBoar = tr("animal_wild_boar")
    static let animalBear = tr("animal_bear")
    static let animalWolf = tr("animal_wolf")
    static let animalFox = tr("animal_fox")
    static let animalSnake = tr("animal_snake")
    static let animalMonkey = tr("animal_monkey")
    static let animalMouse = tr("animal_mouse")
    static let animalRabbit = tr("animal_rabbit")
    static let animalSpider = tr("animal_spider")
    static let animalWasp = tr("animal_wasp")
    static let animalCrow = tr("animal_crow")

    // MARK: - 声音名
    static let soundTiger = tr("sound_tiger")
    static let soundLion = tr("sound_lion")
    static let soundGunshot = tr("sound_gunshot")
    static let soundWolf = tr("sound_wolf")
    static let soundDog = tr("sound_dog")
    static let soundRooster = tr("sound_rooster")
    static let soundEagle = tr("sound_eagle")
    static let soundCat = tr("sound_cat")
    static let soundVibration = tr("sound_vibration")
    static let soundLowFreq = tr("sound_low_freq")
}
