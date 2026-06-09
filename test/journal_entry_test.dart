import 'package:flutter_test/flutter_test.dart';
import 'package:hackathon_thing/models/journal_entry.dart';

void main() {
  group('JournalEntry Tests', () {
    test('toJson and fromJson symmetry', () {
      final entry = JournalEntry(
        id: '12345',
        title: 'Test Entry',
        content: 'This is the body content of the test entry.',
        createdAt: DateTime(1974, 10, 24, 8, 30),
        updatedAt: DateTime(1974, 10, 24, 8, 30),
        tags: ['retro', 'test'],
        location: 'Brooklyn, NY',
        imageUrl: 'images/test.jpg',
        isFavorite: true,
        mood: 'Joyful',
      );

      final json = entry.toJson();
      final fromJson = JournalEntry.fromJson(json);

      expect(fromJson.id, entry.id);
      expect(fromJson.title, entry.title);
      expect(fromJson.content, entry.content);
      expect(fromJson.createdAt, entry.createdAt);
      expect(fromJson.updatedAt, entry.updatedAt);
      expect(fromJson.tags, entry.tags);
      expect(fromJson.location, entry.location);
      expect(fromJson.imageUrl, entry.imageUrl);
      expect(fromJson.isFavorite, entry.isFavorite);
      expect(fromJson.mood, entry.mood);
    });

    test('copyWith overrides correct fields and keeps others', () {
      final entry = JournalEntry(
        id: '1',
        title: 'Original Title',
        content: 'Original Content',
        createdAt: DateTime(2026, 6, 9),
        updatedAt: DateTime(2026, 6, 9),
        tags: ['tag1'],
        location: 'Old Location',
      );

      final copied = entry.copyWith(
        title: 'New Title',
        location: 'New Location',
        isFavorite: true,
        mood: 'Inspired',
      );

      expect(copied.id, entry.id); // Stays the same
      expect(copied.title, 'New Title'); // Changed
      expect(copied.content, entry.content); // Stays the same
      expect(copied.location, 'New Location'); // Changed
      expect(copied.isFavorite, true); // Changed
      expect(copied.mood, 'Inspired'); // Changed
    });
  });
}
