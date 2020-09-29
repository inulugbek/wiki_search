import 'package:flutter/material.dart';

import 'package:localisation_provider/localisation_provider.dart';

import 'core/themes/default_theme.dart';
import 'search/search.dart';

class App extends StatelessWidget {
  const App({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) => AppLocalizationsProvider(
        // supported locales and their names
        supportedLanguages: const <String, String>{
          'en': 'English',
          'de': 'Deutch',
          'es': 'Espanol'
        },

        // path to json files with localisation translations
        getPathFunction: (locale) =>
            'assets/locales/${locale.languageCode}.json',

        builder: (context, delegate, locale) => MaterialApp(
          theme: DefaultTheme.themeData,
          locale: locale,
          supportedLocales: delegate.supportedLocales,
          localeResolutionCallback: delegate.localeResolutionCallback,
          localizationsDelegates: delegate.localizationDelegates,
          home: SearchPage(),
        ),
      );
}
