import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityHandler extends StatefulWidget {
  final Widget child;
  final Widget noConnectionWidget;

  const ConnectivityHandler({
    Key? key,
    required this.child,
    this.noConnectionWidget = const Center(child: Text('No internet connection')),
  }) : super(key: key);

  @override
  _ConnectivityHandlerState createState() => _ConnectivityHandlerState();
}

class _ConnectivityHandlerState extends State<ConnectivityHandler> {
  final Connectivity _connectivity = Connectivity();
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> _checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    _updateConnectionStatus(result);
  }

  void _updateConnectionStatus(ConnectivityResult result) {
    setState(() {
      _isConnected = result != ConnectivityResult.none;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isConnected ? widget.child : widget.noConnectionWidget;
  }
}