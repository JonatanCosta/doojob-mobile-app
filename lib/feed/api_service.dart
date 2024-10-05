import 'dart:convert';
import 'package:http/http.dart' as http;
//import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  static const String apiUrl = String.fromEnvironment('API_URL', defaultValue: 'http://divinas.local:8000');

  final String baseUrl = '$apiUrl/api/girls';

  Future<Map<String, dynamic>> fetchGirls(int page) async {
    final url = '$baseUrl?page=$page';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Falha ao carregar as modelos');
    }
  }
}