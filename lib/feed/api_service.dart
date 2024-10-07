import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:do_job_app/login/login_service.dart'; // Importe o serviço de login
//import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  static const String apiUrl = String.fromEnvironment('API_URL', defaultValue: 'http://divinas.local:8000');

  final String baseUrl = '$apiUrl/v1/girls';

  Future<Map<String, dynamic>> fetchGirls(int page) async {
    final LoginService loginService = LoginService();

    final String? token = await loginService.getBearerToken(); 
  
    final url = '$baseUrl?page=$page';
    final response = await http.get(Uri.parse(url),
      headers: {
          'Content-Type': 'application/json',
          if(token != null) 'Authorization': 'Bearer $token',
        },
      );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Falha ao carregar as modelos');
    }
  }
}