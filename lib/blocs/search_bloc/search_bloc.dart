import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:room_repository/room_repository.dart';
import 'package:user_repository/user_repository.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final FirebaseUserRepository userRepository;
  final FirebaseRoomRepository roomRepository;

  SearchBloc({
    required this.userRepository,
    required this.roomRepository
  }) : super(SearchState.loading()) {
    on<SearchQuery>((event, emit) async {
      switch (event.searchTarget) {
        case SearchTarget.users:
          try {
            final (usersWithInvFr, pitId, searchAfterContent) = await userRepository.searchUsers(event.query, event.userId, null, []);
            
            List<Usr> users;
            List<(Invite, Friendship?)?> invitesFriendships;
            if (event.previousResults != null) {
              users = event.previousResults.$1;
              invitesFriendships = event.previousResults.$2;

              users.addAll(usersWithInvFr.$1);
              invitesFriendships.addAll(usersWithInvFr.$2);
            } else {
              users = usersWithInvFr.$1;
              invitesFriendships = usersWithInvFr.$2;
            }

            emit(SearchState.success((users, invitesFriendships), pitId, searchAfterContent));
          } catch (_) {
            emit(SearchState.failure());
          }

          break;
        
        case SearchTarget.newGroupMembers:
          try {
            final (membersSuggestions, pitId, searchAfterContent) = 
              await userRepository.searchForNewGroupMembers(event.query, event.userId, event.alreadyAddedUsers, null, []);
            
            List<Usr> memSugs;
            if (event.previousResults != null) {
              memSugs = event.previousResults;
              memSugs.addAll(membersSuggestions);
            } else {
              memSugs = membersSuggestions;
            }

            emit(SearchState.success(memSugs, pitId, searchAfterContent));
          } catch (e) {
            emit(SearchState.failure());
          }
          
          break;
        
        case SearchTarget.chatRooms:
          try {
            final (chatRooms, pitId, searchAfterContent) = await roomRepository.searchChatRooms(event.query, event.userId, null, []);
            
            List<(Room, String, String)> rooms;
            if (event.previousResults != null) {
              rooms = event.previousResults;
              rooms.addAll(chatRooms);
            } else {
              rooms = chatRooms;
            }

            emit(SearchState.success(rooms, pitId, searchAfterContent));
          } catch (_) {
            emit(SearchState.failure());
          }

          break;
        
        case SearchTarget.messages:
          // TODO
          break;
        
        case SearchTarget.groupMembers:
          // TODO
          break;
      }
    });

    on<SearchReset>((event, emit) {
      emit(SearchState.loading());
    });
  }
}
