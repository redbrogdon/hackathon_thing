import '../models/journal_entry.dart';
import 'journal_storage_stub.dart'
    if (dart.library.html) 'journal_storage_web.dart'
    if (dart.library.io) 'journal_storage_io.dart';

class JournalRepository {
  final JournalStorage _storage = getStorage();

  Future<List<JournalEntry>> loadEntries() => _storage.loadEntries();
  Future<void> saveEntries(List<JournalEntry> entries) => _storage.saveEntries(entries);
  Future<String?> saveImage(String sourcePath) => _storage.saveImage(sourcePath);
}
