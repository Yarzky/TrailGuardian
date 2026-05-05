import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';
import '../controllers/gps_controller.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  bool _alertaAberto = false;

  @override
  void initState() {
    super.initState();
    // Listen for SOS changes to show dialog
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<GpsController>();
      controller.addListener(_handleSosAlert);
    });
  }

  void _handleSosAlert() {
    final controller = context.read<GpsController>();
    
    // Move map to current position
    _mapController.move(controller.currentPos, _mapController.camera.zoom);

    if (controller.isSos && !_alertaAberto) {
      _mostrarAlertaEmergencia();
    }
  }

  void _mostrarAlertaEmergencia() {
    setState(() => _alertaAberto = true);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.red,
        title: const Text("🚨 SOS ATIVO", style: TextStyle(color: Colors.white)),
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
  void dispose() {
    // Note: We don't dispose the controller here because it's managed by Provider
    // but we should remove our listener
    context.read<GpsController>().removeListener(_handleSosAlert);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GpsController>(
      builder: (context, controller, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Trail Guardian GPS',
                style: TextStyle(color: Colors.white)),
            backgroundColor: controller.isSos ? Colors.red : const Color(0xFF4F6D4A),
          ),
          body: Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: controller.currentPos,
                  initialZoom: 15.5,
                ),
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
                        points: controller.rastro,
                        color: Colors.blue.withOpacity(0.7),
                        strokeWidth: 5.0,
                        strokeCap: StrokeCap.round,
                        strokeJoin: StrokeJoin.round,
                      ),
                    ],
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: controller.currentPos,
                        width: 80,
                        height: 80,
                        child: Icon(
                          Icons.location_on,
                          size: controller.isSos ? 60 : 45,
                          color: controller.isSos ? Colors.red : Colors.blue,
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
                    controller.isConnected ? "● Online" : "○ Offline",
                    style: TextStyle(
                      color: controller.isConnected ? Colors.green : Colors.red,
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
                      _buildDataRow("Lat:", controller.currentPos.latitude.toStringAsFixed(6)),
                      _buildDataRow("Lon:", controller.currentPos.longitude.toStringAsFixed(6)),
                      _buildDataRow("Vel:", "${controller.speed.toStringAsFixed(1)} km/h"),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange),
                          onPressed: () => controller.limparRastro(),
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
            backgroundColor: controller.isSos ? Colors.red : Colors.blue,
            onPressed: () => _mapController.move(controller.currentPos, 15.5),
            child: const Icon(Icons.my_location, color: Colors.white),
          ),
        );
      },
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
