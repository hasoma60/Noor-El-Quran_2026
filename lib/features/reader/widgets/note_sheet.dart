import 'package:flutter/material.dart';
import '../../../core/utils/arabic_utils.dart';
import '../../../core/widgets/base_bottom_sheet.dart';
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
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: BaseBottomSheet(
        title: widget.existingNote != null ? 'تعديل الملاحظة' : 'إضافة ملاحظة',
        subtitle: 'سورة ${widget.chapterName} \u2022 آية ${toArabicNumeral(widget.verse.verseNumber)}',
        maxHeightFraction: 0.6,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
      ),
    );
  }
}
