import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hackathon_thing/models/journal_entry.dart';
import 'package:hackathon_thing/providers/journal_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async {
        return '.';
      },
    );
  });

  tearDownAll(() async {
    // Delete any test local files created
    final file = File('./journal_entries.json');
    if (await file.exists()) {
      await file.delete();
    }
    final imagesDir = Directory('./images');
    if (await imagesDir.exists()) {
      await imagesDir.delete(recursive: true);
    }
  });

  group('JournalProvider Filtering & Sorting Tests', () {
    test('addEntry, deleteEntry, and toggleFavorite operations', () async {
      final provider = JournalProvider();
      await provider.loadEntries();

      final entry = JournalEntry(
        id: 'test-id-123',
        title: 'Mock Title',
        content: 'Mock Content',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        tags: ['test'],
        isFavorite: false,
      );

      // Add
      await provider.addEntry(entry);
      expect(provider.entries.any((e) => e.id == 'test-id-123'), true);

      // Favorite Toggle
      await provider.toggleFavorite('test-id-123');
      expect(provider.entries.firstWhere((e) => e.id == 'test-id-123').isFavorite, true);

      // Delete
      await provider.deleteEntry('test-id-123');
      expect(provider.entries.any((e) => e.id == 'test-id-123'), false);
    });

    test('searching, active mood filter, and sort options combinations', () async {
      final provider = JournalProvider();

      final entry1 = JournalEntry(
        id: '1',
        title: 'Sunny beach stroll',
        content: 'Walked on the warm sand today.',
        createdAt: DateTime(2026, 6, 1),
        updatedAt: DateTime(2026, 6, 1),
        tags: ['outdoors'],
        mood: 'Joyful',
      );

      final entry2 = JournalEntry(
        id: '2',
        title: 'Rainy library afternoon',
        content: 'Immersed in old books and study.',
        createdAt: DateTime(2026, 6, 2),
        updatedAt: DateTime(2026, 6, 2),
        tags: ['books'],
        mood: 'Reflective',
      );

      await provider.addEntry(entry1);
      await provider.addEntry(entry2);

      // Test Newest First Sort (ID 2 is June 2, ID 1 is June 1)
      provider.setSortOption(SortOption.newest);
      expect(provider.filteredAndSortedEntries.first.id, '2');

      // Test Oldest First Sort
      provider.setSortOption(SortOption.oldest);
      expect(provider.filteredAndSortedEntries.first.id, '1');

      // Test Alphabetical AZ Sort ("Rainy..." comes before "Sunny...")
      provider.setSortOption(SortOption.alphabeticalAZ);
      expect(provider.filteredAndSortedEntries.first.id, '2');

      // Test Search matching location/tags/content
      provider.setSearchQuery('sand');
      expect(provider.filteredAndSortedEntries.length, 1);
      expect(provider.filteredAndSortedEntries.first.id, '1');

      // Clear search
      provider.setSearchQuery('');
      expect(provider.filteredAndSortedEntries.length, 2);

      // Test Mood Filter
      provider.setActiveMoodFilter('Reflective');
      expect(provider.filteredAndSortedEntries.length, 1);
      expect(provider.filteredAndSortedEntries.first.id, '2');

      // Clear mood filter
      provider.setActiveMoodFilter(null);
      expect(provider.filteredAndSortedEntries.length, 2);

      // Clean up added entries for next runs
      await provider.deleteEntry('1');
      await provider.deleteEntry('2');
    });
  });
}
