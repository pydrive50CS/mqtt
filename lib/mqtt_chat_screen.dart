import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mqtt_chat_app/person_top_app_bar.dart';
import 'package:mqtt_chat_app/record_button.dart';
import 'package:mqtt_chat_app/reusable_button.dart';
// import 'package:image_picker/image_picker.dart';
import 'chat_messages_rm.dart';
import 'live_data.dart';
import 'message_bubble_view.dart';
import 'mqtt_manager.dart';

enum MQTTConnectionType { connecting, connected, disconnected }

class MqttChatScreen extends StatefulWidget {
  final String topicId;
  final String fromName;
  final String toName;

  const MqttChatScreen({super.key, required this.topicId, required this.fromName, required this.toName});

  @override
  State<MqttChatScreen> createState() => _MqttChatScreenState();
}

class _MqttChatScreenState extends State<MqttChatScreen> {
  late final _mqttConnectionLive = Live<MQTTConnectionType>(MQTTConnectionType.disconnected);
  late final _mqttMessagesLive = Live<List<ClientChatMessage>>([]);
  final TextEditingController _messageInputCtrl = TextEditingController();
  late final MqttManager _mqttManager;
  late final String fromPersonName, fromPersonId;
  late final String withPersonName, withPersonId;
  bool _isVoiceRecording = false;
  bool _isTextMessageComposing = false;
  bool isInitialized = false;
  late final String topic;

  @override
  void initState() {
    initMqtt();
    super.initState();
  }

  void initMqtt() {
    log('inside initviewModel: ${widget.topicId}');
    fromPersonName = widget.fromName.trim();
    fromPersonId = widget.fromName.trim();
    withPersonName = widget.toName.trim();
    withPersonId = widget.toName.trim();
    topic = widget.topicId;
    log('subscribed topic is ${widget.topicId}');
    if (!isInitialized) {
      // viewModel, fromPersonId, withPersonId, topic
      _mqttManager = MqttManager(
          fromPersonId: fromPersonId,
          fromPersonName: fromPersonName,
          withPersonId: withPersonId,
          topic: topic,
          onMqttConnectionChanged: (type) {
            _mqttConnectionLive.value = type;
          },
          onMqttMessageChanged: (clientChatMessage, by) {
            setState(() {
              _mqttMessagesLive.value.add(clientChatMessage);
            });
          });
      isInitialized = true;
    }
  }

  Future<void> capturePhotoFromCameraAndSend() async {
    // final ImagePicker picker = ImagePicker();
    // final XFile? photo = await picker.pickImage(source: ImageSource.camera, preferredCameraDevice: CameraDevice.front, imageQuality: 50);
    // if (photo != null) {
    //   File photoFile = File(photo.path);
    //   Uint8List imageBytes = photoFile.readAsBytesSync();
    //   final stringBytes = String.fromCharCodes(imageBytes);
    //   _mqttManager.sendPhoto(stringBytes);
    // }
  }

  // Future<void> recordVideoFromCameraAndSend() async {
  //   final ImagePicker picker = ImagePicker();
  //   final XFile? video = await picker.pickVideo(
  //     source: ImageSource.camera,
  //     preferredCameraDevice: CameraDevice.front,
  //     maxDuration: const Duration(seconds: 15),
  //   );
  //   if (video != null) {
  //     File videoFile = File(video.path);
  //     Uint8List videoBytes = videoFile.readAsBytesSync();
  //     final stringBytes = String.fromCharCodes(videoBytes);
  //     _mqttManager.sendVideo(stringBytes);
  //   }
  // }

  Future<void> recordVideoFromCameraAndSend() async {
    // final ImagePicker picker = ImagePicker();
    // final XFile? video = await picker.pickVideo(
    //   source: ImageSource.camera,
    //   preferredCameraDevice: CameraDevice.front,
    //   maxDuration: const Duration(seconds: 10),
    // );
    // if (video != null) {
    //   File videoFile = File(video.path);
    //   var bytes = await videoFile.readAsBytes();
    //   await videoFile.delete();
    //   _mqttManager.sendVideo(base64Encode(bytes));
    // }
  }

