import 'package:convert/convert.dart';
import 'dart:math';
import 'package:gbk_codec/gbk_codec.dart';

///bytes 转 hex
String bytes2Hex(List<int> bytes) {
  return hex.encode(bytes);
}

///bytes 转 无符号int
int bytes2Int(List<int> bytes) {
  return int.parse(hex.encode(bytes), radix: 16);
}

///hex 转 bytes
List<int> hex2bytes(String hexStr) {
  return hex.decode(hexStr);
}

int hex2Int(String hex) {
  return int.parse(hex, radix: 16);
}

String int2Hex(int i, {int? length}) {
  String hex = i.toRadixString(16).toUpperCase();

  if (hex.length % 2 != 0) {
    hex = "0" + hex;
  }
  if (length != null) {
    int hexLength = hex.length;
    if (hexLength < length) {
      for (int i = 0; i < length - hexLength; i++) {
        hex = "0" + hex;
      }
    }
  }

  return hex;
}

///hex转有符号整形
int hex2SInt(String hex) {
  if (hex.length % 2 != 0) {
    hex = "0" + hex;
  }
  var num = int.parse(hex, radix: 16);
  var maxVal = pow(2, hex.length / 2 * 8).toInt();
  if (num > maxVal / 2 - 1) {
    num = num - maxVal;
  }
  return num;
}

///hex转有符号整形
int bytes2SInt(List<int> bytes) {
  String hex = bytes2Hex(bytes);

  if (hex.length % 2 != 0) {
    hex = "0" + hex;
  }
  var num = int.parse(hex, radix: 16);
  var maxVal = pow(2, hex.length / 2 * 8).toInt();
  if (num > maxVal / 2 - 1) {
    num = num - maxVal;
  }
  return num;
}

///有符号整形转无符号
List<int> sInt2bytes(int i, {int size = 1}) {
  if (i >= 0) {
    var hex = i.toRadixString(16).toUpperCase();
    if (hex.length % 2 != 0) {
      hex = "0" + hex;
    }
    var hexLength = hex.length;
    var totalLength = size * 2;
    if (hexLength < totalLength) {
      for (int index = 0; index < totalLength - hexLength; index++) {
        hex = "0" + hex;
      }
    }
    return hex2bytes(hex);
  } else {
    var hh = 0xff;
    if (size == 2) {
      hh = 0xffff;
    } else if (size == 3) {
      hh = 0xffffff;
    } else if (size == 4) {
      hh = 0xffffffff;
    } else if (size == 5) {
      hh = 0xffffffffff;
    }

    var hex = (i & hh).toRadixString(16).toUpperCase();
    if (hex.length % 2 != 0) {
      hex = "0" + hex;
    }
    var hexLength = hex.length;
    var totalLength = size * 2;
    if (hexLength < totalLength) {
      for (int index = 0; index < totalLength - hexLength; index++) {
        hex = "0" + hex;
      }
    }
    return hex2bytes(hex);
  }
}


///int 转bytes
List<int> int2bytes(int value, int size) {
  String hexStr = value.toRadixString(16).toUpperCase();

  if (hexStr.length % 2 != 0) {
    hexStr = "0" + hexStr;
  }
  int hexLength = hexStr.length;
  if (hexLength < size * 2) {
    for (int i = 0; i < size * 2 - hexLength; i++) {
      hexStr = "0" + hexStr;
    }
  }
  return hex.decode(hexStr);
}


String hex2GBK(String hex) {
  if (hex == "") {
    return hex;
  }
  hex = hex.replaceAll(" ", "");
  List<int> bytes = List.generate(hex.length ~/ 2, (index) => 0);
  for (int i = 0; i < bytes.length; i++) {
    bytes[i] = hex2Int(hex.substring(i * 2, i * 2 + 2));
  }
  return _trim(gbk_bytes.decode(bytes));
}

String _trim(String? str) {
  if (str != null) {
    for (var i = 0; i < 21; i++) {
      var reg = new RegExp(String.fromCharCode(i));
      str = str!.replaceAll(reg, "");
    }
  }
  return str ?? "";
}

String gbk2Hex(String gbkStr) {
  List<int> gbk_byteCodes = gbk_bytes.encode(gbkStr);
  String hex = '';
  gbk_byteCodes.forEach((i) {
    hex += i.toRadixString(16);
  });
  return hex.toUpperCase();
}

///取bit任意位置的值
int bitX(int value, int x) {
  return value >> x & 0x01;
}
