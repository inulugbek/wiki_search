import 'package:flutter/material.dart';

import 'provider.dart';

class AppLocalizationButton extends StatelessWidget {
  final String title;
  const AppLocalizationButton({Key key, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) => GestureDetector(
        onLongPress: () {
          Scaffold.of(context).hideCurrentSnackBar();
          Scaffold.of(context).showSnackBar(
            SnackBar(
              content: Text('Current language ${context.currentLanguage}'),
            ),
          );
        },
        child: IconButton(
          icon: const Icon(Icons.language),
          onPressed: () => buildLanguageSelectDialog(context, title: title),
        ),
      );
}

Future<void> buildLanguageSelectDialog(BuildContext context, {String title}) =>
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title ?? 'Language'),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: context.supportedLanguages.keys
              .map(
                (langCode) => _AppLanguageRadioButton(
                  title: context.supportedLanguages[langCode],
                  value: langCode,
                  onChanged: (langCode) {
                    context.changeAppLanguage(langCode);
                    Navigator.of(context).pop();
                  },
                ),
              )
              .toList(),
        ),
      ),
    );

class _AppLanguageRadioButton extends StatelessWidget {
  final String title;
  final String value;
  final Function(String) onChanged;

  const _AppLanguageRadioButton({
    @required this.title,
    @required this.value,
    @required this.onChanged,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => ListTile(
        title: Text(title),
        leading: Radio<String>(
          activeColor: Theme.of(context).accentColor,
          value: value,
          groupValue: context.currentLanguageCode,
          onChanged: onChanged,
        ),
        onTap: () => onChanged(value),
      );
}
