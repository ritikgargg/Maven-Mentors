import 'package:flutter/material.dart';
import 'package:practice/payment/razorpay.dart';
import './screens/forgot_password.dart';
import './screens/splash_screen.dart';
import './services/navigation_service.dart';
import './screens/login_page.dart';
import './screens/registration_page.dart';
import './screens/home_page.dart';
import './screens/user_select.dart';
import 'package:flutter/services.dart';
import './screens/verify_email_screen.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return new MaterialApp(

      debugShowCheckedModeBanner: false,
      title: 'Maven Mentors',
      navigatorKey: NavigationService.instance.navigatorKey,
      theme: new ThemeData(
        appBarTheme: AppBarTheme(
          textTheme:TextTheme(
            title: TextStyle(fontFamily: "Josefin Sans",
            fontWeight: FontWeight.w700, fontSize: 16)
          )

        ),
        fontFamily: "Open Sans",
        primaryColor: Color.fromRGBO(43, 125, 209, 1),
        accentColor: Colors.grey[300],
      ),
      home: MySplashScreen(),
      routes: {
        // "/": (BuildContext _context) => MySplashScreen(),
        "user select":(BuildContext _context)=> UserSelect(),
        "login": (BuildContext _context) => LoginPage(),
        "register": (BuildContext _context) => RegistrationPage(),
        "forgot password":(BuildContext _context)=> ForgotPassword(),
        "verify email": (BuildContext _context)=> VerifyEmailScreen(),
      },
    );
  }
}
