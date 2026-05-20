import 'package:flutter/material.dart';

import '../widgets/botao_dispositivo.dart';
import 'tela_mapa.dart';

class TelaSelecao extends StatelessWidget {
  const TelaSelecao({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text("Dispositivos Disponíveis"),
        backgroundColor: const Color(0xFF4F6D4A),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          BotaoDispositivo(
            nome: "ESP32 - 01",
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MapScreen()),
            ),
          ),
          BotaoDispositivo(
            nome: "ESP32 - 02",
            onTap: () {}, // Adicionar lógica futura
          ),
          BotaoDispositivo(
            nome: "ESP32 - 03",
            onTap: () {}, // Adicionar lógica futura
          ),
          BotaoDispositivo(
            nome: "ESP32 - 04",
            onTap: () {}, // Adicionar lógica futura
          ),
          BotaoDispositivo(
            nome: "ESP32 - 05",
            onTap: () {}, // Adicionar lógica futura
          ),
          BotaoDispositivo(
            nome: "ESP32 - 06",
            onTap: () {}, // Adicionar lógica futura
          ),
          BotaoDispositivo(
            nome: "ESP32 - 07",
            onTap: () {}, // Adicionar lógica futura
          ),
          BotaoDispositivo(
            nome: "ESP32 - 08",
            onTap: () {}, // Adicionar lógica futura
          ),
          BotaoDispositivo(
            nome: "ESP32 - 09",
            onTap: () {}, // Adicionar lógica futura
          ),
          BotaoDispositivo(
            nome: "ESP32 - 10",
            onTap: () {}, // Adicionar lógica futura
          ),
        ],
      ),
    );
  }
}
