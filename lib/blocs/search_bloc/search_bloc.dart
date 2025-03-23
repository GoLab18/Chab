import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_repository/user_repository.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final FirebaseUserRepository userRepository;
  SearchBloc({
    required this.userRepository
  }) : super(SearchState.loading()) {
    on<SearchEvent>((event, emit) async {
      switch (event.searchTarget) {
        case SearchTarget.users:      // TODO might be a good idea to trash previous requests when they are overshadowed (?) although idk if needed
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
        
        case SearchTarget.chatRooms:
          // TODO
          break;
        
        case SearchTarget.messages:
          // TODO
          break;
        
        case SearchTarget.members:
          // TODO
          break;
      }
    });
  }
}
