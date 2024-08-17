import 'dart:async';

class Debouncer {
  final int milliseconds;

  Timer? _timer;

  void cancel() {
    _timer?.cancel();
  }

  Debouncer({required this.milliseconds});

  run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}
