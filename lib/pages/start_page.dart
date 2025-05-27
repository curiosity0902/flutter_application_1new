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
  Map<String, Map<String, dynamic>> rooms = {};
  bool _isDisposed = false;
  int _bookingCount = 0;
  double _discount = 0.0;

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
  try {
    final user = currentUser;
    if (user == null) return;

    // 1. Делаем два параллельных запроса
    final QuerySnapshot uidBookings = await FirebaseFirestore.instance
        .collection('reservations')
        .where('uid', isEqualTo: user.uid)
        .get();

    final QuerySnapshot userIdBookings = await FirebaseFirestore.instance
        .collection('reservations')
        .where('userId', isEqualTo: user.uid)
        .get();

    // 2. Объединяем и убираем дубликаты
    final Map<String, QueryDocumentSnapshot> uniqueBookings = {};
    
    for (final doc in uidBookings.docs) {
      uniqueBookings[doc.id] = doc;
    }
    
    for (final doc in userIdBookings.docs) {
      uniqueBookings[doc.id] = doc;
    }

    // 3. Фильтруем активные бронирования
    final now = DateTime.now();
    final List<Map<String, dynamic>> activeReservations = [];
    
    for (final doc in uniqueBookings.values) {
      final data = doc.data() as Map<String, dynamic>;
      final endDate = (data['endDate'] as Timestamp).toDate();
      
      if (endDate.isAfter(now) && data['status'] == 'confirmed') {
        activeReservations.add({
          ...data,
          'id': doc.id,
          'roomName': rooms[data['roomId']]?['name'] ?? 'Неизвестный номер',
        });
      }
    }

    // 4. Подсчет всех бронирований для скидки
    final int totalBookingsCount = uniqueBookings.length;

    // 5. Обновляем состояние
    if (!_isDisposed) {
      setState(() {
        reservations = activeReservations;
        _bookingCount = totalBookingsCount;
        _calculateDiscount(_bookingCount);
      });
    }

  } catch (e) {
    print("Ошибка загрузки бронирований: $e");
    if (!_isDisposed) {
      setState(() {
        reservations = [];
        _bookingCount = 0;
        _discount = 0.0;
      });
    }
  }
}
  void _calculateDiscount(int bookingCount) {
    setState(() {
      if (bookingCount >= 15) {
        _discount = 7.0;
      } else if (bookingCount >= 10) {
        _discount = 6.0;
      } else if (bookingCount >= 5) {
        _discount = 5.0;
      } else {
        _discount = 0.0;
      }
    });
  }

  void _showBookings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Мои бронирования'),
        content: reservations.isEmpty
            ? const Text('У вас нет активных бронирований.')
            : Container(
                constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.6),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: reservations.length,
                  itemBuilder: (context, index) {
                    var reservation = reservations[index];
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
                  },
                ),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscountCard() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HelpChatPage()),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 13.0),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.94,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.grey[100]!,
                Colors.grey[200]!,
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ваша скидка',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 15),
              Stack(
                children: [
                  Container(
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      double progress = _discount / 7;
                      return AnimatedContainer(
                        duration: Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                        height: 20,
                        width: constraints.maxWidth * progress,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF4A6157),
                              Color(0xFF6D8B74),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF4A6157).withOpacity(0.3),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Бронирований: $_bookingCount',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return ScaleTransition(
                        scale: animation,
                        child: child,
                      );
                    },
                    child: Text(
                      '${_discount.toStringAsFixed(1)}%',
                      key: ValueKey<double>(_discount),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A6157),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildMilestone(5, '5%'),
                  _buildMilestone(10, '6%'),
                  _buildMilestone(15, '7%'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMilestone(int count, String percent) {
    bool reached = _bookingCount >= count;
    return Column(
      children: [
        Text(
          '$count+',
          style: TextStyle(
            fontSize: 12,
            color: reached ? Color(0xFF4A6157) : Colors.grey,
            fontWeight: reached ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        const SizedBox(height: 2),
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: reached ? Color(0xFF4A6157) : Colors.grey[400],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          percent,
          style: TextStyle(
            fontSize: 12,
            color: reached ? Color(0xFF4A6157) : Colors.grey,
            fontWeight: reached ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 10, top: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Заголовок
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
                  
                  // Блок бронирований
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: constraints.maxWidth * 0.93,
                      maxWidth: constraints.maxWidth * 0.93,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: Container(
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
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _showBookings,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  child: Text(
                                    'Просмотреть',
                                    style: TextStyle(color: Colors.white, fontSize: 16),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  
                  // Карта
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: constraints.maxWidth * 0.93,
                      maxWidth: constraints.maxWidth * 0.93,
                      minHeight: constraints.maxWidth * 0.24,
                      maxHeight: constraints.maxWidth * 0.24,
                    ),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const MapsPage()),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 4.0, left: 5),
                          child: Container(
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
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Два блока в ряд
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: constraints.maxWidth * 0.93,
                      maxWidth: constraints.maxWidth * 0.93,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Блок правил
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: constraints.maxWidth * 0.44,
                            maxWidth: constraints.maxWidth * 0.44,
                          ),
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const RulesPage()),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(left: 4.0),
                                child: Container(
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
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
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
                                          child: const Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 15, horizontal: 5),
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
                          ),
                        ),
                        
                        // Блок рекомендаций
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: constraints.maxWidth * 0.44,
                            maxWidth: constraints.maxWidth * 0.44,
                          ),
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
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
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton(
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
                                          child: const Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 15, horizontal: 5),
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
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Блок скидки
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: constraints.maxWidth * 0.94,
                      maxWidth: constraints.maxWidth * 0.94,
                    ),
                    child: _buildDiscountCard(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}
}