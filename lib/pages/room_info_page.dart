import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/bottom_menu.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RoomInfoPage extends StatefulWidget {
  final dynamic room;

  RoomInfoPage({required this.room});

  @override
  _RoomInfoPageState createState() => _RoomInfoPageState();
}

class _RoomInfoPageState extends State<RoomInfoPage> {
  List<String> lines = [];
  int _currentIndex = 0;
  String selectedTab = 'description';
  List<dynamic> reviews = [];
  AudioPlayer _audioPlayer = AudioPlayer();

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  List<DateTime> _occupiedDates = [];

  @override
  void initState() {
    super.initState();
    getData();
    fetchReviews();
    fetchOccupiedDates(); 
  }

  void fetchOccupiedDates() async {
    var reservationsSnapshot = await FirebaseFirestore.instance
        .collection('reservations')
        .where('roomId', isEqualTo: widget.room['id'])
        .where('status', isEqualTo: 'confirmed')
        .get();

    List<DateTime> occupiedDates = [];
    for (var reservation in reservationsSnapshot.docs) {
      DateTime reservedStartDate =
          (reservation['startDate'] as Timestamp).toDate();
      DateTime reservedEndDate = (reservation['endDate'] as Timestamp).toDate();

      // Приводим все даты к безвременному формату
      DateTime startDateOnly = DateTime(reservedStartDate.year,
          reservedStartDate.month, reservedStartDate.day);
      DateTime endDateOnly = DateTime(
          reservedEndDate.year, reservedEndDate.month, reservedEndDate.day);

      // Добавляем все дни из периода бронирования в список занятых
      DateTime currentDate = startDateOnly;
      while (currentDate.isBefore(endDateOnly) ||
          currentDate.isAtSameMomentAs(endDateOnly)) {
        occupiedDates.add(currentDate);
        currentDate =
            currentDate.add(Duration(days: 1)); // Увеличиваем на один день
      }
    }

    setState(() {
      _occupiedDates = occupiedDates;
    });
  }

  void getData() {
    lines = widget.room['name'].replaceAll('.', '').split(', ');
    for (int x = 0; x < lines.length - 1; x++) {
      if (lines[x] != '') {
        lines.insert(x + 1, '');
      }
    }
  }

void fetchReviews() async {
  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection('rooms')
      .doc(widget.room['id'])
      .collection('reviews')
      .get();

  reviews = await Future.wait(snapshot.docs.map((doc) async {
    // Загружаем ответы для каждого отзыва
    var repliesSnapshot = await doc.reference.collection('replies').get();
    var replies = repliesSnapshot.docs.map((replyDoc) => replyDoc.data()).toList();
    
    return {
      ...doc.data() as Map<String, dynamic>,
      'docId': doc.id,
      'replies': replies,
    };
  }));

  setState(() {});
}

