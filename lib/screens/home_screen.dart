import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/note.dart';
import '../widgets/note_card.dart';
import 'note_details_screen.dart';
import 'note_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<Note> _notes = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadNotes();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    setState(() => _searchQuery = query);
    _loadNotes(query: query);
  }

  Future<void> _loadNotes({String query = ''}) async {
    setState(() => _isLoading = true);
    try {
      final notes = query.isEmpty
          ? await DatabaseHelper.instance.getAllNotes()
          : await DatabaseHelper.instance.searchNotesByTitle(query);
      if (!mounted) return;
      setState(() {
        _notes = notes;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load notes: $e')),
      );
    }
  }

  Future<void> _openNoteDetails(Note note) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (ctx) => NoteDetailsScreen(note: note)),
    );
    if (changed == true) {
      _loadNotes(query: _searchQuery);
    }
  }

  Future<void> _openNoteForm({Note? note}) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (ctx) => NoteFormScreen(note: note)),
    );
    if (changed == true) {
      _loadNotes(query: _searchQuery);
    }
  }

  Future<void> _deleteNote(Note note) async {
    if (note.id == null) return;
    await DatabaseHelper.instance.deleteNote(note.id!);
    _loadNotes(query: _searchQuery);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('"${note.title}" deleted')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Notes', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        scrolledUnderElevation: 1,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search notes by title...',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: Colors.grey.shade400),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1FAA59),
        onPressed: () => _openNoteForm(),
        tooltip: 'Add note',
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_notes.isEmpty) {
      final bool searching = _searchQuery.isNotEmpty;
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  searching ? Icons.search_off : Icons.note_add_outlined,
                  size: 44,
                  color: Colors.grey.shade400,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                searching ? 'No results found' : 'No notes yet',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
              ),
              const SizedBox(height: 6),
              Text(
                searching
                    ? 'Try searching with a different keyword.'
                    : 'Tap the + button to create your first note.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13.5),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadNotes(query: _searchQuery),
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 88, top: 4),
        itemCount: _notes.length,
        itemBuilder: (context, index) {
          final note = _notes[index];
          return NoteCard(
            note: note,
            onTap: () => _openNoteDetails(note),
            onEdit: () => _openNoteForm(note: note),
            onDelete: () => _deleteNote(note),
          );
        },
      ),
    );
  }
}
