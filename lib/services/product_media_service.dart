import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class ProductMediaService {
  static const String apiUrl =
      "https://palbalaji.tempudo.com/business/api/products.php";

  static Future<bool> deleteImage({
    required int productId,
    required String imagePath,
  }) async {
    final res = await http.post(
      Uri.parse("$apiUrl?action=delete_image"),
      body: {
        "id": productId.toString(),
        "image": imagePath,
      },
    );

    if (res.statusCode != 200) return false;

    final decoded = jsonDecode(res.body);
    return decoded['status'] == 'success';
  }

  /// ADD PRODUCT
  static Future<bool> addProduct({
    required String name,
    required String category,
    required String price,
    required String description,
    required List<String> youtubeUrls,
    required List<Uint8List> images,
  }) async {
    final uri = Uri.parse("$apiUrl?action=add");
    final request = http.MultipartRequest("POST", uri);

    // normal fields
    request.fields['name'] = name;
    request.fields['category'] = category;
    request.fields['price'] = price;
    request.fields['description'] = description;
    request.fields['youtube_url'] = youtubeUrls.join(",");
    int i = 0;

    // images
    for (final img in images) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'files[]',
          img,
          filename: 'image_$i.jpg',
        ),
      );
      i++;
    }

    final res = await request.send();
    final body = await res.stream.bytesToString();

    if (res.statusCode != 200) return false;

    final decoded = jsonDecode(body);
    return decoded['status'] == 'success';
  }

  /// UPDATE PRODUCT (append images)
  static Future<bool> updateProduct({
    required int productId,
    required String name,
    required String category,
    required String price,
    required String description,
    required List<String> youtubeUrls,
    required List<Uint8List> images,
  }) async {
    final uri = Uri.parse("$apiUrl?action=update");
    final request = http.MultipartRequest("POST", uri);

    request.fields['id'] = productId.toString();
    request.fields['name'] = name;
    request.fields['category'] = category;
    request.fields['price'] = price;
    request.fields['description'] = description;
    request.fields['youtube_url'] = youtubeUrls.join(",");

    int i = 0;

    for (final img in images) {
      request.files.add(
        http.MultipartFile.fromBytes(
          'files[]',
          img,
          filename: 'image_$i.jpg',
        ),
      );
      i++;
    }

    final res = await request.send();
    final body = await res.stream.bytesToString();

    if (res.statusCode != 200) return false;

    final decoded = jsonDecode(body);
    return decoded['status'] == 'success';
  }
}
