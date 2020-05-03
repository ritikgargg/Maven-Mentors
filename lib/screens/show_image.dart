import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ShowImage extends StatelessWidget {
  final String _imageUrl;
  ShowImage(this._imageUrl);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
        ),
        body: PhotoView(
          imageProvider: NetworkImage(
            _imageUrl,
          ),
        ));
  }
}
