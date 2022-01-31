import 'dart:async';

import 'package:aspirator5000/constants.dart';
import 'package:aspirator5000/utils/command_stack.dart';
import 'package:aspirator5000/views/pages/connection.page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> _log = [];
  final ScrollController _scrollController = ScrollController();
  final DateFormat _dateFormat = DateFormat("dd/MM/yyyy HH:mm:ss");
  late BluetoothCharacteristic _channel;
  final CommandStack _commandStack = CommandStack();
  StreamSubscription<List<int>>? _bluetoothReceiver;
  StreamSubscription<BluetoothDeviceState>? _bluetoothState;

  void _disconnect() async {
    await GetIt.I<BluetoothDevice>().disconnect();
  }

  Future<void> _listenCommand(String command) async {
    await _channel
        .write(command.split("").map((e) => e.codeUnitAt(0)).toList());
    return;
  }

  void _listenDisconnection(BluetoothDeviceState event) {
    if (event == BluetoothDeviceState.disconnected) {
      GetIt.I.unregister<BluetoothDevice>();
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ConnectionPage()));
    }
  }

  Future<void> _bindDevice() async {
    BluetoothDevice device = GetIt.I<BluetoothDevice>();
    BluetoothService service = (await device.discoverServices())
        .firstWhere((s) => s.uuid == Constants.device);
    _channel =
        service.characteristics.firstWhere((c) => c.uuid == Constants.channel);
    _commandStack.listen(_listenCommand);
    _bluetoothState = device.state.listen(_listenDisconnection);
    return;
  }

  void _startLogWatcher() async {
    _channel.setNotifyValue(true);
    _bluetoothReceiver = _channel.value.listen((event) {
      String now = _dateFormat.format(DateTime.now());
      String log = event.map((v) => String.fromCharCode(v)).join("");

      setState(() {
        _log = [..._log, '[$now] - $log'];
      });

      Future.delayed(
        const Duration(milliseconds: 200),
        () => _scrollController
            .jumpTo(_scrollController.position.maxScrollExtent),
      );
    });
  }

  void _init() async {
    await _bindDevice();
    _startLogWatcher();
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _bluetoothReceiver!.cancel();
    _bluetoothState!.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Controles"),
        actions: [
          IconButton(
            onPressed: _disconnect,
            icon: const Icon(Icons.bluetooth_disabled),
          )
        ],
      ),
      body: SizedBox.expand(
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.only(
              top: 50.0,
              left: 20.0,
              bottom: 20.0,
              right: 20.0,
            ),
            child: Column(
              children: [
                GestureDetector(
                  onTapDown: (_) => _commandStack.add("+U"),
                  onTapUp: (_) => _commandStack.add("-U"),
                  child: const Icon(
                    Icons.keyboard_arrow_up,
                    size: 60.0,
                  ),
                ),
                const SizedBox(
                  height: 30.0,
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTapDown: (_) => _commandStack.add("+LF"),
                      onTapUp: (_) => _commandStack.add("-LF"),
                      child: const Icon(
                        Icons.keyboard_arrow_left,
                        size: 60.0,
                      ),
                    ),
                    const SizedBox(width: 15.0),
                    GestureDetector(
                      onTapDown: (_) => _commandStack.add("+L"),
                      onTapUp: (_) => _commandStack.add("-L"),
                      child: const Icon(
                        Icons.arrow_left,
                        size: 60.0,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTapDown: (_) => _commandStack.add("+R"),
                      onTapUp: (_) => _commandStack.add("-R"),
                      child: const Icon(
                        Icons.arrow_right,
                        size: 60.0,
                      ),
                    ),
                    const SizedBox(width: 15.0),
                    GestureDetector(
                      onTapDown: (_) => _commandStack.add("+RF"),
                      onTapUp: (_) => _commandStack.add("-RF"),
                      child: const Icon(
                        Icons.keyboard_arrow_right,
                        size: 60.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 30.0,
                ),
                GestureDetector(
                  onTapDown: (_) => _commandStack.add("+D"),
                  onTapUp: (_) => _commandStack.add("-D"),
                  child: const Icon(
                    Icons.keyboard_arrow_down,
                    size: 60.0,
                  ),
                ),
                const SizedBox(height: 20.0),
                Expanded(
                  child: Container(
                    color: Colors.black,
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: _log.length,
                      itemBuilder: (itemContext, index) => Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5.0,
                          vertical: 2.0,
                        ),
                        child: Text(
                          _log[index],
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
