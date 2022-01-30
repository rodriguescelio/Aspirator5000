import 'package:aspirator5000/views/pages/connection.page.dart';
import 'package:aspirator5000/views/pages/home.page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:get_it/get_it.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({Key? key}) : super(key: key);

  void _checkBluetoothConnection(BuildContext context) async {
    FlutterBlue flutterBlue = FlutterBlue.instance;

    List<BluetoothDevice> connectedDevices = await flutterBlue.connectedDevices;

    if (connectedDevices.isNotEmpty) {
      if (GetIt.I.isRegistered<BluetoothDevice>()) {
        GetIt.I.unregister<BluetoothDevice>();
      }

      GetIt.I.registerSingleton<BluetoothDevice>(connectedDevices[0]);

      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
    } else {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ConnectionPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    _checkBluetoothConnection(context);
    return Container(
      color: Colors.blueAccent[100],
    );
  }
}
