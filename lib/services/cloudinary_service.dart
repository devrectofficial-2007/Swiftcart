import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';

class CloudinaryService {
  static const String cloudName = "dfkmrsvih"; // Aapka Cloud Name
  static const String uploadPreset = "swiftcart_preset"; // Jo abhi banaya

  Future<String?> pickAndUploadImage() async {
    final picker = ImagePicker();
    // 1. Image Pick Karein
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    if (image == null) return null;

    // 2. API Prepare Karein
    var url = Uri.parse(
      "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
    );
    var request = http.MultipartRequest("POST", url)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', image.path));

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await response.stream.toBytes();
        var jsonRes = jsonDecode(String.fromCharCodes(responseData));
        return jsonRes['secure_url']; // Success: Image URL mil gaya
      }
    } catch (e) {
      print("Upload Error: $e");
    }
    return null;
  }

  Future<String?> pickAndUploadImageFromFile(File imageFile) async {
    // 2. API Prepare Karein
    var url = Uri.parse(
      "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
    );
    var request = http.MultipartRequest("POST", url)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await response.stream.toBytes();
        var jsonRes = jsonDecode(String.fromCharCodes(responseData));
        return jsonRes['secure_url']; // Success: Image URL mil gaya
      }
    } catch (e) {
      print("Upload Error: $e");
    }
    return null;
  }
}
