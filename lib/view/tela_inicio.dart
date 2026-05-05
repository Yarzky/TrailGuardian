import 'package:flutter/material.dart';

import 'tela_selecao.dart';

class TelaInicio extends StatelessWidget {
  const TelaInicio({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Fundo preto sólido para integrar com as bordas da imagem
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // 1. ESPAÇO NO TOPO
            const SizedBox(height: 20),

            // 2. LOGO CENTRALIZADO (Sem cortes)
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Image.asset(
                  'assets/logo.jpeg',
                  fit: BoxFit.contain, // Garante que a imagem inteira apareça
                ),
              ),
            ),

            // 3. TEXTO DO SISTEMA (Abaixo do logo)
            const Expanded(
              flex: 2,
              child: Center(
                child: Text(
                  "SISTEMA DE RASTREAMENTO\nDE TRILHA",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),

            // 4. BOTÃO DE SELEÇÃO
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F6D4A),
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TelaSelecao(),
                      ),
                    );
                  },
                  child: const Text(
                    "SELECIONAR DISPOSITIVO",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            // 5. ESPAÇO FINAL
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
