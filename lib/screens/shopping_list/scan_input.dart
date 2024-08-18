import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

Future<Uint8List?> getImageBytesFromGallery() async {
  final pickedFile = await ImagePicker().pickImage(
    source: ImageSource.gallery,
  );

  if (pickedFile != null) {
    return await pickedFile.readAsBytes();
  }

  return null;
}

Future<Uint8List?> getImageBytesFromCamera() async {
  final pickedFile = await ImagePicker().pickImage(
    source: ImageSource.camera,
  );

  if (pickedFile != null) {
    return await pickedFile.readAsBytes();
  }

  return null;
}

void showExtractedText(BuildContext context, Uint8List imageBytes) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return ExtractedTextScreen(imageBytes: imageBytes);
    },
  );
}

Future<void> selectImage(BuildContext context) async {
  Uint8List? fileBytes;

  showCupertinoModalPopup(
    context: context,
    builder: (context) => CupertinoActionSheet(
      actions: [
        CupertinoActionSheetAction(
          child: Text('Photo Gallery'),
          onPressed: () async {
            // close the options modal
            Navigator.of(context).pop();
            // get image from gallery
            fileBytes = await getImageBytesFromGallery();
            if (fileBytes != null) {
              showExtractedText(context, fileBytes!);
            }
            // submitFile(fileBytes);
          },
        ),
        CupertinoActionSheetAction(
          child: Text('Camera'),
          onPressed: () async {
            // close the options modal
            Navigator.of(context).pop();
            // get image from camera
            fileBytes = await getImageBytesFromCamera();
            if (fileBytes != null) {
              showExtractedText(context, fileBytes!);
            }
          },
        ),
      ],
    ),
  );

  // await picker.pickImage(source: source)
  // showModalBottomSheet(
  //   context: context,
  //   isScrollControlled: true,
  //   builder: (context) {
  //     return SelectStore(
  //       selected: selected,
  //       onStoreSelected: onStoreSelected,
  //     );
  //   },
  // );
}

class ExtractedTextScreen extends StatelessWidget {
  final Uint8List imageBytes;

  const ExtractedTextScreen({super.key, required this.imageBytes});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('Extracted Text Screen'),
    );
  }
}
