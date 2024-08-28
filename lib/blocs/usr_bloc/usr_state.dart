part of 'usr_bloc.dart';

enum UsrStatus {
  success,
  loading,
  failure
}

class UsrState extends Equatable {
  final Usr? user;
  final UsrStatus status;

  const UsrState({
    this.user,
    this.status = UsrStatus.loading
  });

  const UsrState.loading() : this();

  const UsrState.success(Usr user) : this(user: user, status: UsrStatus.success);

  const UsrState.failure() : this(status: UsrStatus.failure);

  @override
  List<Object?> get props => [user, status];
}
