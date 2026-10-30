String formatCount(int n) {
  if (n < 10000) return _groupThousands(n);
  if (n < 1000000) return '${_oneDecimal(n / 1000)} k';
  return '${_oneDecimal(n / 1000000)} M';
}

String _oneDecimal(double v) {
  final s = ((v * 10).floor() / 10).toStringAsFixed(1);
  return (s.endsWith('.0') ? s.substring(0, s.length - 2) : s).replaceAll(
    '.',
    ',',
  );
}

String _groupThousands(int n) {
  final s = n.toString();
  if (s.length <= 3) return s;
  return '${s.substring(0, s.length - 3)}\u202F${s.substring(s.length - 3)}';
}

String timeAgo(DateTime date, {DateTime? now}) {
  final d = (now ?? DateTime.now()).difference(date);
  if (d.inMinutes < 1) return "À l'instant";
  if (d.inHours < 1) return 'Il y a ${d.inMinutes} min';
  if (d.inDays < 1) {
    return 'Il y a ${d.inHours} heure${d.inHours > 1 ? 's' : ''}';
  }
  if (d.inDays < 7) return 'Il y a ${d.inDays} jour${d.inDays > 1 ? 's' : ''}';
  final w = d.inDays ~/ 7;
  return 'Il y a $w semaine${w > 1 ? 's' : ''}';
}
