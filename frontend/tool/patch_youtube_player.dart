// Run after `flutter pub get` if you see:
// "type 'Null' is not a subtype of type 'String' of 'function result'"
// on the in-app video screen.
//
// Usage: dart run tool/patch_youtube_player.dart

import 'dart:io';

void main() {
  final sep = Platform.pathSeparator;
  final local = Platform.environment['LOCALAPPDATA'] ?? Platform.environment['USERPROFILE'] ?? '';
  final pubCache = Platform.environment['PUB_CACHE'] ?? '$local${sep}Pub${sep}Cache';
  final path = '$pubCache${sep}hosted${sep}pub.dev${sep}youtube_player_flutter-9.1.3${sep}lib${sep}src${sep}utils${sep}youtube_meta_data.dart';
  final file = File(path);
  if (!file.existsSync()) {
    print('Package path not found. Try: flutter pub get then run again.');
    exit(1);
  }
  String content = file.readAsStringSync();
  if (content.contains("as String? ?? ''")) {
    print('youtube_player_flutter is already patched.');
    exit(0);
  }
  content = content.replaceAll(
    "videoId: data['videoId'],",
    "videoId: data['videoId'] as String? ?? '',",
  );
  content = content.replaceAll(
    "title: data['title'],",
    "title: data['title'] as String? ?? '',",
  );
  content = content.replaceAll(
    "author: data['author'],",
    "author: data['author'] as String? ?? '',",
  );
  file.writeAsStringSync(content);
  print('Patched youtube_player_flutter. You can run the app again.');
}
