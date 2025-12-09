// ignore_for_file: avoid_print

import 'dart:io';

void main() {
  // 定义所有需要修复的文件路径和对应的 part 语句
  final targets = {
    // Models (Freezed)
    'lib/models/app.dart': "part 'app.freezed.dart';",
    'lib/models/clash_config.dart': "part 'clash_config.freezed.dart';",
    'lib/models/widget.dart': "part 'widget.freezed.dart';",
    'lib/models/common.dart': "part 'common.freezed.dart';",
    'lib/models/config.dart': "part 'config.freezed.dart';",
    'lib/models/core.dart': "part 'core.freezed.dart';",
    'lib/models/profile.dart': "part 'profile.freezed.dart';",
    'lib/models/selector.dart': "part 'selector.freezed.dart';",

    // Providers (Riverpod Generator)
    'lib/providers/app.dart': "part 'app.g.dart';",
    'lib/providers/config.dart': "part 'config.g.dart';",
    'lib/providers/state.dart': "part 'state.g.dart';",
  };

  print('🚀 开始自动修复 part 引用...\n');

  for (var entry in targets.entries) {
    fixFile(entry.key, entry.value);
  }

  print('\n✅ 所有文件处理完毕！');
  print('👉 现在请运行: dart run build_runner build --delete-conflicting-outputs');
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

  // 2. 寻找插入点：找到最后一个 import 语句
  int insertIndex = -1;
  for (int i = 0; i < lines.length; i++) {
    if (lines[i].trim().startsWith('import ')) {
      insertIndex = i;
    }
  }

  // 如果找不到 import，就插在第一行；如果找到了，插在最后一个 import 后面
  if (insertIndex == -1) {
    insertIndex = 0;
  } else {
    insertIndex++; // 插在下一行
  }

  // 3. 插入并保存
  final newLines = List<String>.from(lines);
  newLines.insert(insertIndex, partLine);

  file.writeAsStringSync(newLines.join('\n'));
  print('✅ 已修复: $path');
}
