import 'dart:io';
import 'package:path/path.dart' as p;

void main() async {
  final projectRoot = Directory.current;
  print('🔍 防兽神器（Shoo）项目结构分析');
  print('=' * 60);

  // 统计 Dart 文件
  final dartFiles = <File>[];
  await for (final entity in projectRoot.list(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      dartFiles.add(entity);
    }
  }

  print('\n📊 Dart 文件统计：');
  print('  总文件数: ${dartFiles.length}');

  // 按目录分类
  final categories = <String, List<File>>{};
  for (final file in dartFiles) {
    final relative = p.relative(file.path, from: projectRoot.path);
    final parts = relative.split(Platform.pathSeparator);
    String category;
    if (parts.length > 3 && parts[2] == 'features') {
      category = 'features/${parts[4]}';
    } else if (parts.length > 3) {
      category = '${parts[2]}/${parts[3]}';
    } else {
      category = parts.last;
    }
    categories.putIfAbsent(category, () => []).add(file);
  }

  print('\n📁 文件分布：');
  for (final entry in categories.entries) {
    print('  ${entry.key}: ${entry.value.length} 文件');
  }

  // 代码行数统计
  int totalLines = 0;
  for (final file in dartFiles) {
    totalLines += await file.readAsLines().then((lines) => lines.length);
  }

  print('\n📝 代码行数：');
  print('  总计: $totalLines 行');
  print('  平均: ${(totalLines / dartFiles.length).toStringAsFixed(1)} 行/文件');

  print('\n✅ 项目结构分析完成');
}
