// lib/services/room_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/models/room.dart';

class RoomService {
  Future<List<Room>> getRooms() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('rooms').get();
      return querySnapshot.docs.map((doc) => Room.fromFirestore(doc)).toList();
    } catch (e) {
      print("Error getting rooms: $e");
      rethrow; // Пробросьте исключение, чтобы FutureBuilder мог обработать его
    }
  }
}
