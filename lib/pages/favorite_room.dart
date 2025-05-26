import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'room_info_page.dart'; // Убедитесь, что у вас есть этот импорт

class FavoriteRoomPage extends StatefulWidget {
  const FavoriteRoomPage({Key? key}) : super(key: key);

  @override
  _FavoriteRoomPageState createState() => _FavoriteRoomPageState();
}

class _FavoriteRoomPageState extends State<FavoriteRoomPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<String>> _getFavoriteRoomIds() async {
    final User? user = _auth.currentUser;
    if (user == null) return [];

    final QuerySnapshot snapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .get();

    return snapshot.docs.map((doc) => doc.id).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Padding(
            padding: const EdgeInsets.only(top: 13),
            child: Text(
              'Избранные номера',
              style: TextStyle(
                color: Colors.white,
                fontSize: 44,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          toolbarHeight: 150,
          leading: Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: IconButton(
              icon: Icon(
                Icons.favorite,
                color: Colors.white,
                size: 40,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          backgroundColor: Colors.black),
      body: FutureBuilder<List<String>>(
        future: _getFavoriteRoomIds(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(
              color: Color(0xFF4A6157),
            ));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Нет избранных комнат'));
          }

          List<String> favoriteRoomIds = snapshot.data!;

          return ListView.builder(
            itemCount: favoriteRoomIds.length,
            itemBuilder: (context, index) {
              String roomId = favoriteRoomIds[index];

              return FutureBuilder<DocumentSnapshot>(
                future: _firestore.collection('rooms').doc(roomId).get(),
                builder: (context, roomSnapshot) {
                  if (roomSnapshot.connectionState == ConnectionState.waiting) {
                    return ListTile(
                      title: Text('Загрузка...'),
                    );
                  }

                  if (!roomSnapshot.hasData || !roomSnapshot.data!.exists) {
                    return ListTile(
                      title: Text('Комната не найдена'),
                    );
                  }

                  DocumentSnapshot room = roomSnapshot.data!;
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RoomInfoPage(room: room),
                        ),
                      );
                    },
                    child: roomCard(room),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<void> toggleFavorite(String roomId) async {
    final User? user = _auth.currentUser;
    if (user == null) return;

    final userFavoritesRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(roomId);

    final DocumentSnapshot doc = await userFavoritesRef.get();
    if (doc.exists) {
      await userFavoritesRef.delete();
    } else {
      await userFavoritesRef.set({'roomId': roomId});
    }

    setState(() {});
  }

  Widget roomCard(DocumentSnapshot getRoom) {
    final room = getRoom;
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 110),
      child: Card(
        color: Colors.grey.shade200,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Image.network(
                  room['image'],
                  fit: BoxFit.cover,
                  height: 180,
                  width: double.infinity,
                  loadingBuilder: (BuildContext context, Widget child,
                      ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    } else {
                      return Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF4A6157),
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  (loadingProgress.expectedTotalBytes ?? 1)
                              : null,
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 5.0),
                    child: Text(
                      room['name'] ?? 'Unnamed',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(left: 5.0),
                    child: Text(
                      room['category'] ?? 'No category',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(left: 5.0),
                    child: Text(
                      room['description'] ?? 'No description',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black,
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              child: Padding(
                padding: const EdgeInsets.only(left: 6.0),
                child: Row(
                  children: [
                    Text(
                      '${room['cost']} рублей',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Spacer(),
                    IconButton(
                      icon: Icon(
                        Icons.favorite,
                        size: 15,
                        color: Colors.white,
                      ),
                      onPressed: () async {
                        await toggleFavorite(room.id);
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}