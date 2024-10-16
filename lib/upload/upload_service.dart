import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; 
import 'package:image_picker/image_picker.dart'; // Usar para trabalhar com XFile

class UploadService {
  // Definição do baseUrl dentro da classe com suporte a variáveis de ambiente
  static String baseUrl = const String.fromEnvironment('API_URL', defaultValue: 'http://divinas.local:8000');

  // URL dos endpoints de upload
  final String profileUploadUrl = '$baseUrl/v1/girl/upload-profile-image';
  final String coverUploadUrl = '$baseUrl/v1/girl/upload-cover-image';
  final String feedUploadUrl = '$baseUrl/v1/girl/upload-feed-image';

  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  // Método para fazer upload da imagem de perfil (XFile)
  Future<void> uploadProfileImage(XFile imageFile) async {
    await _uploadImage(imageFile, profileUploadUrl);
  }

  // Método para fazer upload da imagem de capa (XFile)
  Future<void> uploadCoverImage(XFile imageFile) async {
    await _uploadImage(imageFile, coverUploadUrl);
  }

  Future<void> uploadFeedImages(List<XFile> images) async {
    for (var image in images) {
      await _uploadImage(image, feedUploadUrl);
    }
  }

  // Método privado para fazer o upload da imagem (usado por ambos)
  Future<void> _uploadImage(XFile imageFile, String uploadUrl) async {
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

      // Envia a requisição
      var response = await request.send();

      if (response.statusCode == 200) {
        print('Imagem enviada com sucesso');
      } else {
        print('Falha no envio da imagem: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro ao enviar imagem: $e');
    }
  }
}