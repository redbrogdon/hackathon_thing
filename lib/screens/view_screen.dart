import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/journal_entry.dart';
import '../providers/journal_provider.dart';
import '../theme/peejays_theme.dart';
import 'edit_screen.dart';

class ViewScreen extends StatelessWidget {
  final String entryId;

  const ViewScreen({super.key, required this.entryId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<JournalProvider>();

    // Locate the entry or fallback if not found
    final entryIndex = provider.entries.indexWhere((e) => e.id == entryId);
    if (entryIndex == -1) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Entry not found', style: theme.textTheme.titleMedium),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    final entry = provider.entries[entryIndex];
    final formattedDate = DateFormat('MMMM d, yyyy').format(entry.createdAt);
    final entryDisplayNumber = (entryIndex + 1).toString().padLeft(3, '0');

    return Scaffold(
      appBar: AppBar(
        // Retro back button on the left
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border.all(color: theme.colorScheme.outline, width: 2),
              ),
              child: Icon(Icons.arrow_back, color: theme.colorScheme.primary, size: 20),
            ),
          ),
        ),
        // Date and Entry number in the center
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              formattedDate.toUpperCase(),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Entry #$entryDisplayNumber',
              style: theme.textTheme.labelSmall?.copyWith(
                color: PeejaysTheme.lightSecondaryText,
                fontSize: 11,
              ),
            ),
          ],
        ),
        // Retro three-dot options menu on the right
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0, top: 8.0, bottom: 8.0),
            child: GestureDetector(
              onTap: () => _showOptions(context, provider, entry),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  border: Border.all(color: theme.colorScheme.outline, width: 2),
                ),
                child: Icon(Icons.more_vert_rounded, color: theme.colorScheme.primary),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Container(
                  width: double.infinity,
                  decoration: PeejaysTheme.retroCardDecoration(
                    bgColor: theme.colorScheme.surface,
                    outlineColor: theme.colorScheme.outline,
                    shadowOffset: 4,
                  ),
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Location pin and tag header
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.location_on, size: 18, color: theme.colorScheme.error),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              entry.location?.isNotEmpty == true ? entry.location! : 'Somewhere in time',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: PeejaysTheme.lightSecondaryText,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (entry.mood != null && entry.mood!.isNotEmpty)
                            Container(
                              decoration: BoxDecoration(
                                color: PeejaysTheme.lightSecondaryBackground,
                                border: Border.all(color: theme.colorScheme.outline, width: 1),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
                      const SizedBox(height: 16),

                      // Large title headline
                      Text(
                        entry.title,
                        style: theme.textTheme.headlineLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Horizontal Divider
                      const Divider(thickness: 2),
                      const SizedBox(height: 16),

                      // Text body content
                      Text(
                        entry.content,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Landscape image preview at the bottom
                      if (entry.imageUrl != null && entry.imageUrl!.isNotEmpty)
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(color: theme.colorScheme.outline, width: 2),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: _buildViewImage(entry.imageUrl!),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom action buttons
            Container(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: theme.colorScheme.outline, width: 2)),
                color: PeejaysTheme.lightSecondaryBackground,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  // Edit Thoughts button
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => EditScreen(entryId: entry.id),
                          ),
                        );
                      },
                      child: Container(
                        decoration: PeejaysTheme.retroCardDecoration(
                          bgColor: theme.colorScheme.surface,
                          outlineColor: theme.colorScheme.outline,
                          shadowOffset: 2,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.edit, color: theme.colorScheme.primary, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Edit Thoughts',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Heart Toggle Button
                  GestureDetector(
                    onTap: () => provider.toggleFavorite(entry.id),
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: PeejaysTheme.retroCardDecoration(
                        bgColor: entry.isFavorite ? theme.colorScheme.error : theme.colorScheme.surface,
                        outlineColor: theme.colorScheme.outline,
                        shadowOffset: 2,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        entry.isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: entry.isFavorite ? Colors.white : theme.colorScheme.primary,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Image builder
  Widget _buildViewImage(String path) {
    if (path.startsWith('http')) {
      return Image.network(path, fit: BoxFit.fitWidth);
    } else if (path.startsWith('data:image')) {
      final uri = Uri.parse(path);
      return Image.memory(uri.data!.contentAsBytes(), fit: BoxFit.fitWidth);
    } else {
      if (kIsWeb) {
        return Image.network(path, fit: BoxFit.fitWidth, errorBuilder: (_, __, ___) => const SizedBox.shrink());
      } else {
        return Image.file(File(path), fit: BoxFit.fitWidth, errorBuilder: (_, __, ___) => const SizedBox.shrink());
      }
    }
  }

  // Options Dialog for Deleting
  void _showOptions(BuildContext context, JournalProvider provider, JournalEntry entry) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          title: Text(
            'DELETE ENTRY',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.error,
              fontSize: 16,
            ),
          ),
          content: Text(
            'Are you sure you want to delete this memory? This action cannot be undone.',
            style: theme.textTheme.bodyMedium,
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'CANCEL',
                style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.primary),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(
                'DELETE',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                provider.deleteEntry(entry.id);
                // Pop the dialog and then the view screen
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
