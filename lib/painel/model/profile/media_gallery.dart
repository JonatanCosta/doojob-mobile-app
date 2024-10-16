import 'package:flutter/material.dart';
import '../../../upload/upload_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data'; // Para exibir a imagem em memória no web
import 'package:go_router/go_router.dart';


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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Título "Galeria de Imagens e Vídeos"
        Row(
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
        SizedBox(height: 10),

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
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Bordas arredondadas
                  ),
                ),
                icon: Icon(Icons.upload, color: Colors.white),
                label: Text(
                  'Enviar mais fotos',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        SizedBox(height: 10),

        // Exibir a galeria em grid se houver mídias
        medias.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0), // Padding lateral
                child: GridView.builder(
                  shrinkWrap: true, // Ajustar a altura ao conteúdo
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // Exibir 3 mídias por linha
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ),
                  itemCount: medias.length,
                  itemBuilder: (context, index) {
                    final media = medias[index];
                    return GestureDetector(
                      onTap: () {
                        _openFullScreenGallery(context, index); // Abrir a galeria fullscreen
                      },
                      child: Image.network(
                        media['url'], // URL da mídia
                        fit: BoxFit.cover,
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
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8), // Bordas arredondadas
                      ),
                    ),
                    icon: Icon(Icons.upload, color: Colors.white),
                    label: Text(
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
    );
  }

  final ImagePicker _picker = ImagePicker();
  final UploadService uploadService = UploadService();

  void _showImagePicker(BuildContext context, String imageType) {
    //final scaffoldContext = context; // Salva o contexto atual do Scaffold
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
                  //Navigator.of(context).pop();
                  //final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                  List<XFile>? images = await _picker.pickMultiImage(); // Permite selecionar múltiplas imagens

                  if (images != null && images.isNotEmpty) {
                    _showImagePreview(context, images); // Exibe o preview das imagens selecionadas
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

  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Confirmação:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            content: Text(
              'Você está enviando ${images.length} fotos. Essas fotos serão analisadas por nossa equipe em um prazo de até 2h.',
              style: TextStyle(fontSize: 16),
            ),
            actions: [
              ElevatedButton(
                onPressed: isUploading ? null : () async {
                  // Define o estado como enviando
                  setState(() {
                    isUploading = true;
                  });

                  // Chama o método para enviar as imagens
                  await uploadService.uploadFeedImages(images);

                  // Fecha o modal e redireciona para o painel após o envio
                  Navigator.of(dialogContext).pop();
                  //Navigator.pushNamed(context, '/painel');
                  dialogContext.go('/painel');
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
                child: Image.network(
                  widget.medias[index]['url'], // Exibe a imagem
                  fit: BoxFit.contain, // Mantém o aspecto da imagem
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