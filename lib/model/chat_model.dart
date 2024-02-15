class Chats {
  int? _id;
  String? _topic;
  String? _sender;
  String? _receiver;
  String? _message;
  String? _date;


  Chats(this._id, this._topic, this._sender, this._receiver, this._message,
      this._date);

  // Chats.withTopic(this._id, this._sender, this._receiver, this._message,
  //     this._date, [this._topic]);

  //instantiate an empty map object using toMap fn
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};
    map["id"] = _id;
    map["topic"] = _topic;
    map["sender"] = _sender;
    map["receiver"] = _receiver;
    map["message"] = _message;
    map["date"] = _date;
    return map;
  }

//Using named constructor creating simple objects fromMap during retrieve uses fromMap property
  Chats.fromMapObjects(Map<String, dynamic> map){
    _id = map['id'];
    _topic = map['topic'];
    _sender = map['sender'];
    _receiver = map['receiver'];
    _message = map['message'];
    _date = map['date'];
  }


}
