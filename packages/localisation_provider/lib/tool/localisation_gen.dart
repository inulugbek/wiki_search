import 'dart:convert';
import 'dart:io';

import 'package:meta/meta.dart';

import 'excel_parser.dart';
import 'gsheet_parser.dart';

//ignore_for_file: avoid_catches_without_on_clauses
//ignore_for_file: avoid_print

abstract class LocalisationGen {
  /// Generates and saves localisation json files from the Google Spreadsheet
  ///
  /// Expects to be provided with:
  ///
  /// [String] path to Google Service Account credentials `pathToCredentials`
  /// [String] path to save json files `pathToSave`
  /// [String] Spreadsheet Id where localisations are saved `spreadsheetId`
  ///
  /// Provided Google Spreadsheet file is expected at least 3 columns where:
  ///
  /// The very first row are header names and starting from third cell
  /// name equals to corresponding locale value
  ///
  /// 1 and 2 column are keys for translation value, 3 and following columns are values in corresponding language.
  /// 2 column value can be omited
  ///
  /// Example format
  ///
  /// `| page | key | en | es | ru ...`
  /// `| home | hello | hello | hola | привет ...`
  /// `| home | hello | hello | hola | привет ...`
  /// returns [String] result of the generation process
  static Future<String> generateLocalisationFiles({
    @required String pathToSave,
    String pathToCredentials,
    String spreadsheetId,
    String pathToExcel,
  }) async {
    if (pathToSave == null) return 'Provide path to save localisation files';

    try {
      List<Map<String, dynamic>> sheetRecords;
      if (pathToExcel != null) {
        sheetRecords = await ExcelParser(pathToExcelFile: pathToExcel)
            .generateRecordsFromExcel();
      } else if (pathToCredentials != null && spreadsheetId != null) {
        sheetRecords = await GsheetParser(
          spreadsheetId: spreadsheetId,
          pathToCredentials: pathToCredentials,
        ).generateRecordsFromGSheet();
      } else {
        return 'Provide Excel or Google Sheet required arguments ';
      }

      final localisations = await _parseLanguages(sheetRecords);
      return await _saveLocalisations(localisations, pathToSave: pathToSave);
    } on LocalisationGenException catch (e) {
      return e.message;
    }
  }

  /// saves localisations to json files into `pathToSave` provided
  /// json name is 'locale' and content 'data' keys of each [Map<String, dynamic>]
  /// returns [String] result of the process
  static Future<String> _saveLocalisations(
    List<Map<String, dynamic>> localisations, {
    String pathToSave,
  }) async {
    try {
      for (final lang in localisations) {
        final filename = '$pathToSave${lang['locale']}.json';
        await File(filename).writeAsString(jsonEncode(lang['data']));
      }
      return '${localisations.length} language translations were saved';
    } catch (e) {
      throw LocalisationGenException('Error occured: $e');
    }
  }

  /// returns Future [List] of [Map<String, String>] of mapped localisations
  /// for detected languages in provided `sheetRecords`
  static Future<List<Map<String, dynamic>>> _parseLanguages(
    List<Map<String, dynamic>> sheetRecords,
  ) async {
    final localisations = <Map<String, dynamic>>[];

    final columnLength = sheetRecords.first.length;
    final columnNames = sheetRecords.first.keys.toList();

    final numberOfLangs = columnLength - 2;
    print('$numberOfLangs languages were determined');

    // skip first 2 columns since they are keys
    for (var i = 2; i < columnLength; i++) {
      final languageColumn = columnNames[i];
      final languageParsed = _parseLanguage(
        sheetRecords: sheetRecords,
        languageName: languageColumn,
        key: columnNames[0],
        subKey: columnNames[1],
      );
      localisations.add(languageParsed);
    }
    return localisations;
  }

  /// returns [Map<String, dynamic>] of mapped localisations
  /// for provided `languageName` i.e. column name
  static Map<String, dynamic> _parseLanguage({
    List<Map<String, dynamic>> sheetRecords,
    String languageName,
    String key,
    String subKey,
  }) {
    final languageJson = <String, dynamic>{};
    for (final row in sheetRecords) {
      final keyValue = row[key]?.toString();
      final subKeyValue = row[subKey]?.toString();

      if (subKeyValue == null) {
        languageJson[keyValue] = row[languageName];
        continue;
      } else if (subKeyValue.isEmpty) {
        languageJson[keyValue] = row[languageName];
        continue;
      } else {
        if (!languageJson.keys.contains(keyValue)) {
          languageJson[keyValue] = <String, String>{};
        }
        languageJson[keyValue][subKeyValue] = row[languageName];
      }
    }
    return <String, dynamic>{'locale': languageName, 'data': languageJson};
  }
}

/// Custom Exception
class LocalisationGenException implements Exception {
  final String message;

  LocalisationGenException(this.message);
}
