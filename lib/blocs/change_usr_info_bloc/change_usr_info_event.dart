part of 'change_usr_info_bloc.dart';

sealed class ChangeUsrInfoEvent extends Equatable {
  const ChangeUsrInfoEvent();

  @override
  List<Object> get props => [];
}

final class UploadPicture extends ChangeUsrInfoEvent {
  final String picture;
  final String userId;

  const UploadPicture({
    required this.picture,
    required this.userId
  });

  @override
  List<Object> get props => [picture, userId];
}

final class ChangeUsrData extends ChangeUsrInfoEvent {
  final Usr user;

  const ChangeUsrData(this.user);

  @override
  List<Object> get props => [user];
}
