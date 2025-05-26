import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_application_1/routes/routes.dart';
import 'package:flutter_application_1/themes/dark.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
WidgetsFlutterBinding.ensureInitialized();

  try {
    // Инициализация Firebase
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyDRMNHWhfP5DnxQAU0TIZGmlB56Xy3i7Ck',
        appId: '1:951967661425:android:1f814fb42a31cd57130ad0', 
        messagingSenderId: '951967661425', 
        projectId: 'flutterfilms320',
        storageBucket: 'flutterfilms320.appspot.com',
        authDomain: 'flutterfilms320.firebaseapp.com', 
      ),
    );
    
    // Проверка подключения к Firebase
    try {
      await FirebaseAuth.instance.signInAnonymously();
      print("Firebase connection successful");
    } catch (e) {
      print("Firebase auth error: $e");
    }
    
    runApp(const MyApp());
  } catch (e) {
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Firebase init error: $e'),
          ),
        ),
      ),
    );
  }
}

class ErrorApp extends StatelessWidget {
  const ErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Произошла ошибка при инициализации Firebase'),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
   return MultiProvider(
      providers: [
        StreamProvider<User?>.value(
          value: FirebaseAuth.instance.authStateChanges(),
          initialData: null,
          catchError: (_, __) => null,
        ),
      ],
      child:MaterialApp(
  title: 'Hotel App',
  debugShowCheckedModeBanner: false,
  theme: themeData,
  initialRoute: '/begin',
  routes: routes,
  locale: const Locale('ru', 'RU'), // <-- Установить русский язык по умолчанию
  supportedLocales: const [
    Locale('ru', 'RU'),
    Locale('en', 'US'),
  ],
  localizationsDelegates: const [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  builder: (context, child) {
    return Overlay(
      initialEntries: [
        OverlayEntry(
          builder: (context) => child ?? const SizedBox(),
        ),
      ],
    );
  },
),

    );
  }
}