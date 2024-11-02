import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_repository/user_repository.dart';

part 'room_members_event.dart';
part 'room_members_state.dart';

class RoomMembersBloc extends Bloc<RoomMembersEvent, RoomMembersState> {
  final FirebaseUserRepository userRepository;

  RoomMembersBloc({
    required this.userRepository
  }) : super(const RoomMembersState.loading()) {
    on<PrivateChatRoomMembersRequested>((event, emit) async {
      try {
        Stream<Usr> privateChatStream = await userRepository.getPrivateChatRoomFriend(event.roomId, event.currentUserId);

        await emit.forEach(
          privateChatStream,
          onData: (Usr friend) {
            return RoomMembersState.success(privateChatRoomFriend: friend);
          },
          onError: (_, __) => const RoomMembersState.failure()
        );
      } catch (_) {
        emit(const RoomMembersState.failure());
      }
    });

    on<GroupChatRoomMembersRequested>((event, emit) async {
      try {
        Stream<Map<String, Usr>> roomMembersStream = await userRepository.getGroupChatRoomMembersStream(event.roomId);

        await emit.forEach(
          roomMembersStream,
          onData: (Map<String, Usr> members) {
            return RoomMembersState.success(groupChatMembers: members);
          },
          onError: (_, __) => const RoomMembersState.failure()
        );
      } catch (_) {
        emit(const RoomMembersState.failure());
      }
    });
  }
}
