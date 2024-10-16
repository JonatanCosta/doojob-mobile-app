import 'package:flutter/material.dart';
import '../../upload/upload_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data'; // Para exibir a imagem em memória no web
import 'profile/model_profile_info.dart';

class ModelProfileScaffold extends StatelessWidget {
  final Map<String, dynamic> girlData;
  final bool canEdit;
  final UploadService uploadService = UploadService();

  ModelProfileScaffold({required this.girlData, required this.canEdit});

  final String defaultImageUrl = 'https://doojobbucket.s3.sa-east-1.amazonaws.com/logos/0d64989794b1a4c9d89bff571d3d5842.jpg';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Capa
            GestureDetector(
              onTap: () {
                if (canEdit) {
                  _showImagePicker(context, 'cover_img');
                }
              },
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(girlData['cover_img'] ?? defaultImageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            // Imagem de perfil
            Container(
              transform: Matrix4.translationValues(0.0, -50.0, 0.0), // Move a imagem de perfil para cima
              child: GestureDetector(
                onTap: () {
                  if (canEdit) {
                    _showImagePicker(context, 'profile_img');
                  }
                },
                child: Material(
                  elevation: 8,
                  shape: CircleBorder(),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child: CircleAvatar(
                    radius: 70, // Tamanho da imagem de perfil
                    backgroundImage: NetworkImage(girlData['profile_img'] ?? defaultImageUrl),
                  ),
                ),
              ),
            ),
            // Espaçamento entre a imagem de perfil e os dados
            // Exibição dos dados da girlData
            Transform(
              transform: Matrix4.translationValues(0.0, -30.0, 0.0), // Sobe o widget 50 pixels
              child: ModelProfileInfo(
                girlData: girlData,
                canEdit: canEdit,
              ),
            ),
          ],
        ),
      ),
    );
  }

  final ImagePicker _picker = ImagePicker();

  void _showImagePicker(BuildContext context, String imageType) {
    final scaffoldContext = context; // Salva o contexto atual do Scaffold
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Selecionar da Galeria'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

                  if (image != null) {
                    _showImagePreview(scaffoldContext, image, imageType);
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Tirar uma Foto'),
                onTap: () async {
                  Navigator.of(context).pop();
                  final XFile? image = await _picker.pickImage(source: ImageSource.camera);

                  if (image != null) {
                    _showImagePreview(scaffoldContext, image, imageType);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

 void _showImagePreview(BuildContext context, XFile image, String imageType) async {
    Uint8List imageBytes = await image.readAsBytes(); // Lê a imagem como bytes

    showDialog(
      context: context, // Usa o contexto salvo
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirme o envio da imagem'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.memory(imageBytes, height: 200, width: 200, fit: BoxFit.cover), // Exibe o preview da imagem
              SizedBox(height: 20),
              Text('Deseja enviar esta imagem?'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Fechar o preview sem enviar
              child: Text('Cancelar'),
            ),
            ElevatedButton(
                onPressed: () async {
                  bool uploadSuccess = false;

                  try {
                    // Verifica o tipo de imagem e tenta fazer o upload
                    if (imageType == 'profile_img') {
                      await uploadService.uploadProfileImage(image); // Envia a imagem de perfil
                    } else if (imageType == 'cover_img') {
                      await uploadService.uploadCoverImage(image); // Envia a imagem de capa
                    }

                    Navigator.of(context).pop(); // Fecha o modal de preview

                    // Se chegar até aqui, o upload foi bem-sucedido
                    uploadSuccess = true;

                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Foto Adicionada com sucesso!')));

                    // Redireciona para o painel
                    Navigator.pushReplacementNamed(context, '/painel');
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ocorreu um erro ao enviar sua foto!')));
                  }
                },
                child: Text('Confirmar'),
              ),
          ],
        );
      },
    );
  }

  void _openWhatsAppSupport() {
    // Método para abrir o WhatsApp
  }

  // Função para validar se o arquivo é uma imagem ou vídeo
  bool _isValidFile(XFile file) {
    final validImageExtensions = ['jpg', 'jpeg', 'png', 'gif'];
    final validVideoExtensions = ['mp4', 'mov', 'avi', 'mkv'];

    // Obtém a extensão do arquivo selecionado
    final fileExtension = file.path.split('.').last.toLowerCase();

    // Verifica se a extensão está na lista de extensões permitidas
    return validImageExtensions.contains(fileExtension) || validVideoExtensions.contains(fileExtension);
  }

  // Função para exibir uma mensagem de erro caso o arquivo seja inválido
  void _showInvalidFileError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Selecione apenas imagens ou vídeos válidos!')),
    );
  }
}