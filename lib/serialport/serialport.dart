import 'dart:async';

import 'package:flutter/foundation.dart';

import 'lib_serialport_impl.dart';

///通用串口实现
class SerialPortImpl extends ISerialPort {
  late ISerialPort _serialPort;

  SerialPortImpl() {
    _serialPort = LibSerialPortImpl();
  }

  @override
  Future<void> close() {
    return _serialPort.close();
  }

  @override
  Future<bool> open(String portName, {required SerialPortOption option}) {
    return _serialPort.open(portName, option: option);
  }

  @override
  Future<List<String>> serialPortList() {
    return _serialPort.serialPortList();
  }

  @override
  Future<bool> write(Uint8List bytes) {
    return _serialPort.write(bytes);
  }

  @override
  Stream<Uint8List> get readDataStream => _serialPort.readDataStream;

  @override
  ValueNotifier<bool> get connectState => _serialPort.connectState;
}

class SerialPortOption {
  ///波特率
  int baudRate;

  ///数据位
  int bits;

  ///校验位
  ///0 No parity.
  ///1 Odd parity.
  ///2 Even parity.
  ///3 Mark parity.
  ///4 Space parity.
  int parity;

  ///停止位
  int stopBits;

  ///流控
  ///0 No flow control.
  ///1 Software flow control using XON/XOFF characters.
  ///2 Hardware flow control using RTS/CTS signals.
  ///3 Hardware flow control using DTR/DSR signals.
  int flowControl;

  SerialPortOption(
      {this.baudRate = 9600,
      this.parity = 0,
      this.bits = 8,
      this.stopBits = 1,
      this.flowControl = 0});
}

abstract class ISerialPort {
  ///连接状态
  ValueNotifier<bool> get connectState;

  ///是否已连接
  bool get isConnected => connectState.value;

  ///数据读取流
  Stream<Uint8List> get readDataStream;

  ///获取串口列表
  Future<List<String>> serialPortList();

  ///打开端口
  Future<bool> open(String portName, {required SerialPortOption option});

  ///写入数据
  Future<bool> write(Uint8List bytes);

  ///关闭串口
  Future<void> close();
}
