part of 'provider.dart';

// functions

String localisedString(BuildContext context, String key, {dynamic args}) =>
    _Translation.of(context).text(key, args: args);

Future<void> changeAppLanguage(BuildContext context, String languageCode) =>
    AppLocalizationsProvider.of(context).setNewLanguage(languageCode);

// extension

extension AppLocalizationFunctions on BuildContext {
  Locale get currentLocale => AppLocalizationsProvider.of(this).currentLocale;

  String get currentLanguage =>
      AppLocalizationsProvider.of(this).currentLanguage;

  String get currentLanguageCode =>
      AppLocalizationsProvider.of(this).currentLocale.languageCode;

  Map<String, String> get supportedLanguages =>
      AppLocalizationsProvider.of(this).supportedLanguages;

  Iterable<Locale> get supportedLocales =>
      AppLocalizationsProvider.of(this).supportedLocales;

  String localisedString(String key, {dynamic args}) =>
      _Translation.of(this).text(key, args: args);

  Future<void> changeAppLanguage(String language) =>
      AppLocalizationsProvider.of(this).setNewLanguage(language);
}
