import 'package:flutter/material.dart';
import 'package:flutter_proyek_kel02/models/RecipeBundel.dart';
import 'package:flutter_proyek_kel02/screens/auth/login_page.dart';
import 'package:flutter_proyek_kel02/screens/onboarding_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_proyek_kel02/constants.dart';
import 'package:flutter_proyek_kel02/models/NavItem.dart';
import 'package:flutter_proyek_kel02/screens/home/home_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => NavItems(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Recipe App',
        theme: ThemeData(
          // backgroundColor: Colors.white,
          scaffoldBackgroundColor: Colors.white,
          // We apply this to our appBarTheme because most of our appBar have this style
          appBarTheme: AppBarTheme(color: Colors.white, elevation: 0),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: '/onboarding',
        routes: {
          '/onboarding': (context) => OnboardingScreen(),
          '/login': (context) => LoginPage(),
          '/home': (context) => HomeScreen(),
        },
        home: OnboardingScreen(),
      ),
    );
  }
}
