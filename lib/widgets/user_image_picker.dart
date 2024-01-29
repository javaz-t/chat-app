import 'dart:io'; //File
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  const UserImagePicker({super.key,required this.onPickIMage});
  final void Function(File pickedImage)onPickIMage;

  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

File? _pickedImageFile;

class _UserImagePickerState extends State<UserImagePicker> {
  void _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 150,
      imageQuality: 50,
    );
    if (pickedImage == null) {
      return;
    }
    setState(() {
      _pickedImageFile = File(pickedImage.path);
    });
    widget.onPickIMage(_pickedImageFile!);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
            radius: 40,
            backgroundColor: Colors.grey,

            foregroundImage:
                _pickedImageFile != null ?
                FileImage(_pickedImageFile!)
                    : null),
        TextButton.icon(
            onPressed: _pickImage,
            icon: Icon(Icons.image),
            label: Text(
              'select image',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
              ),
            ))
      ],
    );
  }
}
