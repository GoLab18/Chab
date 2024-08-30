part of 'change_usr_info_bloc.dart';

sealed class ChangeUsrInfoState extends Equatable {
  const ChangeUsrInfoState();
  
  @override
  List<Object> get props => [];
}

final class ChangeUsrInfoInitial extends ChangeUsrInfoState {}

final class UploadPictureFailure extends ChangeUsrInfoState {}

final class UploadPicturePending extends ChangeUsrInfoState {}

final class UploadPictureSuccess extends ChangeUsrInfoState {
  final String pictureStorageUrl;

  const UploadPictureSuccess(this.pictureStorageUrl);

  @override
  List<Object> get props => [pictureStorageUrl];
}

final class ChangeUsrDataFailure extends ChangeUsrInfoState {}

final class ChangeUsrDataPending extends ChangeUsrInfoState {}

final class ChangeUsrDataSuccess extends ChangeUsrInfoState {
  final Usr user;

  const ChangeUsrDataSuccess(this.user);

  @override
  List<Object> get props => [user];
}
