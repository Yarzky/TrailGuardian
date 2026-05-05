import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final String broker = '192.168.2.156';
  final String topic = 'trailguardian/gps';
  late MqttServerClient client;
  final MapController _mapController = MapController();

  // ✅ Objeto para calcular distância entre coordenadas (filtro de ruído)
  final Distance distance = const Distance();

  LatLng currentPos = const LatLng(-23.57, -48.03);
  List<LatLng> rastro = [];
  double speed = 0.0;
  bool isSos = false;
  bool isConnected = false;
  bool _alertaAberto = false;

  @override
  void initState() {
    super.initState();
    _setupMqtt();
  }

  Future<void> _setupMqtt() async {
    String clientId = 'flutter_client_${DateTime.now().millisecondsSinceEpoch}';
    client = MqttServerClient(broker, clientId);
    client.port = 1883;
    client.keepAlivePeriod = 20;

    client.onConnected = () => setState(() => isConnected = true);
    client.onDisconnected = () => setState(() => isConnected = false);

    try {
      await client.connect();
    } catch (e) {
      return;
    }

    client.subscribe(topic, MqttQos.atMostOnce);
    client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage recMess = c.first.payload as MqttPublishMessage;
      final String payload = MqttPublishPayload.bytesToStringAsString(
        recMess.payload.message,
      );

      try {
        final data = jsonDecode(payload);
        LatLng novaPosicao = LatLng(
          double.parse(data['lat'].toString()),
          double.parse(data['lon'].toString()),
        );
        double novaVelocidade = double.parse(data['vel'].toString());

        setState(() {
          currentPos = novaPosicao;
          speed = novaVelocidade;

          // --- 🛡️ LÓGICA DE SUAVIZAÇÃO DO RASTRO ---
          if (rastro.isEmpty) {
            rastro.add(novaPosicao);
          } else {
            // Calcula distância do último ponto em metros
            double metros =
                distance.as(LengthUnit.Meter, rastro.last, novaPosicao);

            // FILTROS:
            // 1. Só adiciona se moveu mais de 2.5 metros (evita o "tremido" parado)
            // 2. Só adiciona se a velocidade for real (> 0.8 km/h)
            if (metros > 2.5 && novaVelocidade > 0.8) {
              rastro.add(novaPosicao);
            }
          }
          // ----------------------------------------

          bool novoSos = data['sos'].toString() == "1";
          if (novoSos && !isSos) _mostrarAlertaEmergencia();
          isSos = novoSos;

          // Segue o marcador mantendo o zoom atual
          _mapController.move(currentPos, _mapController.camera.zoom);
        });
      } catch (e) {
        debugPrint("Erro JSON: $e");
      }
    });
  }

  void _mostrarAlertaEmergencia() {
    if (_alertaAberto) return;
    setState(() => _alertaAberto = true);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.red,
        title:
            const Text("🚨 SOS ATIVO", style: TextStyle(color: Colors.white)),
        content: const Text("Pedido de socorro recebido!",
            style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            style: TextButton.styleFrom(backgroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(context);
              setState(() => _alertaAberto = false);
            },
            child: const Text("OK", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trail Guardian GPS',
            style: TextStyle(color: Colors.white)),
        backgroundColor: isSos ? Colors.red : const Color(0xFF4F6D4A),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(initialCenter: currentPos, initialZoom: 15.5),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
                userAgentPackageName: 'com.example.trail_guardian_r02',
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: rastro,
                    color: Colors.blue.withOpacity(0.7),
                    strokeWidth: 5.0,
                    // ✅ Parâmetros corrigidos para rastro suave
                    strokeCap: StrokeCap.round,
                    strokeJoin: StrokeJoin.round,
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: currentPos,
                    width: 80,
                    height: 80,
                    child: Icon(
                      Icons.location_on,
                      size: isSos ? 60 : 45,
                      color: isSos ? Colors.red : Colors.blue,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Indicador Online/Offline
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isConnected ? "● Online" : "○ Offline",
                style: TextStyle(
                  color: isConnected ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Painel de Dados
          Positioned(
            bottom: 20,
            left: 15,
            child: Container(
              width: 210,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(15),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 5)
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("📍 Dados Técnicos",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const Divider(),
                  _buildDataRow("Lat:", currentPos.latitude.toStringAsFixed(6)),
                  _buildDataRow(
                      "Lon:", currentPos.longitude.toStringAsFixed(6)),
                  _buildDataRow("Vel:", "${speed.toStringAsFixed(1)} km/h"),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange),
                      onPressed: () => setState(() => rastro.clear()),
                      child: const Text("Limpar Rastro",
                          style: TextStyle(color: Colors.white)),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: isSos ? Colors.red : Colors.blue,
        onPressed: () => _mapController.move(currentPos, 15.5),
        child: const Icon(Icons.my_location, color: Colors.white),
      ),
    );
  }

  Widget _buildDataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}
