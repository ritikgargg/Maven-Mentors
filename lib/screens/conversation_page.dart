import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:practice/services/navigation_service.dart';
import '../services/snackbar_service.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_parsed_text/flutter_parsed_text.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/auth_provider.dart';

import '../services/db_service.dart';
import '../services/media_service.dart';
import '../services/cloud_storage_service.dart';

import '../models/conversation.dart';
import '../models/message.dart';
import './show_image.dart';
import './show_profile_image.dart';

class ConversationPage extends StatefulWidget {
  String _conversationID;
  String _receiverID;
  String _receiverImage;
  String _receiverName;

  ConversationPage(this._conversationID, this._receiverID, this._receiverName,
      this._receiverImage);

  @override
  State<StatefulWidget> createState() {
    return _ConversationPageState();
  }
}

class _ConversationPageState extends State<ConversationPage> {
  double _deviceHeight;
  double _deviceWidth;
  // bool _isShowingList=false;
  bool _isRefreshed = false;

  GlobalKey<FormState> _formKey;
  ScrollController _listViewController;
  AuthProvider _auth;

  TextEditingController _messageText;
  int _numberOfMessagesDisplayed = 20;
  List<Message> _messagesDisplayed;

  _ConversationPageState() {
    _formKey = GlobalKey<FormState>();
    _listViewController = ScrollController();
    _messageText = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Theme.of(context).accentColor,
      appBar: AppBar(
        // actions: <Widget>[
        //   (_isShowingList)?IconButton(tooltip: "Navigate to bottom",
        //     icon: Icon(Icons.arrow_downward),
        //      onPressed:()=> _listViewController
        //           .jumpTo(_listViewController.position.maxScrollExtent),
        //   ):Container()
        // ],
        backgroundColor: Theme.of(context).primaryColor,
        title: InkWell(
          onTap:(this.widget._receiverID != "01yM04FsPwRcri4kmWPqPrpnwYz1")? () {
            NavigationService.instance.navigateToRoute(MaterialPageRoute(
                builder: (_) => ShowProfileImage(widget._receiverImage)));
          }:(){},
          child: Align(
            alignment:(this.widget._receiverID != "01yM04FsPwRcri4kmWPqPrpnwYz1")?Alignment(-1, 0):Alignment(-0.3, 0),
            child: Row(mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                (this.widget._receiverID != "01yM04FsPwRcri4kmWPqPrpnwYz1")
                    ? Hero(
                        tag: "Show Profile Image",
                        child: CachedNetworkImage(
                          imageUrl: this.widget._receiverImage,
                          imageBuilder: (context, imageProvider) => Container(
                            margin: EdgeInsets.only(right: 10),
                            width: 40.0,
                            height: 40.0,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                  image: imageProvider, fit: BoxFit.cover),
                            ),
                          ),
                          placeholder: (context, url) =>
                              CircularProgressIndicator(),
                          errorWidget: (context, url, error) => Icon(Icons.error),
                        ),
                      )
                    : Image.asset(
                        "assets/images/logomini.png",
                        width: 40,
                        height: 40,
                      
                      ),
                 Text(this.widget._receiverName, style: (this.widget._receiverID == "01yM04FsPwRcri4kmWPqPrpnwYz1")?TextStyle(fontFamily: "League Spartan", fontSize: 16): TextStyle(),)
              ],
            ),
          ),
        ),
      ),
      body: ChangeNotifierProvider<AuthProvider>.value(
        value: AuthProvider.instance,
        child: _conversationPageUI(),
      ),
    );
  }

  Widget _conversationPageUI() {
    return Builder(
      builder: (BuildContext _context) {
        _auth = Provider.of<AuthProvider>(_context);
        SnackBarService.instance.buildContext = _context;
        return Stack(
          overflow: Overflow.visible,
          children: <Widget>[
            _messageListView(),
            Align(
              alignment: Alignment.bottomCenter,
              child: _messageField(_context),
            ),
          ],
        );
      },
    );
  }

  Widget _messageListView() {
    return Container(
      height: _deviceHeight * 0.8,
      width: _deviceWidth,
      child: StreamBuilder<Conversation>(
        stream: DBService.instance.getConversation(this.widget._conversationID),
        builder: (BuildContext _context, _snapshot) {
          if (!_isRefreshed)
            Timer(Duration(microseconds: 50), () {
              _listViewController
                  .jumpTo(_listViewController.position.maxScrollExtent);
            });
          var _conversationData = _snapshot.data;
          if (_conversationData != null) {
            if (_conversationData.messages.length != 0) {
              int itemCount = (_conversationData.messages.length >=
                      _numberOfMessagesDisplayed)
                  ? _numberOfMessagesDisplayed
                  : _conversationData.messages.length;
              _messagesDisplayed = _conversationData.messages
                  .sublist(_conversationData.messages.length - itemCount);
              // _isShowingList=true;
              return RefreshIndicator(
                color: Theme.of(context).primaryColor,
                onRefresh: () async {
                  await Future.delayed(Duration(seconds: 2));
                  setState(() {
                    _isRefreshed = true;
                    if (_conversationData.messages.length >
                        _numberOfMessagesDisplayed)
                      _numberOfMessagesDisplayed += 20;
                  });
                },
                child: ListView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                  controller: _listViewController,
                  children: _messagesDisplayed.map((_message) {
                    bool _isOwnMessage = _message.senderID == _auth.user.uid;
                    return _messageListViewChild(
                        _isOwnMessage, _message, _context);
                  }).toList(),
                ),
              );
            } else {
              return Align(
                alignment: Alignment.center,
                child: Text("Let's start a conversation!"),
              );
            }
          } else {
            return SpinKitCircle(
              color: Colors.blue,
              size: 50.0,
            );
          }
        },
      ),
    );
  }

  Widget _messageListViewChild(
      bool _isOwnMessage, Message _message, BuildContext _context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment:
            _isOwnMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: <Widget>[
          !_isOwnMessage ? _userImageWidget() : Container(),
          SizedBox(width: _deviceWidth * 0.02),
          _message.type == MessageType.Text
              ? _textMessageBubble(
                  _isOwnMessage, _message.content, _message.timestamp)
              : _imageMessageBubble(_isOwnMessage, _message.content,
                  _message.timestamp, _context),
        ],
      ),
    );
  }

  Widget _userImageWidget() {
    double _imageRadius = _deviceHeight * 0.05;
    return CachedNetworkImage(
      imageUrl: this.widget._receiverImage,
      imageBuilder: (context, imageProvider) => Container(
        margin: EdgeInsets.only(right: 10),
        width: _imageRadius,
        height: _imageRadius,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
        ),
      ),
      placeholder: (context, url) => CircularProgressIndicator(),
      errorWidget: (context, url, error) => Icon(Icons.error),
    );
  }

  Widget _textMessageBubble(
      bool _isOwnMessage, String _message, Timestamp _timestamp) {
    List<Color> _colorScheme = _isOwnMessage
        ? [Colors.blue, Theme.of(context).primaryColor]
        : [Color.fromRGBO(69, 69, 69, 1), Color.fromRGBO(43, 43, 43, 1)];
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: _deviceWidth * 0.75),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(15.0),
            topLeft: Radius.circular(15.0),
            bottomLeft:
                _isOwnMessage ? Radius.circular(15.0) : Radius.circular(0.0),
            bottomRight:
                _isOwnMessage ? Radius.circular(0.0) : Radius.circular(15.0),
          ),
          gradient: LinearGradient(
            colors: _colorScheme,
            stops: [0.30, 0.70],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              ParsedText(
                  selectable: true,
                  text: _message,
                  style: TextStyle(
                      color: _isOwnMessage ? Colors.black : Colors.white),
                  parse: <MatchText>[
                    MatchText(
                        type: ParsedType.URL,
                        style: TextStyle(
                          color: _isOwnMessage
                              ? Colors.yellowAccent[100]
                              : Colors.blue[300],
                        ),
                        onTap: (url) async {
                          var a = await canLaunch(url);
                          if (a) {
                            launch(url);
                          }
                        }),
                    MatchText(
                        type: ParsedType.EMAIL,
                        style: TextStyle(
                          color: _isOwnMessage
                              ? Colors.yellowAccent[100]
                              : Colors.blue[300],
                        ),
                        onTap: (url) async {
                          if (await canLaunch(url)) {
                            launch("mailto:" + url);
                          }
                        }),
                    MatchText(
                        type: ParsedType.PHONE,
                        style: TextStyle(
                          color: _isOwnMessage
                              ? Colors.yellowAccent[100]
                              : Colors.blue[300],
                        ),
                        onTap: (url) async {
                          if (await canLaunch(url)) {
                            launch("tel:" + url);
                          }
                        }),
                  ]),
              SizedBox(height: 10),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  timeago.format(_timestamp.toDate()),
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imageMessageBubble(bool _isOwnMessage, String _imageURL,
      Timestamp _timestamp, BuildContext _ctx) {
    List<Color> _colorScheme = _isOwnMessage
        ? [Colors.blue, Color.fromRGBO(42, 117, 188, 1)]
        : [Color.fromRGBO(69, 69, 69, 1), Color.fromRGBO(43, 43, 43, 1)];
    return InkWell(
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => ShowImage(_imageURL))),
        onLongPress: () => showDialog(
            context: _ctx,
            child: SimpleDialog(
              children: <Widget>[
                SimpleDialogOption(
                  child: const Text("Save"),
                  onPressed: () {},
                )
              ],
            )),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(15.0),
              topLeft: Radius.circular(15.0),
              bottomLeft:
                  _isOwnMessage ? Radius.circular(15.0) : Radius.circular(0.0),
              bottomRight:
                  _isOwnMessage ? Radius.circular(0.0) : Radius.circular(15.0),
            ),
            gradient: LinearGradient(
              colors: _colorScheme,
              stops: [0.30, 0.70],
              begin: Alignment.bottomLeft,
              end: Alignment.topRight,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Container(
                height: _deviceHeight * 0.30,
                width: _deviceWidth * 0.40,
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(15.0),
                    topLeft: Radius.circular(15.0),
                  ),
                  child: Image.network(
                    _imageURL,
                    fit: BoxFit.cover,
                    loadingBuilder: (BuildContext context, Widget child,
                        ImageChunkEvent loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          backgroundColor: Theme.of(context).primaryColor,
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes
                              : null,
                        ),
                      );
                    },
                  ),
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              SizedBox(height: 10),
              Container(
                width: _deviceWidth * 0.40,
                child: Text(
                  timeago.format(_timestamp.toDate()),
                  textAlign: TextAlign.end,
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ),
            ],
          ),
        ));
  }

  Widget _messageField(BuildContext _context) {
    return Container(
      height: _deviceHeight * 0.08,
      decoration: BoxDecoration(
        color: Color.fromRGBO(43, 43, 43, 1),
        borderRadius: BorderRadius.circular(100),
      ),
      margin: EdgeInsets.symmetric(
          horizontal: _deviceWidth * 0.04, vertical: _deviceHeight * 0.03),
      child: Form(
        key: _formKey,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            _messageTextField(),
            _sendMessageButton(_context),
            _imageMessageButton(),
          ],
        ),
      ),
    );
  }

  Widget _messageTextField() {
    return SizedBox(
      width: _deviceWidth * 0.55,
      child: TextFormField(
        keyboardType: TextInputType.multiline,
        controller: _messageText,
        style: TextStyle(color: Colors.white),
        cursorColor: Colors.white,
        decoration: InputDecoration(
            border: InputBorder.none,
            hintText: "Type a message",
            hintStyle: TextStyle(color: Colors.white)),
        autocorrect: false,
      ),
    );
  }

  Widget _sendMessageButton(BuildContext _context) {
    return Container(
      height: _deviceHeight * 0.05,
      width: _deviceHeight * 0.05,
      child: IconButton(
          icon: Icon(
            Icons.send,
            color: Colors.white,
          ),
          onPressed: () {
            _isRefreshed = false;
            if (_messageText.text.length != 0) {
              print(_messageText.text);
              DBService.instance.sendMessage(
                this.widget._conversationID,
                Message(
                    content: _messageText.text,
                    timestamp: Timestamp.now(),
                    senderID: _auth.user.uid,
                    type: MessageType.Text),
              );
              _formKey.currentState.reset();
              FocusScope.of(_context).unfocus();
            }
          }),
    );
  }

  Widget _imageMessageButton() {
    return Container(
      height: _deviceHeight * 0.05,
      width: _deviceHeight * 0.05,
      child: FloatingActionButton(
        onPressed: () async {
          var _image = await MediaService.instance.getImageMessageFromLibrary();
          if (_image != null) {
            SnackBarService.instance.showSnackBar("Sending Image");
            var _result = await CloudStorageService.instance
                .uploadMediaMessage(_auth.user.uid, _image);
            var _imageURL = await _result.ref.getDownloadURL();
            await DBService.instance.sendMessage(
              this.widget._conversationID,
              Message(
                  content: _imageURL,
                  senderID: _auth.user.uid,
                  timestamp: Timestamp.now(),
                  type: MessageType.Image),
            );
            SnackBarService.instance.showSnackBarSuccess("Image Sent");
          }
        },
        child: Icon(Icons.camera_enhance),
      ),
    );
  }
}
