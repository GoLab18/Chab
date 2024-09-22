import 'package:chab/components/message_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:room_repository/room_repository.dart';
import 'package:user_repository/user_repository.dart';

import '../blocs/message_bloc/message_bloc.dart';
import '../blocs/room_bloc/room_bloc.dart';
import '../blocs/room_members_bloc/room_members_bloc.dart';
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
              child: BlocBuilder<RoomMembersBloc, RoomMembersState>(
                builder: (context, roomMembersState) {
                  return BlocBuilder<RoomBloc, RoomState>(
                    builder: (context, roomState) {
                      if (
                        roomState.status == ChatRoomStatus.failure
                          || roomMembersState.status == ChatRoomMembersStatus.failure
                      ) {
                        return Text(
                          "Loading error",
                          style: TextStyle(
                            fontSize: 30,
                            color: Theme.of(context).colorScheme.inversePrimary
                          )
                        );
                      } else if (
                        roomState.status == ChatRoomStatus.loading
                          || roomMembersState.status == ChatRoomMembersStatus.loading
                      ) {
                        return const CircularProgressIndicator();
                      } else if (
                        roomState.status == ChatRoomStatus.success
                          || roomMembersState.status == ChatRoomMembersStatus.success
                      ) {
                        return roomState.roomTuple!.room.isPrivate
                          ? StreamBuilder(
                          stream: roomState.roomTuple!.messagesStream,
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
                            
                            final messages = snapshot.data!;
                            Usr friend = roomMembersState.privateChatRoomFriend!;

                            String lastSenderId = messages[0].senderId;

                            // For displaying message sender's avatar
                            bool wasDateDisplayedBefore = false;

                            // Becomes null if next message is non-existent
                            bool? isDateShown;
    
                            DateUtil dateUtil = DateUtil();
                  
                            return Padding(
                              padding: const EdgeInsets.all(8),
                              child: ListView.builder(
                                reverse: true,
                                controller: scrollController,
                                itemCount: messages.length,
                                itemBuilder: (BuildContext context, int index) {
                                  var currentMessage = messages[index];
    
                                  bool nextMessageExists = index + 1 < messages.length;
    
                                  DateTime currentMessageDateTime = currentMessage.timestamp.toDate();

                                  // Based on the previous version of isDateShown
                                  wasDateDisplayedBefore = (isDateShown != null && isDateShown!) ? true : false;
    
                                  if (nextMessageExists) {
                                    dateUtil.nextMessageDateTime = messages[index + 1].timestamp.toDate();
                                    isDateShown = dateUtil.isMessageDateDifferenceMoreThanOrEqualDay(currentMessageDateTime);
                                  } else {
                                    isDateShown == null;
                                  }

                                  String senderId = currentMessage.senderId;
                                  bool isCurrentUsersMessage = senderId == context.read<UsrBloc>().state.user!.id;

                                  bool isDifferentSender = lastSenderId != senderId;
                                  if (isDifferentSender) lastSenderId = senderId;

                                  return Column(
                                    children: [
                                      // Message sequence date view
                                      (isDateShown == null || isDateShown!)
                                        ? MessageSequenceDate(
                                          DateUtil.isTodayDate(currentMessageDateTime)
                                            ? "Today"
                                            : DateUtil.getLongDateFormatFromNow(currentMessageDateTime)
                                        )
                                        : const SizedBox(height: 8),

                                      Row(
                                        mainAxisAlignment: isCurrentUsersMessage
                                          ? MainAxisAlignment.end : MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          if (!isCurrentUsersMessage) Padding(
                                            padding: const EdgeInsets.only(right: 8),
                                            child: (isDifferentSender || wasDateDisplayedBefore)
                                              ? CircleAvatar(
                                                radius: 16,
                                                foregroundImage: friend.picture.isNotEmpty
                                                  ? NetworkImage(friend.picture)
                                                  : null,
                                                backgroundColor: Theme.of(context).colorScheme.tertiary,
                                                child: Icon(
                                                  Icons.person_outlined,
                                                  size: 16,
                                                  color: Theme.of(context).colorScheme.inversePrimary
                                                )
                                              )
                                              : const SizedBox(
                                                width: 32,
                                                height: 32
                                              )
                                          ),
                                          MessageBubble(
                                            message: currentMessage,
                                            isCurrentUserMessage: isCurrentUsersMessage
                                          )
                                        ]
                                      )
                                      // Message
                                    ]
                                  );
                                }
                              )
                            );
                          }
                        )
                        : StreamBuilder(
                          stream: roomMembersState.roomMembersStream,
                          builder: (context, membersSnapshot) {
                            return StreamBuilder(
                              stream: roomState.roomTuple!.messagesStream,
                              builder: (context, msgSnapshot) {
                                if (
                                  msgSnapshot.connectionState == ConnectionState.waiting
                                    || membersSnapshot.connectionState == ConnectionState.waiting
                                ) return const CircularProgressIndicator();
                                
                                if (msgSnapshot.hasError || membersSnapshot.hasError) {
                                  return Text(
                                    "Loading error",
                                    style: TextStyle(
                                      fontSize: 30,
                                      color: Theme.of(context).colorScheme.inversePrimary
                                    )
                                  );
                                }
                                
                                if (
                                  !msgSnapshot.hasData || msgSnapshot.data!.isEmpty
                                    || !membersSnapshot.hasData || membersSnapshot.data!.isEmpty
                                ) return const IsEmptyMessageWidget();
                                
                                final messages = msgSnapshot.data!;
                                final members = membersSnapshot.data!;

                                String lastSenderId = messages[0].senderId;

                                // For displaying message sender's avatar
                                bool wasDateDisplayedBefore = false;

                                // Become null if next message is non-existent
                                bool? isDateShown;
                                bool? isNextSenderDifferent;

                                bool isUsernameShown = false;
                                
                                DateUtil dateUtil = DateUtil();

                                
                                return Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: ListView.builder(
                                    reverse: true,
                                    controller: scrollController,
                                    itemCount: messages.length,
                                    itemBuilder: (BuildContext context, int index) {
                                      var currentMessage = messages[index];
                                
                                      bool nextMessageExists = index + 1 < messages.length;
                                
                                      DateTime currentMessageDateTime = currentMessage.timestamp.toDate();

                                      // Based on the previous version of isDateShown
                                      wasDateDisplayedBefore = (isDateShown != null && isDateShown!) ? true : false;

                                      String currentSenderId = currentMessage.senderId;

                                      if (nextMessageExists) {
                                        Message nextMesssage = messages[index + 1];

                                        dateUtil.nextMessageDateTime = nextMesssage.timestamp.toDate();
                                        isDateShown = dateUtil.isMessageDateDifferenceMoreThanOrEqualDay(currentMessageDateTime);
                                        isNextSenderDifferent = currentSenderId != nextMesssage.senderId;
                                      } else {
                                        isDateShown = null;
                                        isNextSenderDifferent = null;
                                      }

                                      bool isCurrentUsersMessage = currentSenderId == context.read<UsrBloc>().state.user!.id;

                                      // Null if last message sender is the same as current message sender
                                      Usr sender = members[currentSenderId]!;

                                      bool isCurrentSenderDifferent = lastSenderId != currentSenderId;
                                      if (isCurrentSenderDifferent) lastSenderId = currentSenderId;

                                      // Username is shown when the current is sender is not the current user and
                                      // the next sender is a different one or the date will be displayed
                                      isUsernameShown = !isCurrentUsersMessage
                                        && (isNextSenderDifferent == null || isNextSenderDifferent!
                                          || isDateShown == null || isDateShown!);

                                      return Column(
                                        children: [
                                          // Message sequence date view
                                          (isDateShown == null || isDateShown!)
                                            ? MessageSequenceDate(
                                              DateUtil.isTodayDate(currentMessageDateTime)
                                                ? "Today"
                                                : DateUtil.getLongDateFormatFromNow(currentMessageDateTime)
                                            )
                                            : const SizedBox(height: 8),
                            
                                          Row(
                                            mainAxisAlignment: isCurrentUsersMessage
                                              ? MainAxisAlignment.end : MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              if (!isCurrentUsersMessage) Padding(
                                                padding: const EdgeInsets.only(right: 8),
                                                child: (isCurrentSenderDifferent || wasDateDisplayedBefore || index == 0)
                                                  // Sender profile picture
                                                  ? CircleAvatar(
                                                    radius: 16,
                                                    foregroundImage: sender.picture.isNotEmpty
                                                      ? NetworkImage(sender.picture)
                                                      : null,
                                                    backgroundColor: Theme.of(context).colorScheme.tertiary,
                                                    child: Icon(
                                                      Icons.person_outlined,
                                                      size: 16,
                                                      color: Theme.of(context).colorScheme.inversePrimary
                                                    )
                                                  )
                                                  : const SizedBox(
                                                    width: 32,
                                                    height: 32
                                                  )
                                              ),
                                              
                                              // Message
                                              MessageBubble(
                                                message: currentMessage,
                                                isCurrentUserMessage: isCurrentUsersMessage,
                                                sendersName: (isUsernameShown)
                                                  ? sender.name
                                                  : null
                                              )
                                            ]
                                          )
                                        ]
                                      );
                                    }
                                  )
                                );
                              }
                            );
                          }
                        );
                      }
                      
                      throw Exception("Non-existent room_bloc state");
                    }
                  );
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
                      RoomState roomState = context.read<RoomBloc>().state;

                      if (isSendButtonEnabled && roomState.status == ChatRoomStatus.success) {
                        FocusScope.of(context).unfocus();
                        
                        context.read<MessageBloc>().add(
                          AddMessage(
                            roomId: roomState.roomTuple!.room.id,
                            message: Message(
                              id: "", // Will be auto generated in the backend.
                              content: newMessageController.text,
                              senderId: context.read<UsrBloc>().state.user!.id
                            )
                          )
                        );

                        newMessageController.clear();
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
