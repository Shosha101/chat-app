import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CloudStorageService {
  final String cloudName = dotenv.env['CLOUD_NAME'] ?? '';
  final String apiKey = dotenv.env['API_KEY'] ?? '';
  final String apiSecret = dotenv.env['API_SECRET'] ?? '';
  final String uploadPreset = dotenv.env['UPLOAD_PRESET'] ?? '';

  /// Uploads a **user profile image** to Cloudinary and returns the image URL.
  Future<String?> saveUserImageToStorage(File file, String userId) async {
    return _uploadFile(
      file: file,
      publicId: 'images/users/$userId/profile.${file.path.split('.').last}',
    );
  }

  /// Uploads a **chat image** to Cloudinary and returns the image URL.
  Future<String?> saveChatImageToStorage(File file, String chatId, String userId) async {
    return _uploadFile(
      file: file,
      publicId: 'images/chats/$chatId/${userId}_${DateTime.now().millisecondsSinceEpoch}.${file.path.split('.').last}',
    );
  }

  /// 🔥 **Handles file uploads** to Cloudinary with correct MIME type.
  Future<String?> _uploadFile({required File file, required String publicId}) async {
    try {
      final mimeType = lookupMimeType(file.path);
      if (mimeType == null) {
        throw Exception("Cannot determine file MIME type.");
      }

      final uri = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");

      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = uploadPreset
        ..fields['public_id'] = publicId
        ..files.add(await http.MultipartFile.fromPath(
          'file',
          file.path,
          contentType: MediaType.parse(mimeType),
        ));

      final response = await request.send();
      final responseBody = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(responseBody.body);
        return responseData['secure_url']; // ✅ Returns the uploaded image URL
      } else {
        print("❌ Failed to upload image: ${responseBody.body}");
        return null;
      }
    } catch (e) {
      print("🔥 Error during upload: $e");
      return null;
    }
  }
}
