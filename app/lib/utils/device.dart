import 'dart:async';
import 'dart:convert';

import 'package:aspirator5000/constants.dart';
import 'package:aspirator5000/utils/command_stack.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:get_it/get_it.dart';

class Device {
  final CommandStack _commandStack = CommandStack();
  final StreamController<Map<String, dynamic>> _streamController =
      StreamController.broadcast();

  late BluetoothCharacteristic _channel;

  StreamSubscription<List<int>>? _bluetoothReceiver;
  StreamSubscription<BluetoothDeviceState>? _bluetoothState;

  Function()? _onDisconnect;
  Function(String error)? _onError;

  Future<void> _listenCommand(String command) async {
    await _channel
        .write(command.split("").map((e) => e.codeUnitAt(0)).toList());
    return;
  }

  void _listenDisconnection(BluetoothDeviceState event) {
    if (event == BluetoothDeviceState.disconnected) {
      GetIt.I.unregister<BluetoothDevice>();
      _onDisconnect!();
    }
  }

  void _subscribe() {
    _channel.setNotifyValue(true);
    _bluetoothReceiver = _channel.value.listen((event) {
      String message = event.map((v) => String.fromCharCode(v)).join("");
      try {
        _streamController.sink.add(jsonDecode(message));
      } catch (e) {
        _onError?.call("Mensagem inválida recebida. [$message]");
      }
    });
  }

  Future<void> connect() async {
    BluetoothDevice device = GetIt.I<BluetoothDevice>();
    BluetoothService service = (await device.discoverServices())
        .firstWhere((s) => s.uuid == Constants.device);
    _commandStack.listen(_listenCommand);
    _channel =
        service.characteristics.firstWhere((c) => c.uuid == Constants.channel);
    _bluetoothState = device.state.listen(_listenDisconnection);
    _subscribe();
  }

  StreamSubscription<Map<String, dynamic>> onMessage(
      void Function(Map<String, dynamic> message) onMessage) {
    return _streamController.stream.listen(onMessage);
  }

  void onDisconnect(void Function() onDisconnect) {
    _onDisconnect = onDisconnect;
  }

  void onError(void Function(String error) onError) {
    _onError = onError;
  }

  void send(String command) {
    _commandStack.add(command);
  }

  void dispose() {
    _bluetoothReceiver!.cancel();
    _bluetoothState!.cancel();
  }
}
