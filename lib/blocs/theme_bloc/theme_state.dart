part of 'theme_bloc.dart';

abstract class ThemeState extends Equatable {
  const ThemeState();

  ThemeData get themeData;

  @override
  List<Object> get props => [themeData];
}

final class DarkTheme extends ThemeState {
  @override
  final ThemeData themeData = darkMode;
}

final class LightTheme extends ThemeState {
  @override
  final ThemeData themeData = lightMode;
}

