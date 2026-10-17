import 'package:bite_go/core/theme/theme_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('يبدأ على system ويصدر الوضع الجديد عند setMode', () {
    final cubit = ThemeCubit();
    addTearDown(cubit.close);

    expect(cubit.state, ThemeMode.system);

    // قبل الاستدعاء لأن الـ stream من نوع broadcast
    expectLater(cubit.stream, emitsInOrder([ThemeMode.dark, ThemeMode.light]));

    cubit.setMode(ThemeMode.dark);
    cubit.setMode(ThemeMode.light);
  });
}