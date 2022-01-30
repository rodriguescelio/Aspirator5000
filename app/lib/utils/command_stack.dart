typedef ListenFunction = Future<void> Function(String command);

class CommandStack {
  final List<String> _commands = [];
  ListenFunction? _listener;
  bool _running = false;

  void _runStack() async {
    if (_listener != null) {
      if (_commands.isNotEmpty) {
        _running = true;
        String command = _commands.removeAt(0);
        await _listener!(command);
        _runStack();
      } else {
        _running = false;
      }
    }
  }

  void listen(ListenFunction callback) {
    _listener = callback;
    if (!_running) {
      _runStack();
    }
  }

  void add(String command) {
    _commands.add(command);
    if (!_running) {
      _runStack();
    }
  }
}
