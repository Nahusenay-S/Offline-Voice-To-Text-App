import 'package:flutter_test/flutter_test.dart';
import 'package:voice_notes/notes.dart';

class _MemoryPreferences implements NotePreferences {
  final Map<String, String> values = {};

  @override
  Future<String?> getString(String key) async => values[key];

  @override
  Future<void> setString(String key, String value) async {
    values[key] = value;
  }
}

void main() {
  late _MemoryPreferences preferences;
  late LocalNoteStore store;

  setUp(() async {
    preferences = _MemoryPreferences();
    store = LocalNoteStore(preferences: preferences);
  });

  test('saves, reloads, edits, sorts, and deletes notes', () async {
    final firstCreated = DateTime.utc(2026, 1, 1);
    final secondCreated = DateTime.utc(2026, 1, 2);
    final first = await store.saveNote(
      title: 'First note',
      transcript: 'A transcript',
      language: 'English',
      now: firstCreated,
    );
    await store.saveNote(
      title: 'Second note',
      transcript: 'Another transcript',
      language: 'Amharic',
      now: secondCreated,
    );

    final reloaded = LocalNoteStore(preferences: preferences);
    final notes = await reloaded.listNotes();
    expect(notes.map((note) => note.title), ['Second note', 'First note']);

    final edited = await reloaded.saveNote(
      id: first.id,
      title: 'Renamed note',
      transcript: 'Corrected transcript',
      language: 'English',
      now: DateTime.utc(2026, 1, 3),
    );
    expect(edited.createdAt, firstCreated);
    expect(edited.updatedAt, DateTime.utc(2026, 1, 3));
    expect(edited.title, 'Renamed note');
    expect(edited.transcript, 'Corrected transcript');

    await reloaded.deleteNote(first.id);
    expect((await reloaded.listNotes()).map((note) => note.title), [
      'Second note',
    ]);
  });

  test('rejects blank titles and empty transcripts', () async {
    await expectLater(
      store.saveNote(title: '  ', transcript: 'Words', language: 'English'),
      throwsArgumentError,
    );
    await expectLater(
      store.saveNote(title: 'A title', transcript: ' ', language: 'English'),
      throwsArgumentError,
    );
  });
}
