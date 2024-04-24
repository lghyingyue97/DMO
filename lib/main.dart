import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oktoast/oktoast.dart';

import 'localization/l.dart';
import 'page/test.dart';

void main() async {
  var zoneSpecification = ZoneSpecification(
    print: (
      Zone self,
      ZoneDelegate parent,
      Zone zone,
      String line,
    ) {
      Zone.root.print(line);
    },
    handleUncaughtError: (
      Zone self,
      ZoneDelegate parent,
      Zone zone,
      Object error,
      StackTrace stackTrace,
    ) {
      Zone.root.print('$error');
    },
  );
  runZoned(() async {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(const DMOApp());
  }, zoneSpecification: zoneSpecification);
}

class DMOApp extends StatefulWidget {
  const DMOApp({Key? key}) : super(key: key);

  @override
  State<DMOApp> createState() => _DMOAppState();
}

class _DMOAppState extends State<DMOApp> with WidgetsBindingObserver {
  @override
  void initState() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent));
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark
          .copyWith(statusBarColor: Colors.transparent),
      child: OKToast(
        radius: 6,
        movingOnWindowChange: false,
        textPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        child: MaterialApp(
          title: "DMO",
          debugShowCheckedModeBanner: false,
          locale: Locale("zh"),
          supportedLocales: supportedLocales,
          localeResolutionCallback:
              (Locale? locale, Iterable<Locale> supportedLocales) {
            return Locale("zh");
          },
          localizationsDelegates: kLocalizationsDelegates,
          navigatorObservers: [],
          theme: lightTheme,
          home: homePage,
          builder: (ctx, child) {
            return GestureDetector(
              onTap: () {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              behavior: HitTestBehavior.translucent,
              child: MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(textScaler: TextScaler.noScaling),
                  child: child!),
            );
          },
        ),
      ),
    );
  }

  ThemeData get lightTheme {
    return ThemeData(
        brightness: Brightness.light,
        primaryColor: Color(0xff3ad88f),
        scaffoldBackgroundColor: Color(0xffF6F7FA),
        appBarTheme: AppBarTheme(
            backgroundColor: Colors.white,
            centerTitle: true,
            elevation: 0,
            scrolledUnderElevation: 0,
            iconTheme: IconThemeData(color: Colors.black),
            titleTextStyle: TextStyle(
                color: Color(0xff282828),
                fontSize: 18,
                fontWeight: FontWeight.w600)));
  }

  Widget get homePage {
    return TestPage();
  }
}
