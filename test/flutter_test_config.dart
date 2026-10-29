import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import 'helpers/in_memory_storage.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  // يُنفَّذ قبل كل اختبار: storage جديد وفارغ، فلا تتسرب الحالة بين الاختبارات.
  setUp(() {
    HydratedBloc.storage = InMemoryStorage();
  });
  await testMain();
}