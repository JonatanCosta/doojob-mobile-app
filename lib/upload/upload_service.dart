import 'dart:typed_data';
import 'package:http/http.dart' as http;
// ignore: depend_on_referenced_packages
import 'package:http_parser/http_parser.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; 
import 'package:image_picker/image_picker.dart'; // Usar para trabalhar com XFile
//import 'package:image/image.dart' as img;

class UploadService {
  // Definição do baseUrl dentro da classe com suporte a variáveis de ambiente
  static String baseUrl = const String.fromEnvironment('API_URL', defaultValue: 'http://divinas.local:8000');

  // URL dos endpoints de upload
  final String profileUploadUrl = '$baseUrl/v1/girl/upload-profile-image';
  final String coverUploadUrl = '$baseUrl/v1/girl/upload-cover-image';
  final String feedUploadUrl = '$baseUrl/v1/girl/upload-feed-image';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Método para fazer upload da imagem de perfil (XFile)
  Future<void> uploadProfileImage(XFile imageFile) async {
    await uploadImage(imageFile, profileUploadUrl);
  }

  // Método para fazer upload da imagem de capa (XFile)
  Future<void> uploadCoverImage(XFile imageFile) async {
    await uploadImage(imageFile, coverUploadUrl);
  }

  Future<void> uploadFeedImage(XFile imageFile) async {
    await uploadImage(imageFile, feedUploadUrl);
  }

  // Método privado para fazer o upload da imagem (usado por ambos)
  Future<void> uploadImage(XFile imageFile, String uploadUrl) async {
    try {
      // Recupera o token do storage
      String? token = await _secureStorage.read(key: 'bearer_token');

      // Lê o arquivo XFile como bytes
      Uint8List fileBytes = await imageFile.readAsBytes();

      var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));

      // Adiciona os headers 'Accept' e 'Authorization'
      request.headers['Accept'] = 'application/json';
      request.headers['Authorization'] = 'Bearer $token';

      // Adiciona o arquivo na requisição
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: imageFile.name, // O nome do arquivo com extensão
          contentType: MediaType('image', imageFile.mimeType?.split('/').last ?? 'jpeg'), // Define o tipo de mídia
        ),
      );

      print('Request files: ${request.files}');

      // Envia a requisição
      var response = await request.send();

      if (response.statusCode != 200) {
        throw Exception('Falha no envio da imagem: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao enviar imagem: $e');
      rethrow;
    }
  }
}