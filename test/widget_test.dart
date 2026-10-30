import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:voice_notes/main.dart';
import 'package:voice_notes/notes.dart';
import 'package:voice_notes/settings.dart';

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
  testWidgets('settings is reachable from recorder and explains model status', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(384, 853);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final store = LocalNoteStore(preferences: _MemoryPreferences());
    const channel = MethodChannel('com.senay.voice_notes/device');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          expect(call.method, 'getAndroidRuntime');
          return {'abi': 'arm64-v8a', 'is64Bit': true};
        });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null),
    );
    await tester.pumpWidget(MaterialApp(home: RecorderHome(noteStore: store)));
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Whisper base-q5_1'), findsOneWidget);
    expect(find.text('Not loaded yet'), findsOneWidget);
    expect(find.text('Open saved notes'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Settings identifies an incompatible Android runtime', (
    tester,
  ) async {
    final store = LocalNoteStore(preferences: _MemoryPreferences());
    await tester.pumpWidget(
      MaterialApp(
        home: SettingsPage(
          noteStore: store,
          modelReady: false,
          modelSupported: false,
          modelSupportMessage:
              'Offline transcription is unavailable on this phone: it is '
              'running 32-bit Android (armeabi-v7a), but Whisper requires '
              'a supported Android runtime.',
        ),
      ),
    );

    expect(find.text('Not supported on this phone'), findsOneWidget);
    expect(find.textContaining('armeabi-v7a'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('recorder recognizes the Infinix 32-bit Android runtime', (
    tester,
  ) async {
    const channel = MethodChannel('com.senay.voice_notes/device');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          return {'abi': 'armeabi-v7a', 'is64Bit': false};
        });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null),
    );
    final store = LocalNoteStore(preferences: _MemoryPreferences());

    await tester.pumpWidget(MaterialApp(home: RecorderHome(noteStore: store)));
    await tester.pumpAndSettle();

    expect(find.text('Recording your voice...'), findsNothing);
    expect(find.text('Could not start recording:'), findsNothing);
    expect(
      find.textContaining('Android speech recognition will be used instead'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('welcome content starts near the top on a tall phone', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(384, 853);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const VoiceNotesApp());
    await tester.pump();

    expect(tester.getTopLeft(find.text('Voice Notes')).dy, lessThan(60));
    expect(tester.getBottomLeft(find.text('Get Started')).dy, greaterThan(780));
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('A reminder for later'));
    await tester.pumpAndSettle();

    expect(find.text('Try this idea: A reminder for later'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('welcome page scrolls on a narrow phone and opens the recorder', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 560);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const VoiceNotesApp());
    await tester.pump();

    expect(find.text('A note, in\nyour voice.'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.ensureVisible(find.text('Get Started'));
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    expect(find.text('Start with a thought.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('recorder content fits a narrow phone width', (tester) async {
    tester.view.physicalSize = const Size(320, 560);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MaterialApp(home: RecorderHome()));
    await tester.pump();
    expect(tester.takeException(), isNull);

    await tester.drag(find.byType(ListView), const Offset(0, -1200));
    await tester.pumpAndSettle();
    expect(find.text('Your transcript'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('transcript can be saved, reopened, edited, and deleted', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(384, 853);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final store = LocalNoteStore(preferences: _MemoryPreferences());
    await tester.pumpWidget(MaterialApp(home: RecorderHome(noteStore: store)));
    await tester.drag(find.byType(ListView), const Offset(0, -1200));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Your transcript'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'A thought to keep');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Save as a note'));
    await tester.tap(find.text('Save as a note'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), 'My idea');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Note saved on this device'), findsOneWidget);

    await tester.drag(find.byType(ListView).first, const Offset(0, 1600));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('1 note on this device'), findsOneWidget);
    await tester.tap(find.byTooltip('Saved notes'));
    await tester.pumpAndSettle();
    expect(find.text('My idea'), findsOneWidget);

    await tester.tap(find.text('My idea'));
    await tester.pumpAndSettle();
    expect(find.text('A thought to keep'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, 'Renamed idea');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();
    expect(find.text('Saved notes'), findsOneWidget);
    await tester.tap(find.text('Renamed idea'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Delete note'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.text('Your saved notes will live here.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
