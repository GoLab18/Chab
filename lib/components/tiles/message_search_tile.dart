import 'package:chab/util/date_util.dart';
import 'package:flutter/material.dart';
import 'package:room_repository/room_repository.dart';

class MessageSearchTile extends StatelessWidget {
  final Message message;
  final String name;
  final String? picUrl;
  final String currUserId;
  final String? highlightedContent;

  const MessageSearchTile({
    super.key,
    required this.message,
    required this.name,
    required this.picUrl,
    required this.currUserId,
    required this.highlightedContent
  });

  List<TextSpan> _buildHighlightedText({
    required String text,
    required TextStyle normalStyle,
    required TextStyle highlightStyle,
  }) {
    final regex = RegExp(r'<em>(.*?)<\/em>');
    final matches = regex.allMatches(text);

    List<TextSpan> spans = [];
    int lastMatchEnd = 0;
    for (var m in matches) {
      if (m.start > lastMatchEnd) {
        spans.add(TextSpan(
          text: text.substring(lastMatchEnd, m.start),
          style: normalStyle,
        ));
      }

      spans.add(TextSpan(
        text: m.group(1),
        style: highlightStyle,
      ));

      lastMatchEnd = m.end;
    }

    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastMatchEnd),
        style: normalStyle,
      ));
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                CircleAvatar(
                  radius: 22,
                  foregroundImage: (picUrl != null && picUrl!.isNotEmpty)
                    ? NetworkImage(picUrl!)
                    : null,
                  backgroundColor: Theme.of(context).colorScheme.tertiary,
                  child: picUrl == null || picUrl!.isEmpty
                    ? Icon(
                        Icons.person_outline,
                        color: Theme.of(context).colorScheme.inversePrimary,
                      )
                    : null,
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color.fromARGB(255, 193, 149, 15),
                  )
                )
              ]
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: highlightedContent != null
                          ? RichText(
                            text: TextSpan(
                              children: _buildHighlightedText(
                                text: highlightedContent!,
                                normalStyle: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.inversePrimary),
                                highlightStyle: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600)
                              ),
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.secondary,
                              )
                            )
                          )
                          : Text(
                            message.content,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.secondary,
                            )
                          )
                      ),

                      const SizedBox(width: 8),

                      Text(
                        DateUtil.getShortDateFormatFromNow(message.timestamp.toDate()),
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.tertiary,
                        )
                      )
                    ]
                  )
                ]
              )
            )
          ]
        )
      )
    );
  }
}
