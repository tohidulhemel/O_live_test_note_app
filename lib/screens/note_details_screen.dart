import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../database/database_helper.dart';
import '../models/note.dart';
import '../utils/note_style.dart';
import '../widgets/delete_confirmation_dialog.dart';
import 'note_form_screen.dart';

class NoteDetailsScreen extends StatefulWidget {
  final Note note;

  const NoteDetailsScreen({super.key, required this.note});

  @override
  State<NoteDetailsScreen> createState() => _NoteDetailsScreenState();
}

class _NoteDetailsScreenState extends State<NoteDetailsScreen> {
  late Note _note;
  bool _dataChanged = false;

  @override
  void initState() {
    super.initState();
    _note = widget.note;
  }

  void _handleBack() {
    Navigator.pop(context, _dataChanged);
  }

  Future<void> _editNote() async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (ctx) => NoteFormScreen(note: _note)),
    );
    if (changed == true) {
      final notes = await DatabaseHelper.instance.getAllNotes();
      final updated = notes.where((n) => n.id == _note.id).toList();
      if (updated.isNotEmpty && mounted) {
        setState(() {
          _note = updated.first;
          _dataChanged = true;
        });
      }
    }
  }

  Future<void> _deleteNote() async {
    final confirmed = await showDeleteConfirmationDialog(context);
    if (!confirmed || _note.id == null) return;

    await DatabaseHelper.instance.deleteNote(_note.id!);

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final style = styleForNote(_note.id);

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _dataChanged);
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _handleBack,
          ),
          title: const Text('Note Details'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
                decoration: BoxDecoration(
                  color: style.background,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(style.icon, color: style.foreground, size: 30),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      _note.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      DateFormat('MMM d, yyyy • h:mm a').format(_note.updatedAt),
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      _note.description.isEmpty ? 'No description added.' : _note.description,
                      style: TextStyle(
                        fontSize: 14.5,
                        height: 1.6,
                        color: _note.description.isEmpty ? Colors.grey.shade400 : Colors.black87,
                        fontStyle: _note.description.isEmpty ? FontStyle.italic : FontStyle.normal,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _editNote,
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Edit'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade400,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _deleteNote,
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text('Delete'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
