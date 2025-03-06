import 'dart:io';

import 'package:flutter/material.dart';

class PicturePreviewPage extends StatefulWidget {
  final String picturePath;

  const PicturePreviewPage(this.picturePath, {super.key});

  @override
  State<StatefulWidget> createState() {
    return PicturePreviewPageState();
  }
}

class PicturePreviewPageState extends State<PicturePreviewPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Image(image: FileImage(File(widget.picturePath)));
  }
}
