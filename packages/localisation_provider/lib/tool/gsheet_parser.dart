import 'dart:convert';
import 'dart:io';

import 'package:gsheets/gsheets.dart';
import 'package:meta/meta.dart';

import 'localisation_gen.dart';

//ignore_for_file: avoid_catches_without_on_clauses
//ignore_for_file: avoid_print

class GsheetParser {
  final String spreadsheetId;
  final String pathToCredentials;

  GsheetParser({
    @required this.spreadsheetId,
    @required this.pathToCredentials,
  });

  /// returns [List<Map<String, String>>] from GSheet `spreadsheetId` provided
  Future<List<Map<String, dynamic>>> generateRecordsFromGSheet() async {
    final spreadsheet = await _authorizeAndGetSpreadsheet();
    if (spreadsheet == null) {
      throw LocalisationGenException('Spreadsheet was not found');
    }

    final sheetRecords = await _getAllRecordsFromGSheet(spreadsheet);
    if (sheetRecords == null) {
      throw LocalisationGenException('Something went wrong');
    }

    return sheetRecords;
  }

  /// returns Future [List] of [Map<String, String>] where each [List] entity
  /// is a Row from Spreadsheet mapped with Headers i.e. first Row
  /// loaded [Worksheet] should be provided
  Future<List<Map<String, dynamic>>> _getAllRecordsFromGSheet(
    Worksheet spreadsheet,
  ) async {
    final allRows = await spreadsheet.values.allRows();
    final numberOfRows = allRows.length;
    final columnNames = allRows.first;

    final allRecords = <Map<String, dynamic>>[];

    for (var i = 1; i < numberOfRows; i++) {
      final row = <String, dynamic>{};
      final currentRow = allRows[i];

      for (var j = 0; j < currentRow.length; j++) {
        row[columnNames[j]] = currentRow[j];
      }
      allRecords.add(row);
    }

    print('All records from Spreadsheet were loaded');
    return allRecords;
  }

  /// authorizes with credentials obtained from `pathToCredentials` provided
  /// loads [Spreadsheet] with `spreadsheetId` provided
  ///
  /// returns the very first [Worksheet] of loaded [Spreadsheet]
  /// if error occurs or spreadsheet was not found returns [null]
  Future<Worksheet> _authorizeAndGetSpreadsheet() async {
    try {
      final credentials = await _readCredentials();
      final gsheets = GSheets(credentials);
      final spreadsheet =
          (await gsheets.spreadsheet(spreadsheetId)).sheets?.first;
      return spreadsheet;
    } catch (e) {
      throw LocalisationGenException('Error occured: $e');
    }
  }

  /// returns Google Service Account credentials in [Map<String,dynamic>] format
  /// loaded from `pathToCredentials` provided
  Future<Map<String, dynamic>> _readCredentials() async {
    final credentialsString = await File(pathToCredentials).readAsString();
    return jsonDecode(credentialsString) as Map<String, dynamic>;
  }
}
