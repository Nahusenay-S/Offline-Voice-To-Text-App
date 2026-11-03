import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_whisper_ggml/flutter_whisper.dart';

import 'notes.dart';
import 'settings.dart';
import 'transcription.dart';

void main() {
  runApp(const VoiceNotesApp());
}

const mint = Color(0xFF47765E);
const bg = Color(0xFFF5F3EC);
const panel = Color(0xFFFFFEFA);
const muted = Color(0xFF737A70);

class VoiceNotesApp extends StatelessWidget {
  const VoiceNotesApp({super.key, this.noteStore});

  final LocalNoteStore? noteStore;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Voice Notes',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: bg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: mint,
          brightness: Brightness.light,
        ),
      ),
      home: WelcomePage(noteStore: noteStore),
    );
  }
}

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key, this.noteStore});

  final LocalNoteStore? noteStore;

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  void _start({String? prompt}) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 650),
        pageBuilder: (_, animation, secondaryAnimation) =>
            RecorderHome(prompt: prompt, noteStore: widget.noteStore),
        transitionsBuilder: (_, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.04),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFAF9F4),
                    Color(0xFFF5F3EC),
                    Color(0xFFEEF1E9),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 620),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 27,
                              vertical: 18,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      height: 43,
                                      width: 43,
                                      decoration: BoxDecoration(
                                        color: mint.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(
                                          color: mint.withValues(alpha: 0.2),
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.graphic_eq_rounded,
                                        color: mint,
                                        size: 27,
                                      ),
                                    ),
                                    const SizedBox(width: 11),
                                    const Text(
                                      'Voice Notes',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 36),
                                const Text(
                                  'A note, in\nyour voice.',
                                  style: TextStyle(
                                    color: Color(0xFF252D27),
                                    height: 1.02,
                                    fontSize: 46,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -2,
                                  ),
                                ),
                                const SizedBox(height: 15),
                                const Text(
                                  'For the thought you don’t want to lose. Speak in '
                                  'English or Amharic and keep it simple.',
                                  style: TextStyle(
                                    color: muted,
                                    fontSize: 14,
                                    height: 1.55,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Container(
                                  height: 164,
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(18),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE9EDE5),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Row(
                                        children: [
                                          Icon(
                                            Icons.mic_none_rounded,
                                            color: mint,
                                            size: 18,
                                          ),
                                          SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'A quiet place for your ideas',
                                              style: TextStyle(
                                                color: Color(0xFF48534A),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      SizedBox(
                                        height: 34,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: List.generate(31, (index) {
                                            const heights = [
                                              12,
                                              19,
                                              10,
                                              25,
                                              16,
                                              34,
                                              20,
                                              13,
                                              29,
                                              17,
                                              38,
                                              22,
                                              14,
                                              31,
                                              18,
                                              26,
                                              12,
                                              35,
                                              20,
                                              15,
                                              29,
                                              18,
                                              36,
                                              22,
                                              13,
                                              27,
                                              17,
                                              32,
                                              19,
                                              11,
                                              24,
                                            ];
                                            return Container(
                                              width: 3,
                                              height: heights[index].toDouble(),
                                              decoration: BoxDecoration(
                                                color: mint.withValues(
                                                  alpha: index % 4 == 0
                                                      ? 0.42
                                                      : 0.75,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                            );
                                          }),
                                        ),
                                      ),
                                      const Spacer(),
                                      const Row(
                                        children: [
                                          Text(
                                            '00:08',
                                            style: TextStyle(
                                              color: Color(0xFF48534A),
                                              fontSize: 12,
                                              fontFeatures: [
                                                FontFeature.tabularFigures(),
                                              ],
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'VOICE NOTE',
                                            style: TextStyle(
                                              color: muted,
                                              fontSize: 9,
                                              letterSpacing: 1.3,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 22),
                                const Wrap(
                                  spacing: 20,
                                  runSpacing: 10,
                                  children: [
                                    _WelcomeFeature(
                                      icon: Icons.language_rounded,
                                      label: 'English + Amharic',
                                    ),
                                    _WelcomeFeature(
                                      icon: Icons.lock_outline_rounded,
                                      label: 'Saved on your device',
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 28),
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: panel,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: const Color(0xFF252D27)
                                          .withValues(alpha: 0.08),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.only(
                                          left: 3,
                                          bottom: 8,
                                        ),
                                        child: Text(
                                          'NEED A FIRST NOTE?',
                                          style: TextStyle(
                                            color: muted,
                                            fontSize: 9,
                                            letterSpacing: 1.3,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      _StarterPrompt(
                                        icon: Icons.notifications_none_rounded,
                                        label: 'A reminder for later',
                                        onTap: () => _start(
                                          prompt: 'A reminder for later',
                                        ),
                                      ),
                                      _StarterPrompt(
                                        icon: Icons.lightbulb_outline_rounded,
                                        label: 'An idea worth keeping',
                                        onTap: () => _start(
                                          prompt: 'An idea worth keeping',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Spacer(),
                                const SizedBox(height: 26),
                                SizedBox(
                                  width: double.infinity,
                                  height: 57,
                                  child: FilledButton(
                                    onPressed: _start,
                                    style: FilledButton.styleFrom(
                                      backgroundColor: mint,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    child: const Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Get Started',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Icon(
                                          Icons.arrow_forward_rounded,
                                          size: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Center(
                                  child: Text(
                                    'NO ACCOUNT NEEDED',
                                    style: TextStyle(
                                      color: Color(0xFF8A9088),
                                      fontSize: 9,
                                      letterSpacing: 1.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _WelcomeFeature extends StatelessWidget {
  final IconData icon;
  final String label;

  const _WelcomeFeature({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: mint),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: muted, fontSize: 11)),
      ],
    );
  }
}

class _StarterPrompt extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _StarterPrompt({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          height: 42,
          child: Row(
            children: [
              Icon(icon, size: 19, color: mint),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF343D36),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_rounded, size: 16, color: muted),
            ],
          ),
        ),
      ),
    );
  }
}

class VoiceOrbPainter extends CustomPainter {
  final double progress;

  VoiceOrbPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final phase = progress * 2 * 3.141592653589793;

    // Soft light behind the orb.
    canvas.drawCircle(
      center,
      88 + 5 * _sin(phase),
      Paint()
        ..shader = RadialGradient(
          colors: [
            mint.withValues(alpha: 0.24),
            const Color(0xFF7164FF).withValues(alpha: 0.10),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: center, radius: 145)),
    );

    // Orbit rings.
    for (int i = 0; i < 3; i++) {
      final radius = 76.0 + i * 20;
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(phase * (i.isEven ? 1 : -0.65) + i * 0.5);

      final rect = Rect.fromCenter(
        center: Offset.zero,
        width: radius * 2,
        height: radius * (i == 1 ? 1.5 : 0.85),
      );

      canvas.drawOval(
        rect,
        Paint()
          ..color = mint.withValues(alpha: 0.13 - i * 0.025)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );

      canvas.drawCircle(
        Offset(radius, 0),
        3.5,
        Paint()..color = i.isEven ? mint : const Color(0xFFA49BFF),
      );
      canvas.restore();
    }

    // Glass-like center orb.
    canvas.drawCircle(
      center,
      58 + 3 * _sin(phase),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF344E61), Color(0xFF172D40), Color(0xFF111B30)],
        ).createShader(Rect.fromCircle(center: center, radius: 65)),
    );

    canvas.drawCircle(
      center,
      58,
      Paint()
        ..color = mint.withValues(alpha: 0.65)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    // Central microphone symbol, drawn with paths.
    final mic = Path()
      ..moveTo(center.dx - 9, center.dy - 15)
      ..quadraticBezierTo(
        center.dx - 9,
        center.dy - 25,
        center.dx,
        center.dy - 25,
      )
      ..quadraticBezierTo(
        center.dx + 9,
        center.dy - 25,
        center.dx + 9,
        center.dy - 15,
      )
      ..lineTo(center.dx + 9, center.dy + 2)
      ..quadraticBezierTo(
        center.dx + 9,
        center.dy + 13,
        center.dx,
        center.dy + 13,
      )
      ..quadraticBezierTo(
        center.dx - 9,
        center.dy + 13,
        center.dx - 9,
        center.dy + 2,
      )
      ..close();

    canvas.drawPath(
      mic,
      Paint()
        ..color = mint
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round,
    );

    canvas.drawLine(
      Offset(center.dx, center.dy + 13),
      Offset(center.dx, center.dy + 22),
      Paint()
        ..color = mint
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );

    canvas.drawLine(
      Offset(center.dx - 8, center.dy + 22),
      Offset(center.dx + 8, center.dy + 22),
      Paint()
        ..color = mint
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );

    // Floating particles.
    for (int i = 0; i < 13; i++) {
      final angle = phase + i * 2.399;
      final radius = 108.0 + (i % 3) * 10;
      final point = Offset(
        center.dx + radius * _cos(angle),
        center.dy + radius * _sin(angle),
      );

      canvas.drawCircle(
        point,
        1.5 + (i % 3) * 0.6,
        Paint()..color = mint.withValues(alpha: 0.25 + (i % 3) * 0.2),
      );
    }
  }

  double _sin(double value) {
    return _trig(value, true);
  }

  double _cos(double value) {
    return _trig(value, false);
  }

  double _trig(double value, bool sine) {
    // Small helper to keep the illustration self-contained.
    return sine
        ? _TaylorTrig.sin(value)
        : _TaylorTrig.sin(value + 1.5707963267948966);
  }

  @override
  bool shouldRepaint(covariant VoiceOrbPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _TaylorTrig {
  static double sin(double x) {
    // Reduce angle to a stable range, then evaluate a short series.
    x = x % (2 * 3.141592653589793);
    if (x > 3.141592653589793) x -= 2 * 3.141592653589793;
    if (x < -3.141592653589793) x += 2 * 3.141592653589793;

    final x2 = x * x;
    return x * (1 - x2 / 6 + x2 * x2 / 120 - x2 * x2 * x2 / 5040);
  }
}

class RecorderHome extends StatefulWidget {
  final String? prompt;
  final LocalNoteStore? noteStore;

  const RecorderHome({super.key, this.prompt, this.noteStore});

  @override
  State<RecorderHome> createState() => _RecorderHomeState();
}

class _RecorderHomeState extends State<RecorderHome> {
  final AudioRecorder _recorder = AudioRecorder();
  final TextEditingController _transcript = TextEditingController();
  late final LocalNoteStore _noteStore = widget.noteStore ?? LocalNoteStore();

  FlutterWhisper? _whisper;
  SpeechToText? _platformSpeech;
  Timer? _timer;
  int _seconds = 0;
  bool _recording = false;
  bool _busy = false;
  bool _loadingModel = false;
  bool? _modelSupported = true;
  String? _modelSupportMessage;
  double? _progress;
  String _language = 'Amharic';
  String _status = 'Ready when you are';
  String? _savedPath;
  String _platformTranscript = '';

  bool get _usesPlatformSpeechRecognition =>
      !kIsWeb &&
      defaultTargetPlatform == TargetPlatform.android &&
      _modelSupported == false;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      _modelSupported = null;
      unawaited(_checkAndroidWhisperSupport());
    }
  }

  Future<void> _checkAndroidWhisperSupport() async {
    try {
      final runtime = await const MethodChannel('com.senay.voice_notes/device')
          .invokeMapMethod<String, dynamic>('getAndroidRuntime');
      if (runtime == null) {
        throw const FormatException('Android runtime information is missing.');
      }
      final abi = runtime['abi'] as String? ?? '';
      final is64Bit = runtime['is64Bit'] as bool? ?? false;
      final supported = whisperSupportsAndroidRuntime(
        abi: abi,
        is64Bit: is64Bit,
      );
      if (!mounted) return;
      setState(() {
        _modelSupported = supported;
        _modelSupportMessage = supported
            ? null
            : unsupportedAndroidRuntimeMessage(abi, is64Bit: is64Bit);
        if (!supported) _status = _modelSupportMessage!;
      });
    } on MissingPluginException catch (error) {
      if (!mounted) return;
      setState(() {
        _modelSupported = false;
        _modelSupportMessage =
            'Could not verify Android compatibility: ${error.message ?? 'device information is unavailable'}';
        _status = _modelSupportMessage!;
      });
    } on PlatformException catch (error) {
      if (!mounted) return;
      setState(() {
        _modelSupported = false;
        _modelSupportMessage =
            'Could not verify Android compatibility: ${error.message ?? error.code}';
        _status = _modelSupportMessage!;
      });
    } on FormatException catch (error) {
      if (!mounted) return;
      setState(() {
        _modelSupported = false;
        _modelSupportMessage =
            'Could not verify Android compatibility: ${error.message}';
        _status = _modelSupportMessage!;
      });
    }
  }

  String get _time {
    final minutes = (_seconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Future<void> _startPlatformSpeechRecognition() async {
    final speech = _platformSpeech ??= SpeechToText();
    final initialized = await speech.initialize(
      onError: (error) {
        if (mounted) {
          setState(
            () => _status = 'Speech recognition error: ${error.errorMsg}',
          );
        }
      },
    );
    if (!initialized) {
      if (mounted) {
        setState(
          () => _status =
              'Online speech is unavailable on this device. '
              'Install or enable Google Speech Services, then try again.',
        );
      }
      return;
    }

    _platformTranscript = '';
    _transcript.clear();
    await speech.listen(
      listenOptions: SpeechListenOptions(
        localeId: _language == 'Amharic' ? 'am_ET' : 'en_US',
        partialResults: true,
        listenMode: ListenMode.dictation,
      ),
      onResult: (result) {
        _platformTranscript = result.recognizedWords;
        if (mounted) {
          setState(() => _transcript.text = _platformTranscript);
        }
      },
    );
    _seconds = 0;
    _savedPath = null;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _seconds++);
    });
    if (mounted) {
      setState(() {
        _recording = true;
        _status = 'Listening in $_language...';
      });
    }
  }

  Future<void> _startRecording() async {
    if (_busy || _recording) return;

    setState(() {
      _busy = true;
      _status = 'Requesting microphone access...';
    });

    try {
      if (!kIsWeb &&
          defaultTargetPlatform == TargetPlatform.android &&
          _modelSupported == null) {
        setState(
          () => _status = 'Checking this phone’s Whisper compatibility...',
        );
        return;
      }

      if (_usesPlatformSpeechRecognition) {
        await _startPlatformSpeechRecognition();
        return;
      }

      final permitted = await _recorder.hasPermission();

      if (!permitted) {
        setState(
          () => _status =
              'Allow microphone access in your device settings or browser.',
        );
        return;
      }

      String path;

      if (kIsWeb) {
        // The web recorder manages the audio file in the browser.
        path = 'voice_note_${DateTime.now().millisecondsSinceEpoch}';
      } else {
        final directory = await getApplicationDocumentsDirectory();
        path =
            '${directory.path}/voice_note_${DateTime.now().millisecondsSinceEpoch}.wav';
      }

      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 16000,
          numChannels: 1,
        ),
        path: path,
      );

      _seconds = 0;
      _savedPath = null;
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() => _seconds++);
      });

      setState(() {
        _recording = true;
        _status = 'Recording your voice...';
      });
    } catch (error) {
      setState(() => _status = 'Could not start recording: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _stopRecording() async {
    if (!_recording || _busy) return;

    setState(() {
      _busy = true;
      _status = 'Finishing recording...';
    });

    try {
      _timer?.cancel();
      if (_usesPlatformSpeechRecognition) {
        await _platformSpeech?.stop();
        setState(() {
          _recording = false;
          _status = _platformTranscript.trim().isEmpty
              ? 'No speech detected. Try recording again in a quiet place.'
              : 'Online speech recognition complete · $_language';
        });
        return;
      }
      final path = await _recorder.stop();

      setState(() {
        _recording = false;
        _savedPath = path;
        _status = path == null
            ? 'Recording stopped.'
            : 'Recording saved successfully.';
      });
    } catch (error) {
      setState(() => _status = 'Could not stop recording: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _transcribeRecording() async {
    final path = _savedPath;
    if (_busy || path == null) return;
    if (_modelSupported == null) {
      setState(
        () => _status = 'Checking this phone’s Whisper compatibility...',
      );
      return;
    }
    if (!_modelSupported!) {
      setState(() => _status = _modelSupportMessage!);
      return;
    }

    setState(() {
      _busy = true;
      _loadingModel = _whisper == null;
      _progress = 0;
      _status = _whisper == null
          ? 'Preparing the offline model (about 57 MiB on first use)...'
          : 'Transcribing in $_language...';
    });

    try {
      final whisper =
          _whisper ??
          await FlutterWhisper.loadModel(
            model: WhisperModels.baseQ5_1,
            config: const WhisperModelConfig(useGpu: false),
            onDownloadProgress: (progress) {
              if (!mounted) return;
              setState(() {
                _loadingModel = true;
                _progress = progress.fraction;
                _status =
                    'Downloading offline model · ${progress.percent}% '
                    '(${WhisperModels.baseQ5_1.sizeLabel})';
              });
            },
            onModelProgress: (progress) {
              if (!mounted) return;
              setState(() {
                _loadingModel = true;
                _progress = (progress / 100).clamp(0.0, 1.0);
                _status = 'Loading offline model...';
              });
            },
          );
      if (!mounted) {
        if (_whisper == null) await whisper.dispose();
        return;
      }
      _whisper = whisper;

      setState(() {
        _loadingModel = false;
        _progress = 0;
        _status = 'Transcribing in $_language...';
      });

      final result = await transcribeRecordedAudio(
        whisper: whisper,
        audioPath: path,
        language: _language,
        onProgress: (progress) {
          if (!mounted) return;
          setState(() {
            _progress = (progress / 100).clamp(0.0, 1.0);
          });
        },
      );
      if (!mounted) return;

      final text = result.text.trim();
      if (text.isEmpty) {
        setState(() {
          _progress = null;
          _status = 'No speech detected. Try recording again in a quiet place.';
        });
        return;
      }

      _transcript.text = text;
      setState(() {
        _progress = null;
        _status = 'Transcription complete · $_language';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _progress = null;
        _status = 'Transcription failed: $error';
      });
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _loadingModel = false;
        });
      }
    }
  }

  Future<void> _copyTranscript() async {
    final text = _transcript.text.trim();
    if (text.isEmpty) return;

    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Transcript copied')));
  }

  Future<void> _saveNote() async {
    final transcript = _transcript.text.trim();
    if (transcript.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add or transcribe text before saving.')),
      );
      return;
    }

    final firstLine = transcript.split('\n').first;
    final suggestedTitle = firstLine.length > 48
        ? firstLine.substring(0, 48)
        : firstLine;
    final formKey = GlobalKey<FormState>();
    String? title;
    title = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save this note'),
        content: Form(
          key: formKey,
          child: TextFormField(
            initialValue: suggestedTitle,
            autofocus: true,
            maxLength: 60,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(labelText: 'Note title'),
            validator: (value) =>
                value == null || value.trim().isEmpty ? 'Enter a title' : null,
            onSaved: (value) => title = value?.trim(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                formKey.currentState!.save();
                Navigator.pop(context, title);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    final noteTitle = title;
    if (noteTitle == null || !mounted) return;

    try {
      await _noteStore.saveNote(
        title: noteTitle,
        transcript: transcript,
        language: _language,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note saved on this device')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not save note: $error')));
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    unawaited(_platformSpeech?.stop());
    final whisper = _whisper;
    if (whisper != null) {
      whisper.cancel();
      unawaited(whisper.dispose());
    }
    _recorder.dispose();
    _transcript.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFAF9F4), bg, Color(0xFFEEF1E9)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(22, 22, 22, 34),
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        height: 46,
                        width: 46,
                        decoration: BoxDecoration(
                          color: mint.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: mint.withValues(alpha: 0.25),
                          ),
                        ),
                        child: const Icon(
                          Icons.graphic_eq_rounded,
                          color: mint,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Voice Notes',
                              style: TextStyle(
                                fontSize: 23,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.7,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              'VOICE NOTES',
                              style: TextStyle(
                                color: muted,
                                fontSize: 8,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Settings',
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => SettingsPage(
                                noteStore: _noteStore,
                                modelReady: _whisper != null,
                                modelSupported: _modelSupported,
                                modelSupportMessage: _modelSupportMessage,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.settings_outlined, color: muted),
                      ),
                      IconButton(
                        tooltip: 'Back to welcome',
                        constraints: const BoxConstraints.tightFor(
                          width: 40,
                          height: 40,
                        ),
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            PageRouteBuilder(
                              transitionDuration: const Duration(
                                milliseconds: 450,
                              ),
                              pageBuilder: (_, animation, secondaryAnimation) =>
                                  const WelcomePage(),
                              transitionsBuilder:
                                  (_, animation, secondaryAnimation, child) {
                                    return FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    );
                                  },
                            ),
                          );
                        },
                        icon: const Icon(Icons.home_outlined, color: muted),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Intro
                  const Text(
                    'Start with a thought.',
                    style: TextStyle(
                      fontSize: 29,
                      height: 1.15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    widget.prompt == null
                        ? 'Record it now. Sort it out later.'
                        : 'Try this idea: ${widget.prompt}',
                    style: TextStyle(color: muted, fontSize: 14),
                  ),

                  // Recording panel
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFFFFEFA),
                          Color(0xFFF9F8F3),
                          Color(0xFFF3F4ED),
                        ],
                      ),
                      border: Border.all(
                        color: _recording
                            ? mint.withValues(alpha: 0.45)
                            : const Color(0xFF252D27).withValues(alpha: 0.09),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: mint.withValues(
                            alpha: _recording ? 0.08 : 0.025,
                          ),
                          blurRadius: 35,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Text(
                              'VOICE NOTE',
                              style: TextStyle(
                                color: muted,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.8,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 7,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    (_recording
                                            ? const Color(0xFFC65D54)
                                            : mint)
                                        .withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.circle,
                                    size: 7,
                                    color: _recording
                                        ? const Color(0xFFC65D54)
                                        : mint,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    _recording ? 'RECORDING' : 'READY',
                                    style: TextStyle(
                                      fontSize: 9,
                                      letterSpacing: 1.1,
                                      fontWeight: FontWeight.bold,
                                      color: _recording
                                          ? const Color(0xFFC65D54)
                                          : mint,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Microphone illustration
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 350),
                          width: _recording ? 142 : 128,
                          height: _recording ? 142 : 128,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: mint.withValues(
                              alpha: _recording ? 0.13 : 0.07,
                            ),
                            border: Border.all(
                              color: mint.withValues(
                                alpha: _recording ? 0.7 : 0.28,
                              ),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: mint.withValues(
                                  alpha: _recording ? 0.15 : 0.04,
                                ),
                                blurRadius: 30,
                                spreadRadius: 3,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Container(
                              width: 94,
                              height: 94,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFFE5ECE4),
                                    Color(0xFFF6F6EF),
                                  ],
                                ),
                                border: Border.all(
                                  color: const Color(0xFF252D27)
                                      .withValues(alpha: 0.08),
                                ),
                              ),
                              child: Icon(
                                _recording
                                    ? Icons.graphic_eq_rounded
                                    : Icons.mic_none_rounded,
                                color: mint,
                                size: 48,
                              ),
                            ),
                          ),
                        ),

                        Text(
                          _recording
                              ? 'Your voice is being captured'
                              : 'Ready for your next idea?',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _recording
                              ? 'Speak naturally. Stop when you are done.'
                              : 'Find a quiet moment and start speaking.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: muted, fontSize: 12),
                        ),

                        const SizedBox(height: 28),

                        // Decorative waveform; updates while recording.
                        SizedBox(
                          height: 52,
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final barCount = (constraints.maxWidth / 7)
                                  .floor()
                                  .clamp(12, 35)
                                  .toInt();
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(barCount, (index) {
                                  const heights = [
                                    8,
                                    13,
                                    20,
                                    12,
                                    29,
                                    17,
                                    38,
                                    24,
                                    14,
                                    33,
                                    45,
                                    20,
                                    30,
                                    40,
                                    18,
                                    11,
                                    35,
                                    23,
                                    46,
                                    16,
                                    29,
                                    37,
                                    20,
                                    32,
                                    13,
                                    25,
                                    41,
                                    19,
                                    34,
                                    12,
                                    27,
                                    39,
                                    18,
                                    24,
                                    9,
                                  ];

                                  final height =
                                      heights[(index +
                                              (_recording
                                                  ? _seconds % 35
                                                  : 0)) %
                                          heights.length];

                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),
                                    width: 3,
                                    height: _recording
                                        ? height.toDouble()
                                        : height * 0.55,
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: mint.withValues(
                                        alpha: _recording ? 0.9 : 0.3,
                                      ),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  );
                                }),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 18),

                        Text(
                          _time,
                          style: const TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 5,
                          ),
                        ),
                        const SizedBox(height: 7),
                        const Text(
                          'RECORDING DURATION',
                          style: TextStyle(
                            color: muted,
                            fontSize: 9,
                            letterSpacing: 2,
                          ),
                        ),

                        const SizedBox(height: 25),

                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: FilledButton.icon(
                            onPressed: _busy
                                ? null
                                : (_recording
                                      ? _stopRecording
                                      : _startRecording),
                            style: FilledButton.styleFrom(
                              backgroundColor: _recording
                                  ? const Color(0xFFC65D54)
                                  : mint,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            icon: Icon(
                              _recording
                                  ? Icons.stop_rounded
                                  : Icons.fiber_manual_record_rounded,
                            ),
                            label: Text(
                              _busy
                                  ? 'Please wait...'
                                  : _recording
                                  ? 'Stop Recording'
                                  : 'Start Recording',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 15),

                        Text(
                          _status,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: muted, fontSize: 11),
                        ),

                        if (_savedPath != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: mint.withValues(alpha: 0.07),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.check_circle_outline,
                                  color: mint,
                                  size: 18,
                                ),
                                const SizedBox(width: 9),
                                const Expanded(
                                  child: Text(
                                    'Audio recording finished',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                                const Icon(
                                  Icons.audio_file_rounded,
                                  color: mint,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                          if (!_usesPlatformSpeechRecognition) ...[
                            const SizedBox(height: 14),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: FilledButton.icon(
                                onPressed: _busy || _modelSupported != true
                                    ? null
                                    : _transcribeRecording,
                                icon: Icon(
                                  _loadingModel
                                      ? Icons.downloading_rounded
                                      : Icons.graphic_eq_rounded,
                                ),
                                label: Text(
                                  _busy
                                      ? 'Please wait...'
                                      : 'Transcribe recording',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Text(
                            _usesPlatformSpeechRecognition
                                ? 'This phone uses its online speech-recognition service. '
                                      'Keep internet access on while you speak.'
                                : kIsWeb
                                ? 'The first model download needs internet '
                                      '(about 57 MiB). Audio stays in your browser.'
                                : 'First use downloads about 57 MiB. After that, '
                                      'audio is transcribed on this phone, offline.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: muted, fontSize: 10),
                          ),
                          if (_busy) ...[
                            const SizedBox(height: 12),
                            LinearProgressIndicator(value: _progress),
                          ],
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 27),

                  // Language picker
                  const Row(
                    children: [
                      Icon(Icons.translate_rounded, color: mint, size: 19),
                      SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          'Choose your language',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 13),
                  if (_language == 'Amharic') ...[
                    const Text(
                      'Amharic recognition quality can vary. Review and edit '
                      'the transcript after processing.',
                      style: TextStyle(color: muted, fontSize: 11, height: 1.4),
                    ),
                    const SizedBox(height: 12),
                  ],

                  Row(
                    children: [
                      Expanded(
                        child: LanguageOption(
                          flag: '🇪🇹',
                          title: 'አማርኛ',
                          subtitle: 'Amharic',
                          selected: _language == 'Amharic',
                          onTap: () => setState(() => _language = 'Amharic'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: LanguageOption(
                          flag: '🇬🇧',
                          title: 'English',
                          subtitle: 'English',
                          selected: _language == 'English',
                          onTap: () => setState(() => _language = 'English'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 29),

                  // Transcript editor
                  Row(
                    children: [
                      const Icon(Icons.notes_rounded, color: mint, size: 20),
                      const SizedBox(width: 9),
                      const Expanded(
                        child: Text(
                          'Your transcript',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Text(
                        _language,
                        style: const TextStyle(color: muted, fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 13),

                  Container(
                    padding: const EdgeInsets.fromLTRB(17, 16, 17, 10),
                    decoration: BoxDecoration(
                      color: panel,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: const Color(0xFF252D27).withValues(alpha: 0.08),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.auto_awesome_rounded,
                              color: mint,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'Your words, in text',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            IconButton(
                              tooltip: 'Clear text',
                              onPressed: _transcript.clear,
                              constraints: const BoxConstraints.tightFor(
                                width: 34,
                                height: 34,
                              ),
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                size: 19,
                                color: muted,
                              ),
                            ),
                            IconButton(
                              tooltip: 'Copy text',
                              onPressed: _transcript.text.trim().isEmpty
                                  ? null
                                  : _copyTranscript,
                              constraints: const BoxConstraints.tightFor(
                                width: 34,
                                height: 34,
                              ),
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                              icon: const Icon(
                                Icons.copy_rounded,
                                size: 18,
                                color: muted,
                              ),
                            ),
                          ],
                        ),
                        TextField(
                          controller: _transcript,
                          minLines: 4,
                          maxLines: 9,
                          decoration: const InputDecoration(
                            hintText:
                                'Your transcript will appear here after you '
                                'transcribe a recording. You can edit it anytime.',
                            hintStyle: TextStyle(
                              color: Color(0xFF75839B),
                              height: 1.6,
                              fontSize: 12,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                        const Divider(color: Color(0xFFE7E6DE)),
                        const Row(
                          children: [
                            Icon(
                              Icons.offline_bolt_rounded,
                              color: mint,
                              size: 16,
                            ),
                            SizedBox(width: 7),
                            Expanded(
                              child: Text(
                                'Designed for private, offline-first notes',
                                style: TextStyle(color: muted, fontSize: 10),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _saveNote,
                      icon: const Icon(Icons.bookmark_add_outlined),
                      label: const Text('Save as a note'),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Center(
                    child: Text(
                      'MADE FOR YOUR VOICE  •  AMHARIC + ENGLISH',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF657188),
                        fontSize: 9,
                        letterSpacing: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SectionHeading extends StatelessWidget {
  final String title;
  final IconData icon;

  const SectionHeading({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: mint),
        const SizedBox(width: 9),
        Text(
          title,
          style: const TextStyle(
            color: muted,
            fontSize: 10,
            letterSpacing: 1.6,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class LanguageOption extends StatelessWidget {
  final String flag;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const LanguageOption({
    super.key,
    required this.flag,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFFE9EDE5) : panel,
      borderRadius: BorderRadius.circular(19),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(19),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(19),
            border: Border.all(
              color: selected
                  ? mint.withValues(alpha: 0.65)
                  : const Color(0xFF252D27).withValues(alpha: 0.10),
            ),
          ),
          child: Row(
            children: [
              Text(flag, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(color: muted, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
