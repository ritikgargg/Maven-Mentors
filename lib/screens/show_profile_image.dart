import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import '../services/media_service.dart';
import '../services/cloud_storage_service.dart';
import '../services/db_service.dart';

class ShowProfileImage extends StatefulWidget {
  String imageUrl;
  final String _uid;

  ShowProfileImage(this.imageUrl, [this._uid]);

  @override
  _ShowProfileImageState createState() => _ShowProfileImageState();
}

class _ShowProfileImageState extends State<ShowProfileImage> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
       ),

      body:Container(
              child: PhotoView(
                heroAttributes: PhotoViewHeroAttributes(tag: "Show Profile Image"),
                imageProvider: CachedNetworkImageProvider(widget.imageUrl),
              ),
            ),
    );
  }
}
