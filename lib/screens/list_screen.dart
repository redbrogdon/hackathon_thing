import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/journal_entry.dart';
import '../providers/journal_provider.dart';
import '../theme/peejays_theme.dart';
import 'edit_screen.dart';
import 'view_screen.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load entries on launch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JournalProvider>().loadEntries();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<JournalProvider>();
    final entries = provider.filteredAndSortedEntries;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Custom Retro App Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Peejays',
                              style: theme.textTheme.displayMedium?.copyWith(
                                fontSize: 32,
                                color: PeejaysTheme.lightPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Your life, one page at a time.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onBackground.withOpacity(0.7),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Circular initials profile avatar
                      Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          color: PeejaysTheme.lightPrimary,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'JD',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Search Input Field
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            border: Border.all(color: theme.colorScheme.outline, width: 2),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Icon(Icons.search, color: theme.colorScheme.outline),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  onChanged: (val) => provider.setSearchQuery(val),
                                  style: theme.textTheme.bodyMedium,
                                  decoration: InputDecoration(
                                    hintText: 'Search your memories...',
                                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.outline.withOpacity(0.7),
                                    ),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                              if (_searchController.text.isNotEmpty)
                                GestureDetector(
                                  onTap: () {
                                    _searchController.clear();
                                    provider.setSearchQuery('');
                                  },
                                  child: Icon(Icons.close, color: theme.colorScheme.outline, size: 20),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Sorting Selector Trigger
                      GestureDetector(
                        onTap: () => _showSortOptions(context, provider),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            border: Border.all(color: theme.colorScheme.outline, width: 2),
                          ),
                          alignment: Alignment.center,
                          child: Icon(Icons.swap_vert_rounded, color: theme.colorScheme.primary),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Horizontal Quick Filter Pills
                _buildQuickFilters(context, provider),

                const SizedBox(height: 20),

                // Section Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    'Recent Entries',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Main feed or empty state
                Expanded(
                  child: provider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : entries.isEmpty
                          ? _buildEmptyState(theme)
                          : ListView.builder(
                              padding: const EdgeInsets.only(left: 24, right: 24, bottom: 90),
                              itemCount: entries.length,
                              itemBuilder: (context, index) {
                                return _buildJournalCard(context, entries[index]);
                              },
                            ),
                ),
              ],
            ),

            // Floating Pill New Entry Button
            Positioned(
              right: 24,
              bottom: 24,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const EditScreen()),
                  );
                },
                child: Container(
                  decoration: PeejaysTheme.retroCardDecoration(
                    bgColor: theme.colorScheme.primary,
                    outlineColor: theme.colorScheme.primary,
                    shadowOffset: 3,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.edit_note, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        'New Entry',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Quick Filter Row
  Widget _buildQuickFilters(BuildContext context, JournalProvider provider) {
    final filters = [
      {'label': 'All', 'icon': '♾'},
      {'label': 'Joyful', 'icon': '😊'},
      {'label': 'Reflective', 'icon': '🧘'},
      {'label': 'Melancholy', 'icon': '☁️'},
      {'label': 'Inspired', 'icon': '💡'},
    ];

    return SizedBox(
      height: 38,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final label = filter['label']!;
          final icon = filter['icon']!;
          final isActive = (label == 'All' && provider.activeMoodFilter == null) ||
              (provider.activeMoodFilter?.toLowerCase() == label.toLowerCase());

          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                if (label == 'All') {
                  provider.setActiveMoodFilter(null);
                } else {
                  provider.setActiveMoodFilter(label);
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isActive ? PeejaysTheme.lightPrimary : PeejaysTheme.lightSecondaryBackground,
                  border: Border.all(color: PeejaysTheme.lightOutline, width: 2),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    Text(icon, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: isActive ? Colors.white : PeejaysTheme.lightPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Empty state view
  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_stories_outlined, size: 64, color: theme.colorScheme.outline.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              'No journal entries found.',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Time to write your first story! Tap the button below to start composing.',
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Journal Feed Entry Card
  Widget _buildJournalCard(BuildContext context, JournalEntry entry) {
    final theme = Theme.of(context);
    final formattedDate = DateFormat('MMMM d, yyyy').format(entry.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: PeejaysTheme.retroCardDecoration(
        bgColor: theme.colorScheme.surface,
        outlineColor: theme.colorScheme.outline,
        shadowOffset: 4,
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ViewScreen(entryId: entry.id)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Card Top Row (Date and Mood Pill)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    formattedDate,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: PeejaysTheme.lightSecondaryText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (entry.mood != null && entry.mood!.isNotEmpty)
                    Container(
                      decoration: BoxDecoration(
                        color: PeejaysTheme.lightSecondaryBackground,
                        border: Border.all(color: theme.colorScheme.outline, width: 1),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      child: Text(
                        entry.mood!,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              // Title
              Text(
                entry.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),

              // Optional landscape image preview
              if (entry.imageUrl != null && entry.imageUrl!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Container(
                    height: 160,
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.colorScheme.outline, width: 2),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _buildCardImage(entry.imageUrl!),
                  ),
                ),

              // Content snippet
              Text(
                entry.content.length > 100
                    ? '${entry.content.substring(0, 97)}...'
                    : entry.content,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.85),
                ),
              ),
              const SizedBox(height: 16),

              // Bottom Row (Location pin and action arrow)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.location_on, size: 16, color: theme.colorScheme.error),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            entry.location?.isNotEmpty == true ? entry.location! : 'Somewhere in time',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: PeejaysTheme.lightSecondaryText,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, color: theme.colorScheme.primary, size: 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper image builder
  Widget _buildCardImage(String path) {
    if (path.startsWith('http')) {
      return Image.network(path, fit: BoxFit.cover);
    } else if (path.startsWith('data:image')) {
      final uri = Uri.parse(path);
      return Image.memory(uri.data!.contentAsBytes(), fit: BoxFit.cover);
    } else {
      if (kIsWeb) {
        return Image.network(path, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox.shrink());
      } else {
        return Image.file(File(path), fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox.shrink());
      }
    }
  }

  // Show bottom sheet with sorting options
  void _showSortOptions(BuildContext context, JournalProvider provider) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: theme.colorScheme.outline, width: 3)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'ORDER BY',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: theme.colorScheme.outline,
                ),
              ),
              const SizedBox(height: 16),
              _buildSortItem(context, 'Newest First', SortOption.newest, provider),
              _buildSortItem(context, 'Oldest First', SortOption.oldest, provider),
              _buildSortItem(context, 'Alphabetical (A-Z)', SortOption.alphabeticalAZ, provider),
              _buildSortItem(context, 'Alphabetical (Z-A)', SortOption.alphabeticalZA, provider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortItem(BuildContext context, String title, SortOption option, JournalProvider provider) {
    final theme = Theme.of(context);
    final isSelected = provider.currentSort == option;

    return InkWell(
      onTap: () {
        provider.setSortOption(option);
        Navigator.pop(context);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: theme.colorScheme.primary, size: 20),
          ],
        ),
      ),
    );
  }
}
