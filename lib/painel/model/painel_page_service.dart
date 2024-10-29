import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class PainelPageService {
  static String baseUrl = const String.fromEnvironment('API_URL', defaultValue: 'http://divinas.local:8000');
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  // Método para buscar os dados da model
  Future<Map<String, dynamic>?> fetchGirl() async {
    // Busca o token armazenado
    String? token = await storage.read(key: 'bearer_token');
    if (token == null) return null;

    final response = await http.get(
      Uri.parse('$baseUrl/v1/girl'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['model']; // Supondo que o retorno seja um objeto "girl"
    } else {
      return null;
    }
  }

  // Método para buscar os dados da model
  Future<Map<String, dynamic>?> fetchProfile(String girlID) async {
    // Busca o token armazenado
    String? token = await storage.read(key: 'bearer_token');

    final response = await http.get(
      Uri.parse('$baseUrl/v1/girl/$girlID'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['model']; // Supondo que o retorno seja um objeto "girl"
    } else {
      return null;
    }
  }

  // Método para buscar os dados da model
  Future<Map<String, dynamic>?> fetchUser() async {
    // Busca o token armazenado
    String? token = await storage.read(key: 'bearer_token');
    if (token == null) return null;

    final response = await http.get(
      Uri.parse('$baseUrl/v1/user'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['user']; // Supondo que o retorno seja um objeto "girl"
    } else {
      return null;
    }
  }

  Future<http.Response> submitGirlData(Map<String, String> data) async {
    final token = await storage.read(key: 'bearer_token'); // Recupera o token armazenado
    final response = await http.post(
      Uri.parse('$baseUrl/v1/girls'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );
    return response;
  }

  Future<http.Response> updateGirlCity(Map<String, String> data) async {
    final token = await storage.read(key: 'bearer_token'); // Recupera o token armazenado
    final response = await http.post(
      Uri.parse('$baseUrl/v1/girl/update-city'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );
    return response;
  }

  Future<http.Response> updateGirlLocals(Map<String, List<dynamic>> data) async {
    final token = await storage.read(key: 'bearer_token'); // Recupera o token armazenado
    final response = await http.post(
      Uri.parse('$baseUrl/v1/girl/update-locals'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );
    return response;
  }

  Future<http.Response> updateGirlPayments(Map<String, List<dynamic>> data) async {
    final token = await storage.read(key: 'bearer_token'); // Recupera o token armazenado
    final response = await http.post(
      Uri.parse('$baseUrl/v1/girl/update-payments'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );
    return response;
  }
}