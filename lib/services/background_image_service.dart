import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

class BackgroundImageService {
  static Future<Uint8List?> pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      return await image.readAsBytes();
    }
    return null;
  }
}
