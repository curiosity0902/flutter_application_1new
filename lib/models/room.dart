import 'package:cloud_firestore/cloud_firestore.dart';

class Room {
  final String name;
  final String description;
  final String image;
  final double cost;

  Room(
      {required this.name,
      required this.description,
      required this.image,
      required this.cost});

  factory Room.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Room(
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      image: data['image'] ?? '',
      cost: data['cost']?.toDouble() ?? 0.0,
    );
  }
}
