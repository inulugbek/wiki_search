part of 'provider.dart';

//ignore_for_file: avoid_print
//ignore_for_file: avoid_catches_without_on_clauses

class _Translation {
  /// Current locale.
  final Locale locale;

  /// The get path function.
  final GetPathFunction getPathFunction;

  /// The string to return if the key is not found.
  final String notFoundString;

  /// The localized strings.
  final Map<String, String> _strings = HashMap();

  /// Creates a new ez localization instance.
  _Translation({
    this.locale = const Locale('en'),
    this.getPathFunction = defaultGetPathFunction,
    this.notFoundString,
  });

  /// Returns the EzLocalization instance attached to the specified build config.
  static _Translation of(BuildContext context) =>
      Localizations.of<_Translation>(context, _Translation);

  /// Loads the localized strings.
  Future<bool> load() async {
    try {
      final data = await rootBundle.loadString(getPathFunction(locale));
      final strings = jsonDecode(data) as Map<String, dynamic>;
      strings.forEach(_addValues);
      return true;
    } catch (exception, stacktrace) {
      print(exception);
      print(stacktrace);
    }
    return false;
  }

  /// Returns the string associated to the specified key.
  String text(String key, {dynamic args}) {
    var value = _strings[key];
    if (value == null) return '$key $notFoundString';
    if (args != null) value = _formatReturnValue(value, args);
    return value;
  }

  /// The default get path function.
  static String defaultGetPathFunction(Locale locale) =>
      'assets/locales/${locale.languageCode}.json';

  /// Adds the values to the current map.
  void _addValues(String key, dynamic data) {
    if (data is Map<String, dynamic>) {
      data.forEach(
          (subKey, dynamic subData) => _addValues('$key.$subKey', subData));
      return;
    }

    if (data != null) {
      _strings[key] = data.toString();
    }
  }

  /// Formats the return value according to the specified arguments.
  String _formatReturnValue(String value, dynamic arguments) {
    var valueFinal = value;
    final regexp = RegExp(r'\{(.*?)\}');

    if (arguments == null) return valueFinal.replaceAll(regexp, '');

    if (arguments is String) {
      valueFinal = valueFinal.replaceFirst(regexp, arguments);
    } else if (arguments is num) {
      valueFinal = valueFinal.replaceFirst(regexp, arguments.toString());
    } else if (arguments is List<dynamic>) {
      arguments.forEach((dynamic arg) =>
          valueFinal = valueFinal.replaceFirst(regexp, arg?.toString()));
    } else if (arguments is Map<String, dynamic>) {
      arguments.forEach((formatKey, dynamic formatValue) => valueFinal =
          valueFinal.replaceAll('{$formatKey}', formatValue?.toString()));
    }

    return valueFinal.replaceAll(regexp, '');
  }
}
