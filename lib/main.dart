import 'package:flutter/material.dart';

import 'screens/sticker_editor.dart';

void main() {
  runApp(const StickerApp());
}

class StickerApp extends StatelessWidget {
  const StickerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StickerEditor(),
      debugShowCheckedModeBanner: false,
    );
  }
}
