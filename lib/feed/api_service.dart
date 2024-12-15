import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:do_job_app/login/login_service.dart'; // Importe o serviço de login
import '../geolocation/location.dart';
//import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  static const String apiUrl = String.fromEnvironment('API_URL', defaultValue: 'http://divinas.local:8000');

  final String baseUrl = '$apiUrl/v1/girls';

  Future<Map<String, dynamic>> fetchGirls(int page) async {
    final LoginService loginService = LoginService();
    final LocationService locationService = LocationService();

    final String? token = await loginService.getBearerToken(); 

    String? city = await locationService.getCity();
    
    if (city == null || city.isEmpty) {
      city = 'Porto Alegre';
    }

    final url = '$baseUrl?page=$page&&city=$city&&status=approved';

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

  Future<Map<String, dynamic>> fetchCities(String name) async {
    final String url = '$apiUrl/v1/cities?name=$name';
    final response = await http.get(Uri.parse(url), headers: {
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Falha ao carregar as cidades');
    }
  }

  Future<Map<String, dynamic>> fetchSearch(Map<String, dynamic> params) async {
    final LoginService loginService = LoginService();
    final LocationService locationService = LocationService();

    final String? token = await loginService.getBearerToken();

    // Obtém a cidade do objeto ou busca a cidade padrão
    String? city = params['city'] ?? await locationService.getCity();
    if (city == null || city.isEmpty) {
      city = 'Porto Alegre';
    }

    // Adiciona a cidade no mapa de parâmetros
    params['city'] = city;

    print('Parâmetros: $params');

    // Constrói a query string
    final queryString = Uri(queryParameters: params.map((key, value) => MapEntry(key, value.toString()))).query;

    print('Query string: $queryString');

    final url = '$baseUrl?$queryString';

    // Requisição HTTP
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    // Processa a resposta
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Falha ao carregar as modelos');
    }
  }

  Future<Map<String, dynamic>> fetchFilters() async {
    // Requisição HTTP
    final response = await http.get(
      Uri.parse('$apiUrl/v1/filters'),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    // Processa a resposta
    if (response.statusCode == 200) {
      return jsonDecode(response.body)['filters'];
    } else {
      throw Exception('Falha ao carregar as modelos');
    }
  }

}