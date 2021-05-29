import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as Im;
import 'package:path_provider/path_provider.dart';

class Utils {
  static String getUsername(String email) {
    return "live:${email.split('@')[0]}";
  }

  static String getInitials(String name) {
    List<String> nameSplit = name.split(" ");
    if (nameSplit.length > 1) {
      String firstNameInitial = nameSplit[0][0];
      String lastNameInitial = nameSplit[1][0];
      return firstNameInitial + lastNameInitial;
    }
    return nameSplit[0][0];
  }

  static FutureOr<File> pickImage({required ImageSource source}) async {
    PickedFile selectedImage = await (ImagePicker().getImage(source: source) as FutureOr<PickedFile>);
    File pickeeed = File(selectedImage.path);

    return compressImage(pickeeed);
  }

  static Future<File> compressImage(File imageToCompress) async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;

    int random = Random().nextInt(1000);

    Im.Image image = Im.decodeImage(imageToCompress.readAsBytesSync())!;
    Im.copyResize(image, width: 500, height: 500);

    return new File('$path/img_$random.jpg')
      ..writeAsBytesSync(Im.encodeJpg(image, quality: 85));
  }
}
