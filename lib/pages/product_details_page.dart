import 'package:flutter/material.dart';
import '../models/product.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;
import 'dart:ui' as ui;
import 'package:flutter_web_plugins/flutter_web_plugins.dart' as flw;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class ProductDetailsPage extends StatelessWidget {
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

  final Product product;
  const ProductDetailsPage({Key? key, required this.product}) : super(key: key);

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
              _buildYoutubePlayer(context, product.youtubeUrl!),
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
        itemCount: mediaUrls.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, idx) {
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
                  final fullImages = mediaUrls
                      .map((e) => _absoluteUrl(e))
                      .toList();
                  _openImageViewer(context, fullImages, idx);
                },
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
    final videoId = url; //extractVideoId(url);
    if (videoId == null) return;

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
