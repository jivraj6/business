import 'package:buisness/services/product_media_service.dart';
import 'package:flutter/material.dart';
import '../../models/product.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;
import 'dart:ui' as ui;
import 'package:flutter_web_plugins/flutter_web_plugins.dart' as flw;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';

class ProductDetailsPage extends StatefulWidget {
  final Product product;
  ProductDetailsPage({Key? key, required this.product}) : super(key: key);
  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  Widget _buildYoutubePlayer(BuildContext context, String url) {
    final uri = Uri.tryParse(url);
    String? videoId;
    if (uri != null &&
        (uri.host.contains('youtube.com') || uri.host.contains('youtu.be'))) {
      if (uri.host.contains('youtu.be')) {
        videoId = uri.pathSegments.isNotEmpty ? uri.pathSegments[0] : null;
      } else {
        videoId = uri.queryParameters['v'];
      }
    }
    if (videoId == null) {
      return InkWell(
        onTap: () {},
        child: Text(url, style: const TextStyle(color: Colors.blue)),
      );
    }
    // For web, show a clickable thumbnail (since iframe needs registration)
    final thumbUrl = 'https://img.youtube.com/vi/$videoId/0.jpg';
    return GestureDetector(
      onTap: () {
        openYoutubeDialog(context, videoId!);
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              thumbUrl,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
          const Icon(Icons.play_circle_fill, color: Colors.white, size: 64),
        ],
      ),
    );
  }

  List<Uint8List> pickedImages = [];

  String getthumb(String url) {
    final uri = Uri.tryParse(url);
    String? videoId;
    if (uri != null &&
        (uri.host.contains('youtube.com') || uri.host.contains('youtu.be'))) {
      if (uri.host.contains('youtu.be')) {
        videoId = uri.pathSegments.isNotEmpty ? uri.pathSegments[0] : null;
      } else {
        videoId = uri.queryParameters['v'];
      }
    }
    if (videoId != null) {}
    // For web, show a clickable thumbnail (since iframe needs registration)
    return 'https://img.youtube.com/vi/$videoId/0.jpg';
  }

  @override
  Widget build(BuildContext context) {
    var product = widget.product;
    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMediaGallery(product.images),
            if (product.youtubeUrl != null &&
                product.youtubeUrl!.isNotEmpty) ...[
              const SizedBox(height: 24),

              Text(
                'Product Videos:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildVedioGallery(product.youtubeUrl),
              // _buildYoutubePlayer(context, product.youtubeUrl!.first),
            ],
            const SizedBox(height: 24),
            Text(
              product.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Category: ${product.category}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Price: ₹${product.price}',
              style: const TextStyle(fontSize: 18, color: Colors.deepPurple),
            ),
            const SizedBox(height: 16),
            Text(product.description, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  void _openImageViewer(
    BuildContext context,
    List<String> images,
    int initialIndex,
  ) {
    showDialog(
      context: context,
      builder: (_) {
        PageController controller = PageController(initialPage: initialIndex);

        return Dialog(
          backgroundColor: Colors.black,
          insetPadding: EdgeInsets.zero,
          child: Stack(
            children: [
              PageView.builder(
                controller: controller,
                itemCount: images.length,
                itemBuilder: (context, index) {
                  return InteractiveViewer(
                    child: Center(
                      child: Image.network(images[index], fit: BoxFit.contain),
                    ),
                  );
                },
              ),

              // Close Button (Top Right)
              Positioned(
                top: 20,
                right: 20,
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAddMediaButton(BuildContext context, int index) {
    return InkWell(
      onTap: () async {
        if (index == 0) {
          final res = await FilePicker.platform.pickFiles(
            allowMultiple: true,
            withData: true,
            type: FileType.custom,
            allowedExtensions: [
              'jpg',
              'jpeg',
              'png',
              'webp',
            ],
          );

          if (res == null || !mounted) return;
          setState(() {
            for (final file in res.files) {
              if (file.bytes == null) continue;

              final name = file.name.toLowerCase();

              if (name.endsWith('.jpg') ||
                  name.endsWith('.jpeg') ||
                  name.endsWith('.png') ||
                  name.endsWith('.webp')) {
                pickedImages.add(file.bytes!);
              }
            }
          });

          if (pickedImages.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("No media selected")),
            );
            return;
          }

          final ok = await ProductMediaService.updateProduct(
            productId: widget.product.id!,
            name: widget.product.name,
            category: widget.product.category,
            price: widget.product.price.toString(),
            description: widget.product.description,
            youtubeUrls: widget.product.youtubeUrl ?? [],
            images: pickedImages,
          );
          if (!mounted) return;

          if (ok) {
            setState(() {
              pickedImages.clear();
            });

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Media uploaded successfully")),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Upload failed")),
            );
          }
        } else {
          //openYoutubeDialog(context, 'https://youtu.be/dQw4w9WgXcQ');
        }
        //_onAddMedia(context);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 220,
        height: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade400, width: 2),
          color: Colors.grey.shade100,
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, size: 48, color: Colors.grey),
            SizedBox(height: 8),
            Text(
              "Add Media",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVedioGallery(List<String> videoUrls) {
    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: videoUrls.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, idx) {
          // ---------- ADD BUTTON ----------
          if (idx == videoUrls.length) {
            return _buildAddMediaButton(context, 0);
          }

          final rawUrl = videoUrls[idx];
          final url = _absoluteUrl(rawUrl);

          // ---------- YOUTUBE VIDEO ----------
          final ytId = extractVideoId(rawUrl);
          if (ytId != null) {
            final thumb = "https://img.youtube.com/vi/$ytId/0.jpg";

            return GestureDetector(
              onTap: () => openYoutubeDialog(context, ytId),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      thumb,
                      width: 220,
                      height: 220,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const Icon(
                    Icons.play_circle_fill,
                    size: 64,
                    color: Colors.white,
                  ),
                ],
              ),
            );
          }

          // ---------- VIDEO FILE ----------
          if (_isVideo(url)) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 220,
                color: Colors.black12,
                child: const Center(
                  child: Icon(Icons.videocam, size: 48),
                ),
              ),
            );
          }

          // ---------- FALLBACK ----------
          return Container(
            width: 220,
            alignment: Alignment.center,
            child: const Icon(Icons.broken_image),
          );
        },
      ),
    );
  }

  void _confirmDeleteImage(
  BuildContext context,
  String imagePath,
  int index,
) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Delete Image"),
      content: const Text(
        "Are you sure you want to delete this image?",
      ),
      actions: [
        TextButton(
          child: const Text("Cancel"),
          onPressed: () => Navigator.pop(context),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          child: const Text("Delete"),
          onPressed: () async {
            Navigator.pop(context);

            final ok = await ProductMediaService.deleteImage(
              productId: widget.product.id!,
              imagePath: imagePath,
            );

            if (!mounted) return;

            if (ok) {
              setState(() {
                widget.product.images.removeAt(index);
              });

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Image deleted")),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Delete failed")),
              );
            }
          },
        ),
      ],
    ),
  );
}


  Widget _buildMediaGallery(List<String> mediaUrls) {
    if (mediaUrls.isEmpty) {
      return Container(
        height: 220,
        color: Colors.grey.shade200,
        child: const Center(child: Icon(Icons.image, size: 60)),
      );
    }
    return SizedBox(
      height: 220,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: mediaUrls.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, idx) {
          // ---------- ADD BUTTON (LAST ITEM) ----------
          if (idx == mediaUrls.length) {
            return _buildAddMediaButton(context, 0);
          }

          // ---------- NORMAL MEDIA ----------
          final url = _absoluteUrl(mediaUrls[idx]);

          if (_isVideo(url)) {
            return AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                color: Colors.black12,
                child: Center(
                  child: Icon(
                    Icons.videocam,
                    size: 48,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            );
            // For real video playback, use a video player package.
          } else {
            return ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: GestureDetector(
                onTap: () {
                  final fullImages =
                      mediaUrls.map((e) => _absoluteUrl(e)).toList();
                  _openImageViewer(context, fullImages, idx);
                },

                onLongPress: () =>  _confirmDeleteImage(context, mediaUrls[idx], idx),
                child: Image.network(
                  url,
                  width: 220,
                  height: 220,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.broken_image, size: 40),
                ),
              ),
            );
          }
        },
      ),
    );
  }

  bool _isVideo(String url) {
    final lower = url.toLowerCase();
    return lower.endsWith('.mp4') ||
        lower.endsWith('.mov') ||
        lower.endsWith('.avi');
  }

  String _absoluteUrl(String url) {
    if (url.startsWith('http')) return url;
    return 'https://palbalaji.tempudo.com/business/api/$url';
  }

  String? extractVideoId(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;

    if (uri.host.contains("youtu.be")) {
      return uri.pathSegments.isNotEmpty ? uri.pathSegments[0] : null;
    } else {
      return uri.queryParameters["v"];
    }
  }

  void openYoutubeDialog(BuildContext context, String url) {
    final videoId = url;

    showDialog(
      context: context,
      builder: (_) {
        return Dialog(
          insetPadding: EdgeInsets.zero,
          backgroundColor: Colors.black,
          child: Stack(
            children: [
              Center(
                child: SizedBox(
                  width: 900,
                  height: 500,
                  child: InAppWebView(
                    initialUrlRequest: URLRequest(
                      url: WebUri(
                        "https://www.youtube.com/embed/$videoId?autoplay=1&mute=1",
                      ),
                    ),
                  ),
                ),
              ),

              // Close button
              Positioned(
                top: 20,
                right: 20,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 32),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Widget buildYoutubePlayer(String videoId) {
  //   final iframe = html.IFrameElement()
  //     ..width = '100%'
  //     ..height = '100%'
  //     ..src = 'https://www.youtube.com/embed/$videoId?autoplay=1'
  //     ..style.border = 'none';

  //   // ignore: undefined_prefixed_name
  //   if (kIsWeb) {
  //     // ignore: undefined_prefixed_name
  //     ui.platformViewRegistry.registerViewFactory(
  //       'yt-$videoId',
  //       (int _) => iframe,
  //     );
  //   }

  //   return kIsWeb
  //       ? HtmlElementView(viewType: 'yt-$videoId')
  //       : const Center(
  //           child: Text(
  //             "YouTube only works on Web in iframe mode",
  //             style: TextStyle(color: Colors.white),
  //           ),
  //         );
  // }
}
