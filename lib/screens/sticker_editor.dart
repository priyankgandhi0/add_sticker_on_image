import 'dart:io';

import 'package:add_sticker_on_image/core/extension.dart';
import 'package:add_sticker_on_image/widgets/image_stickers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gal/gal.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';

class StickerEditor extends StatefulWidget {
  const StickerEditor({super.key});

  @override
  StickerEditorState createState() => StickerEditorState();
}

class StickerEditorState extends State<StickerEditor> {
  /// Editor for stickers on image
  ///
  /// Uses [ImageStickers] widget to show image and stickers.
  /// Supports picking image from gallery or taking from camera.
  /// Allows to add stickers and undo them.
  /// Allows to save image with stickers to file.
  File? _image;
  final picker = ImagePicker();
  List<UISticker> stickers = [];
  ScreenshotController screenshotController = ScreenshotController();
  StickerControlsBehaviour stickerControlsBehaviour =
      StickerControlsBehaviour.alwaysShow;

  late ScaffoldMessengerState scaffoldMessenger;

  /// Picking image from gallery or taking from camera
  ///
  /// Allows user to pick image from gallery or take new one from camera.
  /// Updates [StickerEditorState._image] with selected image.
  /// If image is not selected, does nothing.
  Future getImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  /// Adds sticker on image
  ///
  /// Adds sticker with default properties to [StickerEditorState.stickers].
  /// Updates UI to show new sticker.
  void addSticker() {
    setState(() {
      stickers.add(
        UISticker(
          imageProvider: AssetImage('assets/sticker.png'),
          x: 100,
          y: 100,
          editable: true,
        ),
      );
    });
  }

  /// Saves the image with stickers
  ///
  /// Temporarily hides sticker controls for a clean screenshot.
  /// Captures the current screen as an image and saves it.
  /// Displays a snackbar message upon successful save.
  /// Saves to gallery on mobile platforms and to downloads folder on desktop.
  Future<void> saveImage() async {
    setState(() {
      stickerControlsBehaviour = StickerControlsBehaviour.alwaysHide;
    });

    await Future.delayed(Duration(milliseconds: 100));

    Uint8List? bytes = await screenshotController.capture();

    setState(() {
      stickerControlsBehaviour = StickerControlsBehaviour.alwaysShow;
    });

    if (bytes != null) {
      if (Platform.isAndroid || Platform.isIOS) {
        // Save to gallery
        Gal.putImageBytes(bytes, name: '${DateTime.now().millisecondsSinceEpoch}.png');
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Image saved to gallery!')),
        );
      } else {
        // Save to computer (Windows, macOS, Linux)
        final directory =
            await getDownloadsDirectory(); // Get user's downloads folder
        if (directory != null) {
          String filePath =
              '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.png';
          File file = File(filePath);
          await file.writeAsBytes(bytes);

          scaffoldMessenger.showSnackBar(
            SnackBar(content: Text('Image saved at: $filePath')),
          );
        }
      }
    }
  }

  /// Undoes the last sticker added
  ///
  /// If there are no stickers to undo, shows a snackbar message.
  void undoSticker() {
    if (stickers.isNotEmpty) {
      setState(() {
        stickers.removeLast();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No stickers to undo!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    scaffoldMessenger = ScaffoldMessenger.of(context);
    return Scaffold(
      appBar: AppBar(title: Text('Sticker App')),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.photo_library),
                onPressed: () => context.pickImage(onImageChoose: (File file) {
                  setState(() {
                    _image = File(file.path);
                  });
                }),
              ),
              IconButton(
                icon: Icon(Icons.camera),
                onPressed: () => context.pickImage(
                    source: ImageSource.camera,
                    onImageChoose: (File file) {
                      setState(() {
                        _image = File(file.path);
                      });
                    }),
              ),
              IconButton(
                icon: Icon(Icons.emoji_emotions),
                onPressed: addSticker,
              ),
              IconButton(
                icon: Icon(Icons.undo),
                onPressed: undoSticker,
              ),
              IconButton(
                icon: Icon(Icons.save),
                onPressed: saveImage,
              ),
            ],
          ),
          Expanded(
            child: Center(
              child: _image == null
                  ? Text('No image selected.')
                  : Screenshot(
                      controller: screenshotController,
                      child: ImageStickers(
                          backgroundImage: FileImage(_image!),
                          stickerList: stickers,
                          stickerControlsBehaviour: stickerControlsBehaviour),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
