import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

import 'drag_and_drop.dart';

class PhotoPicker extends StatefulWidget {
  DragAndDrop dragAndDrop;
  double scale;

  PhotoPicker(this.dragAndDrop, this.scale);

  @override
  _PhotoPickerScreenState createState() => _PhotoPickerScreenState(dragAndDrop.img);
}

class _PhotoPickerScreenState extends State<PhotoPicker> {

  Image? _imageFile;

  _PhotoPickerScreenState(this._imageFile);

  uploadImage() async {
    final _firebaseStorage = FirebaseStorage.instance;
    final _imagePicker = ImagePicker();
    XFile? image;
    //Check Permissions
    await Permission.photos.request();

    var permissionStatus = await Permission.photos.status;

    if (permissionStatus.isGranted || !permissionStatus.isGranted){


      //Select Image
      image = await _imagePicker.pickImage(source: ImageSource.gallery, maxHeight: 500, maxWidth: 500);
      var file = File(image!.path);

      if (image != null){
        //Upload to Firebase
        var snapshot = await _firebaseStorage.ref()
            .child('images/picture_'+widget.dragAndDrop.docRef.id)
            .putFile(file);
        var downloadUrl = await snapshot.ref.getDownloadURL();
        widget.dragAndDrop.updateUrl(downloadUrl);

        setState(() {
          _imageFile = Image.file(file);
        });
      } else {
        print('No Image Path Received');
      }
    } else {
      print('Permission not granted. Try Again with permission access');
    }
  }


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200 * widget.scale,
      child: InkWell(
        onTap: uploadImage,
        child: Center(
          child: _imageFile == null
              ? const SizedBox(
                  height: 100,
                  child: Center(
                    child: Text('Выберите фотографию'),
                  ),
                )
              : _imageFile!
        ),
      ),
    );
  }
}
