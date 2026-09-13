import 'package:flutter/material.dart';

import '../database/database_helper.dart';
import '../models/note.dart';
import '../widgets/note_card.dart';
import 'note_detail_screen.dart';

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

  Future<void> _openNoteDetail({Note? note}) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (ctx) => NoteDetailScreen(note: note)),
    );
    // Refresh the list whenever we come back from add/edit/delete.
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
      appBar: AppBar(
        title: const Text('My Notes'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search notes by title...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
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
        onPressed: () => _openNoteDetail(),
        tooltip: 'Add note',
        child: const Icon(Icons.add),
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
              Icon(
                searching ? Icons.search_off : Icons.note_add_outlined,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                searching
                    ? 'No notes match "$_searchQuery"'
                    : 'No notes yet. Tap + to add one!',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
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
            onTap: () => _openNoteDetail(note: note),
            onDelete: () => _deleteNote(note),
          );
        },
      ),
    );
  }
}
