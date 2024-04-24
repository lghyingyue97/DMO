import 'dart:io';
import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

///检查新版本
void checkNewVersion(BuildContext context) {
  const String channel = String.fromEnvironment("CHANNEL");
  if (channel == "pgy") {
    _checkUpdate(context,
        apiKey: "3dcbc9037ebadfc39df125037808fb36",
        appKey: Platform.isAndroid ? "" : "");
  }
}

///需要更换这里的key
Future<bool> _checkUpdate(BuildContext context,
    {required String apiKey, required String appKey}) async {
  try {
    Response response =
        await Dio().post("https://www.pgyer.com/apiv2/app/check",
            options: Options()
              ..contentType = "application/x-www-form-urlencoded"
              ..responseType = ResponseType.json,
            data: {"_api_key": apiKey, "appKey": appKey});
    if (response.statusCode == 200) {
      Map<String, dynamic> data = response.data["data"];
      String? versonName = data["buildVersion"];
      String? buildUpdateDescription = data["buildUpdateDescription"];
      if (buildUpdateDescription == null ||
          buildUpdateDescription.trim().length == 0) {
        buildUpdateDescription = "修复若干问题";
      }
      String? downloadUrl = data["downloadURL"];
      String buildVersionNo = data["buildVersionNo"];

      String buildNumber = (await PackageInfo.fromPlatform()).buildNumber;

      if (int.tryParse(buildNumber)! < int.tryParse(buildVersionNo)!) {
        showDialog(
            context: context,
            builder: (ctx) {
              return UpdateWidget(
                versionName: versonName,
                downloadUrl: downloadUrl,
                updateContent: buildUpdateDescription,
              );
            });
        return true;
      }
    }
  } catch (e) {}
  return false;
}

class UpdateWidget extends StatefulWidget {
  final String? versionName;
  final String? updateContent;
  final String? downloadUrl;

  UpdateWidget(
      {required this.versionName,
      required this.updateContent,
      required this.downloadUrl});

  @override
  _UpdateWidgetState createState() => _UpdateWidgetState();
}

class _UpdateWidgetState extends State<UpdateWidget> {
  String? versionName;
  String? updateContent;
  String? downloadUrl;
  bool isUpdate = false;

  @override
  void initState() {
    versionName = widget.versionName;
    updateContent = widget.updateContent;
    downloadUrl = widget.downloadUrl;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    ///是否竖屏
    bool isPortrait = size.width < size.height;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Stack(
          children: [
            Positioned(
              top: 50,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.white,
                width: (isPortrait ? size.width : size.height) - 80,
                height: 100,
              ),
            ),
            Container(
              width: (isPortrait ? size.width : size.height) - 80,
              constraints: BoxConstraints(maxHeight: size.height - 100),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  AspectRatio(
                    aspectRatio: 450 / 210,
                    child: Image.asset(
                      "assets/image/pgy/update_bg_app_top.png",
                      fit: BoxFit.fill,
                      width: double.infinity,
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(4),
                            bottomRight: Radius.circular(4))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Text(
                              "新版本:",
                              style:
                                  TextStyle(color: Colors.black, fontSize: 18),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                                child: Text(
                              versionName ?? "",
                              style:
                                  TextStyle(color: Colors.black, fontSize: 18),
                            ))
                          ],
                        ),
                        SizedBox(height: 15),
                        Container(
                          width: double.infinity,
                          constraints: BoxConstraints(
                              maxHeight: 220 > (size.height - 200)
                                  ? (size.height - 200)
                                  : 220,
                              minHeight: 50),
                          child: SingleChildScrollView(
                            child: Text(
                              updateContent ?? "",
                              maxLines: 1000,
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                  height: 1.6),
                            ),
                          ),
                        ),
                        SizedBox(height: 15),
                        !isUpdate ? updateBtn() : _DownloadWidget(downloadUrl),
                      ],
                    ),
                  ),
                  SizedBox(height: 25),
                  CupertinoButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Icon(
                        Icons.clear,
                        color: Colors.white,
                        size: 30,
                      ))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget updateBtn() {
    return CupertinoButton(
      onPressed: () {
        if (Platform.isAndroid) {
          isUpdate = true;
          setState(() {});
        } else {
          ///苹果的
          // itms-services://?action=download-manifest&url=https://www.pgyer.com/app/plist/{buildKey}
          launchUrl(Uri.parse(downloadUrl!));
        }
      },
      padding: EdgeInsets.zero,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
            color: Colors.red, borderRadius: BorderRadius.circular(5)),
        child: Center(
            child: Text(
          "升级",
          style: TextStyle(color: Colors.white, fontSize: 16),
        )),
      ),
    );
  }
}

