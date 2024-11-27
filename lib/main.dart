import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const ConsultaCepApp());
}

class ConsultaCepApp extends StatelessWidget {
  const ConsultaCepApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Consulta CEP',
      theme: ThemeData(
        primarySwatch: Colors.red,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.red),
          bodyMedium: TextStyle(color: Colors.red),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          labelStyle: TextStyle(color: Colors.red),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white, backgroundColor: Colors.red,
          ),
        ),
      ),
      home: const ConsultaCepPage(),
    );
  }
}

class ConsultaCepPage extends StatefulWidget {
  const ConsultaCepPage({Key? key}) : super(key: key);

  @override
  _ConsultaCepPageState createState() => _ConsultaCepPageState();
}

class _ConsultaCepPageState extends State<ConsultaCepPage> {
  final TextEditingController _cepController = TextEditingController();
  String? _resultado;

  Future<void> _buscarCep() async {
    final cep = _cepController.text.trim();
    if (cep.isEmpty || cep.length != 8 || int.tryParse(cep) == null) {
      setState(() {
        _resultado = "Por favor, insira um CEP válido de 8 dígitos.";
      });
      return;
    }

    final url = Uri.parse("https://viacep.com.br/ws/$cep/json/");
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.containsKey('erro')) {
          setState(() {
            _resultado = "CEP não encontrado.";
          });
        } else {
          setState(() {
            _resultado = """
CEP: ${data['cep']}
Logradouro: ${data['logradouro']}
Bairro: ${data['bairro']}
Cidade: ${data['localidade']}
Estado: ${data['uf']}
""";
          });
        }
      } else {
        setState(() {
          _resultado = "Erro ao buscar o CEP. Tente novamente.";
        });
      }
    } catch (e) {
      setState(() {
        _resultado = "Erro de conexão. Verifique sua internet.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pedro Moraes Rogério - 27/11/2024"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _cepController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Digite o CEP",
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _buscarCep,
              child: const Text("Buscar"),
            ),
            const SizedBox(height: 16),
            if (_resultado != null)
              Text(
                _resultado!,
                textAlign: TextAlign.start,
                style: const TextStyle(fontSize: 16, color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}
