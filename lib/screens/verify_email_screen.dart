import 'dart:async';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class VerifyEmailScreen extends StatefulWidget {
  @override
  _VerifyEmailScreenState createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  var _deviceHeight;

  var _deviceWidth;

  var scaffold;
  var _isSuccessful = false;
  Future<bool> _onBackPressed() {
    return showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: Text(
                "Are you sure you want to exit?",
                style: TextStyle(fontSize: 18),
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text(
                    "Yes",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                ),
                FlatButton(
                  child: Text(
                    "No",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                )
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    _deviceWidth = MediaQuery.of(context).size.width;
    _deviceHeight = MediaQuery.of(context).size.height;

    return ChangeNotifierProvider.value(
      value: AuthProvider(),
      child: WillPopScope(
        onWillPop: _onBackPressed,
              child: Scaffold(
          body: Align(
            alignment: Alignment.center,
            child: SingleChildScrollView(
              child: Container(
                width: _deviceWidth * 0.8,
                child: Consumer<AuthProvider>(
                  builder: (ctx, _auth, child) {
                    scaffold = Scaffold.of(ctx);
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      
                      children: <Widget>[
                        SizedBox(
                          height: _deviceHeight * 0.22,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                "Verify your email address",
                                style: TextStyle(
                                    fontSize: 35,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: "Josefin Sans"),
                              ),
                              Text(
                                "To complete your profile and avail our services, please verify your account.",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w300,
                                    fontFamily: "Josefin Sans"),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: _deviceHeight * 0.02),
                        Align(
                          alignment: Alignment.center,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: Image.asset(
                              "assets/images/26520174.jpg",
                              height: _deviceHeight * 0.2,
                              width: _deviceHeight * 0.2,
                            ),
                          ),
                        ),
                        SizedBox(height: _deviceHeight * 0.04),
                        Text(
                          "Verified? Then ",
                          style: TextStyle(fontFamily: "Josefin Sans"),
                        ),
                        Container(
                          margin: const EdgeInsets.all(10),
                          height: _deviceHeight * 0.06,
                          width: _deviceWidth * 0.8,
                          child: MaterialButton(
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(_deviceHeight * 0.03)),
                            onPressed: () {
                              setState(() {
                                _isSuccessful = true;
                              });
                              Timer(
                                  Duration(seconds: 2),
                                  () => Navigator.of(context)
                                      .pushReplacementNamed("login"));
                            },
                            color: Colors.white,
                            child: (_isSuccessful)
                                ? CircularProgressIndicator(
                                    backgroundColor:
                                        Theme.of(context).primaryColor,
                                  )
                                : Text(
                                    "SIGN IN",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                        color: Theme.of(context).primaryColor),
                                  ),
                          ),
                        ),
                        SizedBox(
                          height: _deviceHeight * 0.02,
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                "Didn't receive email?",
                              ),
                              GestureDetector(
                                onTap: () async {
                                  scaffold.showSnackBar(
                                    SnackBar(
                                      content: Text("Sending...",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15,
                                              fontFamily: "Josefin Sans")),
                                    ),
                                  );
                                  await _auth
                                      .sendEmailAddressVerification(_auth.user);
                                  scaffold.hideCurrentSnackBar();
                                  scaffold.showSnackBar(
                                    SnackBar(
                                      duration: Duration(seconds: 2),
                                      backgroundColor: Colors.green,
                                      content: Text(
                                        "Sent!",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontFamily: "Josefin Sans"),
                                      ),
                                    ),
                                  );
                                },
                                child: Text(
                                  " Resend Email",
                                  style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ])
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
