import 'dart:async';

import 'package:flutter/foundation.dart';

/// يحوّل Stream إلى Listenable: يُخطر مستمعيه عند كل حدث في الـ stream.
/// نستعمله لإخبار GoRouter بأن حالة المصادقة تغيّرت فيعيد تقييم redirect.
class StreamListenable extends ChangeNotifier {
  StreamListenable(Stream<dynamic> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}