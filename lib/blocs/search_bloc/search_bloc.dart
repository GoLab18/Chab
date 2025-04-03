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
            final (usersWithInvFr, pitId, searchAfterContent) =
              await userRepository.searchUsers(event.query, event.userId, event.pitId, event.searchAfterContent);
            
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

            if (usersWithInvFr.$1.length < 20 && usersWithInvFr.$1.isNotEmpty) {
              return emit(SearchState.allResultsFound((users, invitesFriendships)));
            }

            users.isEmpty
              ? emit(SearchState.noResultsFound())
              : emit(SearchState.success((users, invitesFriendships), pitId, searchAfterContent));
          } catch (_) {
            emit(SearchState.failure());
          }

          break;
        
        case SearchTarget.newGroupMembers:
          try {
            final (membersSuggestions, pitId, searchAfterContent) = 
              await userRepository.searchForNewGroupMembers(event.query, event.userId, event.alreadyAddedUsers, event.pitId, event.searchAfterContent);
            
            List<Usr> memSugs;
            if (event.previousResults != null) {
              memSugs = event.previousResults;
              memSugs.addAll(membersSuggestions);
            } else {
              memSugs = membersSuggestions;
            }

            if (membersSuggestions.length < 20 && membersSuggestions.isNotEmpty) {
              return emit(SearchState.allResultsFound(memSugs));
            }

            memSugs.isEmpty
              ? emit(SearchState.noResultsFound())
              : emit(SearchState.success(memSugs, pitId, searchAfterContent));
          } catch (e) {
            emit(SearchState.failure());
          }
          
          break;
        
        case SearchTarget.chatRooms:
          try {
            final (chatRooms, pitId, searchAfterContent) =
              await roomRepository.searchChatRooms(event.query, event.userId, event.pitId, event.searchAfterContent);
            
            List<(String, bool, String, String)> rooms;
            if (event.previousResults != null) {
              rooms = event.previousResults;
              rooms.addAll(chatRooms);
            } else {
              rooms = chatRooms;
            }

            if (chatRooms.length < 20 && chatRooms.isNotEmpty) {
              return emit(SearchState.allResultsFound(rooms));
            }

            rooms.isEmpty
              ? emit(SearchState.noResultsFound())
              : emit(SearchState.success(rooms, pitId, searchAfterContent));
          } catch (_) {
            emit(SearchState.failure());
          }

          break;
        
        case SearchTarget.messages:
          try {
            final (messages, pitId, searchAfterContent) =
              await roomRepository.searchMessages(event.query, event.userId, event.roomId!, event.pitId, event.searchAfterContent);

            List<(Message, String, String)> msgs;
            if (event.previousResults != null) {
              msgs = event.previousResults;
              msgs.addAll(messages);
            } else {
              msgs = messages;
            }

            if (messages.length < 20 && messages.isNotEmpty) {
              return emit(SearchState.allResultsFound(msgs));
            }

            msgs.isEmpty
              ? emit(SearchState.noResultsFound())
              : emit(SearchState.success(msgs, pitId, searchAfterContent));
          } catch (_) {
            emit(SearchState.failure());
          }

          break;
        
        case SearchTarget.groupMembers:
          try {
            final (groupMembers, pitId, searchAfterContent) =
              await roomRepository.searchGroupMembers(event.query, event.userId, event.roomId!, event.pitId, event.searchAfterContent);
            
            List<(Member, String, String)> members;
            if (event.previousResults != null) {
              members = event.previousResults;
              members.addAll(groupMembers);
            } else {
              members = groupMembers;
            }

            if (groupMembers.length < 20 && groupMembers.isNotEmpty) {
              return emit(SearchState.allResultsFound(members));
            }

            members.isEmpty
              ? emit(SearchState.noResultsFound())
              : emit(SearchState.success(members, pitId, searchAfterContent));
          } catch (_) {
            emit(SearchState.failure());
          }

          break;
      }
    });

    on<SearchReset>((event, emit) {
      emit(SearchState.loading());
    });
  }
}
