
import 'package:flutter/material.dart';
import 'package:mqtt_chat_app/mqtt_manager.dart';

import 'mqtt_chat_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late String me;
  late String remote;
  late String topic;


  @override
  void initState(){
    me = "Me";
    remote = "Remote";
    topic = MqttManager.generateMqttPeerUniqueTopic(me, remote);
    print('.....................................');
    print('unique topic id:$topic, meid:$me, and toid:$remote');

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MqttChatScreen(topicId: topic, fromName: me,toName: remote,)
    );
  }
}
