import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

export 'log_page.dart';

Future<String?> _logFilePathDir() async {
  if (Platform.isAndroid) {
    return (await getExternalStorageDirectory())!.path + "/logs";
  } else if (Platform.isIOS) {
    return (await getApplicationDocumentsDirectory()).path + "/logs";
  }
  return null;
}

void writeLog({required String tag, required String info}) async {
  const String channel = String.fromEnvironment("CHANNEL");
  if (channel == "pgy" || kDebugMode) {
    DateTime time = DateTime.now();
    String name = time.year.toString() +
        "_" +
        time.month.toString() +
        "_" +
        ((time.day < 10) ? "0${time.day.toString()}" : time.day.toString()) +
        ".txt";
    String? path = await _logFilePathDir();
    if (path != null) {
      File file = File(path + "/" + name);
      if (!file.existsSync()) {
        file.createSync(recursive: true);
      }
      String msg = "[${DateTime.now().toString()}][$tag]$info\r";
      file.writeAsStringSync(msg,
          mode: FileMode.append, encoding: utf8, flush: true);
    }
  }
}

Future<List<String>> logFileList() async {
  String? path = await _logFilePathDir();
  if (path != null) {
    var dir = Directory(path);
    return dir.listSync().map((e) {
      return e.path;
    }).toList()
      ..sort();
  }
  return List.empty();
}
