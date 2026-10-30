import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_whisper_ggml/flutter_whisper.dart';

import 'notes.dart';

const _settingsMint = Color(0xFF47765E);
const _settingsBackground = Color(0xFFF5F3EC);
const _settingsPanel = Color(0xFFFFFEFA);
const _settingsMuted = Color(0xFF737A70);

class SettingsPage extends StatelessWidget {
  const SettingsPage({
    super.key,
    required this.noteStore,
    required this.modelReady,
    required this.modelSupported,
    required this.modelSupportMessage,
  });

  final LocalNoteStore noteStore;
  final bool modelReady;
  final bool? modelSupported;
  final String? modelSupportMessage;

  @override
  Widget build(BuildContext context) {
    final model = WhisperModels.baseQ5_1;
    return Scaffold(
      backgroundColor: _settingsBackground,
      appBar: AppBar(
        backgroundColor: _settingsBackground,
        title: const Text('Settings'),
        actions: [
          IconButton(
            tooltip: 'Saved notes',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => SavedNotesPage(store: noteStore),
                ),
              );
            },
            icon: const Icon(Icons.bookmarks_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          const _SettingsHeading(
            icon: Icons.memory_rounded,
            title: 'Transcription model',
          ),
          const SizedBox(height: 12),
          _SettingsCard(
            children: [
              _SettingRow(
                title: 'Model',
                value: 'Whisper ${model.id}',
                detail: 'Multilingual · Amharic and English',
              ),
              const Divider(height: 25),
              _SettingRow(
                title: 'Download size',
                value: model.sizeLabel,
                detail: 'Internet is needed for the first model download.',
              ),
              const Divider(height: 25),
              _SettingRow(
                title: 'Current session',
                value: modelSupported == null
                    ? 'Checking compatibility...'
                    : !modelSupported!
                    ? 'Not supported on this phone'
                    : modelReady
                    ? 'Loaded and ready'
                    : 'Not loaded yet',
                detail:
                    modelSupportMessage ??
                    (modelReady
                        ? 'The model is loaded in memory and ready to transcribe.'
                        : 'The model loads when you transcribe. The plugin may '
                              'reuse a downloaded copy on this device.'),
                icon: modelSupported == false
                    ? Icons.error_outline_rounded
                    : modelReady
                    ? Icons.check_circle_outline_rounded
                    : Icons.info_outline_rounded,
                iconColor: modelSupported == false
                    ? Colors.red.shade700
                    : modelReady
                    ? _settingsMint
                    : _settingsMuted,
              ),
              if (!kIsWeb) ...[
                const Divider(height: 25),
                _SettingRow(
                  title: 'On-device privacy',
                  value: modelSupported == false
                      ? 'Recordings stay on this device'
                      : 'Audio is processed on this device',
                  detail: modelSupported == false
                      ? 'This phone cannot run the bundled Whisper engine, so '
                            'recordings cannot be transcribed here. Voice Notes '
                            'does not upload them to a cloud service.'
                      : 'After the model is available, transcription is '
                            'designed to work offline. Voice Notes does not '
                            'send recordings to a cloud transcription service.',
                ),
              ] else ...[
                const Divider(height: 25),
                const _SettingRow(
                  title: 'Browser note',
                  value: 'Model loading may use the internet',
                  detail:
                      'Web model and recording behavior can differ from '
                      'Android. Confirm offline behavior on your target phone.',
                ),
              ],
            ],
          ),
          const SizedBox(height: 28),
          const _SettingsHeading(
            icon: Icons.folder_open_rounded,
            title: 'Your notes',
          ),
          const SizedBox(height: 12),
          _SettingsCard(
            children: [
              FutureBuilder<List<VoiceNote>>(
                future: noteStore.listNotes(),
                builder: (context, snapshot) {
                  final count = snapshot.data?.length;
                  return _SettingRow(
                    title: 'Saved notes',
                    value: snapshot.hasError
                        ? 'Could not load note count'
                        : count == null
                        ? 'Loading...'
                        : '$count ${count == 1 ? 'note' : 'notes'} on this device',
                    detail: 'Notes stay in this app’s local storage.',
                  );
                },
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => SavedNotesPage(store: noteStore),
                      ),
                    );
                  },
                  icon: const Icon(Icons.bookmarks_outlined),
                  label: const Text('Open saved notes'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          const Text(
            'Amharic recognition quality can vary. Review and edit the '
            'transcript before saving.',
            style: TextStyle(color: _settingsMuted, height: 1.5, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _SettingsHeading extends StatelessWidget {
  const _SettingsHeading({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 19, color: _settingsMint),
      const SizedBox(width: 9),
      Expanded(
        child: Text(
          title,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
        ),
      ),
    ],
  );
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(17),
    decoration: BoxDecoration(
      color: _settingsPanel,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: _settingsMint.withValues(alpha: 0.1)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    ),
  );
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.title,
    required this.value,
    required this.detail,
    this.icon,
    this.iconColor,
  });

  final String title;
  final String value;
  final String detail;
  final IconData? icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (icon != null) ...[
        Icon(icon, size: 19, color: iconColor ?? _settingsMuted),
        const SizedBox(width: 9),
      ],
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(color: _settingsMuted, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 3),
            Text(
              detail,
              style: const TextStyle(
                color: _settingsMuted,
                fontSize: 11,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
