// ignore_for_file: avoid_print

import 'dart:io';

void main() {
  // 这次只针对缺 .g.dart 的文件
  final targets = {
    'lib/models/clash_config.dart': "part 'clash_config.g.dart';",
    'lib/models/common.dart': "part 'common.g.dart';",
    'lib/models/config.dart': "part 'config.g.dart';",
    'lib/models/core.dart': "part 'core.g.dart';",
    'lib/models/profile.dart': "part 'profile.g.dart';",
  };

  print('🚀 开始补全 JsonSerializable 的 part 引用...\n');

  for (var entry in targets.entries) {
    fixFile(entry.key, entry.value);
  }

  print('\n✅ 补全完毕！');
  print('👉 最后再跑一次: dart run build_runner build --delete-conflicting-outputs');
}

void fixFile(String path, String partLine) {
  final file = File(path);

  if (!file.existsSync()) {
    print('❌ 未找到文件: $path (跳过)');
    return;
  }

  final lines = file.readAsLinesSync();

  // 1. 检查是否已经存在该 part 语句
  if (lines.any((line) => line.trim() == partLine.trim())) {
    print('⏭️  已存在，跳过: $path');
    return;
  }

  // 2. 寻找插入点：为了美观，我们尝试插在现有的 part 语句后面
  // 如果没有 part，就插在最后一个 import 后面
  int insertIndex = -1;

  // 先找最后一个 part
  for (int i = 0; i < lines.length; i++) {
    if (lines[i].trim().startsWith('part ')) {
      insertIndex = i;
    }
  }

  // 没找到 part，就找 import
  if (insertIndex == -1) {
    for (int i = 0; i < lines.length; i++) {
      if (lines[i].trim().startsWith('import ')) {
        insertIndex = i;
      }
    }
  }

  // 确定位置
  if (insertIndex == -1) {
    insertIndex = 0;
  } else {
    insertIndex++; // 插在下一行
  }

  // 3. 插入并保存
  final newLines = List<String>.from(lines);
  newLines.insert(insertIndex, partLine);

  file.writeAsStringSync(newLines.join('\n'));
  print('✅ 已添加: $partLine -> $path');
}
