import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _mint = Color(0xFF47765E);
const _background = Color(0xFFF5F3EC);
const _panel = Color(0xFFFFFEFA);
const _muted = Color(0xFF737A70);

class VoiceNote {
  const VoiceNote({
    required this.id,
    required this.title,
    required this.transcript,
    required this.language,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String transcript;
  final String language;
  final DateTime createdAt;
  final DateTime updatedAt;

  VoiceNote copyWith({
    String? title,
    String? transcript,
    String? language,
    DateTime? updatedAt,
  }) {
    return VoiceNote(
      id: id,
      title: title ?? this.title,
      transcript: transcript ?? this.transcript,
      language: language ?? this.language,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, Object> toJson() => {
    'id': id,
    'title': title,
    'transcript': transcript,
    'language': language,
    'createdAt': createdAt.toUtc().toIso8601String(),
    'updatedAt': updatedAt.toUtc().toIso8601String(),
  };

  factory VoiceNote.fromJson(Map<String, dynamic> json) => VoiceNote(
    id: json['id'] as String,
    title: json['title'] as String,
    transcript: json['transcript'] as String,
    language: json['language'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );
}

class LocalNoteStore {
  LocalNoteStore({NotePreferences? preferences})
    : _preferences = preferences ?? _SharedPreferencesNotes();

  final NotePreferences _preferences;
  static final Random _random = Random.secure();
  static const _storageKey = 'voice_notes.saved_notes';

  Future<List<VoiceNote>> listNotes() async {
    final json = await _preferences.getString(_storageKey);
    if (json == null) return [];
    final decoded = jsonDecode(json);
    if (decoded is! List) {
      throw const FormatException('Saved notes data must be a list.');
    }
    final notes = decoded
        .map(
          (item) => VoiceNote.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
    notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return notes;
  }

  Future<VoiceNote> saveNote({
    String? id,
    required String title,
    required String transcript,
    required String language,
    DateTime? now,
  }) async {
    final cleanTitle = title.trim();
    final cleanTranscript = transcript.trim();
    if (cleanTitle.isEmpty) {
      throw ArgumentError.value(title, 'title', 'A title is required.');
    }
    if (cleanTranscript.isEmpty) {
      throw ArgumentError.value(
        transcript,
        'transcript',
        'A transcript is required.',
      );
    }

    final notes = await listNotes();
    final existingIndex = id == null
        ? -1
        : notes.indexWhere((note) => note.id == id);
    final timestamp = (now ?? DateTime.now()).toUtc();
    final existing = existingIndex == -1 ? null : notes[existingIndex];
    final note = VoiceNote(
      id: existing?.id ?? id ?? _newId(timestamp),
      title: cleanTitle,
      transcript: cleanTranscript,
      language: language,
      createdAt: existing?.createdAt ?? timestamp,
      updatedAt: timestamp,
    );
    if (existingIndex == -1) {
      notes.add(note);
    } else {
      notes[existingIndex] = note;
    }
    await _write(notes);
    return note;
  }

  Future<void> deleteNote(String id) async {
    final notes = await listNotes();
    final updatedNotes = notes.where((note) => note.id != id).toList();
    if (updatedNotes.length == notes.length) return;
    await _write(updatedNotes);
  }

  String _newId(DateTime timestamp) =>
      '${timestamp.microsecondsSinceEpoch}-${_random.nextInt(1 << 32)}';

  Future<void> _write(List<VoiceNote> notes) => _preferences.setString(
    _storageKey,
    jsonEncode(notes.map((note) => note.toJson()).toList()),
  );
}

abstract interface class NotePreferences {
  Future<String?> getString(String key);
  Future<void> setString(String key, String value);
}

class _SharedPreferencesNotes implements NotePreferences {
  final SharedPreferencesAsync _preferences = SharedPreferencesAsync();

  @override
  Future<String?> getString(String key) => _preferences.getString(key);

  @override
  Future<void> setString(String key, String value) =>
      _preferences.setString(key, value);
}

class SavedNotesPage extends StatefulWidget {
  const SavedNotesPage({super.key, required this.store});

  final LocalNoteStore store;

  @override
  State<SavedNotesPage> createState() => _SavedNotesPageState();
}

class _SavedNotesPageState extends State<SavedNotesPage> {
  late Future<List<VoiceNote>> _notes;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _notes = widget.store.listNotes();
  }

  Future<void> _open(VoiceNote note) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => NoteEditorPage(store: widget.store, note: note),
      ),
    );
    if (changed == true && mounted) {
      setState(_reload);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        title: const Text('Saved notes'),
      ),
      body: FutureBuilder<List<VoiceNote>>(
        future: _notes,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _LoadError(onRetry: () => setState(_reload));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final notes = snapshot.data!;
          if (notes.isEmpty) {
            return const _EmptyNotes();
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
            itemCount: notes.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final note = notes[index];
              return Material(
                color: _panel,
                borderRadius: BorderRadius.circular(18),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 17,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  title: Text(
                    note.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text(
                      '${note.transcript}\n${note.language} · ${_formatDate(note.updatedAt)}',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _muted,
                        height: 1.4,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: _muted),
                  onTap: () => _open(note),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class NoteEditorPage extends StatefulWidget {
  const NoteEditorPage({super.key, required this.store, required this.note});

  final LocalNoteStore store;
  final VoiceNote note;

  @override
  State<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends State<NoteEditorPage> {
  late final TextEditingController _title;
  late final TextEditingController _transcript;
  bool _saving = false;

  bool get _hasChanges =>
      _title.text != widget.note.title ||
      _transcript.text != widget.note.transcript;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.note.title);
    _transcript = TextEditingController(text: widget.note.transcript);
    _title.addListener(_editChanged);
    _transcript.addListener(_editChanged);
  }

  void _editChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await widget.store.saveNote(
        id: widget.note.id,
        title: _title.text,
        transcript: _transcript.text,
        language: widget.note.language,
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted) _showError(context, 'Could not save note: $error');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this note?'),
        content: const Text('This permanently removes the saved note.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep note'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await widget.store.deleteNote(widget.note.id);
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted) _showError(context, 'Could not delete note: $error');
    }
  }

  Future<bool> _confirmDiscard() async {
    if (_saving) return false;
    if (!_hasChanges) return true;
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Discard unsaved edits?'),
            content: const Text('Your changes have not been saved.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Keep editing'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Discard'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  void dispose() {
    _title.removeListener(_editChanged);
    _transcript.removeListener(_editChanged);
    _title.dispose();
    _transcript.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<void>(
      canPop: !_hasChanges && !_saving,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        final discard = await _confirmDiscard();
        if (!discard || !navigator.mounted) return;
        navigator.pop();
      },
      child: Scaffold(
        backgroundColor: _background,
        appBar: AppBar(
          backgroundColor: _background,
          title: const Text('Edit note'),
          actions: [
            IconButton(
              tooltip: 'Delete note',
              onPressed: _saving ? null : _delete,
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            TextField(
              controller: _title,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Title',
                filled: true,
                fillColor: _panel,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _transcript,
              minLines: 10,
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Transcript',
                alignLabelWithHint: true,
                filled: true,
                fillColor: _panel,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: const Icon(Icons.check_rounded),
              label: Text(_saving ? 'Saving...' : 'Save changes'),
            ),
            const SizedBox(height: 12),
            Text(
              '${widget.note.language} · Created ${_formatDate(widget.note.createdAt)}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: _muted, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyNotes extends StatelessWidget {
  const _EmptyNotes();

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.bookmarks_outlined,
            size: 42,
            color: _mint.withValues(alpha: 0.75),
          ),
          const SizedBox(height: 14),
          const Text(
            'Your saved notes will live here.',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 6),
          const Text(
            'Save a transcript to find it again later.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _muted, fontSize: 13),
          ),
        ],
      ),
    ),
  );
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Could not load saved notes.'),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onRetry, child: const Text('Try again')),
        ],
      ),
    ),
  );
}

String _formatDate(DateTime date) {
  final local = date.toLocal();
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  return '$month/$day/${local.year}';
}

void _showError(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
