import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../models/gps_data.dart';
import '../services/mqtt_service.dart';

class GpsController extends ChangeNotifier {
  final MqttService _mqttService;
  
  LatLng currentPos = const LatLng(-23.57, -48.03);
  List<LatLng> rastro = [];
  double speed = 0.0;
  bool isSos = false;
  bool get isConnected => _mqttService.isConnected.value;

  final Distance _distance = const Distance();

  GpsController(this._mqttService) {
    _mqttService.isConnected.addListener(notifyListeners);
    _mqttService.gpsStream.listen(_updateGpsData);
  }

  void _updateGpsData(GpsData data) {
    currentPos = data.position;
    speed = data.speed;
    
    _atualizarRastro(data.position, data.speed);
    
    isSos = data.isSos;
    
    notifyListeners();
  }

  void _atualizarRastro(LatLng novaPosicao, double novaVelocidade) {
    if (rastro.isEmpty) {
      rastro.add(novaPosicao);
    } else {
      double metros = _distance.as(LengthUnit.Meter, rastro.last, novaPosicao);

      // FILTROS:
      // 1. Só adiciona se moveu mais de 2.5 metros (evita o "tremido" parado)
      // 2. Só adiciona se a velocidade for real (> 0.8 km/h)
      if (metros > 2.5 && novaVelocidade > 0.8) {
        rastro.add(novaPosicao);
      }
    }
  }

  void limparRastro() {
    rastro.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _mqttService.isConnected.removeListener(notifyListeners);
    super.dispose();
  }
}
