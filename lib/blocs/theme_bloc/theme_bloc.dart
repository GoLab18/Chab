import 'package:chab/themes/dark_mode.dart';
import 'package:chab/themes/light_mode.dart';
import 'package:chab/util/shared_preferences_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'theme_event.dart';
part 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(
    SharedPreferencesUtil.isDarkTheme
      ? DarkTheme()
      : LightTheme()
  ) {
    on<ToggleThemes>((event, emit) async {
      await SharedPreferencesUtil.toggleThemesPrefs();

      emit(
        SharedPreferencesUtil.isDarkTheme
          ? DarkTheme()
          : LightTheme()
      );
    });
  }
}
