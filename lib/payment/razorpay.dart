import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:practice/screens/home_page.dart';
import 'package:practice/services/db_service.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../services/navigation_service.dart';
import '../screens/conversation_page.dart';
import 'package:fluttertoast/fluttertoast.dart';


class RazorPayScreen extends StatefulWidget {
  String _uid;
  String _userType;
  RazorPayScreen(this._userType,this._uid);
  @override
  _RazorPayScreenState createState() => _RazorPayScreenState();
}

class _RazorPayScreenState extends State<RazorPayScreen> {
  double _deviceWidth;
  double _deviceHeight;
  Razorpay _razorpay;
  bool _isCreatingConversation=false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _razorpay.clear();
  }

  void openCheckout() {
    var options = {
      'key': 'rzp_test_lVkVvOf9ekH0DK',
      'amount': 110000,
      'name': 'Maven Mentors',
      'description': 'Monthly Guidance Fee',
      'currency': "INR",
      'prefill': {'contact': '', 'email': ''},
    };
    try {
      _razorpay.open(options);
    } catch (error) {
      print("object");
      debugPrint(error.toString());
    }
  }
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

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    setState(() {
      _isCreatingConversation=true;
    });
    DBService.instance.updateUserPaidStatus(this.widget._uid).then((_) async {
      await DBService.instance.createOrGetFirstConversation(
          this.widget._uid, "01yM04FsPwRcri4kmWPqPrpnwYz1",
          (String _conversationID) {
            _isCreatingConversation=false;
            NavigationService.instance.navigateToReplacementRoute( MaterialPageRoute(builder: (_) =>HomePage(this.widget._userType, this.widget._uid)));
        NavigationService.instance.navigateToRoute(
          MaterialPageRoute(builder: (_) {
            return ConversationPage(
                _conversationID,
                "01yM04FsPwRcri4kmWPqPrpnwYz1",
                "Maven Mentors",
                "https://i.pravatar.cc/150?img=56");
          }),
        );
      });
    });
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(msg: "${response.message}", gravity: ToastGravity.CENTER);
    print(response.code);
    print(response.message);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {}

  @override
  Widget build(BuildContext context) {
    _deviceWidth = MediaQuery.of(context).size.width;
    _deviceHeight = MediaQuery.of(context).size.height;
    return WillPopScope(
      onWillPop: _onBackPressed,
          child: Scaffold(
        body:(_isCreatingConversation)?SpinKitCircle(color: Colors.blue,size: 50.0,): SingleChildScrollView(
          child: Center(
            child: Container(
              height: _deviceHeight,
              width: _deviceWidth * 0.8,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: <Widget>[
                    Container(
                      height: _deviceHeight * 0.22,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            
                            "Monthly Mentorship Fee",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 35,
                                fontWeight: FontWeight.w700,
                                fontFamily: "Josefin Sans"),
                          ),
                          Text(
                            "You are just one step away.",
                            style: TextStyle(
                                fontSize: 23,
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
                        borderRadius: BorderRadius.circular(_deviceWidth * 0.3),
                        child: Image.asset(
                          "assets/images/payfee.jpg",
                          height: _deviceWidth * 0.6,
                          width: _deviceWidth * 0.6,
                        ),
                      ),
                    ),
                    SizedBox(height: _deviceHeight * 0.04),
                    Container(
                       margin: const EdgeInsets.all(10),
                      height: _deviceHeight * 0.06,
                      width: _deviceWidth * 0.8,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [Colors.black54, Colors.black]),
                        borderRadius: BorderRadius.circular(15)

                      ),
                      child: Center(child: Text("₹ 1100.00", style: TextStyle(color:Colors.white, fontWeight: FontWeight.bold, fontSize: 18),)),
                    ),
                    Container(
                      margin: const EdgeInsets.all(10),
                      height: _deviceHeight * 0.06,
                      width: _deviceWidth * 0.8,
                      child: MaterialButton(
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(_deviceHeight * 0.03)),
                        onPressed: openCheckout,
                        color: Colors.white,
                        child: Text(
                          "PAY",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).primaryColor),
                        ),
                      ),
                    ),
                  ]),
            ),
          ),
        ),
      ),
    );
  }
}
