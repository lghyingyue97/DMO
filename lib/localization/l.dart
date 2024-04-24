import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'zh.dart';

export 's.dart';

///国际化代理
Iterable<LocalizationsDelegate<dynamic>> kLocalizationsDelegates = [
  GlobalCupertinoLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  $L.delegate({
    Locale("zh"): $ZH(),
  }),
];

///支持的语言
List<Locale> get supportedLocales => [Locale("zh")];

class $L extends DefaultWidgetsLocalizations {
  const $L();

  static late $L current;

  static GeneratedLocalizationsDelegate delegate(Map<Locale, $L> locales) {
    return GeneratedLocalizationsDelegate(locales);
  }

  @override
  TextDirection get textDirection => TextDirection.ltr;
}

class GeneratedLocalizationsDelegate extends LocalizationsDelegate<$L> {
  final Map<Locale, $L>? locales;

  const GeneratedLocalizationsDelegate(this.locales);

  List<Locale> get supportedLocales {
    return locales != null ? locales!.keys.toList() : [];
  }

  @override
  Future<$L> load(Locale locale) {
    final String? lang = getLang(locale);
    $L.current = locales!.values.first;
    if (lang != null) {
      if (locales != null) {
        locales!.forEach((ll, s) {
          if (getLang(ll) == lang) {
            $L.current = s;
            return;
          }
        });
      }
    }
    return SynchronousFuture<$L>($L.current);
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale, true);

  @override
  bool shouldReload(GeneratedLocalizationsDelegate old) => false;

  ///
  /// Returns true if the specified locale is supported, false otherwise.
  ///
  bool _isSupported(Locale locale, bool withCountry) {
    for (Locale supportedLocale in supportedLocales) {
      // Language must always match both locales.
      if (supportedLocale.languageCode != locale.languageCode) {
        continue;
      }

      // If country code matches, return this locale.
      if (supportedLocale.countryCode == locale.countryCode) {
        return true;
      }

      // If no country requirement is requested, check if this locale has no country.
      if (true != withCountry &&
          (supportedLocale.countryCode == null ||
              supportedLocale.countryCode!.isEmpty)) {
        return true;
      }
    }

    return false;
  }

  String? getLang(Locale l) => l.countryCode == null || l.countryCode!.isEmpty
      ? l.languageCode
      : l.toString();
}
