import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:store_navigator/screens/shopping_list/widgets/bulk_search_results.dart';
import 'package:store_navigator/utils/data/product.dart';
import 'package:store_navigator/utils/data/shopping_list.dart';

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

void showExtractedText(
    BuildContext context,
    Uint8List imageBytes,
    ShoppingList shoppingList,
    Function(Product, {String userDefinedName}) addProduct,
    Function(Product) removeProduct) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return ExtractedTextScreen(
          imageBytes: imageBytes,
          shoppingList: shoppingList,
          addProduct: addProduct,
          removeProduct: removeProduct);
    },
  );
}

Future<void> selectImage(
    BuildContext context,
    ShoppingList shoppingList,
    Function(Product, {String userDefinedName}) addProduct,
    Function(Product) removeProduct) async {
  Uint8List? fileBytes;

  void showModal(Uint8List? fileBytes) {
    if (fileBytes != null && context.mounted) {
      showExtractedText(
          context, fileBytes, shoppingList, addProduct, removeProduct);
    }
  }

  showCupertinoModalPopup(
    context: context,
    builder: (ctx) => CupertinoActionSheet(
      actions: [
        CupertinoActionSheetAction(
          child: const Text('Photo Gallery'),
          onPressed: () async {
            // close the options modal
            Navigator.of(ctx).pop();
            // get image from gallery
            fileBytes = await getImageBytesFromGallery();

            showModal(fileBytes);
          },
        ),
        CupertinoActionSheetAction(
          child: const Text('Camera'),
          onPressed: () async {
            // close the options modal
            Navigator.of(ctx).pop();
            // get image from camera
            fileBytes = await getImageBytesFromCamera();
            showModal(fileBytes);
          },
        ),
      ],
    ),
  );
}

// TODO: do we need to make it stateful to properly dispose the textRecognizer?
class ExtractedTextScreen extends StatefulWidget {
  final Uint8List imageBytes;
  final ShoppingList shoppingList;
  final Function(Product, {String userDefinedName}) addProduct;
  final Function(Product) removeProduct;

  const ExtractedTextScreen(
      {super.key,
      required this.imageBytes,
      required this.shoppingList,
      required this.addProduct,
      required this.removeProduct});

  @override
  State<ExtractedTextScreen> createState() => _ExtractedTextScreenState();
}

enum SearchResultsClass {
  nonEmpty,
  empty,
}

class _ExtractedTextScreenState extends State<ExtractedTextScreen> {
  final TextRecognizer textRecognizer =
      TextRecognizer(script: TextRecognitionScript.latin);

  bool isLoading = false;

  String extractedText = '';
  Map<String, List<Product>> searchResults = {};

  @override
  void initState() {
    super.initState();

    extractText();
  }

  @override
  void dispose() {
    textRecognizer.close();
    super.dispose();
  }

  File convertBytesToFile(Uint8List bytes) {
    final tempDir = Directory.systemTemp;
    final tempFile = File('${tempDir.path}/temp.png');
    tempFile.writeAsBytesSync(bytes);
    return tempFile;
  }

  // @override
  Future<void> extractText() async {
    setState(() {
      isLoading = true;
    });

    final inputImage =
        InputImage.fromFile(convertBytesToFile(widget.imageBytes));

    final recognisedText = await textRecognizer.processImage(inputImage);

    setState(() {
      isLoading = false;
      extractedText = recognisedText.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : BulkSearchResults(
            searchText: extractedText,
            shoppingList: widget.shoppingList,
            addProduct: widget.addProduct,
            removeProduct: widget.removeProduct);
  }
}
