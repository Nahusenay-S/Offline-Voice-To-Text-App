import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_whisper_ggml/flutter_whisper.dart';
import 'package:voice_notes/transcription.dart';

class _FakeBackend implements WhisperBackend {
  String? language;
  int? progress;

  @override
  Future<WhisperResult> transcribe(
    Float32List samples,
    WhisperTranscribeConfig config, {
    void Function(int progress)? onProgress,
    void Function(WhisperSegment segment)? onSegment,
  }) async {
    language = config.language;
    onProgress?.call(42);
    progress = 42;
    return const WhisperResult(
      language: 'en',
      segments: [
        WhisperSegment(
          text: ' Test transcript',
          start: Duration.zero,
          end: Duration(seconds: 1),
        ),
      ],
    );
  }

  @override
  void cancel() {}

  @override
  void dispose() {}
}

class _FakeAudioDecoder implements WhisperAudioDecoder {
  String? decodedPath;

  @override
  Future<Float32List> decode(String inputPath) async {
    decodedPath = inputPath;
    return Float32List(160);
  }

  @override
  Future<void> cancel() async {}
}

void main() {
  test('transcribes the recorded WAV using the selected language', () async {
    final backend = _FakeBackend();
    final decoder = _FakeAudioDecoder();
    final whisper = FlutterWhisper.withBackend(backend, audioDecoder: decoder);
    var reportedProgress = 0;

    final result = await transcribeRecordedAudio(
      whisper: whisper,
      audioPath: 'recording.wav',
      language: 'Amharic',
      onProgress: (progress) => reportedProgress = progress,
    );

    expect(decoder.decodedPath, 'recording.wav');
    expect(backend.language, 'am');
    expect(backend.progress, 42);
    expect(reportedProgress, 42);
    expect(result.text.trim(), 'Test transcript');

    await whisper.dispose();
  });

  test('uses the English Whisper language code', () {
    expect(whisperLanguageCode('English'), 'en');
  });

  test('rejects unsupported language selections', () {
    expect(() => whisperLanguageCode('Tigrinya'), throwsArgumentError);
  });

  test('matches supported native Android ABIs and bitness', () {
    expect(
      whisperSupportsAndroidRuntime(abi: 'arm64-v8a', is64Bit: true),
      isTrue,
    );
    expect(whisperSupportsAndroidRuntime(abi: 'x86_64', is64Bit: true), isTrue);
    expect(
      whisperSupportsAndroidRuntime(abi: 'armeabi-v7a', is64Bit: false),
      isFalse,
    );
    expect(
      whisperSupportsAndroidRuntime(abi: 'armeabi-v7a', is64Bit: true),
      isFalse,
    );
    expect(
      whisperSupportsAndroidRuntime(abi: 'x86', is64Bit: false),
      isFalse,
    );
  });

  test('explains why 32-bit Android cannot load Whisper', () {
    expect(
      unsupportedAndroidRuntimeMessage('armeabi-v7a', is64Bit: false),
      contains('Android speech recognition will be used instead'),
    );
  });
}
