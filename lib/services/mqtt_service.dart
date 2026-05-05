import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import '../models/gps_data.dart';

class MqttService {
  final String broker;
  final String topic;
  late MqttServerClient _client;
  
  final _controller = StreamController<GpsData>.broadcast();
  Stream<GpsData> get gpsStream => _controller.stream;

  final ValueNotifier<bool> isConnected = ValueNotifier(false);

  MqttService({required this.broker, required this.topic});

  Future<void> connect() async {
    String clientId = 'flutter_client_${DateTime.now().millisecondsSinceEpoch}';
    _client = MqttServerClient(broker, clientId);
    _client.port = 1883;
    _client.keepAlivePeriod = 20;
    _client.logging(on: false);

    _client.onConnected = () {
      isConnected.value = true;
      debugPrint('MQTT connected');
    };

    _client.onDisconnected = () {
      isConnected.value = false;
      debugPrint('MQTT disconnected');
    };

    final connMessage = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .startClean()
        .withWillQos(MqttQos.atMostOnce);
    _client.connectionMessage = connMessage;

    try {
      await _client.connect();
    } catch (e) {
      debugPrint('MQTT connection failed: $e');
      _client.disconnect();
    }

    _client.subscribe(topic, MqttQos.atMostOnce);

    _client.updates?.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage recMess = c.first.payload as MqttPublishMessage;
      final String payload = MqttPublishPayload.bytesToStringAsString(
        recMess.payload.message,
      );

      try {
        final Map<String, dynamic> data = jsonDecode(payload);
        final gpsData = GpsData.fromJson(data);
        _controller.add(gpsData);
      } catch (e) {
        debugPrint("Error parsing MQTT payload: $e");
      }
    });
  }

  void disconnect() {
    _client.disconnect();
    _controller.close();
  }
}
