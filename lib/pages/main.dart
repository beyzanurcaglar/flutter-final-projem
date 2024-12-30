import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'homepage.dart';
import 'login.dart';

void main() async {
  await Hive.initFlutter(); // Hive veritabanını başlatıyoruz
  await Hive.openBox("information"); // Kişisel bilgilerin tutulacağı box
  await Hive.openBox("daily"); // Günlük verilerin tutulacağı box
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FitTrack',
      theme: ThemeData(primarySwatch: Colors.green),
      home: _checkInformation(context),
      // routes bölümüne login ve ana sayfa tanımlamayı unutmayın
      routes: {
        '/login': (context) => LoginPage(),
        '/main': (context) => MainTabView(),
      },
    );
  }

  Widget _checkInformation(BuildContext context) {
    var infoBox = Hive.box("information");
    if (infoBox.isNotEmpty) {
      return MainTabView();  // Ana sayfa yönlendirmesi
    } else {
      return LoginPage();  // Login sayfasına yönlendirme
    }
  }
}
