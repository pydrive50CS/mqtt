import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:permission_handler/permission_handler.dart';

class RecordButton extends StatefulWidget {
  final VoidCallback onStartRecording;
  final ValueChanged<File> onSendRecording;
  final VoidCallback onCancelRecording;

  const RecordButton({required this.onStartRecording, required this.onSendRecording, required this.onCancelRecording, super.key});

  @override
  _RecordButtonState createState() => _RecordButtonState();
}

class _RecordButtonState extends State<RecordButton> {
  static const int MIN_RECORDING_DURATION = 30000; // minimum recording duration in milliseconds
  bool _isRecording = false;
  bool _isSendButtonVisible = false;
  late Timer _timer;
  int _countDown = 0;
  final double _buttonXPosition = 0;
  final recorder = FlutterSoundRecorder();
  bool isRecorderReady = false;
  final audioPlayer = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;

  Future initRecorder() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw 'Permission not granted';
    }
    await recorder.openRecorder();
    recorder.setSubscriptionDuration(const Duration(milliseconds: 500));
  }

  @override
  void initState() {
    super.initState();
    initRecorder();
  }

  @override
  void dispose() {
    recorder.closeRecorder();
    super.dispose();
  }

  Future<void> _startRecording() async {
    // Add this check is prev rec stopped or not
    if (recorder.isStopped) {
      await recorder.startRecorder(toFile: "audio");
      setState(() {
        _isRecording = true;
        _isSendButtonVisible = false;
      });

      // start recording audio here
      widget.onStartRecording();

      _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        setState(() {
          _countDown += 100;
        });
        if (_countDown >= MIN_RECORDING_DURATION) {
          setState(() {
            _isSendButtonVisible = true;
          });
          timer.cancel();
        }
      });
    } else {
      recorder.stopRecorder();
    }
  }

  Future _stopRecording() async {
    _timer.cancel();
    _countDown = 0;
    setState(() {
      _isRecording = false;
    });
    final filePath = await recorder.stopRecorder();
    widget.onSendRecording(File(filePath!));
  }

  void _cancelRecording() {
    _timer.cancel();
    _countDown = 0;
    setState(() {
      _isRecording = false;
    });
    widget.onCancelRecording();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        _startRecording();
      },
      onTapUp: (_) {
        if (_isRecording) {
          _stopRecording();
        }
      },
      onTapCancel: () {
        if (_isRecording) {
          _cancelRecording();
        }
      },
      child: SizedBox(
        width: _isRecording ? MediaQuery.of(context).size.width - 48 : 48.0,
        //height: _isRecording ? 48.0 : 48.0,
        child: _isRecording
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 200,
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(25),
                      color: Colors.indigo.shade100,
                    ),
                    child: Text(
                      '${(_countDown / 1000).toStringAsFixed(1)} sec << Slide to cancel',
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: const TextStyle(fontSize: 16.0),
                    ),
                  ),
                  FloatingActionButton.small(
                    heroTag: "mqtt_chat_send_voice_button",
                    onPressed: () {},
                    // backgroundColor: KHColor.primaryColor,
                    elevation: 0,
                    child: const Icon(
                      Icons.send,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              )
            : FloatingActionButton.small(
                heroTag: "mqtt_chat_record_voice_button",
                onPressed: () {},
                // backgroundColor: KHColor.primaryColor,
                elevation: 0,
                child: const Icon(
                  Icons.mic,
                  color: Colors.white,
                  size: 20,
                ),
              ),
      ),
    );
  }
}
