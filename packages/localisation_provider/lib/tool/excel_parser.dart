import 'dart:io';

import 'package:excel/excel.dart';
import 'package:meta/meta.dart';

import 'localisation_gen.dart';

//ignore_for_file: avoid_catches_without_on_clauses
//ignore_for_file: avoid_print

class ExcelParser {
  final String pathToExcelFile;

  ExcelParser({
    @required this.pathToExcelFile,
  });

  /// returns [List<Map<String, String>>] from GSheet `spreadsheetId` provided
  Future<List<Map<String, dynamic>>> generateRecordsFromExcel() async {
    final spreadsheet = await _readAndGetSpreadsheet();
    if (spreadsheet == null) {
      throw LocalisationGenException('Spreadsheet was not found');
    }

    final sheetRecords = await _getAllRecordsFromExcel(spreadsheet);
    if (sheetRecords == null) {
      throw LocalisationGenException('Something went wrong');
    }

    return sheetRecords;
  }

  /// returns Future [List] of [Map<String, String>] where each [List] entity
  /// is a Row from Spreadsheet mapped with Headers i.e. first Row
  /// loaded [Worksheet] should be provided
  Future<List<Map<String, dynamic>>> _getAllRecordsFromExcel(
    Sheet spreadsheet,
  ) async {
    final allRows = spreadsheet.rows;
    final numberOfRows = allRows.length;
    final columnNames = allRows.first;

    final allRecords = <Map<String, dynamic>>[];

    for (var i = 1; i < numberOfRows; i++) {
      final row = <String, dynamic>{};
      final currentRow = allRows[i];

      for (var j = 0; j < currentRow.length; j++) {
        row[columnNames[j].toString()] = currentRow[j];
      }
      allRecords.add(row);
    }

    print('All records from Excel were loaded');
    return allRecords;
  }

  /// loads [Excel] with `pathToExcelFile` provided
  ///
  /// returns the very first [Sheet] of loaded [Excel]
  /// if error occurs or spreadsheet was not found returns [null]
  Future<Sheet> _readAndGetSpreadsheet() async {
    try {
      final excel = await _readExcel();
      final spreadsheet = excel.sheets.values?.first;
      return spreadsheet;
    } catch (e) {
      throw LocalisationGenException('Error occured: $e');
    }
  }

  /// returns Excel file loaded from `pathToExcelFile` provided
  Future<Excel> _readExcel() async {
    final bytes = File(pathToExcelFile).readAsBytesSync();
    return Excel.decodeBytes(bytes);
  }
}
