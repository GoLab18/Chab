import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:user_repository/user_repository.dart';

class StagedMembersCubit extends Cubit<List<Usr>> {
  StagedMembersCubit() : super(<Usr>[]);

  void stageMember(Usr member) {
    final newState = List<Usr>.from(state)..add(member);
    emit(newState);
  }

  void unstageMember(Usr member) {
    final newState = List<Usr>.from(state)..removeWhere((user) => user.id == member.id);
    emit(newState);
  }
}
