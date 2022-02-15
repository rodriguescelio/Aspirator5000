import 'dart:async';

import 'package:aspirator5000/utils/device.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ManualPage extends StatefulWidget {
  const ManualPage({Key? key}) : super(key: key);

  @override
  _ManualPageState createState() => _ManualPageState();
}

class _ManualPageState extends State<ManualPage> {
  final Device _device = GetIt.I<Device>();

  StreamSubscription<Map<String, dynamic>>? _subscription;

  void _onMessage(Map<String, dynamic> message) {}

  @override
  void initState() {
    super.initState();
    _subscription = _device.onMessage(_onMessage);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
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
                onTapDown: (_) => _device.send("+U"),
                onTapUp: (_) => _device.send("-U"),
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
                    onTapDown: (_) => _device.send("+LF"),
                    onTapUp: (_) => _device.send("-LF"),
                    child: const Icon(
                      Icons.keyboard_arrow_left,
                      size: 60.0,
                    ),
                  ),
                  const SizedBox(width: 15.0),
                  GestureDetector(
                    onTapDown: (_) => _device.send("+L"),
                    onTapUp: (_) => _device.send("-L"),
                    child: const Icon(
                      Icons.arrow_left,
                      size: 60.0,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTapDown: (_) => _device.send("+R"),
                    onTapUp: (_) => _device.send("-R"),
                    child: const Icon(
                      Icons.arrow_right,
                      size: 60.0,
                    ),
                  ),
                  const SizedBox(width: 15.0),
                  GestureDetector(
                    onTapDown: (_) => _device.send("+RF"),
                    onTapUp: (_) => _device.send("-RF"),
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
                onTapDown: (_) => _device.send("+D"),
                onTapUp: (_) => _device.send("-D"),
                child: const Icon(
                  Icons.keyboard_arrow_down,
                  size: 60.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
