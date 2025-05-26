import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HelpChatPage extends StatefulWidget {
  const HelpChatPage({super.key});

  @override
  _HelpChatPageState createState() => _HelpChatPageState();
}

class _HelpChatPageState extends State<HelpChatPage> {
  List<String> initialQuestions = [
    'Где находится отель?',
    'Когда я могу забронировать номер?',
    'Почему выбирают нас?'
  ];

  Map<String, List<String>> followUpQuestions = {
    'Где находится отель?': [
      'Есть ли еще такие отели в Казани?',
      'Есть ли вы в других городах?'
    ],
    'Когда я могу забронировать номер?': [
      'Как узнать, когда я могу забронировать?',
      'Как выбрать дату бронирования?'
    ],
    'Почему выбирают нас?': [
      'Какие у вас преимущества?',
      'Есть ли скидки для постоянных клиентов?'
    ],
  };

  Map<String, String> answers = {
    'Где находится отель?':
        'Мы находимся по адресу: \nг.Казань, ул.Бари Галеева д.3',
    'Когда я могу забронировать номер?': 'Вы можете сделать это в любое время',
    'Почему выбирают нас?':
        'Наш отель является ярким представителем успешно развивающейся компании на рынке с 2014 года',
    'Есть ли еще такие отели в Казани?':
        'Нет, к сожалению, у нас один филиал в Казани.',
    'Есть ли вы в других городах?':
        'Пока что нет, но скоро у нас откроется новый филиал в Москве.',
    'Как узнать, когда я могу забронировать?':
        'Для этого вам нужно найти интересующий вас номер и открыть календарь. Окрашенные даты заняты и недоступны к бронированию.',
    'Как выбрать дату бронирования?':
        'К сожалению, мы не несем за это ответственность. Внимательно просмотрите свободные даты и выберите удобные для вас.',
    'Какие у вас преимущества?':
        'Мы предлагаем лучшие условия по доступным ценам.',
    'Есть ли скидки для постоянных клиентов?':
        'Да, у нас есть программа лояльности.'
  };

  String currentQuestion = '';
  int currentFollowUpIndex = 0;
  String? currentFollowUpQuestion;
  TextEditingController _controller = TextEditingController();

  List<Map<String, dynamic>> messages = [];

  User? currentUser;
  String? userName;

  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      _loadUserData();
    }
  }

  Future<void> _loadUserData() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .get();

    if (userDoc.exists) {
      setState(() {
        userName = userDoc['fullname'];
      });
    }
  }

  List<String> getNextQuestions() {
    if (currentQuestion.isNotEmpty &&
        followUpQuestions.containsKey(currentQuestion)) {
      return followUpQuestions[currentQuestion]!;
    }
    return [];
  }

  void _handleFollowUpQuestion(String question) {
    setState(() {
      messages.add({'message': '$question', 'isFollowUp': true});
      messages.add({
        'message': 'Ответ: ${answers[question] ?? ''}',
        'isFollowUp': false
      });
      currentFollowUpQuestion = question;
      currentFollowUpIndex++;
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.only(left: 35.0),
          child: Text(
            'Чат поддержки',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: IconButton(
              icon: Icon(
                Icons.help_outline,
                color: Colors.white,
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('У вас вопросы?'),
                      content: Text('Задайте их в чате.'),
                      actions: <Widget>[
                        TextButton(
                          child: Text('Закрыть'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Container(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: initialQuestions.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        currentQuestion = initialQuestions[index];
                        currentFollowUpIndex = 0;
                        currentFollowUpQuestion = null;
                        messages.add({
                          'message': ' ${initialQuestions[index]}',
                          'isFollowUp': false
                        });
                        messages.add({
                          'message':
                              'Ответ: ${answers[initialQuestions[index]] ?? ''}',
                          'isFollowUp': false
                        });
                      });
                      _scrollToBottom();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: currentQuestion == initialQuestions[index]
                              ? Colors.black
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            initialQuestions[index],
                            style: TextStyle(
                              fontSize: 16,
                              color: currentQuestion == initialQuestions[index]
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  Map<String, dynamic> message = messages[index];
                  bool isUserMessage =
                      message['message'].startsWith('$userName: ');
                  bool isFollowUp = message['isFollowUp'] ?? false;
                  bool isQuestion = message['message'].startsWith(' ');

                  return ListTile(
                    title: Align(
                      alignment: isQuestion
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: isFollowUp
                              ? Colors.black
                              : (isUserMessage
                                  ? Colors.black
                                  : Colors.grey[300]),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          message['message'],
                          style: TextStyle(
                            fontSize: 16,
                            color: isFollowUp || isUserMessage
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Column(
                children: [
                  if (currentQuestion.isNotEmpty &&
                      currentFollowUpIndex < getNextQuestions().length)
                    GestureDetector(
                      onTap: () {
                        _handleFollowUpQuestion(
                            getNextQuestions()[currentFollowUpIndex]);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              getNextQuestions()[currentFollowUpIndex],
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            hintText: 'Введите сообщение...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(
                                color: Colors.black,
                                width: 1.5,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide(
                                color: Colors.black,
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide(
                                color: Colors.black,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.send,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          if (_controller.text.isNotEmpty) {
                            setState(() {
                              String userMessage = _controller.text;
                              messages.add({
                                'message': '$userName: $userMessage',
                                'isFollowUp': false
                              });
                              messages.add({
                                'message': 'Ответ: выберите корректный вопрос.',
                                'isFollowUp': false
                              });
                              _controller.clear();
                            });
                            _scrollToBottom();
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