class _DownloadWidget extends StatefulWidget {
  final String? downloadUrl;

  _DownloadWidget(this.downloadUrl);

  @override
  __DownloadWidgetState createState() => __DownloadWidgetState();
}

class __DownloadWidgetState extends State<_DownloadWidget> {
  String? downloadUrl;
  CancelToken? cancelToken;
  bool isDownloadSuccess = false;
  bool isDownloadFail = false;
  String? apkFilePath;

  ValueNotifier<double> progressVN = ValueNotifier<double>(0);

  @override
  void initState() {
    downloadUrl = widget.downloadUrl;
    download(downloadUrl!);
    super.initState();
  }

  @override
  void dispose() {
    if (!isDownloadSuccess) {
      cancelToken!.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isDownloadSuccess
        ? installWidget()
        : (isDownloadFail ? retryBtn() : progressBtn());
  }

  Widget retryBtn() {
    return CupertinoButton(
      onPressed: () {
        isDownloadFail = false;
        download(downloadUrl!);
      },
      padding: EdgeInsets.zero,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
            color: Colors.red, borderRadius: BorderRadius.circular(5)),
        child: Center(
            child: Text(
          "升级失败,重试？",
          style: TextStyle(color: Colors.white, fontSize: 16),
        )),
      ),
    );
  }

  Widget progressBtn() {
    return CupertinoButton(
      onPressed: null,
      padding: EdgeInsets.zero,
      child: Container(
        height: 40,
        child: ValueListenableBuilder<double>(
          valueListenable: progressVN,
          builder: (ctx, value, child) {
            return LiquidLinearProgressIndicator(
              value: value,
              // Defaults to 0.5.
              valueColor: AlwaysStoppedAnimation(Colors.red),
              // Defaults to the current Theme's accentColor.
              backgroundColor: Colors.white,
              // Defaults to the current Theme's backgroundColor.
              borderColor: Colors.red,
              borderWidth: 1.5,
              borderRadius: 5,
              direction: Axis.horizontal,
              // The direction the liquid moves (Axis.vertical = bottom to top, Axis.horizontal = left to right). Defaults to Axis.horizontal.
              center: Text(
                (value * 100).toStringAsFixed(0) + "%",
                style: TextStyle(
                    color: value > 0.45 ? Colors.white : Colors.black),
              ),
            );
          },
        ),
      ),
    );
  }

  void download(String url) async {
    if (cancelToken != null) {
      cancelToken!.cancel();
    }
    cancelToken = CancelToken();
    String dic = (await getExternalStorageDirectory())!.path + "/apk/";
    String filePath =
        dic + DateTime.now().millisecondsSinceEpoch.toString() + ".apk";
    try {
      Response response = await Dio().download(url, filePath,
          cancelToken: cancelToken, onReceiveProgress: (count, total) {
        if (total != -1) {
          progressVN.value = count / total;
        }
      });
      if (response.statusCode == 200) {
        isDownloadSuccess = true;
        apkFilePath = filePath;
        setState(() {});
        OpenFile.open(filePath);
      } else {
        isDownloadFail = true;
        setState(() {});
      }
    } catch (e) {
      isDownloadFail = true;
      setState(() {});
    }
  }

  Widget installWidget() {
    return CupertinoButton(
      onPressed: () {
        OpenFile.open(apkFilePath);
      },
      padding: EdgeInsets.zero,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
            color: Colors.red, borderRadius: BorderRadius.circular(5)),
        child: Center(
            child: Text(
          "安装",
          style: TextStyle(color: Colors.white, fontSize: 16),
        )),
      ),
    );
  }
}

class Wave extends StatefulWidget {
  final double? value;
  final Color color;
  final Axis direction;

  const Wave({
    Key? key,
    required this.value,
    required this.color,
    required this.direction,
  }) : super(key: key);

  @override
  _WaveState createState() => _WaveState();
}

class _WaveState extends State<Wave> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
      builder: (context, child) => ClipPath(
        child: Container(
          color: widget.color,
        ),
        clipper: _WaveClipper(
          animationValue: _animationController.value,
          value: widget.value,
          direction: widget.direction,
        ),
      ),
    );
  }
}

class _WaveClipper extends CustomClipper<Path> {
  final double animationValue;
  final double? value;
  final Axis direction;

  _WaveClipper({
    required this.animationValue,
    required this.value,
    required this.direction,
  });

