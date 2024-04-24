import 'dart:ffi';

import 'dmo_serialport.dart';

export 'dmo_serialport.dart';

///85模块的AT指令
enum ATCommand { DMOCONNECT, DMOANAGROUP, DMOCH}

///握手命令
void handshake() {
  DMOCommunication.sendATCommand(ATCommandTask(cmd: ATCommand.DMOCONNECT.name));
}

/// 查询参数命令
void queryParameters() {
  DMOCommunication.sendATCommand(ATCommandTask(cmd: ATCommand.DMOANAGROUP.name, noParamQuery: true));
}

/// 查询信道命令
void queryChannel() {
  DMOCommunication.sendATCommand(ATCommandTask(cmd: ATCommand.DMOCH.name, noParamQuery: true));
}

/// 修改信道命令
void modifyChannel(String? channel) {
  DMOCommunication.sendATCommand(ATCommandTask(cmd: ATCommand.DMOCH.name, paramData: [channel??'']));
}

/// 修改参数命令
void modifyParameter(String? gbw, String? tfv, String? rfv, String? txsubtyp, String? txsubidx, String? rxsubtyp, String? rxsubidx, String? sq) {
  // String gbwValue = gbw == "窄带" ? "12.5K" : "25K";
  String gbwValue = gbw == "12.5K" ? "0" : "1";
  String tfvValue = tfv!.replaceAll("MHz", "").replaceAll(".", "") + "000";
  String rfvValue = rfv!.replaceAll("MHz", "").replaceAll(".", "") + "000";

  String params = "$gbwValue,$tfvValue,$rfvValue,$txsubtyp,$txsubidx,$rxsubtyp,$rxsubidx,$sq";
  DMOCommunication.sendATCommand(ATCommandTask(cmd: ATCommand.DMOANAGROUP.name, paramData: [params]));
}




