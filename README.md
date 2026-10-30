# Voice Notes

Voice Notes records speech and transcribes it locally with a multilingual
Whisper model. Select Amharic or English, record a clip, and choose
**Transcribe recording**. The first transcription downloads the model (about
57 MiB); after it is cached, Android transcription is designed to work offline.

Transcripts can be edited in the recorder and saved as titled notes. Open
**Saved notes** to reopen, rename, edit, or delete notes. Saved note text and
metadata are stored on-device with platform preferences (browser local storage
on Chrome); recorded audio is not currently retained as part of a saved note.
Open **Settings** from the recorder’s gear button to view the Whisper model,
the current-session load state, offline/privacy information, and saved notes.

## Development

```shell
flutter pub get
flutter test
flutter analyze
flutter run
```

Android is the primary target. Chrome is available for UI development, but its
recording, model loading, and transcription behavior can differ from Android.
On 64-bit ARM and x86 Android, the app uses the bundled Whisper model offline.
On 32-bit Android, where that native Whisper library is not available, the app
uses the device's Android speech-recognition service so recording and Amharic
dictation still work. That fallback may require internet access and its
accuracy depends on the speech service installed on the phone.

For a normal Android release, build an App Bundle so Google Play only delivers
the native ABI needed by each phone:

```shell
flutter build appbundle --release
```

For direct APK distribution, use ABI splits instead of the universal APK:

```shell
flutter build apk --release --split-per-abi
```

Release builds enable code and resource shrinking. The debug APK is intended
for development and is substantially larger.
