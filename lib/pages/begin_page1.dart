import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/auth.dart';
import 'package:flutter_application_1/pages/begin_page2.dart';

class BeginPage1 extends StatefulWidget {
  const BeginPage1({super.key});

  @override
  State<BeginPage1> createState() => _BeginPage1State();
}

class _BeginPage1State extends State<BeginPage1> {
  int currentPage = 1;

  void _nextPage() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => BeginPage2(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(65.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;

          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ),
    );
  }

  void _skip() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => AuthPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/hotel_inside2.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.white.withOpacity(0.75),
            ),
          ),
          Positioned(
            top: 70,
            right: 30,
            child: GestureDetector(
              onTap: _skip,
              child: Text(
                'Пропустить',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 160),
                // Logotip
                Image.asset(
                  'assets/hotel_logo_without_text.png',
                  width: 110,
                  height: 110,
                ),
                const Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center, 
                  crossAxisAlignment:
                      CrossAxisAlignment.center, 
                  children: [
                    Text(
                      'Мы рады новым гостям!',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18.0),
                      child: Text(
                        'В нашем приложении вы можете просматривать разные номера и бронировать их.',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 5),
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            currentPage == index ? Colors.black : Colors.grey,
                      ),
                    );
                  }),
                ),
                SizedBox(height: 40),
                // Next button
                ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    backgroundColor: Color(0xFF4A6157),
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 12),
                  ),
                  child: Text(
                    'Далее',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NextPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Далее'),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: BeginPage1(),
  ));
}
