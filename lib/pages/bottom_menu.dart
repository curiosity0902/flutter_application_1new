import 'package:flutter/material.dart';
import 'package:flutter_application_1/database/users_service/service.dart';
import 'package:flutter_application_1/pages/all_rooms_page.dart';
import 'package:flutter_application_1/pages/favorite_room.dart';
import 'package:flutter_application_1/pages/start_page.dart';
import 'package:flutter_application_1/profile_pages/profile.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class HomePage extends StatefulWidget {
  int getIndex;
  HomePage({super.key, this.getIndex = 1});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  AuthService authService = AuthService();
  String title = "";
  int index = 2;
  final pages = [
    const AllRoomsPage(),
    const StartPage(),
    FavoriteRoomPage(),
    const Profile(key: PageStorageKey('ProfilePage')),
  ];

  void onTabTapped(int value) {
    setState(() {
      index = value;
    });
  }

  @override
  void initState() {
    index = widget.getIndex;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[index],
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(
            bottom: 20.0, left: 10, right: 10), 
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: Container(
            color: const Color(0xFF4A6157),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              child: GNav(
                color: Colors.white,
                activeColor: Colors.white,
                haptic: true,
                gap: 5,
                tabBorderRadius: 25,
                tabBackgroundColor: Color.fromARGB(255, 32, 42, 38),
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                selectedIndex: index,
                tabs: [
                  GButton(
                    icon: Icons.holiday_village_rounded,
                    text: 'Номера',
                    iconSize: 26,
                    onPressed: () {
                      setState(() => {index = 0});
                    },
                  ),
                  GButton(
                    icon: Icons.home,
                    text: '',
                    iconSize: 26,
                    onPressed: () {
                      setState(() => {index = 1});
                    },
                  ),
                  GButton(
                    icon: Icons.favorite_border,
                    text: 'Избранное',
                    iconSize: 26,
                    onPressed: () {
                      setState(() => {index = 2});
                    },
                  ),
                  GButton(
                    icon: Icons.person_outline,
                    text: 'Профиль',
                    iconSize: 26,
                    onPressed: () {
                      setState(() => {index = 3});
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
