import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';

import 'serialport.dart';

class LibSerialPortImpl extends ISerialPort {
  SerialPort? _port;
  SerialPortReader? _reader;

  StreamSubscription<Uint8List>? _readerSubscription;

  ///接收数据分发
  StreamController<Uint8List> _readStreamController =
      StreamController.broadcast();

  ValueNotifier<bool> _connectState = ValueNotifier(false);

  ///获取串口列表
  @override
  Future<List<String>> serialPortList() async {
    return SerialPort.availablePorts;
  }

  ///打开串口
  @override
  Future<bool> open(String portName, {required SerialPortOption option}) async {
    try {
      if (portName == _port?.name && isConnected) {
        return true;
      }
      close();
      _port = SerialPort(portName);

      bool open = _port!.openReadWrite();

      var config = SerialPortConfig()
        ..baudRate = option.baudRate
        ..stopBits = option.stopBits
        ..bits = option.bits
        ..parity = option.parity
        ..setFlowControl(option.flowControl);
      if (open) {
        ///必须先打开端口 在设置配置,不然不起效
        _port!.config = config;
        connectState.value = true;
        _reader = SerialPortReader(_port!);
        _readerSubscription = _reader!.stream.listen((data) {
          _readStreamController.add(data);
        }, onError: (error) {
          print(error);
          close();
        });
      } else {
        close();
        print("打开串口失败");
        print(SerialPort.lastError);
      }
      return open;
    } on Exception catch (e) {
      close();
      if (SerialPort.lastError?.errorCode == 2) {
        print("打开串口失败，未找到串口");
      }
      print(SerialPort.lastError);
    }
    return false;
  }

  @override
  Future<bool> write(Uint8List bytes) async {
    if (isConnected) {
      _port?.write(Uint8List.fromList(bytes));
      return true;
    } else {
      return false;
    }
  }

  @override
  Future<void> close() async {
    _reader?.close();
    _port?.close();
    _port?.dispose();
    _readerSubscription?.cancel();
    _reader = null;
    _port = null;
    connectState.value = false;
  }

  @override
  Stream<Uint8List> get readDataStream => _readStreamController.stream;

  @override
  ValueNotifier<bool> get connectState => _connectState;
}
