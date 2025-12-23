import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;

/// CSV Parser utility for importing food nutrition data
class CSVParser {
  /// Parse CSV from file path
  static Future<List<Map<String, dynamic>>> parseFile(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('CSV file not found: $filePath');
    }
    
    final contents = await file.readAsString();
    return _parseCSVString(contents);
  }

  /// Parse CSV from assets
  static Future<List<Map<String, dynamic>>> parseAsset(String assetPath) async {
    final contents = await rootBundle.loadString(assetPath);
    return _parseCSVString(contents);
  }

  /// Parse CSV string into list of maps
  static List<Map<String, dynamic>> _parseCSVString(String csvString) {
    final lines = csvString.split('\n');
    if (lines.isEmpty) return [];

    // First line is headers
    final headers = _parseCSVLine(lines[0]);
    final results = <Map<String, dynamic>>[];

    // Parse data rows
    for (var i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      final values = _parseCSVLine(line);
      if (values.length != headers.length) {
        print('Warning: Row $i has ${values.length} columns, expected ${headers.length}');
        continue;
      }

      final row = <String, dynamic>{};
      for (var j = 0; j < headers.length; j++) {
        row[headers[j]] = values[j];
      }
      results.add(row);
    }

    return results;
  }

  /// Parse a single CSV line (handles quoted fields)
  static List<String> _parseCSVLine(String line) {
    final values = <String>[];
    var currentValue = StringBuffer();
    var inQuotes = false;

    for (var i = 0; i < line.length; i++) {
      final char = line[i];

      if (char == '"') {
        // Handle quotes
        if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
          // Escaped quote
          currentValue.write('"');
          i++; // Skip next quote
        } else {
          // Toggle quote mode
          inQuotes = !inQuotes;
        }
      } else if (char == ',' && !inQuotes) {
        // Field separator (not in quotes)
        values.add(currentValue.toString().trim());
        currentValue.clear();
      } else {
        currentValue.write(char);
      }
    }

    // Add last value
    values.add(currentValue.toString().trim());

    return values;
  }

  /// Convert string to double, handling errors
  static double parseDouble(String? value, {double defaultValue = 0.0}) {
    if (value == null || value.isEmpty) return defaultValue;
    return double.tryParse(value.replaceAll(',', '')) ?? defaultValue;
  }

  /// Convert string to int, handling errors
  static int parseInt(String? value, {int defaultValue = 0}) {
    if (value == null || value.isEmpty) return defaultValue;
    return int.tryParse(value.replaceAll(',', '')) ?? defaultValue;
  }

  /// Clean and normalize food name
  static String cleanFoodName(String name) {
    return name
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ') // Normalize whitespace
        .replaceAll(RegExp(r'[^\w\s\-\(\),/]'), '') // Remove special chars
        .toLowerCase()
        .split(' ')
        .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}
