import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:practice/user_type.dart';

import '../models/contact.dart';
import '../models/conversation.dart';
import '../models/message.dart';

class DBService {
  static DBService instance = DBService();

  Firestore _db;

  DBService() {
    _db = Firestore.instance;
  }

  String _userCollection = "Users";
  String _conversationsCollection = "Conversations";

  Future<Map<String, dynamic>> checkUserData(String _uid) async {
    var docSnapshot = await _db.collection(_userCollection).document(_uid).get();
    return docSnapshot.data;
  }

  Future<void> createUserInDB(String _uid, String _name, String _email,
      String _imageURL, int _mobileNumber) async {
    try {
      await _db.collection(_userCollection).document(_uid).setData({
        "name": _name,
        "email": _email,
        "image": _imageURL,
        "type": "Mentee",
        "paid":"no",
        "mobileNumber": _mobileNumber,
        // "lastSeen": DateTime.now().toUtc(),
      });

      return await _db.collection("Mentee").document(_uid).setData({
        "name": _name,
        "email": _email,
        "image": _imageURL,
        "type":"Mentee",
        "paid": "no",
        "mobileNumber": _mobileNumber,

      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> sendMessage(String _conversationID, Message _message) {
    var _ref =
        _db.collection(_conversationsCollection).document(_conversationID);
    var _messageType = "";
    switch (_message.type) {
      case MessageType.Text:
        _messageType = "text";
        break;
      case MessageType.Image:
        _messageType = "image";
        break;
      default:
    }
    return _ref.updateData({
      "messages": FieldValue.arrayUnion(
        [
          {
            "message": _message.content,
            "senderID": _message.senderID,
            "timestamp": _message.timestamp,
            "type": _messageType,
          },
        ],
      ),
    });
  }
  Future<void> createOrGetFirstConversation(String _currentID, String _recepientID,Future<void> _onSuccess(String _conversationID) )async{
     var _ref = _db.collection(_conversationsCollection);
    var _userConversationRef = _db
        .collection(_userCollection)
        .document(_currentID)
        .collection(_conversationsCollection);
         try {
      var conversation =
          await _userConversationRef.document(_recepientID).get();
      if (conversation.data != null) {
        return _onSuccess(conversation.data["conversationID"]);
      } else {
        var _conversationRef = _ref.document();
        await _conversationRef.setData(
          {
            "members": [_currentID, _recepientID],
            "ownerID": _currentID,
            'messages': [],
          },
        );
        return _onSuccess(_conversationRef.documentID);
      }
    } catch (e) {
      print(e);
    }
       

  }


  Future<void> createOrGetConversartion(String _currentID, String _recepientID,
      Future<void> _onSuccess(String _conversationID)) async {
    var _ref = _db.collection(_conversationsCollection);
    var _userConversationRef = _db
        .collection(_userCollection)
        .document(_currentID)
        .collection(_conversationsCollection);
    try {
      var conversation =
          await _userConversationRef.document(_recepientID).get();
      if (conversation.data != null) {
        return _onSuccess(conversation.data["conversationID"]);
      } else {
        var _conversationRef = _ref.document();
        await _conversationRef.setData(
          {
            "members": [_currentID, _recepientID],
            "ownerID": _currentID,
            'messages': [],
          },
        );
        return _onSuccess(_conversationRef.documentID);
      }
    } catch (e) {
      print(e);
    }
  }

  Stream<Contact> getUserData(String _userID) {
    var _ref = _db.collection(_userCollection).document(_userID);
    return _ref.get().asStream().map((_snapshot) {
      return Contact.fromFirestore(_snapshot);
    });
  }

  Stream<List<ConversationSnippet>> getUserConversations(String _userID) {
    var _ref = _db
        .collection(_userCollection)
        .document(_userID)
        .collection(_conversationsCollection)
        .orderBy("timestamp", descending: true);
    return _ref.snapshots().map((_snapshot) {
      return _snapshot.documents.map((_doc) {
        return ConversationSnippet.fromFirestore(_doc);
      }).toList();
    });
  }

  Stream<List<Contact>> getUsersInDB(String userType, String _uid) {
    String otherUserType =
        (userType == "Mentee") ? "Mentors" : "Mentees";
    var _ref = _db
        .collection(userType)
        .document(_uid)
        .collection(otherUserType);

    return _ref.getDocuments().asStream().map((_snapshot) {
      return _snapshot.documents.map((_doc) {
        return Contact.fromFirestore(_doc);
      }).toList();
    });
  }

  Stream<Conversation> getConversation(String _conversationID) {
    var _ref =
        _db.collection(_conversationsCollection).document(_conversationID);
    return _ref.snapshots().map(
      (_doc) {
        return Conversation.fromFirestore(_doc);
      },
    );
  }
  Future<void> updateUserPaidStatus(String _uid)async{
     await _db.collection(_userCollection).document(_uid).updateData({"paid":"yes"});
     await _db.collection("Mentee").document(_uid).updateData({"paid":"yes"});
  }
  
}
