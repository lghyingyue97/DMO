import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'write_log.dart';

void showLogPage(BuildContext context) {
  const String channel = String.fromEnvironment("CHANNEL");
  if (channel == "pgy" || kDebugMode) {
    Navigator.of(context).push(new MaterialPageRoute(builder: (ctx) {
      return LogListPage();
    }));
  }
}

///本地日志列表页面
class LogListPage extends StatefulWidget {
  const LogListPage();

  @override
  State<LogListPage> createState() => _LogListPageState();
}

class _LogListPageState extends State<LogListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("日志")),
      body: FutureBuilder<List<String>>(
        builder: (ctx, data) {
          List<String> list = data.data ?? [];
          return ListView.builder(
            itemBuilder: (ctx, index) {
              return Container(
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(color: Colors.white, width: 0.2))),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          OpenFile.open(list[index]);
                        },
                        child: Text(
                          list[index]
                              .substring(list[index].lastIndexOf("/") + 1),
                          style: TextStyle(fontSize: 22),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Share.shareXFiles([list[index]].map((e) {
                          return XFile(e);
                        }).toList());
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Icon(Icons.share)),
                    )
                  ],
                ),
              );
            },
            itemCount: list.length,
          );
        },
        future: logFileList(),
      ),
    );
  }
}
