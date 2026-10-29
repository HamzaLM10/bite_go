import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

/// الحالة هي ThemeMode نفسه (enum): system / light / dark.
/// صار HydratedCubit: يُحفظ اختيار المستخدم ويُستعاد عند التشغيل التالي.
class ThemeCubit extends HydratedCubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.system);

  void setMode(ThemeMode mode) => emit(mode);

  @override
  ThemeMode? fromJson(Map<String, dynamic> json) {
    // اسم غير معروف أو تالف ← null ← يبدأ من ThemeMode.system.
    return ThemeMode.values.asNameMap()[json['mode']];
  }

  @override
  Map<String, dynamic>? toJson(ThemeMode state) => {'mode': state.name};
}