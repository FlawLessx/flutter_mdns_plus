import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_mdns_plugin_plus/flutter_mdns_plugin_plus.dart';

void main() => runApp(new MyApp());

const String discovery_service = "_googlecast._tcp";

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late FlutterMdnsPlugin _mdnsPlugin;
  List<String> messageLog = <String>[];
  late DiscoveryCallbacks discoveryCallbacks;
  // ignore: unused_field
  List<ServiceInfo> _discoveredServices = <ServiceInfo>[];

  @override
  initState() {
    super.initState();

    discoveryCallbacks = new DiscoveryCallbacks(
      onDiscovered: (ServiceInfo info) {
        print("Discovered ${info.toString()}");
        setState(() {
          messageLog.insert(0, "DISCOVERY: Discovered ${info.toString()}");
        });
      },
      onDiscoveryStarted: () {
        print("Discovery started");
        setState(() {
          messageLog.insert(0, "DISCOVERY: Discovery Running");
        });
      },
      onDiscoveryStopped: () {
        print("Discovery stopped");
        setState(() {
          messageLog.insert(0, "DISCOVERY: Discovery Not Running");
        });
      },
      onResolved: (ServiceInfo info) {
        print("Resolved Service ${info.toString()}");
        setState(() {
          messageLog.insert(0, "DISCOVERY: Resolved ${info.toString()}");
        });
      },
    );

    messageLog.add("Starting mDNS for service [$discovery_service]");
    startMdnsDiscovery(discovery_service);
  }

  startMdnsDiscovery(String serviceType) {
    _mdnsPlugin = new FlutterMdnsPlugin(discoveryCallbacks: discoveryCallbacks);
    // cannot directly start discovery, have to wait for ios to be ready first...
    Timer(Duration(seconds: 3), () => _mdnsPlugin.startDiscovery(serviceType));
//    mdns.startDiscovery(serviceType);
  }

  void reassemble() {
    super.reassemble();

    // ignore: unnecessary_null_comparison
    if (null != _mdnsPlugin) {
      _discoveredServices = <ServiceInfo>[];
      _mdnsPlugin.restartDiscovery();
    }
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
          body: new ListView.builder(
        reverse: true,
        itemCount: messageLog.length,
        itemBuilder: (BuildContext context, int index) {
          return new Text(messageLog[index]);
        },
      )),
    );
  }
}
