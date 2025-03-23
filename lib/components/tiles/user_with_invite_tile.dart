import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_repository/user_repository.dart';

import '../../blocs/invites_operations_bloc/invites_operations_bloc.dart';
import '../../blocs/usr_bloc/usr_bloc.dart';
import '../../util/date_util.dart';
import '../button_template.dart';

class UserWithInviteTile extends StatefulWidget {
  final Usr user;
  final Invite? invite;
  final Friendship? friendship;

  const UserWithInviteTile(this.user, this.invite, this.friendship, {super.key});

  @override
  State<UserWithInviteTile> createState() => _UserWithInviteTileState();
}

class _UserWithInviteTileState extends State<UserWithInviteTile> {
  void navigateToUserPage(BuildContext context) {

  }

  String assertFriendshipStatusString([InviteStatus? status, bool isFromCurrUserInvite = true]) {
    return switch (status) {
      null => "Not a friend",
      InviteStatus.declined => "Not a friend",
      InviteStatus.pending => isFromCurrUserInvite ? "Invite sent" : "Invite received",
      InviteStatus.accepted => "Friends since ${DateUtil.getShortDateFormatFromNow(widget.friendship!.since.toDate())}"
    };
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        onTap: () => navigateToUserPage(context),
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
                          (widget.invite == null)
                            ? assertFriendshipStatusString()
                            : assertFriendshipStatusString(widget.invite!.status, (widget.invite!.fromUser != widget.user.id) ? true : false),
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.tertiary
                          )
                        )
                      ]
                    )
                  )
                ),
        
                // Accepts invite
                if (
                  widget.invite != null
                  && widget.invite!.status == InviteStatus.pending
                  && widget.invite!.toUser == widget.user.id
                ) IconButton(
                  onPressed: () {
                    setState(() {
                      context.read<InvitesOperationsBloc>().add(UpdateInviteStatus(
                        inviteId: widget.invite!.id,
                        newStatus: InviteStatus.accepted,
                        toUser: context.read<UsrBloc>().state.user!,
                        fromUser: widget.user
                      ));
                    });
                  },
                  icon: Icon(
                    Icons.check_circle_outlined,
                    size: 26,
                    color: Theme.of(context).colorScheme.inversePrimary
                  )
                ),

                // Declines invite
                if (
                  widget.invite != null
                  && widget.invite!.status == InviteStatus.pending
                  && widget.invite!.toUser == widget.user.id
                ) IconButton(
                  onPressed: () {
                    setState(() {
                      context.read<InvitesOperationsBloc>().add(UpdateInviteStatus(
                        inviteId: widget.invite!.id,
                        newStatus: InviteStatus.declined
                      ));
                    });
                  },
                  icon: Icon(
                    Icons.cancel_outlined,
                    size: 26,
                    color: Theme.of(context).colorScheme.secondary
                  )
                ),

                if (widget.invite == null) ButtonTemplate(
                  buttonText: "Send invite",
                  onButtonPressed: () {
                    setState(() {
                      context.read<InvitesOperationsBloc>().add(AddInvite(
                        context.read<UsrBloc>().state.user!.id,
                        widget.user.id
                      ));
                    });
                  }
                )
              ]
            )
          )
        )
      )
    );
  }
}