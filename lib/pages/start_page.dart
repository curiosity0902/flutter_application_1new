import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/maps_page.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application_1/pages/recomendation.dart';
import 'package:flutter_application_1/pages/rules_page.dart';
import 'help_chat_page.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  User? currentUser;
  List<Map<String, dynamic>> reservations = [];
  Map<String, Map<String, dynamic>> rooms =
      {}; // Словарь для хранения комнат по id
  bool _isDisposed = false; 

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      _loadRoomsAndBookings();
    }
  }

  @override
  void dispose() {
    _isDisposed = true; 
    super.dispose();
  }

  Future<void> _loadRoomsAndBookings() async {
    var roomSnapshot =
        await FirebaseFirestore.instance.collection('rooms').get();

    for (var doc in roomSnapshot.docs) {
      var roomData = doc.data() as Map<String, dynamic>;
      rooms[roomData['id']] = roomData;
    }

    var reservationSnapshot = await FirebaseFirestore.instance
        .collection('reservations')
        .where('uid', isEqualTo: currentUser?.uid)
        .get();

    List<Map<String, dynamic>> tempReservations = [];
    for (var doc in reservationSnapshot.docs) {
      var reservationData = doc.data() as Map<String, dynamic>;

      String roomId = reservationData['roomId'];

      if (rooms.containsKey(roomId)) {
        reservationData['roomName'] =
            rooms[roomId]?['name']; 
      }

      tempReservations.add(reservationData);
    }

    if (!_isDisposed) {
      setState(() {
        reservations = tempReservations;
      });
    }
  }

  void _showBookings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Мои бронирования'),
        content: reservations.isEmpty
            ? Text('У вас нет бронирований.')
            : Container(
                constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.6),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: reservations.map((reservation) {
                      Timestamp startDate = reservation['startDate'];
                      Timestamp endDate = reservation['endDate'];
                      String formattedStartDate =
                          DateFormat('dd.MM.yyyy').format(startDate.toDate());
                      String formattedEndDate =
                          DateFormat('dd.MM.yyyy').format(endDate.toDate());

                      return ListTile(
                        title: Text('Номер: ${reservation['roomName']}'),
                        subtitle: Text(
                            'Дата заезда: $formattedStartDate\nДата выезда: $formattedEndDate'),
                      );
                    }).toList(),
                  ),
                ),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 10, top: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 10, top: 20),
                child: Text(
                  'Главная страница',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 44,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.93,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Мои бронирования',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _showBookings,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Center(
                            child: Text(
                              'Просмотреть',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 15),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MapsPage()),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 4.0, left: 5),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.93,
                    height: MediaQuery.of(context).size.width * 0.24,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                      image: const DecorationImage(
                        image: AssetImage('assets/map_photo.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Основные правила отеля
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const RulesPage()),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.44,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Основные правила отеля',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const RulesPage()),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4A6157),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 5),
                                child: Center(
                                  child: Icon(
                                    Icons.rule,
                                    size: 30,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const RecomendationPage()),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 13.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.44,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Мои рекомендации',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const RecomendationPage()),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4A6157),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 5),
                                child: Center(
                                  child: Icon(
                                    Icons.recommend,
                                    size: 30,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const HelpChatPage()),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 13.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.94,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'У вас остались вопросы?',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const HelpChatPage()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 5),
                            child: Center(
                              child: Text(
                                'Связаться',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
