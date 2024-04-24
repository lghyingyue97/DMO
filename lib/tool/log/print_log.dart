import 'dart:io';
import 'write_log.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart' as logger;

_XLog Log = _XLog();

logger.Logger _logger = logger.Logger(
    output: _ConsoleOutput(),
    filter: _LogFilter(),
    printer: Platform.isIOS
        ? logger.PrefixPrinter(logger.PrettyPrinter(colors: false))
        : logger.PrettyPrinter());

class _ConsoleOutput extends logger.LogOutput {
  @override
  void output(logger.OutputEvent event) {
    const String channel = String.fromEnvironment("CHANNEL");
    if (channel == "pgy" || kDebugMode) {
      event.lines.forEach(print);
      event.lines.forEach((element) {
        String newElement =
            element.replaceFirst("[38;5;196m", "").replaceAll("[0m", "");
        writeLog(tag: event.level.name, info: newElement);
      });
    }
  }
}

class _LogFilter extends logger.LogFilter {
  @override
  bool shouldLog(logger.LogEvent event) {
    const String channel = String.fromEnvironment("CHANNEL");
    if (kDebugMode || channel == "pgy") {
      return true;
    }
    return false;
  }
}

class _XLog {
  void t({
    dynamic message,
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _logger.t(message ?? "[track]",
        time: time, error: error, stackTrace: stackTrace);
  }

  void d({
    dynamic message,
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _logger.d(message ?? "[debug]",
        time: time, error: error, stackTrace: stackTrace);
  }

  void i({
    dynamic message,
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _logger.i(message ?? "[info]",
        time: time, error: error, stackTrace: stackTrace);
  }

  void w({
    dynamic message,
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _logger.w(message ?? "[warning]",
        time: time, error: error, stackTrace: stackTrace);
  }

  void e({
    dynamic message,
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _logger.e(message ?? "[error]",
        time: time, error: error, stackTrace: stackTrace);
  }

  void f({
    dynamic message,
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _logger.f(message ?? "[fatal]",
        time: time, error: error, stackTrace: stackTrace);
  }
}
