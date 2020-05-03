import 'package:cloud_firestore/cloud_firestore.dart';

class Contact {
  final String id;
  final String email;
  final String image;
  final String name;

  Contact({this.id, this.email, this.name, this.image});

  factory Contact.fromFirestore(DocumentSnapshot _snapshot) {
    var _data = _snapshot.data;
    return Contact(
      id: _snapshot.documentID,
      email: _data["email"],
      name: _data["name"],
      image: _data["image"],
    );
  }
}
