import 'package:aspirator5000/constants.dart';
import 'package:aspirator5000/views/pages/home.page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:get_it/get_it.dart';

class ConnectionPage extends StatefulWidget {
  const ConnectionPage({Key? key}) : super(key: key);
  @override
  _ConnectionPageState createState() => _ConnectionPageState();
}

class _ConnectionPageState extends State<ConnectionPage> {
  List<ScanResult> _devices = [];

  bool _loading = false;

  void _getBluetoothDevices() async {
    if (!_loading) {
      _loading = true;

      List<ScanResult> devices = await FlutterBlue.instance.scan(
        timeout: const Duration(seconds: 10),
        withDevices: [Constants.device],
      ).toList();

      setState(() {
        _devices = devices;
      });

      _loading = false;
    }
  }

  void _connectTo(BluetoothDevice device) async {
    try {
      if (GetIt.I.isRegistered<BluetoothDevice>()) {
        GetIt.I<BluetoothDevice>().disconnect();
        GetIt.I.unregister<BluetoothDevice>();
      }

      await device.connect(
        timeout: const Duration(seconds: 5),
        autoConnect: false,
      );

      GetIt.I.registerSingleton<BluetoothDevice>(device);
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            Text('Não foi possível conectar ao dispositivo: ${e.toString()}'),
      ));
    }
  }

  @override
  void initState() {
    super.initState();
    _getBluetoothDevices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Conectar ao dispositivo"),
        actions: [
          IconButton(
            onPressed: _getBluetoothDevices,
            icon: const Icon(Icons.sync),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _devices.length,
        itemBuilder: (context, index) => ListTile(
          title: Text(
            _devices[index].device.name.isNotEmpty
                ? _devices[index].device.name
                : "Desconhecido",
          ),
          subtitle: Text(_devices[index].device.id.toString()),
          onTap: () => _connectTo(_devices[index].device),
        ),
      ),
    );
  }
}
