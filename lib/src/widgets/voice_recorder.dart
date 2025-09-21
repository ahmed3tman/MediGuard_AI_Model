import 'dart:async';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';


/// A simple voice recorder widget.
/// - Handles microphone permission on both Android and iOS.
/// - Records audio to a temporary file and returns the file path via `onRecorded`.
class VoiceRecorder extends StatefulWidget {
  /// Called when a recording is completed with the recorded file path.
  final ValueChanged<String> onRecorded;
  const VoiceRecorder({super.key, required this.onRecorded});

  @override
  State<VoiceRecorder> createState() => _VoiceRecorderState();
}

class _VoiceRecorderState extends State<VoiceRecorder> {
  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecording = false;
  String? _filePath;

  @override
  void dispose() {
    // Stop and dispose recorder; fire-and-forget since dispose cannot be async.
    if (_isRecording) {
      _recorder.stop();
    }
    _recorder.dispose();
    super.dispose();
  }

  Future<bool> _requestPermission() async {
    // Prefer using the package's hasPermission helper, fallback to permission_handler
    try {
      final granted = await _recorder.hasPermission();
      return granted;
    } catch (_) {
      final status = await Permission.microphone.request();
      return status.isGranted;
    }
  }

  Future<void> _start() async {
    final granted = await _requestPermission();
    if (!granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Microphone permission is required.')),
      );
      return;
    }

    final dir = await getTemporaryDirectory();
    final filePath =
        '${dir.path}/rec_${DateTime.now().millisecondsSinceEpoch}.m4a';

    const encoder = AudioEncoder.aacLc;
    final config = const RecordConfig(encoder: encoder, numChannels: 1);

    try {
      if (!await _recorder.isEncoderSupported(encoder)) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Encoder not supported on this device.'),
          ),
        );
        return;
      }

      await _recorder.start(config, path: filePath);

      if (!mounted) return;
      setState(() {
        _isRecording = true;
        _filePath = filePath;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to start recording: $e')));
    }
  }

  Future<void> _stop() async {
    if (!await _recorder.isRecording()) return;
    final path = await _recorder.stop();

    if (!mounted) return;
    setState(() {
      _isRecording = false;
    });

    if (path != null) {
      setState(() => _filePath = path);
      widget.onRecorded(path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          key: const Key('recordButton'),
          onPressed: _isRecording ? _stop : _start,
          icon: Icon(_isRecording ? Icons.stop : Icons.mic),
          color: _isRecording ? Colors.red : null,
        ),
        if (_filePath != null && !_isRecording)
          IconButton(
            key: const Key('playButton'),
            onPressed: () async {
              // Optional: implement playback later if needed.
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Recorded file: $_filePath')),
              );
            },
            icon: const Icon(Icons.play_arrow),
          ),
      ],
    );
  }
}
