import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:practice/payment/razorpay.dart';
import '../user_type.dart';
import '../services/snackbar_service.dart';
import '../services/navigation_service.dart';
import '../services/db_service.dart';
import '../screens/home_page.dart';

enum AuthStatus {
  NotAuthenticated,
  Authenticating,
  Authenticated,
  UserNotFound,
  Error,
}

class AuthProvider extends ChangeNotifier {
  FirebaseUser user;
  AuthStatus status;

  FirebaseAuth _auth;
  static AuthProvider instance = AuthProvider();

  AuthProvider() {
    _auth = FirebaseAuth.instance;
    _checkCurrentUserIsAuthenticated();
  }

  Future<void> _autoLogin() async {
    if (user != null) {
    var userData=await DBService.instance.checkUserData(user.uid);
    if(userData["type"]=="Mentor"){
      NavigationService.instance.navigateToRoute(MaterialPageRoute(builder: (_)=> HomePage(userData["type"], user.uid)));
    }
    else if(userData["type"]=="Mentee" && user.isEmailVerified && userData["paid"]=="yes" ){
      NavigationService.instance.navigateToRoute(MaterialPageRoute(builder: (_)=> HomePage(userData["type"], user.uid)));
    }

    }
  }

  void _checkCurrentUserIsAuthenticated() async {
    user = await _auth.currentUser();

    if (user != null ) {
      notifyListeners();
      await _autoLogin();
    }
  }

  void loginUserWithEmailAndPassword(String _email, String _password, UserType _userType) async {
    status = AuthStatus.Authenticating;
    notifyListeners();
    try {

      AuthResult _result = await _auth.signInWithEmailAndPassword(
          email: _email, password: _password);
      user = _result.user;
        var userType=(_userType==UserType.Mentee)?"Mentee":"Mentor";
      var userData=await DBService.instance.checkUserData(user.uid);
      if(userData["type"]=="Mentor" && userData["type"]==userType){
            NavigationService.instance.navigateToAndRemoveAllRoutes(MaterialPageRoute(builder: (_)=> HomePage(userData["type"], user.uid)));
      }
      else if(userData["type"]=="Mentee" && userData["type"]==userType){
        status = AuthStatus.Authenticated;
       if(!user.isEmailVerified){
         NavigationService.instance.navigateToAndRemoveAll("verify email");
       }
       else if(userData["paid"]=="no"){
         NavigationService.instance.navigateToAndRemoveAllRoutes(MaterialPageRoute(builder: (_)=> RazorPayScreen(userData["type"],user.uid)));
       }
         else{
           NavigationService.instance.navigateToAndRemoveAllRoutes(MaterialPageRoute(builder: (_)=> HomePage(userData["type"], user.uid)));
         }
      }
      else{
        user=null;
        throw Exception();
      }
    } catch (e) {
      status = AuthStatus.Error;
      print(e.message);
      user = null;
      SnackBarService.instance.showSnackBarError("Error Authenticating");
    }
    notifyListeners();
  }

  Future<void> registerUserWithEmailAndPassword(String _email, String _password,
      Future<void> onSuccess(String _uid)) async {
    status = AuthStatus.Authenticating;
    notifyListeners();
    try {
      AuthResult _result = await _auth.createUserWithEmailAndPassword(
          email: _email, password: _password);
      user = _result.user;
      status = AuthStatus.Authenticated;
      await onSuccess(user.uid);
      await sendEmailAddressVerification(user);
      NavigationService.instance.navigateToAndRemoveAll('verify email');
    } catch (e) {
      status = AuthStatus.Error;
      user = null;
      SnackBarService.instance.showSnackBarError("Error Registering User");
    }
    notifyListeners();
  }

  void logoutUser(Future<void> onSuccess()) async {
    try {
      await _auth.signOut();
       await NavigationService.instance.navigateToAndRemoveAll('user select');
      user = null;
      status = AuthStatus.NotAuthenticated;
      await onSuccess();
    } catch (e) {
      SnackBarService.instance.showSnackBarError("Error Logging Out");
    }
    notifyListeners();
  }


Future<void> resetPassword(String email) async {
  try{
    return _auth.sendPasswordResetEmail(email: email);
  }
  catch(error){
    throw error;

  }
    
}
bool checkEmailVerified(){
  return user.isEmailVerified;
  
}
Future<void> sendEmailAddressVerification(FirebaseUser user)async {
   try{
     await user.sendEmailVerification();
   }catch(error){
     print(error.message);
   }
}
}
