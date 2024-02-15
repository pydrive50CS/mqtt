

class ChatMessagesRM {
  final bool success;
  final String message;
  final ChatMessagesData data;

  ChatMessagesRM({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ChatMessagesRM.fromJson(Map<String, dynamic> json) {
    return ChatMessagesRM(
      success: json['success'],
      message: json['message'],
      data: ChatMessagesData.fromJson(json['data']),
    );
  }
}

class ChatMessagesData {
  final List<ChatMessage> chatMessages;

  ChatMessagesData({
    required this.chatMessages,
  });

  factory ChatMessagesData.fromJson(Map<String, dynamic> json) {
    return ChatMessagesData(
      chatMessages: (json['chatMessages'] as List<dynamic>)
          .map((message) => ChatMessage.fromJson(message))
          .toList(),
    );
  }
}

class ChatMessage {
  String content;
  ContentType type;
  MessageBy by;
  DateTime datetime;

  ChatMessage({
    required this.content,
    required this.type,
    required this.by,
    required this.datetime,
    //required bool isSend,
    //required bool isRead
  });

  ChatMessage.fromJson(Map<String, dynamic> json)
      : content = json['content'],
        type = ContentType.values[json['type'] as int],
        by = MessageBy.values[json['by'] as int],
        datetime = DateTime.parse(json['datetime']);

  Map<String, dynamic> toJson() => {
        'content': content,
        'type': type.index,
        'by': by.index,
        'datetime': datetime.toIso8601String(),
      };
}

enum ContentType { status, text, audio, video, photo }

enum MessageBy { send, received }

/// Client Chat Message

class ClientChatMessage {
  String fromClientId;
  String withClientId;
  ChatMessage chatMessage;

  ClientChatMessage({required this.fromClientId, required this.withClientId, required this.chatMessage});

  ClientChatMessage.fromJson(Map<String, dynamic> json)
      : fromClientId = json['fromClientId'],
        withClientId = json['withClientId'],
        chatMessage = ChatMessage.fromJson(json['chatMessage']);

  Map<String, dynamic> toJson() => {
        'fromClientId': fromClientId,
        'withClientId': withClientId,
        'chatMessage': chatMessage.toJson(),
      };
}

/*
{
  "fromClientId": "1234",
  "withClientId": "mine",
  "chatMessage": {
    "content" : "Content",
    "type" : 0,
    "by" : 1,
    "datetime": "2024-02-06"
  }
}
*/
