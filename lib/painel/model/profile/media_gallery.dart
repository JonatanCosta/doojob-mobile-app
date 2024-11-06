import 'package:flutter/material.dart';
import '../../../upload/upload_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class MediaGallery extends StatefulWidget {
  final List<dynamic> medias; // Lista de mídias
  final bool canEdit; // Verificar se o usuário pode editar

  MediaGallery({
    Key? key,
    required this.medias,
    required this.canEdit,
  }) : super(key: key);

  _MediaGalleryState createState() => _MediaGalleryState();
}

class _MediaGalleryState extends State<MediaGallery> with AutomaticKeepAliveClientMixin {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return SingleChildScrollView(
      key: PageStorageKey('media_gallery_key'),
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
          if (widget.canEdit && widget.medias.isNotEmpty)
            Padding(
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
          widget.medias.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: GridView.builder(
                    key: PageStorageKey('media_grid'),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4,
                    ),
                    itemCount: widget.medias.length > 6 ? 6 : widget.medias.length,
                    itemBuilder: (context, index) {
                      final media = widget.medias[index];
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _currentIndex = index;
                            _pageController = PageController(initialPage: _currentIndex);
                          });
                          _showFullScreenGallery(context);
                        },
                        child: CachedNetworkImage(
                          imageUrl: media['url'],
                          imageBuilder: (context, imageProvider) => Image(
                            image: ResizeImage(imageProvider, width: 300, height: 300),
                            fit: BoxFit.cover,
                          ),
                          placeholder: (context, url) => CircularProgressIndicator(),
                          errorWidget: (context, url, error) => Icon(Icons.error),
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

  void _showFullScreenGallery(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              PhotoViewGallery.builder(
                itemCount: widget.medias.length,
                pageController: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                builder: (context, index) {
                  return PhotoViewGalleryPageOptions(
                    imageProvider: CachedNetworkImageProvider(widget.medias[index]['url']),
                    //imageProvider: NetworkImage(widget.medias[index]['url']),
                    minScale: PhotoViewComputedScale.contained,
                    maxScale: PhotoViewComputedScale.covered * 2,
                    heroAttributes: PhotoViewHeroAttributes(tag: widget.medias[index]['url']),
                  );
                },
                scrollPhysics: const BouncingScrollPhysics(),
                backgroundDecoration: const BoxDecoration(color: Colors.black),
              ),
              Positioned(
                top: 40,
                left: 20,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

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
                  if (images != null && images.isNotEmpty) {
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

  final ImagePicker _picker = ImagePicker();
  final UploadService uploadService = UploadService();

  void _showImagePreview(BuildContext context, List<XFile> images) async {
    bool isUploading = false;
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
                  if (!isUploading)
                    Text(
                      'Você está enviando ${images.length} fotos. Essas fotos serão analisadas por nossa equipe em até 2h.',
                      style: TextStyle(fontSize: 16),
                    ),
                  if (isUploading)
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
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: isUploading ? null : () async {
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
                    backgroundColor: isUploading ? Colors.grey : Color(0xFFFF5252),
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
                  child: const Text('Cancelar'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}