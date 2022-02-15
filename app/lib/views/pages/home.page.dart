import 'dart:async';

import 'package:aspirator5000/utils/device.dart';
import 'package:aspirator5000/views/pages/automatic.page.dart';
import 'package:aspirator5000/views/pages/connection.page.dart';
import 'package:aspirator5000/views/pages/manual.page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:get_it/get_it.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final Device _device = GetIt.I<Device>();

  late TabController _tabController;

  void _disconnect() async {
    await GetIt.I<BluetoothDevice>().disconnect();
  }

  void _listenDisconnection() {
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ConnectionPage()));
  }

  void _listenError(String error) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(error),
    ));
  }

  Future<void> _bindDevice() async {
    _device.connect();
    _device.onDisconnect(_listenDisconnection);
    _device.onError(_listenError);
  }

  void _tabChanging() {
    setState(() {});
  }

  void _init() async {
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_tabChanging);
    await _bindDevice();
  }

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _device.dispose();
    super.dispose();
  }

  Widget _tabButton(String label, int index, void Function() onPressed) {
    return Flexible(
      fit: FlexFit.tight,
      child: TextButton(
        style: ButtonStyle(
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
          ),
          backgroundColor: MaterialStateProperty.all(
            _tabController.index == index ? Colors.blue : Colors.transparent,
          ),
          foregroundColor: MaterialStateProperty.all(
            _tabController.index == index ? Colors.white : Colors.blue,
          ),
        ),
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }

  void _toAutomatic() {
    _tabController.animateTo(0);
    _device.send("AUTOMATIC");
  }

  void _toManual() {
    _tabController.animateTo(1);
    _device.send("MANUAL");
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
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                child: Container(
                  padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: const BorderRadius.all(Radius.circular(30.0)),
                  ),
                  child: Row(
                    children: [
                      _tabButton("Automático", 0, _toAutomatic),
                      _tabButton("Manual", 1, _toManual),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    AutomaticPage(),
                    ManualPage(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
