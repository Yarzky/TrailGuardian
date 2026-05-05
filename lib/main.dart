import 'package:flutter/material.dart';

import 'view/tela_inicio.dart';

void main() => runApp(const TrailGuardianApp());

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
