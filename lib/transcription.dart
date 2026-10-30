import 'package:flutter_whisper_ggml/flutter_whisper.dart';

bool whisperSupportsAndroidRuntime({
  required String abi,
  required bool is64Bit,
}) => switch (abi) {
  'arm64-v8a' || 'x86_64' => is64Bit,
  _ => false,
};

String unsupportedAndroidRuntimeMessage(String abi, {required bool is64Bit}) =>
    'The offline Whisper model is unavailable on this phone: it is running '
    '${is64Bit ? '64-bit' : '32-bit'} Android'
    '${abi.isEmpty ? '' : ' ($abi)'}, but the Whisper engine included in '
    'Voice Notes does not include a native library for this Android ABI. '
    'Android speech recognition will be used instead.';

String whisperLanguageCode(String language) => switch (language) {
  'Amharic' => 'am',
  'English' => 'en',
  _ => throw ArgumentError.value(language, 'language', 'Unsupported language'),
};

Future<WhisperResult> transcribeRecordedAudio({
  required FlutterWhisper whisper,
  required String audioPath,
  required String language,
  void Function(int progress)? onProgress,
}) {
  return whisper.transcribeFile(
    audioPath,
    config: WhisperTranscribeConfig(
      language: whisperLanguageCode(language),
      threads: 4,
    ),
    onProgress: onProgress,
  );
}
