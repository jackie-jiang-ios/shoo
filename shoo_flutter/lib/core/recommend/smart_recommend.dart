import '../../models/animal.dart';

/// 智能推荐引擎
///
/// 基于当前时段动态推荐需要防范的动物。
/// 逻辑依据：
/// - 夜间（18:00-06:00）：蛇类、野猪等夜行性动物活跃
/// - 清晨/黄昏（05:00-08:00 / 17:00-20:00）：野兽出没高峰
/// - 白天（08:00-17:00）：野狗、猴子等常见动物
class SmartRecommendEngine {
  SmartRecommendEngine._();

  /// 根据当前时间获取推荐动物 ID 列表
  static List<String> getRecommendedAnimalIds() {
    return getRecommendedAnimalIdsForTime(DateTime.now());
  }

  /// 根据指定时间获取推荐动物 ID 列表（便于测试）
  static List<String> getRecommendedAnimalIdsForTime(DateTime time) {
    final hour = time.hour;

    // 夜间：18:00 - 05:59
    if (hour >= 18 || hour < 6) {
      return ['snake', 'wild_boar', 'wolf'];
    }

    // 清晨/黄昏高峰：06:00 - 07:59 / 17:00 - 17:59
    if ((hour >= 6 && hour < 8) || hour == 17) {
      return ['wild_boar', 'snake', 'wild_dog'];
    }

    // 白天：08:00 - 16:59
    return ['wild_dog', 'monkey', 'bear'];
  }

  /// 根据当前时间和语言代码获取推荐动物的本地化名称
  static List<String> getRecommendedNames(String langCode) {
    final ids = getRecommendedAnimalIds();
    return ids
        .map((id) => AnimalDatabase.findById(id))
        .whereType<Animal>()
        .map((a) => a.getLocalizedName(langCode))
        .toList();
  }
}
