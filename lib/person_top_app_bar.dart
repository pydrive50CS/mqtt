import 'package:flutter/material.dart';

import 'live_data.dart';
import 'mqtt_chat_screen.dart';

class PersonTopAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String personImageUrl, personName, personId;
  final Live<MQTTConnectionType> mqttConnectionTypeLive;
  final VoidCallback onBackButtonPressed;

  const PersonTopAppBar({
    super.key,
    required this.personName,
    required this.personId,
    required this.onBackButtonPressed,
    required this.personImageUrl,
    required this.mqttConnectionTypeLive,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      // backgroundColor: context.colorScheme.background,
      elevation: 2,
      leading: const SizedBox(width: 0),
      leadingWidth: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.exit_to_app_sharp),
          onPressed: onBackButtonPressed,
        )
      ],
      title: Row(
        children: [
          SizedBox(
            height: kToolbarHeight * 0.7,
            child: CircleAvatar(
              backgroundImage: const AssetImage("assets/images/kataho_icon_small.png"), //NetworkImage(personImageUrl),
              child: Align(
                alignment: Alignment.bottomRight,
                child: mqttConnectionTypeLive.listen((mqttConnectionType) => Container(
                      height: 12,
                      width: 12,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: getColorByMqttConnectionState(mqttConnectionType),
                          border: Border.all(
                            color: Colors.white,
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 1,
                              blurRadius: 2,
                              offset: const Offset(1, 1),
                            ),
                          ]),
                    )),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                personName,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500, overflow: TextOverflow.ellipsis),
              ),
              Text(
                personId,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w300, overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  Color getColorByMqttConnectionState(MQTTConnectionType mqttConnectionType) {
    switch (mqttConnectionType) {
      case MQTTConnectionType.connected:
        return Colors.green;
      case MQTTConnectionType.disconnected:
        return Colors.red;
      default:
        return Colors.yellow;
    }
  }
}
