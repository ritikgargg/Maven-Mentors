import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

import '../services/snackbar_service.dart';
import '../services/navigation_service.dart';
import '../user_type.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginPageState();
  }
}

class _LoginPageState extends State<LoginPage> {
  double _deviceHeight;
  double _deviceWidth;
  UserType _userType= UserTypeInfo.instance.userType;
  bool _isVisible=false;
  // static var mediaquery;

  GlobalKey<FormState> _formKey;
  AuthProvider _auth;

  String _email;
  String _password;

  _LoginPageState() {
    _formKey = GlobalKey<FormState>();
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    // mediaquery=MediaQuery.of(context);


    return Scaffold(
      backgroundColor: Theme.of(context).accentColor,
      body: Align(
        alignment: Alignment.center,
        child: ChangeNotifierProvider<AuthProvider>.value(
          value: AuthProvider.instance,
          child: _loginPageUI(),
        ),
      ),
    );
  }

  Widget _loginPageUI() {
    return Builder(
      builder: (BuildContext _context) {
        SnackBarService.instance.buildContext = _context;
        _auth = Provider.of<AuthProvider>(_context);
        return SingleChildScrollView(
                  child: Container(
            height: _deviceHeight * 0.60,
            padding: EdgeInsets.symmetric(horizontal: _deviceWidth * 0.10),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _headingWidget(),
                _inputForm(),
                _loginButton(),
                (_userType==UserType.Mentee)? _registerButton(): Container(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _headingWidget() {
    return Container(
      height: _deviceHeight * 0.10,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "Welcome back!",
            style: TextStyle(fontSize: 35, fontWeight: FontWeight.w700,fontFamily: "Josefin Sans"),
          ),
          Text(
            "Please login to your account.",
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.w300, fontFamily: "Josefin Sans"),
          ),
        ],
      ),
    );
  }

  Widget _inputForm() {
    return Container(
      height: _deviceHeight * 0.20,
      child: Form(
        key: _formKey,
        onChanged: () {
          _formKey.currentState.save();
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _emailTextField(),
            _passwordTextField(),
            InkWell(
              onTap:(){
                NavigationService.instance.navigateTo("forgot password");
              },
              child:Align(
                alignment: Alignment.bottomRight,
                child: Text("Forgot password?",style: TextStyle(fontWeight: FontWeight.w700, color: Theme.of(context).primaryColor),))
            )
          ],
        ),
      ),
    );
  }

  Widget _emailTextField() {
    return TextFormField(
      autocorrect: false,
      style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w700),
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
        hintText: "Email Address",
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
      style: TextStyle(color: Theme.of(context).primaryColor,fontWeight: FontWeight.w700),
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
          icon:(!_isVisible)?Icon(Icons.visibility):Icon(Icons.visibility_off),
          onPressed: (){
            setState(() {
              _isVisible=!_isVisible;
            });
          },),
        hintText: "Password",
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color:Theme.of(context).primaryColor),
        ),
      ),
    );
  }

  Widget _loginButton() {
    return _auth.status == AuthStatus.Authenticating
        ? Align(
            alignment: Alignment.center,
            child: CircularProgressIndicator(
              backgroundColor: Theme.of(context).primaryColor,
            ),
          )
        : Container(
            height: _deviceHeight * 0.06,
            width: _deviceWidth,
            child: MaterialButton(
              shape: RoundedRectangleBorder(borderRadius:BorderRadius.circular(_deviceHeight * 0.03)),
              onPressed: () {
                
                if (_formKey.currentState.validate()) {
                  _auth.loginUserWithEmailAndPassword(_email, _password, _userType);
                }
              },
              color: Colors.white,
              child: Text(
                "LOGIN",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700,
                color: Theme.of(context).primaryColor),
              ),
            ),
          );
  }

  Widget _registerButton() {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(
          "register"
        );
      },
      child: Container(
        height: _deviceHeight * 0.06,
        width: _deviceWidth,
        child: Text(
          "REGISTER",
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.w700, color: Theme.of(context).primaryColor),
        ),
      ),
    );
  }
}
