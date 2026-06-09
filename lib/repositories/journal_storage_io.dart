import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/journal_entry.dart';
import 'journal_storage_stub.dart';
export 'journal_storage_stub.dart';

class IoJournalStorage implements JournalStorage {
  Future<File> get _localFile async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/journal_entries.json');
  }

  @override
  Future<List<JournalEntry>> loadEntries() async {
    try {
      final file = await _localFile;
      if (!await file.exists()) {
        return [];
      }
      final contents = await file.readAsString();
      final List<dynamic> jsonList = jsonDecode(contents);
      return jsonList.map((json) => JournalEntry.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> saveEntries(List<JournalEntry> entries) async {
    try {
      final file = await _localFile;
      final jsonList = entries.map((e) => e.toJson()).toList();
      await file.writeAsString(jsonEncode(jsonList));
    } catch (e) {
      // Handle storage write error silently
    }
  }

  @override
  Future<String?> saveImage(String sourcePath) async {
    try {
      final sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) return null;

      final directory = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${directory.path}/images');
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      // Extract filename safely using OS path separator
      final separator = Platform.pathSeparator;
      final fileName = sourcePath.contains(separator)
          ? sourcePath.split(separator).last
          : sourcePath.split('/').last;

      final destPath = '${imagesDir.path}/$fileName';
      await sourceFile.copy(destPath);
      return destPath;
    } catch (e) {
      return null;
    }
  }
}

JournalStorage getStorage() => IoJournalStorage();