  @override
  Path getClip(Size size) {
    if (direction == Axis.horizontal) {
      Path path = Path()
        ..addPolygon(_generateHorizontalWavePath(size), false)
        ..lineTo(0.0, size.height)
        ..lineTo(0.0, 0.0)
        ..close();
      return path;
    }

    Path path = Path()
      ..addPolygon(_generateVerticalWavePath(size), false)
      ..lineTo(size.width, size.height)
      ..lineTo(0.0, size.height)
      ..close();
    return path;
  }

  List<Offset> _generateHorizontalWavePath(Size size) {
    final waveList = <Offset>[];
    for (int i = -2; i <= size.height.toInt() + 2; i++) {
      final waveHeight = (size.width / 20);
      final dx = math.sin((animationValue * 360 - i) % 360 * (math.pi / 180)) *
              waveHeight +
          (size.width * value!);
      waveList.add(Offset(dx, i.toDouble()));
    }
    return waveList;
  }

  List<Offset> _generateVerticalWavePath(Size size) {
    final waveList = <Offset>[];
    for (int i = -2; i <= size.width.toInt() + 2; i++) {
      final waveHeight = (size.height / 20);
      final dy = math.sin((animationValue * 360 - i) % 360 * (math.pi / 180)) *
              waveHeight +
          (size.height - (size.height * value!));
      waveList.add(Offset(i.toDouble(), dy));
    }
    return waveList;
  }

  @override
  bool shouldReclip(_WaveClipper oldClipper) =>
      animationValue != oldClipper.animationValue;
}

class LiquidLinearProgressIndicator extends ProgressIndicator {
  ///The width of the border, if this is set [borderColor] must also be set.
  final double? borderWidth;

  ///The color of the border, if this is set [borderWidth] must also be set.
  final Color? borderColor;

  ///The radius of the border.
  final double? borderRadius;

  ///The widget to show in the center of the progress indicator.
  final Widget? center;

  ///The direction the liquid travels.
  final Axis direction;

  LiquidLinearProgressIndicator({
    Key? key,
    double value = 0.5,
    Color? backgroundColor,
    Animation<Color>? valueColor,
    this.borderWidth,
    this.borderColor,
    this.borderRadius,
    this.center,
    this.direction = Axis.horizontal,
  }) : super(
          key: key,
          value: value,
          backgroundColor: backgroundColor,
          valueColor: valueColor,
        ) {
    if (borderWidth != null && borderColor == null ||
        borderColor != null && borderWidth == null) {
      throw ArgumentError("borderWidth and borderColor should both be set.");
    }
  }

  Color _getBackgroundColor(BuildContext context) =>
      backgroundColor ?? Theme.of(context).colorScheme.background;

  Color _getValueColor(BuildContext context) =>
      valueColor?.value ?? Theme.of(context).colorScheme.secondary;

  @override
  State<StatefulWidget> createState() => _LiquidLinearProgressIndicatorState();
}

class _LiquidLinearProgressIndicatorState
    extends State<LiquidLinearProgressIndicator> {
  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _LinearClipper(
        radius: widget.borderRadius,
      ),
      child: CustomPaint(
        painter: _LinearPainter(
          color: widget._getBackgroundColor(context),
          radius: widget.borderRadius,
        ),
        foregroundPainter: _LinearBorderPainter(
          color: widget.borderColor,
          width: widget.borderWidth,
          radius: widget.borderRadius,
        ),
        child: Stack(
          children: <Widget>[
            Wave(
              value: widget.value,
              color: widget._getValueColor(context),
              direction: widget.direction,
            ),
            if (widget.center != null) Center(child: widget.center),
          ],
        ),
      ),
    );
  }
}

class _LinearPainter extends CustomPainter {
  final Color color;
  final double? radius;

  _LinearPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(radius ?? 0),
        ),
        paint);
  }

  @override
  bool shouldRepaint(_LinearPainter oldDelegate) => color != oldDelegate.color;
}

class _LinearBorderPainter extends CustomPainter {
  final Color? color;
  final double? width;
  final double? radius;

  _LinearBorderPainter({
    required this.color,
    required this.width,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (color == null || width == null) {
      return;
    }

    final paint = Paint()
      ..color = color!
      ..style = PaintingStyle.stroke
      ..strokeWidth = width!;
    final alteredRadius = radius ?? 0;
    canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(width! / 2, width! / 2, size.width - width!,
              size.height - width!),
          Radius.circular(alteredRadius - width!),
        ),
        paint);
  }

  @override
  bool shouldRepaint(_LinearBorderPainter oldDelegate) =>
      color != oldDelegate.color ||
      width != oldDelegate.width ||
      radius != oldDelegate.radius;
}

class _LinearClipper extends CustomClipper<Path> {
  final double? radius;

  _LinearClipper({required this.radius});

  @override
  Path getClip(Size size) {
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(radius ?? 0),
        ),
      );
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
