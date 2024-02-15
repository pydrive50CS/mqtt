import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'chat_messages_rm.dart';


class MessageBubbleView extends StatelessWidget {
  final List<ClientChatMessage> messages;
  final int revIndex;
  const MessageBubbleView({super.key, required this.messages, required this.revIndex});

  @override
  Widget build(BuildContext context) {
    final chatMessage = messages[revIndex].chatMessage;
    final isBySend = chatMessage.by == MessageBy.send;
    final isStatusMessage = chatMessage.type == ContentType.status;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      child: isStatusMessage
          ? Center(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.grey.shade300,
                ),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Text(isBySend ? "You're ${chatMessage.content.split(" ").last}" : chatMessage.content, style: const TextStyle(fontSize: 14)),
              ),
            )
          : Align(
              alignment: isBySend ? Alignment.topRight : Alignment.topLeft,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: isBySend ? const Radius.circular(20) : Radius.zero,
                    bottomRight: isBySend ? Radius.zero : const Radius.circular(20),
                    topRight: const Radius.circular(20),
                    bottomLeft: const Radius.circular(20),
                  ),
                  color: isBySend ? Colors.indigo[200] : Colors.grey.shade300,
                ),
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (chatMessage.type == ContentType.text) ...[
                      Text(chatMessage.content, style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 10),
                    ] else if (chatMessage.type == ContentType.audio) ...[
                      //ChatAudioPlayer(data: Uint8List.fromList(chatMessage.content.codeUnits)),
                      const SizedBox(height: 10),
                    ] else if (chatMessage.type == ContentType.photo) ...[
                      ClipRRect(
                        borderRadius: const BorderRadius.all(Radius.circular(16)),
                        child: Image.memory(Uint8List.fromList(chatMessage.content.codeUnits), height: 500),
                      ),
                      const SizedBox(height: 10),
                    ] else ...[
                      // TODO: Show Video Player Widget
                      //ChatVideoPlayer(data: chatMessage.content),
                      const SizedBox(height: 10),
                    ],
                    // Text(
                    //   "${DateFormat('dd MMM, hh:mm:ss a').format(chatMessage.datetime)} ✓",
                    //   style: const TextStyle(fontSize: 14, color: Colors.black54),
                    // ),
                  ],
                ),
              ),
            ),
    );
  }
}
