import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:practice/services/db_service.dart';
import 'package:practice/user_type.dart';

import './profile_page.dart';
import './recent_conversations_page.dart';
import './search_page.dart';
import '../providers/auth_provider.dart';
import 'package:provider/provider.dart';

import './conversation_page.dart';
import '../services/navigation_service.dart';
import 'package:rating_dialog/rating_dialog.dart';

class HomePage extends StatefulWidget {
  String userType;
  String _uid;
  HomePage(this.userType, this._uid);
  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  double _height;
  double _width;
  TabController _tabController;
  bool _isCreatingConversation = false;

  _HomePageState() {
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1);
  }
  void ratingMentor() {
    showDialog(
        context: context,
        barrierDismissible: true, // set to false if you want to force a rating
        builder: (context) {
          return RatingDialog(
            icon: CircleAvatar(
              radius: 30,
              backgroundColor: Theme.of(context).primaryColor,
              child: Image.asset("assets/images/logomini.png", fit:BoxFit.contain,height:30 ,width: 30,)), // set your own image/icon widget
            title: "Rate your mentor",
            description:
                "Rate your mentor on the basis of his mentorship the previous week.",
            submitButton: "SUBMIT",
            alternativeButton: "Contact us instead?", // optional
            positiveComment: "We are so happy to hear :)", // optional
            negativeComment: "We're sad to hear :(", // optional
            accentColor: Theme.of(context).primaryColor, 
            // optional
            onSubmitPressed: (int rating) {
              print("onSubmitPressed: rating = $rating");
              Fluttertoast.showToast(
                fontSize: 20,
                  msg: "Thank you for your response.",
                  gravity: ToastGravity.CENTER);
              // TODO: open the app's page on Google Play / Apple App Store
            },
            onAlternativePressed: _chatWithUs,
          );
        });
  }

  void _chatWithUs() {
    setState(() {
      _isCreatingConversation = true;
    });
    DBService.instance.createOrGetConversartion(
        this.widget._uid, "01yM04FsPwRcri4kmWPqPrpnwYz1",
        (String _conversationID) {
      _isCreatingConversation = false;
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

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        backgroundColor: Theme.of(context).accentColor,
        floatingActionButton: (UserTypeInfo.instance.userType == UserType.Admin)
            ? null
            : FloatingActionButton(
                onPressed: _chatWithUs,
                tooltip: "Chat with us",
                child: Icon(
                  Icons.question_answer,
                  color: Theme.of(context).primaryColor,
                  size: 30,
                ),
              ),
        appBar: AppBar(
          actions: <Widget>[
           (widget.userType=="Mentee") ? IconButton(
               icon: Icon(Icons.feedback),
                onPressed: () {
                  ratingMentor();
                }):Container(),
          ],
          leading: Padding(
            padding: const EdgeInsets.only(
              left: 8.0,
              top: 8.0,
              bottom: 8.0,
              right: 4.0,
            ),
            child: Image.asset(
              "assets/images/logomini.png",
              width: 18,
              height: 18,
            ),
          ),
          backgroundColor: Theme.of(context).primaryColor,
          title: Text(
            "Maven Mentors",
            style: TextStyle(
              fontSize: 17,
              fontFamily: "League Spartan",
            ),
          ),
          bottom: TabBar(
            unselectedLabelColor: Colors.white,
            indicatorColor: Colors.amber,
            labelColor: Colors.amber,
            controller: _tabController,
            tabs: [
              Tab(
                icon: Icon(
                  Icons.people_outline,
                  size: 25,
                ),
              ),
              Tab(
                icon: Icon(
                  Icons.chat_bubble_outline,
                  size: 25,
                ),
              ),
              Tab(
                icon: Icon(
                  Icons.person_outline,
                  size: 25,
                ),
              ),
            ],
          ),
        ),
        body: (_isCreatingConversation)
            ? SpinKitCircle(
                color: Colors.blue,
                size: 50.0,
              )
            : _tabBarPages(),
      ),
    );
  }

  Widget _tabBarPages() {
    return TabBarView(
      controller: _tabController,
      children: <Widget>[
        SearchPage(_height, _width,this.widget.userType),
        RecentConversationsPage(_height, _width),
        ProfilePage(_height, _width),
      ],
    );
  }
}
