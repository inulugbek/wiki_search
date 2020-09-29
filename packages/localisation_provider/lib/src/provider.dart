import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl_standalone.dart'
    if (dart.library.html) 'package:intl/intl_browser.dart';

export 'widgets.dart';

part 'delegate.dart';
part 'public.dart';
part 'translation.dart';

// ignore_for_file: unawaited_futures

const String kLocalePref = 'LOCALE';

typedef AppLocalizationdWidgetBuilder = Widget Function(
  BuildContext context,
  _AppLocalizationDelegate ezLocalizationDelegate,
  Locale locale,
);

/// Callback allowing to get the language path according to the specified locale.
typedef GetPathFunction = String Function(Locale locale);

class AppLocalizationsProvider extends StatefulWidget {
  /// The widget builder.
  final AppLocalizationdWidgetBuilder builder;

  /// Map of supported languages where key is language code and value language name to be displayed
  ///
  /// first provided will be default
  final Map<String, String> supportedLanguages;

  final GetPathFunction getPathFunction;

  /// notFoundString
  final String notFoundString;

  /// Creates a new [AppLocalizationsProvider] builder instance.
  const AppLocalizationsProvider({
    @required this.builder,
    @required this.supportedLanguages,
    Key key,
    this.notFoundString,
    this.getPathFunction,
  })  : assert(builder != null),
        assert(supportedLanguages != null),
        super(key: key);

  @override
  State<StatefulWidget> createState() => _AppLocalizationsProviderState();

  static _AppLocalizationsProviderState of(BuildContext context) =>
      context.findAncestorStateOfType<_AppLocalizationsProviderState>();
}

class _AppLocalizationsProviderState extends State<AppLocalizationsProvider> {
  /// current delegate.
  _AppLocalizationDelegate delegate;

  Locale currentLocale;

  Map<String, String> get supportedLanguages => widget.supportedLanguages;

  /// returns supported [Iterable<Locale>] created from provided [Map]
  Iterable<Locale> get supportedLocales =>
      widget.supportedLanguages.keys.map(_localeFromString);

  /// returns name of Current language specified in the provided [Map]
  String get currentLanguage =>
      widget.supportedLanguages[currentLocale.languageCode];

  @override
  void initState() {
    super.initState();
    _initDelegate();
  }

  @override
  void dispose() {
    Hive.box<String>(kLocalePref).close();
    super.dispose();
  }

  void _initDelegate() {
    delegate = _AppLocalizationDelegate(
      supportedLocales: supportedLocales,
      notFoundString: widget.notFoundString ?? 'not found',
      getPathFunction:
          widget.getPathFunction ?? _Translation.defaultGetPathFunction,
    );
    setNewLanguage();
  }

  Future<void> setNewLanguage([String newLanguageCode]) async {
    var locale = _localeFromString(newLanguageCode);

    locale ??= await _loadSavedLocale();
    locale ??= await _getDeviceLocale();

    locale = delegate._isLocaleSupported(delegate.supportedLocales, locale);
    locale ??= delegate.supportedLocales.first;

    setState(() => currentLocale = locale);

    _saveLocale(locale);
  }

  // Get Device Locale
  Future<Locale> _getDeviceLocale() async {
    final _deviceLocale = await findSystemLocale();
    return _localeFromString(_deviceLocale);
  }

  Future<Locale> _loadSavedLocale() async {
    await _initHive();
    final _strLocale = Hive.box<String>(kLocalePref).get(kLocalePref);
    return _localeFromString(_strLocale);
  }

  Future<void> _saveLocale(Locale locale) =>
      Hive.box<String>(kLocalePref).put(kLocalePref, locale.toString());

  @override
  Widget build(BuildContext context) =>
      widget.builder(context, delegate, currentLocale);

  Locale _localeFromString(String val) {
    if (val != null) {
      if (val.isNotEmpty) {
        final localeList = val.split('_');
        return (localeList.length > 1)
            ? Locale(localeList.first, localeList.last)
            : Locale(localeList.first);
      }
    }
    return null;
  }

  /// init Hive storage
  Future<void> _initHive() async {
    if (!Hive.isBoxOpen(kLocalePref)) {
      await Hive.initFlutter();
      await Hive.openBox<String>(kLocalePref);
    }
  }
}
