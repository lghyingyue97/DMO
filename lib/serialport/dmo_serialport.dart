import 'dart:async';
import 'dart:typed_data';

import 'package:dmo/serialport/serialport.dart';
import 'package:synchronized/extension.dart';
import 'package:synchronized/synchronized.dart';

late _DMOSerialPort DMOCommunication = _DMOSerialPort._();

String get _AT_END => "\r\n";

String get _AT_START => "AT+";

///响应开始
String get _AT_RESPONSE_START => "+";

///响应结束
String get _AT_RESPONSE_END => "\r\n";

///85模块的串口配置
SerialPortOption get DMOSerialPortOption => SerialPortOption(
    baudRate: 115200, bits: 8, stopBits: 1, parity: 0, flowControl: 0);

///DMO串口通信
class _DMOSerialPort extends SerialPortImpl {
  ///处理数据锁
  Lock _readLock = Lock();

  ///接收的临时数据
  StringBuffer _tempReceiveData = StringBuffer();

  ///发送超时是否需要超时重发
  bool get _openSendTimeoutRetry => true;

  ///DMO响应数据分发
  StreamController<ATCommandResponse> _responseStreamController =
  StreamController.broadcast();

  ///业务监听此流做逻辑处理
  Stream<ATCommandResponse> get responseStream =>
      _responseStreamController.stream;

  _DMOSerialPort._() {
    readDataStream.listen((data) {
      _handleReadData(data);
    });
    connectState.addListener(() {
      if (!isConnected) {
        _tempReceiveData.clearAll();
        _stopTaskTimeout();
        _taskList.clear();
        _currentTask = null;
      }
    });
  }

  ///处理读取数据
  Future<void> _handleReadData(Uint8List data) async {
    await _readLock.synchronized(() async {
      if (!isConnected) {
        _tempReceiveData.clearAll();
        return;
      }
      await _tempReceiveData.append(String.fromCharCodes(data));
      String str = _tempReceiveData.toString();
      if (str.startsWith(_AT_RESPONSE_START) &&
          str.contains(_AT_RESPONSE_END)) {
        String data = str.substring(
            0, str.indexOf(_AT_RESPONSE_END) + _AT_RESPONSE_END.length);
        String command = data.substring(data.indexOf(_AT_RESPONSE_START) + 1,
            data.indexOf(_AT_RESPONSE_END));

        var response = ATCommandResponse(
          cmd: command.substring(0, command.indexOf(":")),
          result: command.substring(command.indexOf(":") + 1),
        );

        _responseStreamController.add(response);

        print("DMO COMMAND ====> " + response.cmd);
        print("DMO RESULT  ====> " + response.result);
        if (_currentTask != null && _currentTask!.cmd == response.cmd) {
          _removeCurrentTask();
        }
        await _tempReceiveData.delete(0, data.length);
      }
    });
  }

  List<ATCommandTask> _taskList = [];
  ATCommandTask? _currentTask = null;

  ///任务执行超时
  Timer? _taskTimeOutTimer = null;

  ///停止任务超时记时
  void _stopTaskTimeout() {
    if (_taskTimeOutTimer != null) {
      _taskTimeOutTimer?.cancel();
      _taskTimeOutTimer = null;
    }
  }

  ///开始任务超时记时
  void _startTaskTimeout() {
    if (_taskTimeOutTimer == null) {
      _taskTimeOutTimer = Timer(Duration(milliseconds: 3000), () {
        print("任务超时,需要重新写入");
        _currentTask = null;
        _startTaskRunner();
      });
    }
  }

  ///开始执行任务队列
  Future<void> _startTaskRunner() async {
    _stopTaskTimeout();
    if (_taskList.length != 0 && _currentTask == null && isConnected) {
      _currentTask = _taskList.first;
      print("写入数据->${String.fromCharCodes(_currentTask!.sendData).trim()}");
      await write(_currentTask!.sendData);
      if (_openSendTimeoutRetry) {
        _startTaskTimeout();
      } else {
        await Future.delayed(Duration(milliseconds: 30));
        _removeCurrentTask();
      }
    }
  }

  ///发送AT指令
  void sendATCommand(ATCommandTask task) {
    _addTask(task);
  }

  ///添加任务
  void _addTask(ATCommandTask task) {
    if (!isConnected) {
      print("串口未连接,无法写入");
      return;
    }

    ///此逻辑用来移除重复的命令
    if (_taskList.length >= 2) {
      ///任务队列超过2个任务
      var len = _taskList.length - 1;
      //start from the top
      for (var i = len; i >= 1; i--) {
        if (_taskList[i].cmd == task.cmd) {
          ///如果已经存在这个命令 就先移除掉执行最后一次即可
          _taskList.remove(i);
        }
      }
    }
    _taskList.add(task);
    _startTaskRunner();
  }

  ///移除当前任务(任务执行完成)
  void _removeCurrentTask() {
    if (_currentTask != null) {
      _taskList.remove(_currentTask);
      _currentTask = null;
    }

    ///开始下次任务循环
    _startTaskRunner();
  }
}

///AT 指令响应
class ATCommandResponse {
  String cmd;
  String result;

  ATCommandResponse({required this.cmd, required this.result});
}

///at指令任务
class ATCommandTask {
  String cmd;

  ///是否是无参查询
  bool noParamQuery;

  ///带参数指令
  List<String>? paramData;

  Uint8List get sendData {
    if (paramData != null && paramData!.length > 0) {
      return Uint8List.fromList(
          (_AT_START + cmd + "=" + paramData!.join(",") + _AT_END).codeUnits);
    } else if (noParamQuery) {
      ///无参查询
      return Uint8List.fromList((_AT_START + cmd + "?" + _AT_END).codeUnits);
    }

    return Uint8List.fromList((_AT_START + cmd + _AT_END).codeUnits);
  }

  ATCommandTask({required this.cmd, this.noParamQuery = false, this.paramData});
}

extension SBExt on StringBuffer {
  Future<void> delete(int start, int end) {
    return this.synchronized(() {
      try {
        String newString = this.toString().replaceRange(start, end, "");
        this.clear();
        this.write(newString);
      } catch (e) {}
    });
  }

  Future<void> clearAll() {
    return this.synchronized(() {
      this.clear();
    });
  }

  Future<void> append(String str) {
    return this.synchronized(() {
      this.write(str);
    });
  }

  String substring(int start, int end) {
    return this.toString().substring(start, end);
  }
}
