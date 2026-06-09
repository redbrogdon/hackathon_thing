import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/journal_entry.dart';
import '../providers/journal_provider.dart';
import '../theme/peejays_theme.dart';

class EditScreen extends StatefulWidget {
  final String? entryId;

  const EditScreen({super.key, this.entryId});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late TextEditingController _locationController;

  DateTime _selectedDate = DateTime.now();
  List<String> _tags = [];
  String? _mood;
  String? _imageUrl;
  int _wordCount = 0;

  bool get _isEditing => widget.entryId != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _contentController = TextEditingController();
    _locationController = TextEditingController();

    _contentController.addListener(_updateWordCount);

    // If editing, load current values
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isEditing) {
        final provider = context.read<JournalProvider>();
        final entry = provider.entries.firstWhere((e) => e.id == widget.entryId);
        setState(() {
          _titleController.text = entry.title;
          _contentController.text = entry.content;
          _locationController.text = entry.location ?? '';
          _selectedDate = entry.createdAt;
          _tags = List.from(entry.tags);
          _mood = entry.mood;
          _imageUrl = entry.imageUrl;
          _updateWordCount();
        });
      }
    });
  }

  @override
  void dispose() {
    _contentController.removeListener(_updateWordCount);
    _titleController.dispose();
    _contentController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _updateWordCount() {
    final text = _contentController.text.trim();
    if (text.isEmpty) {
      setState(() {
        _wordCount = 0;
      });
      return;
    }
    final words = text.split(RegExp(r'\s+'));
    setState(() {
      _wordCount = words.where((w) => w.isNotEmpty).length;
    });
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
      if (pickedFile != null) {
        setState(() {
          _imageUrl = pickedFile.path;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to pick image.')),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: PeejaysTheme.lightPrimary,
                  onPrimary: Colors.white,
                  surface: PeejaysTheme.lightSurface,
                  onSurface: PeejaysTheme.lightOnBackground,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _showAddTagDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          title: Text(
            'ADD MOOD OR TAG',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          content: TextField(
            controller: controller,
            style: theme.textTheme.bodyMedium,
            decoration: InputDecoration(
              hintText: 'Enter keyword...',
              hintStyle: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: theme.colorScheme.outline),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('CANCEL', style: theme.textTheme.labelMedium),
            ),
            TextButton(
              onPressed: () {
                final tag = controller.text.trim();
                if (tag.isNotEmpty) {
                  setState(() {
                    if (_mood == null) {
                      _mood = tag; // Use the first tag as the entry mood
                    } else {
                      if (!_tags.contains(tag)) {
                        _tags.add(tag);
                      }
                    }
                  });
                }
                Navigator.pop(context);
              },
              child: Text('ADD', style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showDictationMock() {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          title: Text(
            'VOICE DICTATION',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.mic_rounded, size: 48, color: PeejaysTheme.lightAccent),
              const SizedBox(height: 16),
              Text(
                'Transcribing voice notes to text...',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _contentController.text =
                      '${_contentController.text} [Dictation: A cool autumn breeze swept through the open window, carrying the scent of damp leaves.]';
                  _updateWordCount();
                });
              },
              child: Text('SIMULATE SPEECH', style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final provider = context.read<JournalProvider>();
      final title = _titleController.text.trim();
      final content = _contentController.text.trim();
      final location = _locationController.text.trim();

      if (_isEditing) {
        final existingEntry = provider.entries.firstWhere((e) => e.id == widget.entryId);
        final updatedEntry = existingEntry.copyWith(
          title: title,
          content: content,
          location: location,
          createdAt: _selectedDate, // Update creation date if modified
          tags: _tags,
          mood: _mood,
          imageUrl: _imageUrl,
        );
        provider.updateEntry(updatedEntry);
      } else {
        final newEntry = JournalEntry(
          id: const Uuid().v4(),
          title: title,
          content: content,
          createdAt: _selectedDate,
          updatedAt: DateTime.now(),
          tags: _tags,
          location: location,
          imageUrl: _imageUrl,
          mood: _mood,
          isFavorite: false,
        );
        provider.addEntry(newEntry);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formattedDate = DateFormat('MMMM d, yyyy').format(_selectedDate);

    return Scaffold(
      appBar: AppBar(
        // Cancel/X button
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border.all(color: theme.colorScheme.outline, width: 2),
              ),
              child: Icon(Icons.close, color: theme.colorScheme.primary, size: 20),
            ),
          ),
        ),
        title: Text(
          _isEditing ? 'EDIT ENTRY' : 'NEW ENTRY',
          style: theme.appBarTheme.titleTextStyle,
        ),
        actions: [
          // Solid Save button
          Padding(
            padding: const EdgeInsets.only(right: 12.0, top: 10.0, bottom: 10.0),
            child: GestureDetector(
              onTap: _save,
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  border: Border.all(color: theme.colorScheme.primary),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.center,
                child: Text(
                  'SAVE',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(24.0),
                  children: [
                    // TITLE card
                    Container(
                      decoration: PeejaysTheme.retroCardDecoration(
                        bgColor: theme.colorScheme.surface,
                        outlineColor: theme.colorScheme.outline,
                        shadowOffset: 4,
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TITLE',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: PeejaysTheme.lightSecondaryText,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          TextFormField(
                            controller: _titleController,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            decoration: InputDecoration(
                              hintText: 'A name for this moment...',
                              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.outline.withOpacity(0.6),
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Title is required';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Date Selection row
                    Row(
                      children: [
                        Icon(Icons.calendar_today_rounded, size: 18, color: theme.colorScheme.outline),
                        const SizedBox(width: 8),
                        Text(
                          formattedDate,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: PeejaysTheme.lightSecondaryText,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => _selectDate(context),
                          child: Icon(Icons.edit_calendar_rounded, size: 18, color: theme.colorScheme.primary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // LOCATION card
                    Container(
                      decoration: PeejaysTheme.retroCardDecoration(
                        bgColor: theme.colorScheme.surface,
                        outlineColor: theme.colorScheme.outline,
                        shadowOffset: 4,
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'LOCATION',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: PeejaysTheme.lightSecondaryText,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          TextFormField(
                            controller: _locationController,
                            style: theme.textTheme.bodyMedium,
                            decoration: InputDecoration(
                              hintText: 'Where are you writing this?',
                              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.outline.withOpacity(0.6),
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // DEAR DIARY body input card
                    Container(
                      decoration: PeejaysTheme.retroCardDecoration(
                        bgColor: theme.colorScheme.surface,
                        outlineColor: theme.colorScheme.outline,
                        shadowOffset: 4,
                      ),
                      constraints: const BoxConstraints(minHeight: 280),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'DEAR DIARY...',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: PeejaysTheme.lightSecondaryText,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _contentController,
                            style: theme.textTheme.bodyLarge,
                            maxLines: null,
                            minLines: 8,
                            keyboardType: TextInputType.multiline,
                            decoration: InputDecoration(
                              hintText: 'The ink is fresh and the day is young. What stories will you tell?',
                              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.outline.withOpacity(0.6),
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // MOOD & TAGS chips row
                    Container(
                      decoration: PeejaysTheme.retroCardDecoration(
                        bgColor: theme.colorScheme.surface,
                        outlineColor: theme.colorScheme.outline,
                        shadowOffset: 4,
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'MOOD & TAGS',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: PeejaysTheme.lightSecondaryText,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              // Display primary mood if set
                              if (_mood != null)
                                Chip(
                                  label: Text(_mood!),
                                  backgroundColor: PeejaysTheme.lightSecondaryBackground,
                                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                                  side: BorderSide(color: theme.colorScheme.outline),
                                  onDeleted: () {
                                    setState(() {
                                      _mood = null;
                                    });
                                  },
                                ),
                              // Display tags
                              ..._tags.map((tag) => Chip(
                                    label: Text(tag),
                                    backgroundColor: theme.colorScheme.surface,
                                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                                    side: BorderSide(color: theme.colorScheme.outline),
                                    onDeleted: () {
                                      setState(() {
                                        _tags.remove(tag);
                                      });
                                    },
                                  )),
                              // Add button
                              GestureDetector(
                                onTap: _showAddTagDialog,
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surface,
                                    border: Border.all(color: theme.colorScheme.outline, width: 2),
                                  ),
                                  alignment: Alignment.center,
                                  child: Icon(Icons.add, color: theme.colorScheme.primary, size: 18),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Image attachment card (if set)
                    if (_imageUrl != null && _imageUrl!.isNotEmpty)
                      Container(
                        decoration: PeejaysTheme.retroCardDecoration(
                          bgColor: theme.colorScheme.surface,
                          outlineColor: theme.colorScheme.outline,
                          shadowOffset: 4,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          children: [
                            AspectRatio(
                              aspectRatio: 16 / 9,
                              child: _buildAttachmentImage(_imageUrl!),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _imageUrl = null;
                                  });
                                },
                                child: Container(
                                  color: Colors.black.withOpacity(0.6),
                                  padding: const EdgeInsets.all(4),
                                  child: const Icon(Icons.delete, color: Colors.white, size: 20),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Bottom toolbar (add image, add voice mock, word counter)
            Container(
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: theme.colorScheme.outline, width: 2)),
                color: PeejaysTheme.lightSecondaryBackground,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      // Image add button
                      _buildToolbarButton(Icons.image_rounded, _pickImage),
                      const SizedBox(width: 12),
                      // Dictation add button
                      _buildToolbarButton(Icons.mic_rounded, _showDictationMock),
                      const SizedBox(width: 12),
                      // Tag dialog trigger button
                      _buildToolbarButton(Icons.sell_rounded, _showAddTagDialog),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        '$_wordCount words',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: PeejaysTheme.lightSecondaryText,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(Icons.border_color_rounded, size: 14, color: theme.colorScheme.outline),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbarButton(IconData icon, VoidCallback onTap) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border.all(color: theme.colorScheme.outline, width: 2),
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: theme.colorScheme.primary, size: 20),
      ),
    );
  }

  Widget _buildAttachmentImage(String path) {
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
}
