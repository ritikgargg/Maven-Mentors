import 'dart:io';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

import '../services/media_service.dart';
import '../services/cloud_storage_service.dart';
import '../services/db_service.dart';
import '../services/snackbar_service.dart';

class RegistrationPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _RegistrationPageState();
  }
}

class _RegistrationPageState extends State<RegistrationPage> {
  double _deviceHeight;
  double _deviceWidth;

  GlobalKey<FormState> _formKey;
  AuthProvider _auth;

  String _name;
  String _email;
  String _password;
  int _mobileNumber;
  File _image;
  bool _isVisible = false;

  _RegistrationPageState() {
    _formKey = GlobalKey<FormState>();
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
        backgroundColor: Theme.of(context).accentColor,
        body: Center(
          child: SingleChildScrollView(
                    child: Container(
    child: ChangeNotifierProvider<AuthProvider>.value(
      value: AuthProvider.instance,
      child: registrationPageUI(),
    ),
            ),
          ),
        ),
      );
  }

  Widget registrationPageUI() {
    return Builder(
      builder: (BuildContext _context) {
        SnackBarService.instance.buildContext = _context;
        _auth = Provider.of<AuthProvider>(_context);
        return Container(
          height: _deviceHeight * 0.85,
          padding: EdgeInsets.symmetric(horizontal: _deviceWidth * 0.10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _headingWidget(),
              _inputForm(),
              _registerButton(),
            ],
          ),
        );
      },
    );
  }

  Widget _headingWidget() {
    return Container(
      height: _deviceHeight * 0.12,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "Let's get going!",
            style: TextStyle(
                fontSize: 35,
                fontWeight: FontWeight.w700,
                fontFamily: "Josefin Sans"),
          ),
          Text(
            "Please enter your details.",
            style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w100,
                fontFamily: "Josefin Sans"),
          ),
        ],
      ),
    );
  }

  Widget _inputForm() {
    return Container(
      height: _deviceHeight * 0.45,
      child: Form(
        key: _formKey,
        onChanged: () {
          _formKey.currentState.save();
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _imageSelectorWidget(),
            _nameTextField(),
            _emailTextField(),
            _mobileNumberTextField(),
            _passwordTextField(),
          ],
        ),
      ),
    );
  }

  Widget _imageSelectorWidget() {
    return Align(
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: () async {
          File _imageFile =
              await MediaService.instance.getProfileImageFromLibrary();
          setState(() {
            _image = _imageFile;
          });
        },
        child: Container(
          height: _deviceHeight * 0.10,
          width: _deviceHeight * 0.10,
          child: (_image != null)
              ? ClipRRect(
                borderRadius: BorderRadius.circular(_deviceHeight * 0.05),
                child: Image.file(_image, fit: BoxFit.cover,))
              : ClipRRect(
                borderRadius: BorderRadius.circular(_deviceHeight * 0.05),
                              child: Image.network(
                    "https://cdn0.iconfinder.com/data/icons/occupation-002/64/programmer-programming-occupation-avatar-512.png",
                    fit: BoxFit.cover,
                    loadingBuilder: (BuildContext context, Widget child,
                        ImageChunkEvent loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          backgroundColor: Theme.of(context).primaryColor,
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes
                              : null,
                        ),
                      );
                    },
                  ),
              ),
        ),
      ),
    );
  }

  Widget _nameTextField() {
    return TextFormField(
      autocorrect: false,
      style: TextStyle(
          color: Theme.of(context).primaryColor, fontWeight: FontWeight.w700),
      validator: (_input) {
        return _input.length != 0 ? null : "Please enter a name";
      },
      onSaved: (_input) {
        setState(() {
          _name = _input;
        });
      },
      cursorColor: Theme.of(context).primaryColor,
      decoration: InputDecoration(
        hintText: "Name",
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
      ),
    );
  }

  Widget _emailTextField() {
    return TextFormField(
      autocorrect: false,
      style: TextStyle(
          color: Theme.of(context).primaryColor, fontWeight: FontWeight.w700),
      validator: (_input) {
        return _input.length != 0 && _input.contains("@")
            ? null
            : "Please enter a valid email";
      },
      onSaved: (_input) {
        setState(() {
          _email = _input;
        });
      },
      cursorColor: Theme.of(context).primaryColor,
      decoration: InputDecoration(
        hintText: "Email",
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
      ),
    );
  }

  Widget _passwordTextField() {
    return TextFormField(
      autocorrect: false,
      obscureText: !_isVisible,
      style: TextStyle(
          color: Theme.of(context).primaryColor, fontWeight: FontWeight.w700),
      validator: (_input) {
        return _input.length != 0 ? null : "Please enter a password";
      },
      onSaved: (_input) {
        setState(() {
          _password = _input;
        });
      },
      cursorColor: Theme.of(context).primaryColor,
      decoration: InputDecoration(
        suffixIcon: IconButton(
          icon: (!_isVisible)
              ? Icon(Icons.visibility)
              : Icon(Icons.visibility_off),
          onPressed: () {
            setState(() {
              _isVisible = !_isVisible;
            });
          },
        ),
        hintText: "Password",
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
      ),
    );
  }
  Widget _mobileNumberTextField() {
    return TextFormField(
      autocorrect: false,
      style: TextStyle(
          color: Theme.of(context).primaryColor, fontWeight: FontWeight.w700),
      validator: (_input) {
        return _input.length != 0 ? null : "Please enter a mobile number";
      },
      onSaved: (_input) {
        setState(() {
          _mobileNumber = int.parse(_input);
        });
      },
      cursorColor: Theme.of(context).primaryColor,
      decoration: InputDecoration(
        hintText: "Mobile number",
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
      ),
    );
  }

  Widget _registerButton() {
    return _auth.status != AuthStatus.Authenticating
        ? Container(
            height: _deviceHeight * 0.06,
            width: _deviceWidth,
            child: MaterialButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(_deviceHeight * 0.03)),
              onPressed: () {
                if (_image == null&& _formKey.currentState.validate()) {
                  Fluttertoast.showToast(
                    msg: "Please select an image",
                    gravity: ToastGravity.CENTER,
                    fontSize: 18,
                  );
                }
                if (_formKey.currentState.validate() && _image != null) {
                  _auth.registerUserWithEmailAndPassword(_email, _password,
                      (String _uid) async {
                    var _result = await CloudStorageService.instance
                        .uploadUserImage(_uid, _image);
                    var _imageURL = await _result.ref.getDownloadURL();
                    await DBService.instance.createUserInDB(
                        _uid, _name, _email, _imageURL, _mobileNumber);
                  });
                }
              },
              color: Colors.white,
              child: Text(
                "Register",
                style: TextStyle(
                    fontSize: 18,
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w700),
              ),
            ),
          )
        : Align(
            alignment: Alignment.center,
            child: CircularProgressIndicator(
              backgroundColor: Theme.of(context).primaryColor,
            ),
          );
  }
}
