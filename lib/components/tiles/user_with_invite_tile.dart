import 'package:flutter/material.dart';
import 'package:user_repository/user_repository.dart';

import '../../blocs/invites_operations_bloc/invites_operations_bloc.dart';
import '../../blocs/usr_bloc/usr_bloc.dart';
import '../../util/date_util.dart';

class UserWithInviteTile extends StatefulWidget {
  final Usr user;
  final Invite? invite;
  final Friendship? friendship;
  final InvitesOperationsBloc invOpsBloc;
  final UsrBloc usrBloc;

  const UserWithInviteTile(this.user, this.invite, this.friendship, this.invOpsBloc, this.usrBloc, {super.key});

  @override
  State<UserWithInviteTile> createState() => _UserWithInviteTileState();
}

class _UserWithInviteTileState extends State<UserWithInviteTile> {
  Invite? invite;
  Friendship? friendship;

  @override
  void initState() {
    super.initState();

    invite = widget.invite;
    friendship = widget.friendship;
  }

  void acceptInvite() {
    widget.invOpsBloc.add(UpdateInviteStatus(
      inviteId: invite!.id,
      newStatus: InviteStatus.accepted,
      toUser: widget.usrBloc.state.user!,
      fromUser: widget.user
    ));

    setState(() {
      invite = invite?.copyWith(status: InviteStatus.accepted);
    });
  }

  void declineInvite() {
    widget.invOpsBloc.add(UpdateInviteStatus(
      inviteId: invite!.id,
      newStatus: InviteStatus.declined
    ));

    setState(() {
      invite = invite?.copyWith(status: InviteStatus.declined);
    });
  }

  void sendInvite() {
    invite = Invite(id: "", fromUser: widget.usrBloc.state.user!.id, toUser: widget.user.id);

    widget.invOpsBloc.add(AddInvite(invite!));

    setState(() {});
  }
  
  void navigateToUserPage(BuildContext context, Usr user) {

  }

  String assertFriendshipStatusString([InviteStatus? status, bool isFromCurrUserInvite = true]) {
    return switch (status) {
      null => "Not a friend",
      InviteStatus.declined => "Your invite was declined",
      InviteStatus.pending => isFromCurrUserInvite ? "Invite sent" : "Invite received",
      InviteStatus.accepted => (friendship != null) ? "Friends since ${DateUtil.getShortDateFormatFromNow(friendship!.since.toDate())}" : "Accepted"
    };
  }

  Color assertStatusColor(InviteStatus? status) {
    return switch (status) {
      null => Theme.of(context).colorScheme.secondary,
      InviteStatus.declined => Theme.of(context).colorScheme.error.withAlpha(200),
      InviteStatus.pending => Theme.of(context).colorScheme.tertiary,
      InviteStatus.accepted => Theme.of(context).colorScheme.primary
    };
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        onTap: () => navigateToUserPage(context, widget.user),
        splashColor: Theme.of(context).colorScheme.tertiary.withOpacity(0.5),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: SizedBox(
            height: 48,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Profile picture
                CircleAvatar(
                  radius: 24,
                  foregroundImage: widget.user.picture.isNotEmpty
                    ? NetworkImage(widget.user.picture)
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
                        // Username
                        Text(
                          widget.user.name,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.inversePrimary
                          )
                        ),

                        Text(
                          (invite == null)
                            ? assertFriendshipStatusString()
                            : assertFriendshipStatusString(invite!.status, (invite!.fromUser != widget.user.id) ? true : false),
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 12,
                            color: assertStatusColor(invite?.status)
                          )
                        )
                      ]
                    )
                  )
                ),
        
                // Accepts invite
                if (
                  invite != null
                  && invite!.status == InviteStatus.pending
                  && invite!.fromUser == widget.user.id
                ) IconButton(
                  onPressed: acceptInvite,
                  icon: Icon(
                    Icons.check_circle_outlined,
                    size: 26,
                    color: Theme.of(context).colorScheme.inversePrimary
                  )
                ),

                // Declines invite
                if (
                  invite != null
                  && invite!.status == InviteStatus.pending
                  && invite!.fromUser == widget.user.id
                ) IconButton(
                  onPressed: declineInvite,
                  icon: Icon(
                    Icons.cancel_outlined,
                    size: 26,
                    color: Theme.of(context).colorScheme.secondary
                  )
                ),

                if (invite == null) IconButton.filled(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  onPressed: sendInvite,
                  icon: Icon(
                    Icons.person_add_alt_1_outlined,
                    size: 18,
                    color: Theme.of(context).colorScheme.inversePrimary
                  )
                )
              ]
            )
          )
        )
      )
    );
  }
}