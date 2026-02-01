import 'package:flutter/material.dart';
import '../../../core/utils/arabic_utils.dart';
import '../../../domain/entities/verse.dart';

class NoteSheet extends StatefulWidget {
  final Verse verse;
  final int chapterId;
  final String chapterName;
  final String? existingNote;
  final void Function(String note) onSave;

  const NoteSheet({
    super.key,
    required this.verse,
    required this.chapterId,
    required this.chapterName,
    this.existingNote,
    required this.onSave,
  });

  @override
  State<NoteSheet> createState() => _NoteSheetState();
}

class _NoteSheetState extends State<NoteSheet> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.existingNote ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.existingNote != null ? 'تعديل الملاحظة' : 'إضافة ملاحظة',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),

            // Reference
            Text(
              'سورة ${widget.chapterName} \u2022 آية ${toArabicNumeral(widget.verse.verseNumber)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.amber[700],
              ),
            ),

            const SizedBox(height: 16),

            // Text field
            TextField(
              controller: _controller,
              maxLines: 4,
              textDirection: TextDirection.rtl,
              decoration: const InputDecoration(
                hintText: 'اكتب ملاحظتك...',
              ),
              autofocus: true,
            ),

            const SizedBox(height: 16),

            // Save button
            FilledButton(
              onPressed: () {
                final text = _controller.text.trim();
                if (text.isNotEmpty) {
                  widget.onSave(text);
                  Navigator.pop(context);
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFD97706),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('حفظ', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
