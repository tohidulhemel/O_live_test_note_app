import 'package:flutter/material.dart';


class NoteStyle {
  final Color background;
  final Color foreground;
  final IconData icon;

  const NoteStyle({
    required this.background,
    required this.foreground,
    required this.icon,
  });
}

const List<NoteStyle> _palette = [
  NoteStyle(
    background: Color(0xFFD9F5E6),
    foreground: Color(0xFF1FAA59),
    icon: Icons.description_outlined,
  ),
  NoteStyle(
    background: Color(0xFFDCEAFC),
    foreground: Color(0xFF2D8CF0),
    icon: Icons.lightbulb_outline,
  ),
  NoteStyle(
    background: Color(0xFFEAE0FB),
    foreground: Color(0xFF8B5CF6),
    icon: Icons.sticky_note_2_outlined,
  ),
  NoteStyle(
    background: Color(0xFFFDEBD3),
    foreground: Color(0xFFE29328),
    icon: Icons.checklist_outlined,
  ),
  NoteStyle(
    background: Color(0xFFFBE0E6),
    foreground: Color(0xFFEE5A75),
    icon: Icons.favorite_border,
  ),
  NoteStyle(
    background: Color(0xFFD8F3F0),
    foreground: Color(0xFF14A38B),
    icon: Icons.bookmark_border,
  ),
  NoteStyle(
    background: Color(0xFFE4E7FB),
    foreground: Color(0xFF5B6EE1),
    icon: Icons.event_note_outlined,
  ),
];

NoteStyle styleForNote(int? id) {
  final index = (id ?? 0) % _palette.length;
  return _palette[index];
}
