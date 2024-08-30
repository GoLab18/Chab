import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_repository/user_repository.dart';

part 'change_usr_info_event.dart';
part 'change_usr_info_state.dart';

class ChangeUsrInfoBloc extends Bloc<ChangeUsrInfoEvent, ChangeUsrInfoState> {
  final FirebaseUserRepository userRepository;
  
  ChangeUsrInfoBloc({
    required this.userRepository
  }) : super(ChangeUsrInfoInitial()) {
    on<UploadPicture>((event, emit) async {
      emit(UploadPicturePending());

      try {
        String pictureStorageUrl = await userRepository.uploadPicture(
          event.userId,
          event.picture
        );

        emit(UploadPictureSuccess(pictureStorageUrl));
      } catch (e) {
        emit(UploadPictureFailure());
      }
    });

    on<ChangeUsrData>((event, emit) async {
      emit(ChangeUsrDataPending());

      try {
        await userRepository.setUserData(event.user);

        emit(ChangeUsrDataSuccess(event.user));
      } catch (e) {
        emit(ChangeUsrDataFailure());
      }
    });
  }
}
