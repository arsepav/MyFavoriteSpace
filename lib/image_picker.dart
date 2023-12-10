import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';


Future<String> uploadImage(File file, String name) async {
  String downloadUrl = "";
  var snapshot = await FirebaseStorage.instance.ref()
        .child('images/picture_$name')
        .putFile(file);

  downloadUrl = await snapshot.ref.getDownloadURL();

  return downloadUrl;
}

class PictureGetter {
  final _imagePicker = ImagePicker();

  Future<File?> pickImage() async {
    XFile? image;
    await Permission.photos.request();
    var permissionStatus = await Permission.photos.status;

    if (permissionStatus.isGranted || !permissionStatus.isGranted){
      image = await _imagePicker.pickImage(source: ImageSource.gallery, maxHeight: 500, maxWidth: 500);

    } else {
      print('Permission not granted. Try Again with permission access');
    }
    if (image == null){
      return null;
    }
    return File(image.path);
  }



}