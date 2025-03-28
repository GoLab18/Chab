import 'package:flutter/material.dart';

class AvatarAction extends StatelessWidget {
  final double radius;
  final ImageProvider<Object>? avatarImage;
  final IconData circleAvatarBackgroundIconData;
  final double actionContainerSize;
  final Icon actionIcon;
  final VoidCallback onActionPressed;

  const AvatarAction({
    super.key,
    required this.radius,
    required this.avatarImage,
    required this.circleAvatarBackgroundIconData,
    required this.actionContainerSize,
    required this.actionIcon,
    required this.onActionPressed
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      fit: StackFit.loose,
      children: [
        CircleAvatar(
          radius: radius,
          foregroundImage: avatarImage,
          child: Icon(
            circleAvatarBackgroundIconData,
            color: Theme.of(context).colorScheme.inversePrimary
          )
        ),
    
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: actionContainerSize,
            height: actionContainerSize,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              shape: BoxShape.circle
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: onActionPressed,
              icon: actionIcon
            )
          )
        )
      ]
    );
  }
}