part of 'provider.dart';

/// The EzLocalization delegate class.
class _AppLocalizationDelegate extends LocalizationsDelegate<_Translation> {
  /// Contains all supported locales.
  final Iterable<Locale> supportedLocales;

  /// The get path function.
  final GetPathFunction getPathFunction;

  /// The string to return if the key is not found.
  final String notFoundString;

  /// Creates a new app localization delegate instance.
  const _AppLocalizationDelegate({
    this.supportedLocales = const <Locale>[Locale('en')],
    this.getPathFunction,
    this.notFoundString,
  });

  @override
  bool isSupported(Locale locale) =>
      _isLocaleSupported(supportedLocales, locale) != null;

  @override
  Future<_Translation> load(Locale locale) async {
    final translation = _Translation(
      locale: locale,
      getPathFunction: getPathFunction,
      notFoundString: notFoundString,
    );

    await translation.load();

    return translation;
  }

  @override
  bool shouldReload(LocalizationsDelegate<_Translation> old) => false;

  /// The default locale resolution callback.
  Locale localeResolutionCallback(
    Locale locale,
    Iterable<Locale> supportedLocales,
  ) {
    if (locale == null) return supportedLocales.first;

    return _isLocaleSupported(supportedLocales, locale) ??
        supportedLocales.first;
  }

  /// The localization delegates to add in your application.
  List<LocalizationsDelegate<dynamic>> get localizationDelegates => [
        this,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ];

  /// Returns the locale if it's supported by this localization delegate, null otherwise.
  Locale _isLocaleSupported(Iterable<Locale> supportedLocales, Locale locale) {
    for (final supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return supportedLocale;
      }
    }

    return null;
  }
}
