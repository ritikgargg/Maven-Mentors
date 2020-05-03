import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class ForgotPassword extends StatefulWidget {
  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  TextEditingController _emailController = TextEditingController();
  double _deviceHeight;
  double _deviceWidth;
  var scaffold;
  bool _isSending=false;
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _emailController.clear();
  }

  @override
  Widget build(BuildContext context) {
    
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return ChangeNotifierProvider.value(
      value: AuthProvider(),
      child: Scaffold(
        backgroundColor: Theme.of(context).accentColor,
          body: SingleChildScrollView(
                      child: Center(
        child: Container(
            height: _deviceHeight*0.8,
            width: _deviceWidth *0.8,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
         
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(height: _deviceHeight*0.15,),
                Image.asset("assets/images/forget.png",
                height: _deviceHeight*0.4,
                width: _deviceWidth*0.4,
                fit: BoxFit.contain,),
                SizedBox(height: _deviceHeight*0.02,),
                TextField(
                  autocorrect: false,
                  style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w700),
                  showCursor: true,
                  cursorColor: Theme.of(context).primaryColor,
                  controller: _emailController,
                  decoration: InputDecoration(
                    focusedBorder: UnderlineInputBorder(
                      // borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide(
                        color: Theme.of(context).primaryColor,
                        
                      ),
                    ),
                    hintText: "Email Address",
                    focusColor: Theme.of(context).primaryColor,
                  ),
                ),
                SizedBox(height: _deviceHeight * 0.03),
                Consumer<AuthProvider>(builder: (ctx, _auth, child) {
                  scaffold=Scaffold.of(ctx);
                  
                  return Container(
                    height: _deviceHeight * 0.06,
                    child: MaterialButton(
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(_deviceHeight * 0.03)),
                      onPressed: () async {
                        setState(() {
                          _isSending=true;
                        });
                        if (_emailController.text.length != 0) {
                          try {
                            await _auth.resetPassword(_emailController.text);
                            scaffold.showSnackBar(SnackBar(
                              duration: Duration(seconds:3),
                              content: Text(
                                "A password reset link has been sent to ${_emailController.text}",
                                style: TextStyle(fontFamily: "Josefin Sans"),
                              ),
                              backgroundColor: Colors.green,
                            ));
                            Timer(Duration(seconds: 3),()=>Navigator.of(context).pop());
                          } catch (error) {
                            scaffold.showSnackBar(SnackBar(
                              content: Text(
                                error.message,
                                style: TextStyle(fontFamily: "Josefin Sans"),
                              ),
                              backgroundColor: Colors.red,
                            ));
                          }
                        }
                      },
                      color: Colors.white,
                      child: (_isSending)?CircularProgressIndicator(backgroundColor: Theme.of(context).primaryColor,):Text(
                        "SEND REQUEST",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).primaryColor),
                      ),
                    ),
                  );
                }),
              ],
            ),
        ),
      ),
          )),
    );
  }
}