  @override
  void dispose() {
    _messageInputCtrl.dispose();
    _mqttConnectionLive.dispose();
    _mqttMessagesLive.dispose();
    _isVoiceRecording = false;
    _isTextMessageComposing = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        showExitDialog();
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFEEEEEE),
        appBar: PersonTopAppBar(
          // title: 'MQTT Chat App',
          personImageUrl: "https://cdn-icons-png.flaticon.com/128/3177/3177440.png",
          personName: withPersonName,
          personId: "Test User",
          mqttConnectionTypeLive: _mqttConnectionLive,
          onBackButtonPressed: () {
            showExitDialog();
            // Navigator.pop(context);
          },
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: _mqttMessagesLive.listen((messages) => ListView.builder(
                    itemCount: messages.length,
                    shrinkWrap: true,
                    padding: const EdgeInsets.only(top: 8, bottom: 8),
                    reverse: true,
                    scrollDirection: Axis.vertical,
                    itemBuilder: (context, index) {
                      var revIndex = (messages.length - 1) - index;
                      return MessageBubbleView(messages: messages, revIndex: revIndex);
                    },
                  )),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.only(left: 10, bottom: 5, top: 5, right: 10),
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: const BorderRadius.all(Radius.circular(48)),
                    border: Border.all(
                        ////color: KHColor.primaryColor,
                        width: 1)),
                child: Row(
                  children: <Widget>[
                    _isVoiceRecording
                        ? const SizedBox()
                        : Expanded(
                            child: TextField(
                              controller: _messageInputCtrl,
                              autocorrect: false,
                              autofocus: false,
                              maxLines: 5,
                              minLines: 1,
                              onChanged: (text) {
                                if (text.isNotEmpty && _isTextMessageComposing == false) {
                                  setState(() {
                                    _isTextMessageComposing = text.isNotEmpty;
                                  });
                                } else if (text.isEmpty && _isTextMessageComposing == true) {
                                  setState(() {
                                    _isTextMessageComposing = text.isNotEmpty;
                                  });
                                }
                              },
                              decoration: const InputDecoration(
                                hintText: "Write message...",
                                hintStyle: TextStyle(color: Colors.black54),
                                border: InputBorder.none,
                              ),
                              keyboardType: TextInputType.multiline,
                              textInputAction: TextInputAction.newline,
                            ),
                          ),
                    /*_isTextMessageComposing || _isVoiceRecording
                        ? const SizedBox()
                        : FloatingActionButton(
                            onPressed: () {
                              // Video Record & Send
                              recordVideoFromCameraAndSend();
                              //viewModel = Provider.of<MqttViewModel>(context);
                              //_mqttManager = MqttManager(viewModel, personId);
                            },
                            backgroundColor: Colors.blue,
                            elevation: 0,
                            child: const Icon(
                              Icons.videocam,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),*/
                    const SizedBox(width: 5),
                    _isTextMessageComposing || _isVoiceRecording
                        ? const SizedBox()
                        : FloatingActionButton.small(
                            onPressed: () {
                              // Capture photo using camera and send to mqtt
                              capturePhotoFromCameraAndSend();
                            },
                            ////backgroundColor: KHColor.primaryColor,
                            elevation: 0,
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                    const SizedBox(width: 5),
                    _isTextMessageComposing
                        ? const SizedBox()
                        : RecordButton(onStartRecording: () {
                            setState(() {
                              _isVoiceRecording = true;
                              _isTextMessageComposing = false;
                            });
                          }, onSendRecording: (audioFile) {
                            setState(() {
                              _isVoiceRecording = false;
                              _isTextMessageComposing = false;
                            });
                            Fluttertoast.showToast(msg: "Recorded file path\n $audioFile", toastLength: Toast.LENGTH_SHORT);
                            Uint8List audioBytes = audioFile.readAsBytesSync();
                            final stringBytes = String.fromCharCodes(audioBytes);
                            _mqttManager.sendAudio(stringBytes);
                            initState();
                          }, onCancelRecording: () {
                            setState(() {
                              _isVoiceRecording = false;
                              _isTextMessageComposing = false;
                            });
                          }),
                    _isVoiceRecording || !_isTextMessageComposing
                        ? const SizedBox()
                        : FloatingActionButton.small(
                            onPressed: () {
                              // Send Text Message
                              if (_messageInputCtrl.text.isNotEmpty) {
                                String tempText = _messageInputCtrl.text;
                                _messageInputCtrl.clear();
                                _mqttManager.sendMessage(tempText);
                                setState(() {
                                  _isTextMessageComposing = false;
                                  _isVoiceRecording = false;
                                });
                              }
                            },
                            ////backgroundColor: KHColor.primaryColor,
                            elevation: 0,
                            child: const Icon(
                              Icons.send,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> showExitDialog() async {
    final bool result = await showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Exit Chat",
                  ),
                  // SizedBox(height: SizeUtils.kTopHeight),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ReusableButton(
                          text: "OK",
                          onPressed: () async {
                            await _mqttManager.disconnect();
                            _mqttMessagesLive.value.clear();
                            if (context.mounted) {
                              Navigator.of(context).pop(true);
                            }
                          }),
                      const SizedBox(
                        width: 20,
                      ),
                      ReusableButton(text: "Cancel", onPressed: () => Navigator.of(context).pop(false))
                    ],
                  ),
                ],
              ),
            ));

    if (result) {
      if (context.mounted) {
        // context.pushReplacement(const DashboardScreen());
      }
    }
  }
}
