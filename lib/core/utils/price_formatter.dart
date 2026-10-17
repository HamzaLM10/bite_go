/// ينسّق السعر بالليرة السورية: 12500 → "12,500 ل.س".
/// الليرة لا تُعرض بكسور عملياً، فنقرّب لأقرب عدد صحيح.
String formatPrice(double value) {
  final rounded = value.round();
  final digits = rounded.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return '${rounded < 0 ? '-' : ''}$buffer ل.س';
}