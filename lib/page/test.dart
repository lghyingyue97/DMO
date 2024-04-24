import 'package:dmo/serialport/dmo_command.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:oktoast/oktoast.dart';
import 'package:dmo/serialport/dmo_serialport.dart';

class TestPage extends StatefulWidget {
  const TestPage({Key? key}) : super(key: key);

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  String? gbw;
  String? gbww;
  String? tfv;
  String? rfv;
  String? txsubtyp;
  String? txsubtypp;
  String? rxsubtyp;
  String? rxsubtypp;
  String? txsubidx;
  String? rxsubidx;
  String? sq;

  String? selectedChannel;

  late StreamSubscription<ATCommandResponse> _responseSubscription;

  TextEditingController freq = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 初始化时订阅响应流
    _subscribeToResponseStream();
  }

  @override
  void dispose() {
    _responseSubscription.cancel();
    super.dispose();
  }

  // 订阅响应流
  void _subscribeToResponseStream() {
    _responseSubscription = DMOCommunication.responseStream.listen((response) {
      if (response.cmd == "DMOANAGROUP") {
        _updateParameters(response.result);
      }
      if (response.cmd == "DMOANAGROUP" && response.result == "OK") {
        showToast("修改参数成功");
      }
      if (response.cmd == "DMOCH" && response.result != "OK") {
        setState(() {
          selectedChannel = _extractChannel(response.result);
        });
      }
      if (response.cmd == "DMOCONNECT" && response.result == "SUCCESS") {
        showToast("握手成功");
      }
      if (response.cmd == "DMOCH" && response.result == "OK") {
        showToast("信道切换成功");
      }
      if (response.result == "ERR") {
        showToast("操作失败");
      }
    });
  }

  String? _extractChannel(String result) {
    List<String> parts = result.split(',');
    if (parts.length == 2) {
      return parts[1];
    }
    return parts[0];
  }

  void _updateParameters(String result) {
    List<String> params = result.split(',');
    if (params.length == 8) {
      setState(() {
        gbww = parseGBW(params[0]);
        gbw = params[0];
        tfv = parseFrequency(params[1]);
        rfv = parseFrequency(params[2]);
        txsubtyp = params[3];
        txsubtypp = parseSubtype(params[3]);
        rxsubtyp = params[5];
        rxsubtypp = parseSubtype(params[5]);
        txsubidx = params[4];
        rxsubidx = params[6];
        sq = parseSQ(params[7]);
      });
    }
  }

  String parseGBW(String value) {
    if (value == "12.5K") {
      return "窄带";
    } else if (value == "25K") {
      return "宽带";
    } else if (value =="窄带") {
      return "12.5K";
    } else if (value == "宽带") {
      return "25K";
    } else {
      return "未知";
    }
  }

  String parseFrequency(String value) {
    double freq = double.tryParse(value) ?? 0;
    return (freq / 1000000).toStringAsFixed(3) + "MHz";
  }

  String parseSubtype(String value) {
    switch (value) {
      case "NONE":
        return "纯语音";
      case "CTCSS":
        return "亚音频";
      case "DCSN":
        return "亚音数码";
      case "DCSI":
        return "反向亚音数码";
      default:
        return "未知";
    }
  }

  String parseSQ(String value) {
    int sqLevel = int.tryParse(value) ?? 0;
    if (sqLevel == 0) {
      return "静噪打开模式";
    } else if (sqLevel >= 1 && sqLevel <= 5) {
      return sqLevel.toString();
    } else {
      return "未知";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("测试"),
      ),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 10),
              ValueListenableBuilder(
                valueListenable: DMOCommunication.connectState,
                builder: (ctx, state, child) {
                  return Text("串口开启状态: $state", textAlign: TextAlign.center);
                },
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      DMOCommunication.serialPortList().then((value) {
                        print(value);
                      });
                    },
                    child: Text("读取串口列表"),
                  ),
                  SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      DMOCommunication.open("com5", option: DMOSerialPortOption);
                    },
                    child: Text("打开串口"),
                  ),
                  SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      DMOCommunication.close();
                    },
                    child: Text("关闭串口"),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      handshake();
                    },
                    child: Text("发送握手信息"),
                  ),
                  SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      _responseSubscription.cancel();
                      queryParameters();
                      // 重新订阅响应流
                      _subscribeToResponseStream();
                    },
                    child: Text("查询参数"),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      queryChannel();
                    },
                    child: Text("查询信道"),
                  ),
                  SizedBox(width: 20),
                  DropdownButton<String>(
                    value: selectedChannel,
                    onChanged: (String? value) {
                      setState(() {
                        selectedChannel = value;
                      });
                    },
                    items: <String>['1', '2', '3'].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text('信道 $value'),

                      );
                    }).toList(),
                  ),
                  SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      modifyChannel(selectedChannel);
                      queryParameters();
                    },
                    child: Text("切换信道"),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DropdownButton<String>(
                    value: gbw,
                    onChanged: (String? value) {
                      setState(() {
                        gbw = value;
                      });
                    },
                    items: <String>['12.5K', '25K'].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      modifyParameter(gbw, tfv, rfv, txsubtyp, txsubidx, rxsubtyp, rxsubidx, sq);
                      queryParameters();
                    },
                    child: Text("修改带宽"),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    // width: MediaQuery.of(context).size.width * 0.1,
                    width: 120,
                    height: 30,
                    child: TextFormField(
                      controller: freq,
                      decoration: InputDecoration(
                        labelText: "频率(MHz)",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      modifyParameter(gbw, freq.text, freq.text, txsubtyp, txsubidx, rxsubtyp, rxsubidx, sq);
                      queryParameters();
                    },
                    child: Text("修改频率"),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DropdownButton<String>(
                    value: txsubtyp,
                    onChanged: (String? value) {
                      setState(() {
                        txsubtyp = value;
                        rxsubtyp = value;
                      });
                    },
                    items: <String>['NONE', 'CTCSS', 'DCSN', 'DCSI'].map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      modifyParameter(gbw, tfv, rfv, txsubtyp, txsubidx, rxsubtyp, rxsubidx, sq);
                      queryParameters();
                    },
                    child: Text("修改SUBTYP"),
                  ),
                ],
              ),
              SizedBox(height: 20),
              _buildParameterRow("GBW", gbww),
              _buildParameterRow("TFV", tfv),
              _buildParameterRow("RFV", rfv),
              _buildParameterRow("TXSUBTYPE", txsubtypp),
              _buildParameterRow("RXSUBTYPE", rxsubtypp),
              _buildParameterRow("TXSUBV", txsubidx),
              _buildParameterRow("RXSUBV", rxsubidx),
              _buildParameterRow("SQ", sq),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildParameterRow(String label, String? value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 1,
            child: Text(
              label,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            flex: 4,
            child: Text(
              value ?? "-",
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }
}

