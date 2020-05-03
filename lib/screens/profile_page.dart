import 'package:flutter/material.dart';


import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../providers/auth_provider.dart';

import '../services/db_service.dart';
import '../services/navigation_service.dart';

import '../models/contact.dart';
import './show_profile_image.dart';
import '../services/snackbar_service.dart';

class ProfilePage extends StatelessWidget {
  final double _height;
  final double _width;
  ProfilePage(this._height, this._width);
  AuthProvider _auth;

  Color color;

  @override
  Widget build(BuildContext context) {
    color = Theme.of(context).primaryColor;
    return Container(
      color: Theme.of(context).accentColor,
      height:_height,
      width: _width,
      child: ChangeNotifierProvider<AuthProvider>.value(
        value: AuthProvider.instance,
        child: _profilePageUI(),
      ),
    );
  }

  Widget _profilePageUI() {
    return Builder(
      builder: (BuildContext _context) {
        _auth = Provider.of<AuthProvider>(_context);
        return StreamBuilder<Contact>(
          stream: DBService.instance.getUserData(_auth.user.uid),
          builder: (_context, _snapshot) {
            var _userData = _snapshot.data;
            return _snapshot.hasData
                ? Align(
                    alignment: Alignment.center,
                    child: SizedBox(
                      height: _height * 0.50,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          _userImageWidget(_userData.image),
                          _userNameWidget(_userData.name),
                          _userEmailWidget(_userData.email),
                          _logoutButton(_context),
                        ],
                      ),
                    ),
                  )
                : SpinKitCircle(
                    color: Colors.blue,
                    size: 50.0,
                  );
          },
        );
      },
    );
  }

  Widget _userImageWidget(String _image) {
    double _imageRadius = _height * 0.20;
    return InkWell(
      onTap: () async {
         NavigationService.instance.navigateToRoute(MaterialPageRoute(builder: (_)=> ShowProfileImage(_image, _auth.user.uid)));
      },
          child: Hero(
            tag: "Show Profile Image",
                      child: CachedNetworkImage(
        imageUrl: _image,
        imageBuilder: (context, imageProvider) => Container(
            width: _imageRadius,
            height: _imageRadius,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
            ),
        ),
        placeholder: (context, url) => CircularProgressIndicator(backgroundColor: Theme.of(context).primaryColor,),
        errorWidget: (context, url, error) => Icon(Icons.error),
      ),
          ),
    );
  }

  Widget _userNameWidget(String _userName) {
    return Container(
      height: _height * 0.05,
      width: _width,
      child: Text(
        _userName,
        textAlign: TextAlign.center,
        style: TextStyle(color: color, fontSize: 30),
      ),
    );
  }

  Widget _userEmailWidget(String _email) {
    return Container(
      height: _height * 0.03,
      width:_width,
      child: Text(
        _email,
        textAlign: TextAlign.center,
        style: TextStyle(color: color, fontSize: 15),
      ),
    );
  }

  Widget _logoutButton(BuildContext _ctx) {
    return Container(
      height: _height * 0.06,
      width: _width * 0.80,
      child: MaterialButton(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_height * 0.03)),
        onPressed: ()async {
          

         var check=await showDialog(context: _ctx,
          builder: (_){
            return AlertDialog(
              title: Text("Log out?",style: TextStyle(fontWeight:FontWeight.w600),),
              content: Text("Are you sure you want to log out?"),
              actions: <Widget>[
                FlatButton(onPressed: (){
                 Navigator.pop(_ctx, false);
                }, child: Text("Cancel", style: TextStyle(fontWeight:FontWeight.w600,  fontSize: 16),)),
                FlatButton(onPressed: (){
                  Navigator.pop(_ctx,true);
                  
                }, child: Text("Log out",style: TextStyle(fontWeight:FontWeight.w600, fontSize: 16),))

              ],

            );
          }
        );
        if(check) _auth.logoutUser(() {});
        },
        color: Colors.red,
        child: Text(
          "LOGOUT",
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
        ),
      ),
    );
  }
}
