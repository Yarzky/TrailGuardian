import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants.dart';
import 'services/mqtt_service.dart';
import 'controllers/gps_controller.dart';
import 'view/tela_inicio.dart';

void main() {
  final mqttService = MqttService(
    broker: AppConstants.mqttBroker,
    topic: AppConstants.mqttTopic,
  );
  
  // Connect to MQTT when app starts or when needed
  mqttService.connect();

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: mqttService),
        ChangeNotifierProvider(create: (_) => GpsController(mqttService)),
      ],
      child: const TrailGuardianApp(),
    ),
  );
}

class TrailGuardianApp extends StatelessWidget {
  const TrailGuardianApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Trail Guardian',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const TelaInicio(),
    );
  }
}
