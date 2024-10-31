import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_repository/user_repository.dart';

import '../../blocs/invites_operations_bloc/invites_operations_bloc.dart';
import '../../util/date_util.dart';

class InviteTile extends StatefulWidget {
  final Usr user;
  final Invite invite;
  final int tabIndex;
  final void Function(InviteStatus)? onStatusChanged;

  const InviteTile({
    super.key,
    required this.user,
    required this.invite,
    required this.tabIndex,
    this.onStatusChanged
  });

  @override
  State<InviteTile> createState() => _InviteTileState();
}

class _InviteTileState extends State<InviteTile> {

  String assertStatusString(InviteStatus status) {
    return switch (status) {
      InviteStatus.pending => "Pending",
      InviteStatus.declined => "Declined",
      InviteStatus.accepted => "Accepted"
    };
  }

  Color assertStatusColor(InviteStatus status) {
    return switch (status) {
      InviteStatus.pending => Theme.of(context).colorScheme.tertiary,
      InviteStatus.declined => Theme.of(context).colorScheme.error.withAlpha(200),
      InviteStatus.accepted => Theme.of(context).colorScheme.primary
    };
  }

  @override
  Widget build(BuildContext context) {
    final InviteStatus status = widget.invite.status;

    return Material(
      child: InkWell(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: SizedBox(
            height: 48,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Sender profile picture
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
                        // Username of the sender/receiver
                        Text(
                          widget.user.name,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.inversePrimary
                          )
                        ),
        
                        widget.tabIndex == 0
                        // Invite sending date
                          ? Text(
                            DateUtil.getLongDateFormatFromNow(widget.invite.timestamp.toDate()),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.tertiary
                            )
                          )
                          : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Invite sending date
                              Text(
                                DateUtil.getLongDateFormatFromNow(widget.invite.timestamp.toDate()),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).colorScheme.tertiary
                                )
                              ),
        
                              // Invite status
                              Text(
                                assertStatusString(status),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: assertStatusColor(status)
                                )
                              )
                            ]
                          )
        
                      ]
                    )
                  )
                ),
        
                // Accepts invite, setting it to a status "accepted"
                if (widget.tabIndex == 0 && status == InviteStatus.pending) IconButton(
                  onPressed: () {
                    context.read<InvitesOperationsBloc>().add(UpdateInviteStatus(
                      inviteId: widget.invite.id,
                      newStatus: InviteStatus.accepted,
                      fromUserId: widget.user.id
                    ));
        
                    widget.onStatusChanged!(InviteStatus.accepted);
                  },
                  icon: Icon(
                    Icons.check_circle_outlined,
                    size: 26,
                    color: Theme.of(context).colorScheme.inversePrimary
                  )
                ),
        
                // Declines invite, setting it to a status "declined"
                if (widget.tabIndex == 0 && status == InviteStatus.pending) IconButton(
                  onPressed: () {
                    context.read<InvitesOperationsBloc>().add(UpdateInviteStatus(
                      inviteId: widget.invite.id,
                      newStatus: InviteStatus.declined
                    ));
        
                    widget.onStatusChanged!(InviteStatus.declined);
                  },
                  icon: Icon(
                    Icons.cancel_outlined,
                    size: 26,
                    color: Theme.of(context).colorScheme.secondary
                  )
                ),
        
                // Status prompt for when invite is already answered
                if (widget.tabIndex == 0 && status != InviteStatus.pending) Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Text(
                    assertStatusString(status),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: assertStatusColor(status)
                    )
                  )
                ),
                
                // Delete invite icon button
                if (widget.tabIndex == 1) IconButton(
                  onPressed: () => context.read<InvitesOperationsBloc>().add(DeleteInvite(widget.invite.id)),
                  icon: Icon(
                    Icons.cancel_outlined,
                    size: 26,
                    color: Theme.of(context).colorScheme.secondary
                  )
                )
              ]
            )
          )
        ),
      ),
    );
  }
}