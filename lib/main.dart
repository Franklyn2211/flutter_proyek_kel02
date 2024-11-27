import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_proyek_kel02/screens/auth/login_page.dart';
import 'package:flutter_proyek_kel02/screens/onboarding_screen.dart';
import 'package:flutter_proyek_kel02/utils/auth_preferences.dart';
import 'package:provider/provider.dart';
import 'package:flutter_proyek_kel02/constants.dart';
import 'package:flutter_proyek_kel02/models/NavItem.dart';
import 'package:flutter_proyek_kel02/screens/home/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => NavItems(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Recipe App',
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: AppBarTheme(color: Colors.white, elevation: 0),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        routes: {
          '/onboarding': (context) => OnboardingScreen(),
          '/login': (context) => LoginPage(),
          '/home': (context) => HomeScreen(),
        },
        home: OnboardingScreen(), // Halaman awal adalah OnboardingScreen
      ),
    );
  }
}