  void navigation(String name) async {
    DocumentSnapshot documentSnapshot =
        await FirebaseFirestore.instance.collection('rooms').doc(name).get();
    dynamic room = documentSnapshot.data();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RoomInfoPage(
          room: room,
        ),
      ),
    );
  }

  // Добавляем контроллер для сохранения бронирования
  void _showCalendar() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              children: [
                TableCalendar(
                  locale: 'ru_RU', 
                  focusedDay: _focusedDay,
                  firstDay: DateTime.now(),
                  lastDay: DateTime(2030),
                  selectedDayPredicate: (day) {
                    DateTime dayOnly = DateTime(day.year, day.month, day.day);
                    return

                        // ((_selectedStartDate != null &&
                        //             day.isAfter(_selectedStartDate!)) ||
                        //         (_selectedEndDate != null &&
                        //             day == _selectedStartDate)) &&
                        //     ((_selectedEndDate != null &&
                        //             dayOnly.isBefore(_selectedEndDate!)) ||
                        //         (_selectedStartDate != null &&
                        //             day == _selectedStartDate));

                        _selectedStartDate != null &&
                            (day == _selectedStartDate! ||
                                (day.isAfter(_selectedStartDate!) &&
                                    _selectedEndDate != null &&
                                    dayOnly.isBefore(_selectedEndDate!)));
                  },
                  calendarStyle: CalendarStyle(
                    // tablePadding: EdgeInsets.only(bottom: 10),
                    selectedDecoration: BoxDecoration(
                      color: Color.fromARGB(
                          255, 74, 97, 87), 
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: Colors.transparent, 
                      shape: BoxShape.circle,
                    ),
                  ),

                  headerStyle: HeaderStyle(
                    formatButtonVisible:
                        false, 
                    titleCentered: true, 
                  ),

                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, day, events) {
                      // Приводим день к безвременному формату и проверяем, есть ли он в списке занятых
                      DateTime dayOnly = DateTime(day.year, day.month, day.day);
                      bool isOccupied = _occupiedDates.contains(dayOnly);

                      return Container(
                        decoration: BoxDecoration(
                          color: isOccupied
                              ? Color.fromARGB(167, 74, 97, 87)
                              : Colors
                                  .transparent, 
                          shape: BoxShape.circle, 
                        ),
                        child: Center(
                          child: Text(
                            '${day.day}', 
                            style: TextStyle(
                              color: isOccupied
                                  ? Colors.white
                                  : Colors
                                      .black, 
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      if (_selectedStartDate == null ||
                          _selectedEndDate != null) {
                        _selectedStartDate = selectedDay;
                        _selectedEndDate = null; 
                      } else if (_selectedStartDate != null &&
                          _selectedEndDate == null) {
                        _selectedEndDate =
                            selectedDay.isAfter(_selectedStartDate!)
                                ? selectedDay
                                : _selectedStartDate;
                      }
                      _focusedDay = focusedDay;
                    });
                  },
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _selectedStartDate = null;
                          _selectedEndDate = null;
                        });
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF4A6157),
                      ),
                      child: Text(
                        'Отмена',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed:
                          _selectedStartDate != null ? _saveReservation : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF4A6157),
                      ),
                      child: Text(
                        'Сохранить',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _saveReservation() async {
    if (_selectedStartDate == null) {
      return;
    }

    if (_selectedEndDate == null) {
      _selectedEndDate = _selectedStartDate;
    }

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    // Проверка, заняты ли выбранные даты
    var reservationsSnapshot = await FirebaseFirestore.instance
        .collection('reservations')
        .where('roomId', isEqualTo: widget.room['id'])
        .where('status', isEqualTo: 'confirmed')
        .get();

    for (var reservation in reservationsSnapshot.docs) {
      DateTime reservedStartDate =
          (reservation['startDate'] as Timestamp).toDate();
      DateTime reservedEndDate = (reservation['endDate'] as Timestamp).toDate();

      // Проверка на пересечение дат
      if ((_selectedStartDate!.isBefore(reservedEndDate) &&
          _selectedEndDate!.isAfter(reservedStartDate))) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Ошибка"),
            content: Text("Выбранный период уже забронирован."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
              ),
            ],
          ),
        );
        return;
      }
    }

    await FirebaseFirestore.instance.collection('reservations').add({
      'uid': user.uid,
      'roomId': widget.room['id'],
      'startDate': _selectedStartDate,
      'endDate': _selectedEndDate,
      'status': 'confirmed',
    });

    _focusedDay = DateTime.now();
    _selectedStartDate = null;
    _selectedEndDate = null;
    fetchOccupiedDates();
    Navigator.of(context).pop();
  }

  void _playSound() async {
    await _audioPlayer.play(AssetSource('sound1.mp3'));
  }

  void _showAddReviewDialog() async {
    TextEditingController reviewController = TextEditingController();

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    Map<String, dynamic> userData = userSnapshot.data() as Map<String, dynamic>;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Добавить отзыв', style: TextStyle(
          color: const Color(0xFF4A6157),
          fontWeight: FontWeight.bold,
        ),),
        content: TextField(
          controller: reviewController,
          decoration: InputDecoration(hintText: 'Ваш отзыв'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Отмена'),
          ),
          TextButton(
            onPressed: () async {
              if (reviewController.text.isNotEmpty) {
                await FirebaseFirestore.instance
                    .collection('rooms')
                    .doc(widget.room['id'])
                    .collection('reviews')
                    .add({
                  'username': userData['fullname'],
                  'profileImage': userData['image'],
                  'review': reviewController.text,
                });
                fetchReviews();
                _playSound();
                Navigator.of(context).pop();
              }
            },
            child: Text('Добавить',
            style: TextStyle(
              color: Colors.black
            ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomPaint(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 25),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IconButton(
                          color: Colors.transparent,
                          icon:
                              const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            textAlign: TextAlign.center,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            widget.room['name'],
                            style: const TextStyle(
                              fontSize: 21,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          color: Colors.transparent,
                          icon: const Icon(Icons.home, color: Colors.white),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HomePage(getIndex: 1),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: CarouselSlider(
                            items: [
                              Image.network(
                                widget.room['image'],
                                fit: BoxFit.cover,
                                loadingBuilder: (BuildContext context,
                                    Widget child,
                                    ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) {
                                    return child;
                                  } else {
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                (loadingProgress
                                                        .expectedTotalBytes ??
                                                    1)
                                            : null,
                                        color: const Color(0xFF4A6157),
                                      ),
                                    );
                                  }
                                },
                              ),
                              Image.network(
                                widget.room['image1'],
                                fit: BoxFit.cover,
                                loadingBuilder: (BuildContext context,
                                    Widget child,
                                    ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) {
                                    return child;
                                  } else {
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                (loadingProgress
                                                        .expectedTotalBytes ??
                                                    1)
                                            : null,
                                        color: const Color(0xFF4A6157),
                                      ),
                                    );
                                  }
                                },
                              ),
                              Image.network(
                                widget.room['image2'],
                                fit: BoxFit.cover,
                                loadingBuilder: (BuildContext context,
                                    Widget child,
                                    ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) {
                                    return child;
                                  } else {
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress
                                                    .expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                (loadingProgress
                                                        .expectedTotalBytes ??
                                                    1)
                                            : null,
                                        color: const Color(0xFF4A6157),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
                            options: CarouselOptions(
                              height: 350,
                              viewportFraction: 1.0,
                              onPageChanged: (index, reason) {
                                setState(() {
                                  _currentIndex = index;
                                });
                              },
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 30,
                          left: 65,
                          width: MediaQuery.of(context).size.width * 0.59,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 33, vertical: 8),
                            child: Text(
                              textAlign: TextAlign.center,
                              widget.room['cost'] + ' рублей за ночь',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 10,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(3, (index) {
                              return Container(
                                width: 8,
                                height: 8,
                                margin: EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _currentIndex == index
                                      ? Colors.black
                                      : Colors.grey,
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildTabButton('description', 'Описание'),
                        _buildTabButton('information', 'Информация'),
                        _buildTabButton('reviews', 'Отзывы'),
                      ],
                    ),
                    const SizedBox(height: 25),
                    if (selectedTab == 'description')
                      Padding(
                        padding: const EdgeInsets.only(left: 14.0),
                        child: Text(
                          widget.room['description'] ?? '',
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                    if (selectedTab == 'information')
                      Padding(
                        padding: const EdgeInsets.only(left: 14.0),
                        child: Text(
                          widget.room['information'] ?? '',
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
  if (selectedTab == 'reviews')
  Column(
    children: [
      if (reviews.isEmpty)
        Center(
          child: Text('Пока нет отзывов'),
        )
      else
        Column(
          children: [
            for (var review in reviews)
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Основной отзыв
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.grey.shade200,
                          child: ClipOval(
                            child: review['profileImage'] != null &&
                                    review['profileImage'].isNotEmpty
                                ? FadeInImage.assetNetwork(
                                    placeholder: 'assets/icon_profile.png',
                                    image: review['profileImage'],
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                  )
                                : Image.asset(
                                    'assets/icon_profile.png',
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                review['username'] ?? 'Гость',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(review['review'] ?? ''),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Ответы на отзыв
                    if (review['replies'] != null && review['replies'].isNotEmpty)
                      Column(
                        children: [
                          const SizedBox(height: 12),
                          ...review['replies'].map<Widget>((reply) => Container(
                            margin: const EdgeInsets.only(top: 8.0),
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Colors.grey.shade200,
                                  child: ClipOval(
                                    child: reply['profileImage'] != null &&
                                            reply['profileImage'].isNotEmpty
                                        ? FadeInImage.assetNetwork(
                                            placeholder: 'assets/icon_profile.png',
                                            image: reply['profileImage'],
                                            width: 40,
                                            height: 40,
                                            fit: BoxFit.cover,
                                          )
                                        : Image.asset(
                                            'assets/icon_profile.png',
                                            width: 40,
                                            height: 40,
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        reply['username'] ?? 'Администратор',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        reply['reply'] ?? '',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )).toList(),
                        ],
                      ),
                  ],
                ),
              ),
            const SizedBox(height: 25),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A6157),
              ),
              onPressed: _showAddReviewDialog,
              child: const Text(
                'Добавить отзыв',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      const SizedBox(height: 25),
    ],
  ),
  
            Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(20),
              ),
              margin: EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12.0),
                      child: Text(
                        'Выбрать дату',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _showCalendar,
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.calendar_today,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
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

  Widget _buildTabButton(String tab, String title) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = tab;
        });
      },
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: selectedTab == tab ? Colors.black : Colors.grey,
            ),
          ),
          if (selectedTab == tab)
            Container(
              height: 2,
              width: 60,
              color: Colors.black,
            ),
        ],
      ),
    );
  }
}
