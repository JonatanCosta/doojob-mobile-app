import 'package:flutter/material.dart';
import '../../../upload/upload_service.dart';
import 'package:image_picker/image_picker.dart';
// import 'dart:typed_data';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';


class MediaGallery extends StatelessWidget {
  final List<dynamic> medias; // Lista de mídias
  final bool canEdit; // Verificar se o usuário pode editar
  
  MediaGallery({
    Key? key,
    required this.medias,
    required this.canEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView( // Adicione este widget para permitir rolagem
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Título "Galeria de Imagens e Vídeos"
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.photo_library_outlined, size: 24, color: Colors.black),
              SizedBox(width: 5),
              Text(
                'Galeria de Imagens e Vídeos',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Botão "Enviar mais fotos" se canEdit for verdadeiro e já houver mídias
          if (canEdit && medias.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showImagePicker(context, 'feed_img'); // Abre o modal de seleção de imagem
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.upload, color: Colors.white),
                  label: const Text(
                    'Enviar fotos',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 10),

          // Exibir a galeria em grid se houver mídias
          medias.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: GridView.builder(
                    shrinkWrap: true, // Permite que o GridView se ajuste ao conteúdo
                    physics: const NeverScrollableScrollPhysics(), // Evita que o GridView role de forma independente
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, // Exibir 3 mídias por linha
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4,
                    ),
                    itemCount: medias.length,
                    itemBuilder: (context, index) {
                      final media = medias[index];
                      return GestureDetector(
                        onTap: () {
                          _openFullScreenGallery(context, index); // Abre a galeria fullscreen
                        },
                        child: CachedNetworkImage(
                          imageUrl: media['url'],
                          fit: BoxFit.cover,
                          placeholder: (context, url) => CircularProgressIndicator(
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF5252)),
                          ),
                          errorWidget: (context, url, error) => const Icon(Icons.error),
                        ),
                      );
                    },
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _showImagePicker(context, 'feed_img');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.upload, color: Colors.white),
                      label: const Text(
                        'Envie sua primeira foto',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  final ImagePicker _picker = ImagePicker();
  final UploadService uploadService = UploadService();

  void _showImagePicker(BuildContext context, String imageType) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Selecionar da Galeria'),
                onTap: () async {
                  List<XFile>? images = await _picker.pickMultiImage(); 

                  if (images.isNotEmpty) {
                    _showImagePreview(context, images);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }



void _showImagePreview(BuildContext context, List<XFile> images) async {
  bool isUploading = false; // Variável para controlar o estado de envio
  double progress = 0.0;

  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Confirmação:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isUploading) // Exibe o texto inicial apenas se não estiver enviando
                  Text(
                    'Você está enviando ${images.length} fotos. Essas fotos serão analisadas por nossa equipe em um prazo de até 2h.',
                    style: TextStyle(fontSize: 16),
                  ),
                if (isUploading) // Exibe o texto "Aguarde..." durante o upload
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      'Aguarde o fim do envio, não feche essa página.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                const SizedBox(height: 20),
                if (isUploading)
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[300],
                    color: Color(0xFFFF5252),
                  ),
              ]
            ),
            actions: [
              ElevatedButton(
                onPressed: isUploading ? null : () async {
                  // Define o estado como enviando
                  setState(() {
                    isUploading = true;
                    progress = 0.0;
                  });

                  for (int i = 0; i < images.length; i++) {
                    await uploadService.uploadFeedImage(images[i]);

                    setState(() {
                      progress = (i + 1) / images.length;
                    });
                  }

                  Navigator.of(dialogContext).pop();

                  Navigator.of(context).pop();

                  context.pushReplacement('/painel');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isUploading ? Colors.grey : Color(0xFFFF5252), // Cor do botão
                ),
                child: isUploading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Confirmar Envio',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
              ),
              TextButton(
                onPressed: isUploading
                    ? null
                    : () {
                        Navigator.of(dialogContext).pop(); // Fecha o modal se o usuário cancelar
                      },
                child: Text('Cancelar'),
              ),
            ],
          );
        },
      );
    },
  );
}
  // Função para abrir a galeria fullscreen com PageView
  void _openFullScreenGallery(BuildContext context, int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenGallery(
          medias: medias,
          initialIndex: initialIndex,
        ),
      ),
    );
  }
}

class FullScreenGallery extends StatefulWidget {
  final List<dynamic> medias;
  final int initialIndex;

  const FullScreenGallery({
    Key? key,
    required this.medias,
    required this.initialIndex,
  }) : super(key: key);

  @override
  _FullScreenGalleryState createState() => _FullScreenGalleryState();
}

class _FullScreenGalleryState extends State<FullScreenGallery> {
  late int _currentIndex;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.medias.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return Center(
                child: CachedNetworkImage(
                  imageUrl: widget.medias[index]['url'],
                  fit: BoxFit.cover,
                  placeholder: (context, url) => CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF5252))),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              );
            },
          ),
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () {
                Navigator.of(context).pop(); // Fecha a galeria fullscreen
              },
            ),
          ),
        ],
      ),
    );
  }
}