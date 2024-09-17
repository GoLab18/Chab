import 'package:chab/components/message_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:room_repository/room_repository.dart';

import '../blocs/message_bloc/message_bloc.dart';
import '../blocs/room_bloc/room_bloc.dart';
import '../blocs/usr_bloc/usr_bloc.dart';
import '../components/app_bars/chat_room_app_bar.dart';
import '../components/is_empty_message_widget.dart';
import '../components/message_sequence_date.dart';
import '../util/date_util.dart';

class ChatRoomPage extends StatefulWidget {
  const ChatRoomPage({super.key});

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  late ScrollController scrollController;
  late TextEditingController newMessageController;
  bool isSendButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    
    scrollController = ScrollController()..addListener(scrollLoading);
    newMessageController = TextEditingController()..addListener(buttonEnabling);
  }

  // TODO loading on scroll
  void scrollLoading() {
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent) null;
  }

  void buttonEnabling() {
    if (isSendButtonEnabled != newMessageController.text.isNotEmpty) {
      setState(() {
        isSendButtonEnabled = newMessageController.text.isNotEmpty;
      });
    }
  }

  void pickPhoto() {

  }

  @override
  void dispose() {
    scrollController.removeListener(scrollLoading);
    scrollController.dispose();
    newMessageController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ChatRoomAppBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Messages dynamic loading
          Expanded(
            child: Center(
              child: BlocBuilder<RoomBloc, RoomState>(
                builder: (context, state) {
                  if (state.status == ChatRoomStatus.failure) {
                    return Text(
                      "Loading error",
                      style: TextStyle(
                        fontSize: 30,
                        color: Theme.of(context).colorScheme.inversePrimary
                      )
                    );
                  } else if (state.status == ChatRoomStatus.loading) {
                    return const CircularProgressIndicator();
                  } else if (state.status == ChatRoomStatus.success) {
                    return StreamBuilder(
                      stream: state.roomTuple!.messagesStream,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) return const CircularProgressIndicator();
              
                        if (snapshot.hasError) {
                          return Text(
                            "Loading error",
                            style: TextStyle(
                              fontSize: 30,
                              color: Theme.of(context).colorScheme.inversePrimary
                            )
                          );
                        }
                        
                        if (!snapshot.hasData || snapshot.data!.isEmpty) return const IsEmptyMessageWidget();
                        
                        final messages = snapshot.data;

                        DateUtil dateUtil = DateUtil();
              
                        return Padding(
                          padding: const EdgeInsets.all(8),
                          child: ListView.builder(
                            reverse: true,
                            controller: scrollController,
                            itemCount: messages!.length,
                            itemBuilder: (BuildContext context, int index) {
                              var currentMessage = messages[index];

                              bool nextMessageExists = index + 1 < messages.length;

                              // Is null if next message is non-existent
                              bool? isDateShown;

                              DateTime currentMessageDateTime = currentMessage.timestamp.toDate();

                              if (nextMessageExists) {
                                dateUtil.nextMessageDateTime = messages[index + 1].timestamp.toDate();
                                isDateShown = dateUtil.isMessageDateDifferenceMoreThanOrEqualDay(currentMessageDateTime);
                              }

                              bool isCurrentUsersMessage = currentMessage.senderId == context.read<UsrBloc>().state.user!.id;


                              return Column(
                                crossAxisAlignment: (isCurrentUsersMessage)
                                  ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                children: [
                                  // Message sequence date view
                                  (isDateShown == null || isDateShown)
                                    ? MessageSequenceDate(
                                      DateUtil.isTodayDate(currentMessageDateTime)
                                        ? "Today"
                                        : DateUtil.getLongDateFormatFromNow(currentMessageDateTime)
                                    )
                                    : const SizedBox(height: 8),

                                  // Message
                                  MessageBubble(
                                    message: currentMessage,
                                    isCurrentUserMessage: isCurrentUsersMessage
                                  )
                                ]
                              );
                            }
                          )
                        );
                      }
                    );
                  }
                  
                  throw Exception("Non-existent room_bloc state");
                }
              )
            )
          ),

          // New message field
          Container(
            height: 60,
            color: Theme.of(context).colorScheme.primary,
            child: Center(
              child: TextFormField(
                controller: newMessageController,
                onTapOutside: (event) => FocusScope.of(context).unfocus(),
                maxLines: null,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(4000)
                ],
                cursorColor: Theme.of(context).colorScheme.inversePrimary,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  prefixIcon: IconButton(
                    onPressed: pickPhoto,
                    icon: Icon(
                      Icons.photo_outlined,
                      color: Theme.of(context).colorScheme.tertiary
                    )
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      if (isSendButtonEnabled) {
                        context.read<MessageBloc>().add(
                          AddMessage(
                            roomId: context.read<RoomBloc>().state.roomTuple!.room.id,
                            message: Message(
                              id: "", // Will be auto generated in the backend.
                              content: newMessageController.text,
                              senderId: context.read<UsrBloc>().state.user!.id
                            )
                          )
                        );

                        newMessageController.clear();
                        FocusScope.of(context).unfocus();
                      }
                    },
                    icon: Icon(
                      Icons.send_outlined,
                      color: isSendButtonEnabled
                        ? Theme.of(context).colorScheme.inversePrimary
                        : Theme.of(context).colorScheme.tertiary
                    )
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
                  hintText: "Message..",
                  hintStyle: TextStyle(
                    color: Theme.of(context).hintColor
                  )
                )
              )
            )
          )
        ]
      )
    );
  }
}
