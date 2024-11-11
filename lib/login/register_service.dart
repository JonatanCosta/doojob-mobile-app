import 'dart:convert';
//import 'dart:ffi';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'package:g_recaptcha_v3/g_recaptcha_v3.dart';

class RegisterService {
  // Definição do baseUrl dentro da classe com suporte a variáveis de ambiente
  static String baseUrl = const String.fromEnvironment('API_URL', defaultValue: 'http://divinas.local:8000');

  // Instância do storage para salvar o token de forma segura
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  // Método para logar
  Future<bool> register(String name, String telephone, String password, bool isModel) async {
    final url = Uri.parse('$baseUrl/v1/users'); // Ajuste para a rota correta de login da API

    final token = await GRecaptchaV3.execute('register');
    
    if (token == null) {
      return false;
    }

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
        'is_model': isModel,
        'recaptcha_token': token,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final token = responseData['access_token'];
      final isModel = responseData['is_model'];

      // Salva o token de forma segura
      await storage.write(key: 'bearer_token', value: token);
      await storage.write(key: 'is_model', value: isModel.toString());

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