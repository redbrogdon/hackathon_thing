import '../models/journal_entry.dart';

abstract class JournalStorage {
  Future<List<JournalEntry>> loadEntries();
  Future<void> saveEntries(List<JournalEntry> entries);
  Future<String?> saveImage(String sourcePath);
}

JournalStorage getStorage() => throw UnsupportedError('Cannot create storage');
