import 'dart:convert';
import 'dart:html' as html;
import '../models/journal_entry.dart';
import 'journal_storage_stub.dart';

class WebJournalStorage implements JournalStorage {
  static const _storageKey = 'peejays_journal_entries';

  @override
  Future<List<JournalEntry>> loadEntries() async {
    try {
      final contents = html.window.localStorage[_storageKey];
      if (contents == null || contents.isEmpty) {
        return [];
      }
      final List<dynamic> jsonList = jsonDecode(contents);
      return jsonList.map((json) => JournalEntry.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> saveEntries(List<JournalEntry> entries) async {
    try {
      final jsonList = entries.map((e) => e.toJson()).toList();
      html.window.localStorage[_storageKey] = jsonEncode(jsonList);
    } catch (e) {
      // Handle web localstorage quota errors
    }
  }

  @override
  Future<String?> saveImage(String sourcePath) async {
    // For Web, image pickers yield a blob URI which is directly readable.
    // We return it unchanged since it resides in-browser.
    return sourcePath;
  }
}

JournalStorage getStorage() => WebJournalStorage();
