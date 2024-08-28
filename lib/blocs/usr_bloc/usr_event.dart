part of 'usr_bloc.dart';

@immutable
sealed class UsrEvent extends Equatable {
  const UsrEvent();
  
  @override
  List<Object> get props => [];
}

final class GetUser extends UsrEvent {
  final String userId;

  const GetUser({
    required this.userId
  });
  
  @override
  List<Object> get props => [userId];
}
