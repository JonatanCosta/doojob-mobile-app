import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class RegisterService {
  // Definição do baseUrl dentro da classe com suporte a variáveis de ambiente
  static String baseUrl = const String.fromEnvironment('API_URL', defaultValue: 'http://divinas.local:8000');

  // Instância do storage para salvar o token de forma segura
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  // Método para logar
  Future<bool> register(String name, String telephone, String password) async {
    final url = Uri.parse('$baseUrl/v1/users'); // Ajuste para a rota correta de login da API

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'password': password,
        'telephone': telephone,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final token = responseData['access_token'];

      // Salva o token de forma segura
      await storage.write(key: 'bearer_token', value: token);

      print("bearer_token salvo: $token");

      return true; // Login bem-sucedido
    } else {
      return false; // Falha no login
    }
  }

  // Método para recuperar o token armazenado
  Future<String?> getBearerToken() async {
    return await storage.read(key: 'bearer_token');
  }

  // Método para logout
  Future<void> logout() async {
    await storage.delete(key: 'bearer_token'); // Remove o token ao fazer logout
  }

  Future<bool> isLogged() async {
    final token = await getBearerToken(); // Verifica se o token existe

    if (token != null) {
     return true;
    }

    return false;
  }
}