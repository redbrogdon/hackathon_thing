import 'package:flutter/material.dart';
import '../models/journal_entry.dart';
import '../repositories/journal_repository.dart';

enum SortOption { newest, oldest, alphabeticalAZ, alphabeticalZA }

class JournalProvider extends ChangeNotifier {
  final JournalRepository _repository = JournalRepository();

  List<JournalEntry> _entries = [];
  String _searchQuery = '';
  String? _activeMoodFilter;
  SortOption _currentSort = SortOption.newest;
  bool _isLoading = false;

  List<JournalEntry> get entries => List.unmodifiable(_entries);
  String get searchQuery => _searchQuery;
  String? get activeMoodFilter => _activeMoodFilter;
  SortOption get currentSort => _currentSort;
  bool get isLoading => _isLoading;

  /// Loads entries from the persistence repository.
  Future<void> loadEntries() async {
    _isLoading = true;
    notifyListeners();
    try {
      _entries = await _repository.loadEntries();
    } catch (e) {
      _entries = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Returns the entries filtered and sorted based on current state.
  List<JournalEntry> get filteredAndSortedEntries {
    List<JournalEntry> results = List.from(_entries);

    // 1. Filter by Search Query (matching title, content, location, mood, tags)
    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.toLowerCase().trim();
      results = results.where((entry) {
        final titleMatch = entry.title.toLowerCase().contains(query);
        final contentMatch = entry.content.toLowerCase().contains(query);
        final locationMatch = entry.location?.toLowerCase().contains(query) ?? false;
        final moodMatch = entry.mood?.toLowerCase().contains(query) ?? false;
        final tagsMatch = entry.tags.any((tag) => tag.toLowerCase().contains(query));

        return titleMatch || contentMatch || locationMatch || moodMatch || tagsMatch;
      }).toList();
    }

    // 2. Filter by Quick Mood / Tag Pill selection
    if (_activeMoodFilter != null && _activeMoodFilter != 'All') {
      final filter = _activeMoodFilter!.toLowerCase();
      results = results.where((entry) {
        final moodMatch = entry.mood?.toLowerCase() == filter;
        final tagMatch = entry.tags.any((tag) => tag.toLowerCase() == filter);
        return moodMatch || tagMatch;
      }).toList();
    }

    // 3. Sort entries
    switch (_currentSort) {
      case SortOption.newest:
        results.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case SortOption.oldest:
        results.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case SortOption.alphabeticalAZ:
        results.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
      case SortOption.alphabeticalZA:
        results.sort((a, b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()));
        break;
    }

    return results;
  }

  /// Adds a new entry and saves.
  Future<void> addEntry(JournalEntry entry) async {
    // If an image path is attached, try copying it locally first
    String? localImagePath = entry.imageUrl;
    if (entry.imageUrl != null && entry.imageUrl!.isNotEmpty) {
      final copiedPath = await _repository.saveImage(entry.imageUrl!);
      if (copiedPath != null) {
        localImagePath = copiedPath;
      }
    }

    final newEntry = entry.copyWith(imageUrl: localImagePath);
    _entries.add(newEntry);
    await _repository.saveEntries(_entries);
    notifyListeners();
  }

  /// Updates an existing entry and saves.
  Future<void> updateEntry(JournalEntry entry) async {
    final index = _entries.indexWhere((e) => e.id == entry.id);
    if (index != -1) {
      // If the image path is different and not empty, copy it
      String? localImagePath = entry.imageUrl;
      final oldImage = _entries[index].imageUrl;

      if (entry.imageUrl != null && entry.imageUrl!.isNotEmpty && entry.imageUrl != oldImage) {
        final copiedPath = await _repository.saveImage(entry.imageUrl!);
        if (copiedPath != null) {
          localImagePath = copiedPath;
        }
      }

      final updatedEntry = entry.copyWith(imageUrl: localImagePath, updatedAt: DateTime.now());
      _entries[index] = updatedEntry;
      await _repository.saveEntries(_entries);
      notifyListeners();
    }
  }

  /// Deletes an entry and saves.
  Future<void> deleteEntry(String id) async {
    _entries.removeWhere((e) => e.id == id);
    await _repository.saveEntries(_entries);
    notifyListeners();
  }

  /// Toggles the favorite status of an entry and saves.
  Future<void> toggleFavorite(String id) async {
    final index = _entries.indexWhere((e) => e.id == id);
    if (index != -1) {
      _entries[index] = _entries[index].copyWith(isFavorite: !_entries[index].isFavorite);
      await _repository.saveEntries(_entries);
      notifyListeners();
    }
  }

  /// Set the active search query.
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Set the active mood/tag filter pill.
  void setActiveMoodFilter(String? mood) {
    _activeMoodFilter = mood;
    notifyListeners();
  }

  /// Set the current sort option.
  void setSortOption(SortOption option) {
    _currentSort = option;
    notifyListeners();
  }
}
