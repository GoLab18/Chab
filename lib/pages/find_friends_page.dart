import 'package:chab/components/tiles/invite_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_repository/user_repository.dart';

import '../blocs/invites_operations_bloc/invites_operations_bloc.dart';
import '../blocs/received_invites_bloc/received_invites_bloc.dart';
import '../blocs/room_operations_bloc/room_operations_bloc.dart';
import '../blocs/sent_invites_bloc/sent_invites_bloc.dart';
import '../components/app_bars/search_app_bar.dart';
import '../components/is_empty_message_widget.dart';

class FindFriendsPage extends StatefulWidget {
  final String currentUserId;

  const FindFriendsPage(this.currentUserId, {super.key});

  @override
  State<FindFriendsPage> createState() => _FindFriendsPageState();
}

class _FindFriendsPageState extends State<FindFriendsPage> {

  // Current tab index
  int _currentIndex = 0;

  // Accounts for stream not yielding data on InviteStatus change and holds only
  // the values of non-pending invite statuses behind their indexes as keys
  Map<int, InviteStatus> cachedStatuses = {};

  void cacheStatusCallback(int index, InviteStatus status) {
    setState(() {
      cachedStatuses[index] = status;
    });
  }
  
  void bottomBarNavigation(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  // TODO a button for deleting all the accepted/declined invites in the sent invites part
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: const SearchAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(4),
        child: Center(
          child: BlocBuilder<ReceivedInvitesBloc, ReceivedInvitesState>(
            builder: (context, rcState) => BlocBuilder<SentInvitesBloc, SentInvitesState>(
              builder: (context, stState) {
                if (
                  rcState.status == ReceivedInvitesStatus.failure
                  || stState.status == SentInvitesStatus.failure
                ) {
                  return Text(
                    "Loading error",
                    style: TextStyle(
                      fontSize: 30,
                      color: Theme.of(context).colorScheme.inversePrimary
                    )
                  );
                } else if (
                  rcState.status == ReceivedInvitesStatus.loading
                  || stState.status == SentInvitesStatus.loading
                ) {
                  return const Center(
                    child: CircularProgressIndicator()
                  );
                } else if (
                  rcState.status == ReceivedInvitesStatus.success
                  && stState.status == SentInvitesStatus.success
                ) {
                  return StreamBuilder(
                    stream: rcState.userInvitesStream,
                    builder: (context, rcSnapshot) {
                      return StreamBuilder(
                        stream: stState.userInvitesStream,
                        builder: (context, stSnapshot) {
                          if (
                            rcSnapshot.connectionState == ConnectionState.waiting || !rcSnapshot.hasData
                            || stSnapshot.connectionState == ConnectionState.waiting || !stSnapshot.hasData
                          ) {
                            return const Center(
                              child: CircularProgressIndicator()
                            );
                          }
                          
                          if (rcSnapshot.hasError || stSnapshot.hasError) {
                            return Text(
                              "Loading error",
                              style: TextStyle(
                                fontSize: 20,
                                color: Theme.of(context).colorScheme.inversePrimary
                              )
                            );
                          }
                                
                          List<(Usr, Invite)> receivedInvites = rcSnapshot.data!;
                          List<(Usr, Invite)> sentInvites = stSnapshot.data!;

                          bool isCurrentPageReceivedInvites = _currentIndex == 0;

                          if (
                            (isCurrentPageReceivedInvites && receivedInvites.isEmpty)
                            || (!isCurrentPageReceivedInvites && sentInvites.isEmpty)
                          ) {
                            return const IsEmptyMessageWidget();
                          }
                                
                          return _currentIndex == 0

                            // Accepts invite, setting it to a status "accepted"
                            // Creates a new private room
                            ? BlocListener<InvitesOperationsBloc, InvitesOperationsState>(
                              listener: (context, state) {
                                if (
                                  state.opStatus == InviteOperationStatus.success
                                  && state.invStatus == InviteStatus.accepted
                                ) {
                                  context.read<RoomOperationsBloc>().add(CreatePrivateChatRoom(
                                    widget.currentUserId,
                                    state.fromUserId!
                                  ));
                                }
                              },
                              child: ListView.builder(
                                itemCount: receivedInvites.length,
                                itemBuilder: (context, index) {
                                  var (user, invite) = receivedInvites[index];

                                  return InviteTile(
                                    user: user,
                                    invite: cachedStatuses.containsKey(index) ? invite.copyWith(status: cachedStatuses[index]) : invite,
                                    tabIndex: _currentIndex,
                                    onStatusChanged: (status) => cacheStatusCallback(index, status)
                                  );
                                }
                              ),
                            )
                            
                            : ListView.builder(
                              itemCount: sentInvites.length,
                              itemBuilder: (context, index) {
                                var (user, invite) = sentInvites[index];
                                  
                                return InviteTile(
                                  user: user,
                                  invite: invite,
                                  tabIndex: _currentIndex
                                );
                              }
                            );
                        }
                      );
                    }
                  );
                }
  
                throw Exception("Non-existent received_invites_bloc or sent_invites_bloc state");
              }
            )
          )
        )
      ),
      floatingActionButton: (_currentIndex == 1)
        ? FloatingActionButton(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.inversePrimary,
          shape: const CircleBorder(),
          onPressed: () => {
            // TODO
          },
          child: const Icon(
            Icons.add
          ),
        )
        : null,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        selectedItemColor: Theme.of(context).colorScheme.surface,
        unselectedItemColor: Theme.of(context).colorScheme.inversePrimary,
        onTap: bottomBarNavigation,
        currentIndex: _currentIndex,
        selectedFontSize: 15,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.group_add_outlined),
            label: "Received invites"
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.outbox_outlined),
            label: "Sent invites"
          )
        ]
      )
    );
  }
}