import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_repository/user_repository.dart';

import '../blocs/received_invites_bloc/received_invites_bloc.dart';
import '../blocs/sent_invites_bloc/sent_invites_bloc.dart';
import '../components/app_bars/search_app_bar.dart';
import '../components/is_empty_message_widget.dart';
import '../util/date_util.dart';

class FindFriendsPage extends StatefulWidget {
  const FindFriendsPage({super.key});

  @override
  State<FindFriendsPage> createState() => _FindFriendsPageState();
}

class _FindFriendsPageState extends State<FindFriendsPage> {
  int _currentIndex = 0;

  
  void bottomBarNavigation(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
  
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
                                
                          List<(Usr, DateTime)> receivedInvites = rcSnapshot.data!;
                          List<(Usr, DateTime)> sentInvites = stSnapshot.data!;

                          bool isCurrentPageReceivedInvites = _currentIndex == 0;

                          if (
                            (isCurrentPageReceivedInvites && receivedInvites.isEmpty)
                            || (!isCurrentPageReceivedInvites && sentInvites.isEmpty)
                          ) {
                            return const IsEmptyMessageWidget();
                          }
                                
                          return _currentIndex == 0
                            ? ListView.builder(
                              itemCount: receivedInvites.length,
                              itemBuilder: (context, index) {
                                var (user, inviteSendingDate) = receivedInvites[index];
                                  
                                return Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: SizedBox(
                                    height: 48,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        // User profile picture
                                        CircleAvatar(
                                          radius: 24,
                                          foregroundImage: user.picture.isNotEmpty
                                            ? NetworkImage(user.picture)
                                            : null,
                                          backgroundColor: Theme.of(context).colorScheme.tertiary,
                                          child: Icon(
                                            Icons.person_outlined,
                                            color: Theme.of(context).colorScheme.inversePrimary
                                          )
                                        ),
                                      ]
                                    )
                                  )
                                );
                              }
                            )
                            : ListView.builder(
                              itemCount: sentInvites.length,
                              itemBuilder: (context, index) {
                                var (user, inviteSendingDate) = sentInvites[index];
                                  
                                return Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: SizedBox(
                                    height: 48,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        // User profile picture
                                        CircleAvatar(
                                          radius: 24,
                                          foregroundImage: user.picture.isNotEmpty
                                            ? NetworkImage(user.picture)
                                            : null,
                                          backgroundColor: Theme.of(context).colorScheme.tertiary,
                                          child: Icon(
                                            Icons.person_outlined,
                                            color: Theme.of(context).colorScheme.inversePrimary
                                          )
                                        ),

                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              left: 12,
                                              right: 8
                                            ),
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  user.name,
                                                  overflow: TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                  style: TextStyle(
                                                    color: Theme.of(context).colorScheme.inversePrimary
                                                  )
                                                ),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      DateUtil.getLongDateFormatFromNow(inviteSendingDate),
                                                      overflow: TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Theme.of(context).colorScheme.tertiary
                                                      )
                                                    ),

                                                    // TODO Status of the invite
                                                    Text(
                                                      "Status: pending..",
                                                      overflow: TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.bold,
                                                        color: Theme.of(context).colorScheme.tertiary
                                                      )
                                                    )
                                                  ]
                                                )
                                              ]
                                            )
                                          )
                                        ),

                                        // Delete icon button
                                        IconButton(
                                          onPressed: () {},
                                          icon: Icon(
                                            Icons.cancel_outlined,
                                            size: 26,
                                            color: Theme.of(context).colorScheme.secondary
                                          )
                                        )
                                      ]
                                    )
                                  )
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