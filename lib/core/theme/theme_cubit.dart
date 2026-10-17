import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// الحالة هي ThemeMode نفسه (enum): system / light / dark.
/// لا نحتاج sealed state ولا Equatable لأن القيمة بسيطة ومقارنتها مباشرة.
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.system);

  void setMode(ThemeMode mode) => emit(mode);
}