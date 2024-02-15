import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

import 'chat_messages_rm.dart';
import 'mqtt_chat_screen.dart';

class MqttManager {
  MqttClient? _mqttClient;
  final String host = "202.52.240.148";
  final int port = 5065;
  final String topicPrefix = "test/chat/";
  final String fromPersonId;
  final String fromPersonName;
  final String withPersonId;
  final String topic;
  final Function(MQTTConnectionType type) onMqttConnectionChanged;
  final Function(ClientChatMessage clientChatMessage, MessageBy by) onMqttMessageChanged;

  MqttManager(
      {required this.fromPersonId,
      required this.fromPersonName,
      required this.withPersonId,
      required this.topic,
      required this.onMqttConnectionChanged,
      required this.onMqttMessageChanged}) {
    initializeMQTTClient();
    connect();
  }

  void initializeMQTTClient() {
    _mqttClient = MqttServerClient(host, fromPersonId);
    _mqttClient!.port = port;
    _mqttClient!.keepAlivePeriod = 60000;
    //disconnected callback
    _mqttClient!.onDisconnected = onDisconnected;
    _mqttClient!.logging(on: kDebugMode);

    //connected callback
    _mqttClient!.onConnected = onConnected;
    _mqttClient!.onSubscribed = onSubscribed;

    //.withWillQos(MqttQos.exactlyOnce);
    final MqttConnectMessage connMessage = MqttConnectMessage()
        .withClientIdentifier(fromPersonId)
        .withWillTopic('withWillTopic') //if will topic is entered, then will message is a must
        .withWillMessage('withWillMessage')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    //log('Mosquito Client Connecting');
    _mqttClient!.connectionMessage = connMessage;
  }

  void connect() async {
    assert(_mqttClient != null);
    try {
      //log('client connection started.....');
      onMqttConnectionChanged(MQTTConnectionType.connecting);
      await _mqttClient!.connect();
    } on NoConnectionException catch (e) {
      // Raised by the client when connection fails.
      log('EXAMPLE::client exception - $e');
      disconnect();
    } on SocketException catch (e) {
      log('EXAMPLE::socket exception - $e');
      disconnect();
    }
  }

  static String generateMqttPeerUniqueTopic(String id1, String id2) {
    BigInt bigInt1 = BigInt.parse(id1, radix: 36);
    BigInt bigInt2 = BigInt.parse(id2, radix: 36);
    BigInt result = bigInt1 + bigInt2;
    String generatedUniqueTopic = result.toRadixString(36);
    log('Utility Function generateMqttPeerUniqueTopic: id1: $id1 id2: $id2 Generated Unique Topic: $generatedUniqueTopic');
    return generatedUniqueTopic;
  }

  void onDisconnected() {
    log('Example : OnDisconnect Client callback =====> Client disconnected');
    onMqttConnectionChanged(MQTTConnectionType.disconnected);
    // sendMessage("DISCONNECTED");
  }

  void publish(String message) async {
    try {
      // connect();
      final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
      builder.addString(message);
      _mqttClient!.publishMessage(topicPrefix + topic, MqttQos.exactlyOnce, builder.payload!);
    } catch (e) {
      log('exceptio : $e');
    }
  }

  void onSubscribed(String topic) {
    // sendMessage("SUBSCRIBED - $topic");
    log('subscription confirmed for $topic');
  }

  void onConnected() {
    onMqttConnectionChanged(MQTTConnectionType.connected);
    _mqttClient!.subscribe(topicPrefix + topic, MqttQos.exactlyOnce);
    _mqttClient!.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      try {
        final recMessage = c[0].payload as MqttPublishMessage;
        final String pt = MqttPublishPayload.bytesToStringAsString(recMessage.payload.message);
        var clientChatMessage = ClientChatMessage.fromJson(jsonDecode(pt));
        bool isMyMessage = clientChatMessage.fromClientId == fromPersonId;
        bool isChatWithMe = clientChatMessage.withClientId.trim() == fromPersonId;
        if (!isMyMessage && isChatWithMe) {
          clientChatMessage.chatMessage.by = MessageBy.received;
          onMqttMessageChanged(clientChatMessage, MessageBy.received);
        }
      } catch (e) {
        log('MQTT Bad Message Received Exception: $e');
      }
    });
    sendStatus("$fromPersonName Connected."); // ✅
  }

  Future<void> disconnect() async {
    sendStatus("$fromPersonName Disconnected."); // ❌
    await Future.delayed(const Duration(milliseconds: 200), () {
      _mqttClient!.disconnect();
    });
  }

  // ===========================|  Chat Features |===============================

  void sendStatus(String statusText) {
    var clientChatMessage = ClientChatMessage(
      fromClientId: fromPersonId,
      withClientId: withPersonId,
      chatMessage: ChatMessage(content: statusText, type: ContentType.status, by: MessageBy.send, datetime: DateTime.now()),
    );
    onMqttMessageChanged(clientChatMessage, MessageBy.send);
    publish(jsonEncode(clientChatMessage.toJson()));
  }

  void sendMessage(String plainText) {
    var clientChatMessage = ClientChatMessage(
      fromClientId: fromPersonId,
      withClientId: withPersonId,
      chatMessage: ChatMessage(content: plainText, type: ContentType.text, by: MessageBy.send, datetime: DateTime.now()),
    );
    onMqttMessageChanged(clientChatMessage, MessageBy.send);
    publish(jsonEncode(clientChatMessage.toJson()));
  }

  void sendAudio(String audioBytes) {
    var clientChatMessage = ClientChatMessage(
      fromClientId: fromPersonId,
      withClientId: withPersonId,
      chatMessage: ChatMessage(content: audioBytes, type: ContentType.audio, by: MessageBy.send, datetime: DateTime.now()),
    );
    onMqttMessageChanged(clientChatMessage, MessageBy.send);
    publish(jsonEncode(clientChatMessage.toJson()));
  }

  void sendPhoto(String photoBytes) {
    var clientChatMessage = ClientChatMessage(
      fromClientId: fromPersonId,
      withClientId: withPersonId,
      chatMessage: ChatMessage(content: photoBytes, type: ContentType.photo, by: MessageBy.send, datetime: DateTime.now()),
    );
    onMqttMessageChanged(clientChatMessage, MessageBy.send);
    publish(jsonEncode(clientChatMessage.toJson()));
  }

  void sendVideo(String videoBytes) {
    var clientChatMessage = ClientChatMessage(
      fromClientId: fromPersonId,
      withClientId: withPersonId,
      chatMessage: ChatMessage(content: videoBytes, type: ContentType.video, by: MessageBy.send, datetime: DateTime.now()),
    );
    onMqttMessageChanged(clientChatMessage, MessageBy.send);
    publish(jsonEncode(clientChatMessage.toJson()));
  }
}
