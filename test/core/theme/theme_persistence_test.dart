import 'package:bite_go/core/theme/theme_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

void main() {
  test('الثيم المختار يُستعاد عند إنشاء ThemeCubit جديد', () {
    final first = ThemeCubit()..setMode(ThemeMode.dark);
    addTearDown(first.close);

    // نسخة جديدة تحاكي تشغيل التطبيق من جديد.
    final second = ThemeCubit();
    addTearDown(second.close);

    expect(second.state, ThemeMode.dark);
  });

  test('بيانات تالفة تُتجاهل ويبدأ من ThemeMode.system', () {
    // المفتاح الافتراضي هو اسم الكلاس.
    HydratedBloc.storage.write('ThemeCubit', {'mode': 'غير-معروف'});

    final cubit = ThemeCubit();
    addTearDown(cubit.close);

    expect(cubit.state, ThemeMode.system);
  });
}