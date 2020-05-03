import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SnackBarService {
  BuildContext _buildContext;

  static SnackBarService instance = SnackBarService();

  SnackBarService() {}

  set buildContext(BuildContext _context) {
    _buildContext = _context;
  }
  void closeSnackBar(){
    Scaffold.of(_buildContext).hideCurrentSnackBar();
  }
  void showSnackBar(String _message) {
    Scaffold.of(_buildContext).hideCurrentSnackBar();
    Scaffold.of(_buildContext).showSnackBar(
      SnackBar(
        // duration: Duration(seconds: 3),
        content: Text(
          _message,
          style: TextStyle(color: Colors.white, fontSize: 15,fontFamily: "Josefin Sans"),
        ),
      ),
    );
  }

  void showSnackBarError(String _message) {
    Scaffold.of(_buildContext).hideCurrentSnackBar();
    Scaffold.of(_buildContext).showSnackBar(
      SnackBar(
        duration: Duration(seconds: 2),
        content: Text(
          _message,
          style: TextStyle(color: Colors.white, fontSize: 15,fontFamily: "Josefin Sans"),
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  void showSnackBarSuccess(String _message) {
    Scaffold.of(_buildContext).hideCurrentSnackBar();
    Scaffold.of(_buildContext).showSnackBar(
      SnackBar(
        duration: Duration(seconds: 2),
        content: Text(
          _message,
          style: TextStyle(color: Colors.white, fontSize: 15,fontFamily: "Josefin Sans"),
        ),
        backgroundColor: Colors.green,
      ),
    );
  }
}
