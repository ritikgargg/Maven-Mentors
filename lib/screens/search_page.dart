import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:cached_network_image/cached_network_image.dart';

import '../providers/auth_provider.dart';

import '../services/db_service.dart';
import '../services/navigation_service.dart';

import '../screens/conversation_page.dart';

import '../models/contact.dart';
import '../user_type.dart';

class SearchPage extends StatefulWidget {
  double _height;
  double _width;
  String userType;

  SearchPage(this._height, this._width, this.userType);

  @override
  State<StatefulWidget> createState() {
    return _SearchPageState();
  }
}

class _SearchPageState extends State<SearchPage> {
  String _searchText;

  AuthProvider _auth;
  bool _isCreatingConversation = false;
  bool _check;
  String otherUser;

  _SearchPageState() {
    _searchText = '';
  }

  @override
  Widget build(BuildContext context) {
    otherUser=(widget.userType=="Mentee")?"a mentor":"mentees";
    return Container(
      child: ChangeNotifierProvider<AuthProvider>.value(
        value: AuthProvider.instance,
        child: _searchPageUI(),
      ),
    );
  }

  Widget _searchPageUI() {
    return Builder(
      builder: (BuildContext _context) {
        _auth = Provider.of<AuthProvider>(_context);
        return (_isCreatingConversation)
            ? SpinKitCircle(
                color: Colors.blue,
                size: 50.0,
              )
            : _usersListView();
      },
    );
  }

  Widget _messageIfAllotmentNotDone(String otherUserType) {
    return Center(
      child: Card(
        
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(30)
          )
        ),
              child: Container(
                

              padding: const EdgeInsets.all(20),
          alignment: Alignment.center,
          decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(30)
          ),
            gradient: LinearGradient(colors: 
            [ Color.fromRGBO(43, 125, 209,1),
                  Color.fromRGBO(87, 238, 254,1),],
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight)
          ),
          
          width: widget._width * 0.8,
          height: widget._height * 0.35,
          child: Text(
            "Thank you for becoming a part of maven mentors. We will allot you $otherUserType as soon as we find a suitable match for you.\nYou can contact us anytime by pressing the button below to chat with us.",
            style: TextStyle(
             
              fontSize: 20,
              
             
       
            ),

            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _usersListView() {
    return StreamBuilder<List<Contact>>(
      stream:
          DBService.instance.getUsersInDB(this.widget.userType, _auth.user.uid),
      builder: (_context, _snapshot) {
        var _usersData = _snapshot.data;
        if (_usersData != null) {
          _usersData.removeWhere((_contact) => _contact.id == _auth.user.uid);
          return _usersData.length != 0
              ? LayoutBuilder(
                  builder: (_ctx, _constraints) {
                    return Container(
                      height: _constraints.maxHeight,
                      width: _constraints.maxWidth,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: ListView.builder(
                          itemCount: _usersData.length,
                          itemBuilder: (BuildContext _context, int _index) {
                            var _userData = _usersData[_index];
                            var _currentTime = DateTime.now();
                            var _recepientID = _usersData[_index].id;
                            // var _isUserActive = !_userData.lastseen.toDate().isBefore(
                            //       _currentTime.subtract(
                            //         Duration(hours: 1),
                            //       ),
                            //     );
                            return Column(
                              children: <Widget>[
                                ListTile(
                                  onTap: () {
                                    setState(() {
                                      _isCreatingConversation = true;
                                    });

                                    DBService.instance.createOrGetConversartion(
                                        _auth.user.uid, _recepientID,
                                        (String _conversationID) {
                                      _isCreatingConversation = false;
                                      NavigationService.instance
                                          .navigateToRoute(
                                        MaterialPageRoute(builder: (_context) {
                                          return ConversationPage(
                                              _conversationID,
                                              _recepientID,
                                              _userData.name,
                                              _userData.image);
                                        }),
                                      );
                                    });
                                  },
                                  title: Text(_userData.name),
                                  leading: InkWell(
                                    onTap: () {
                                      showDialog(
                                          context: _context,
                                          builder: (BuildContext context) {
                                            return Dialog(
                                              insetAnimationCurve:
                                                  Curves.easeIn,
                                              insetAnimationDuration:
                                                  Duration(seconds: 1),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20.0)),
                                              child: CachedNetworkImage(
                                                imageUrl: _userData.image,
                                                imageBuilder:
                                                    (context, imageProvider) =>
                                                        Container(
                                                  height: widget._height * 0.3,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20.0),
                                                    image: DecorationImage(
                                                        image: imageProvider,
                                                        fit: BoxFit.cover),
                                                  ),
                                                ),
                                               
                                                placeholder: (context, url) =>
                                                    CircularProgressIndicator(
                                                  backgroundColor:
                                                      Theme.of(context)
                                                          .primaryColor,
                                                ),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Icon(Icons.error),
                                              ),
                                            );
                                          });
                                    },
                                    child: CachedNetworkImage(
                                      imageUrl: _userData.image,
                                      imageBuilder: (context, imageProvider) =>
                                          Container(
                                        width: 55.0,
                                        height: 55.0,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                              image: imageProvider,
                                              fit: BoxFit.cover),
                                        ),
                                      ),
                                      placeholder: (context, url) =>
                                          CircularProgressIndicator(
                                        backgroundColor:
                                            Theme.of(context).primaryColor,
                                        strokeWidth: 2.0,
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.error),
                                    ),
                                  ),
                                ),
                                Divider(
                                  indent: 80,
                                  endIndent: 15,
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    );
                  },
                )
              : _messageIfAllotmentNotDone(otherUser);
        } else {
          return SpinKitCircle(
            color: Colors.blue,
            size: 50.0,
          );
        }
      },
    );
  }
}
