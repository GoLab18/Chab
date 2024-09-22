import 'package:flutter/material.dart';
import 'package:room_repository/room_repository.dart';

import '../util/date_util.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isCurrentUserMessage;
  final String? sendersName;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isCurrentUserMessage,
    this.sendersName
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      constraints: const BoxConstraints(maxWidth: 200),
      decoration: BoxDecoration(
        color: isCurrentUserMessage
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(8)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (sendersName != null) Text(
            sendersName!,
            style: const TextStyle(
              fontSize: 14,
              color: Color.fromARGB(255, 193, 149, 15)
            )
          ),
          Wrap(
            spacing: 8,
            alignment: WrapAlignment.end,
            crossAxisAlignment: WrapCrossAlignment.end,
            children: [
              // Message text
              Text(
                message.content,
                maxLines: null,
                softWrap: true,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary
                )
              ),
          
              // Last message's timestamp
              Text(
                  DateUtil.getFormatedTime(message.timestamp.toDate()),
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.tertiary
                  )
                )
            ]
          )
        ]
      )
    );
  }
}