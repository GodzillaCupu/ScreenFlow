import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../core/constants/app_constants.dart';

/// Wraps the `record` plugin for local, offline microphone capture.
/// Files are written under <appDocs>/recordings/<scriptUuid>/.
class AudioRecorderService {
  final AudioRecorder _recorder = AudioRecorder();

  Future<bool> hasPermission() => _recorder.hasPermission();

  Future<bool> get isRecording => _recorder.isRecording();

  /// Amplitude stream for a live VU-meter / waveform while recording.
  Stream<Amplitude> amplitudeStream() => _recorder.onAmplitudeChanged(
        const Duration(milliseconds: 120),
      );

  /// Starts recording and returns the absolute output path.
  Future<String> start(String scriptUuid) async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(
      p.join(docs.path, AppConstants.recordingsDir, scriptUuid),
    );
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    final path = p.join(
      dir.path,
      'take_${DateTime.now().millisecondsSinceEpoch}.m4a',
    );
    await _recorder.start(
      const RecordConfig(encoder: AudioEncoder.aacLc, bitRate: 128000),
      path: path,
    );
    return path;
  }

  /// Stops recording and returns the finalized file path (or null if none).
  Future<String?> stop() => _recorder.stop();

  Future<void> pause() => _recorder.pause();
  Future<void> resume() => _recorder.resume();

  Future<void> dispose() => _recorder.dispose();
}
