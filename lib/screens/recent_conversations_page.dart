import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

import '../services/db_service.dart';
import '../services/navigation_service.dart';

import '../models/conversation.dart';
import '../models/message.dart';

import '../screens/conversation_page.dart';

class RecentConversationsPage extends StatelessWidget {
  final double _height;
  final double _width;

  RecentConversationsPage(this._height, this._width);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _height,
      width: _width,
      child: ChangeNotifierProvider<AuthProvider>.value(
        value: AuthProvider.instance,
        child: _conversationsListViewWidget(),
      ),
    );
  }

  Widget _conversationsListViewWidget() {
    return Builder(
      builder: (BuildContext _context) {
        var _auth = Provider.of<AuthProvider>(_context);
        return Container(
          height: _height,
          width: _width,
          child: StreamBuilder<List<ConversationSnippet>>(
            stream: DBService.instance.getUserConversations(_auth.user.uid),
            builder: (_context, _snashot) {
              var _data = _snashot.data;
              if (_data != null) {
                _data.removeWhere((_c) {
                  return (_c.timestamp == null)||(_c.id=="01yM04FsPwRcri4kmWPqPrpnwYz1");
                });
                return _data.length != 0
                    ? Padding(
                      padding: const EdgeInsets.only(top:8.0),
                      child: ListView.builder(
                          itemCount: _data.length,
                          itemBuilder: (_context, _index) {
                            return Column(
                              children: <Widget>[
                                ListTile(
                                  
                                  onTap: () {
                                    NavigationService.instance.navigateToRoute(
                                      MaterialPageRoute(
                                        builder: (BuildContext _context) {
                                          return ConversationPage(
                                              _data[_index].conversationID,
                                              _data[_index].id,
                                              _data[_index].name,
                                              _data[_index].image);
                                        },
                                      ),
                                    );
                                  },
                                  title: Text(_data[_index].name),
                                  subtitle: Text(
                                    _data[_index].type == MessageType.Text
                                        ? _data[_index].lastMessage
                                        : "Attachment: Image",
                                    overflow: TextOverflow.clip,
                                    maxLines: 1,
                                  ),
                                  leading: InkWell(
                                    onTap: () => showDialog(
                                        context: _context,
                                        builder: (BuildContext context) {
                                          return Dialog(
                                            insetAnimationCurve: Curves.easeIn,
                                            insetAnimationDuration: Duration(seconds: 1),
                                           shape: RoundedRectangleBorder(
                                               borderRadius: BorderRadius.circular(
                                                   20.0)), 
                                           child: CachedNetworkImage(
                                             imageUrl: _data[_index].image,
                                             imageBuilder:
                                                 (context, imageProvider) =>
                                                     Container(
                                               
                                               height: _height*0.3,
                                               decoration: BoxDecoration(
                                                 borderRadius: BorderRadius.circular(
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
                                             errorWidget: (context, url, error) =>
                                                 Icon(Icons.error),
                                           ),
                                            );
                                        }),
                                    child: CachedNetworkImage(
                                      imageUrl: _data[_index].image,
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
                                          CircularProgressIndicator(backgroundColor: Theme.of(context).primaryColor,strokeWidth: 2.0,),
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.error),
                                    ),
                                  ),
                                  trailing: _listTileTrailingWidgets(
                                      _data[_index].timestamp),
                                ),
                                Divider(indent:80 ,
                                endIndent: 15,),
                              ],
                            );
                          },
                        ),
                    )
                    : Align(
                        child: Text(
                          "No Conversations Yet!",
                          style: TextStyle(
                              color: Theme.of(_context).primaryColor,
                              fontSize: 15.0,
                              fontWeight: FontWeight.w700),
                        ),
                      );
              } else {
                return SpinKitCircle(
                  color: Colors.blue,
                  size: 50.0,
                );
              }
            },
          ),
        );
      },
    );
  }

  Widget _listTileTrailingWidgets(Timestamp _lastMessageTimestamp) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Text(
          "Last Message",
          style: TextStyle(fontSize: 13),
        ),
        Text(
          timeago.format(_lastMessageTimestamp.toDate()),
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
