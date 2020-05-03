import 'package:flutter/material.dart';
import './user_select.dart';
import 'dart:async';
import '../providers/auth_provider.dart';


class MySplashScreen extends StatefulWidget {
  
  MySplashScreen(){
    
  }
  @override
  _MySplashScreenState createState() => _MySplashScreenState();
}


class _MySplashScreenState extends State<MySplashScreen> {
  bool isInit=true;
  AuthProvider _auth;
  @override
  void didChangeDependencies() {
    if(isInit)
    {
      Timer(Duration(seconds: 2), (){_auth=AuthProvider();});
      Timer(Duration(seconds: 4), ()=>Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_)=> UserSelect())));
      isInit=false;
    }
    
    super.didChangeDependencies();
    
      }
  @override

  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
            color: Color.fromRGBO(43, 125, 209,1),
            child: Center(
                child:Image.asset('assets/images/logomini.png',
                         fit: BoxFit.contain,
                         width: MediaQuery.of(context).size.width*0.25,
                         height: MediaQuery.of(context).size.width*0.25,)
          ) ,
          ),
      
    );
  }
}