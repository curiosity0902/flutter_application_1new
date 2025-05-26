import 'package:flutter/material.dart';

class Room {
  final String category;
  final int cost;
  final String information;

  Room({
    required this.category,
    required this.cost,
    required this.information,
  });
}

class RecomendationPage extends StatefulWidget {
  const RecomendationPage({super.key});

  @override
  State<RecomendationPage> createState() => _RecomendationPageState();
}

class _RecomendationPageState extends State<RecomendationPage> {
  int numPeople = 2;
  String roomType = 'Эконом';
  int maxCost = 2000;

  List<Room> rooms = [
    Room(category: 'Эконом', cost: 1500, information: 'Уютный номер для двоих'),
    Room(
        category: 'Комфорт',
        cost: 3000,
        information: 'Комфортабельный номер для троих'),
    Room(
        category: 'Люкс',
        cost: 6000,
        information: 'Роскошный номер для четверых'),
    Room(
        category: 'Эконом',
        cost: 1700,
        information: 'Уютный номер для одного человека'),
    Room(
        category: 'Комфорт',
        cost: 4500,
        information: 'Комфортный номер для пятерых'),
    Room(category: 'Люкс', cost: 7000, information: 'Люкс для молодоженов'),
    Room(
        category: 'Стандартный',
        cost: 2500,
        information: 'Стандартный номер для двоих'),
    Room(
        category: 'Делюкс',
        cost: 8000,
        information: 'Роскошный номер для бизнесменов'),
  ];

  List<String> getRecommendedRooms() {
    List<String> recommendedRooms = [];

    if (roomType == 'Люкс') {
      if (maxCost == 6000 || maxCost == 7000) {
        if (numPeople == 2) {
          recommendedRooms.add('Люкс');
        } else if (numPeople == 3 || numPeople == 4) {
          recommendedRooms.add('Люкс');
        } else if (numPeople >= 5) {
          recommendedRooms.add('Люкс');
        }
      } else if (maxCost > 7000) {
        recommendedRooms.add('Люкс для молодоженов');
        recommendedRooms.add('Президентский люкс');
      }
    }

    if (roomType == 'Комфорт') {
      if (numPeople == 2) {
        recommendedRooms.add('Улучшенный номер');
      } else if (numPeople == 3 || numPeople == 4) {
        recommendedRooms.add('Комфорт');
      } else if (numPeople >= 5) {
        recommendedRooms.add('Комфорт для большой семьи');
      }
    }

    if (roomType == 'Эконом') {
      if (numPeople == 2) {
        recommendedRooms.add('Стандартный номер');
      } else if (numPeople == 3 || numPeople == 4) {
        recommendedRooms.add('Стандартный номер');
      } else if (numPeople >= 5) {
        recommendedRooms.add('Эконом для большой семьи');
      }
    }

    return recommendedRooms;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Рекомендации по номерам',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text('1. Сколько человек будет проживать?',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  DropdownButton<int>(
                    value: numPeople,
                    onChanged: (int? newValue) {
                      setState(() {
                        numPeople = newValue!;
                      });
                    },
                    isExpanded: true,
                    items: <int>[2, 3, 4, 5, 6]
                        .map<DropdownMenuItem<int>>((int value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text('$value человек'),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text('2. Какой тип номера вас интересует?',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  DropdownButton<String>(
                    value: roomType,
                    onChanged: (String? newValue) {
                      setState(() {
                        roomType = newValue!;
                      });
                    },
                    isExpanded: true,
                    items: <String>['Эконом', 'Комфорт', 'Люкс']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text('3. Какую стоимость номера рассматриваете?',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  DropdownButton<int>(
                    value: maxCost,
                    onChanged: (int? newValue) {
                      setState(() {
                        maxCost = newValue!;
                      });
                    },
                    isExpanded: true,
                    items: <int>[2000, 4000, 5000, 9000]
                        .map<DropdownMenuItem<int>>((int value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text('Менее $value'),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                List<String> recommendedRooms = getRecommendedRooms();
                showDialog(
                  context: context,
                  builder: (context) => Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.3,
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Рекомендуемые номера',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          SizedBox(height: 16),
                          recommendedRooms.isEmpty
                              ? Text('Нет подходящих номеров.',
                                  style: TextStyle(fontSize: 16))
                              : Expanded(
                                  child: ListView(
                                    children: recommendedRooms.map((room) {
                                      return ListTile(
                                        title: Text(room),
                                      );
                                    }).toList(),
                                  ),
                                ),
                          SizedBox(height: 16),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('Закрыть',
                                  style: TextStyle(fontSize: 16)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A6157),
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text(
                'Получить рекомендации',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
