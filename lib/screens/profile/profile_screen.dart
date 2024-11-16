import 'package:flutter/material.dart';
import 'package:flutter_proyek_kel02/components/my_bottom_nav_bar.dart';
import 'package:flutter_proyek_kel02/constants.dart';
import 'package:flutter_proyek_kel02/screens/profile/components/body.dart';
import 'package:flutter_proyek_kel02/size_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/auth_preferences.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    await AuthPreferences.saveLoginStatus(false);
    Navigator.pushReplacementNamed(context, '/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: buildAppBar(context),
      body: Body(),
      bottomNavigationBar: MyBottomNavBar(),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: kPrimaryColor,
      leading: SizedBox(),
      // On Android it's false by default
      centerTitle: true,
      title: Text("Profile"),
      actions: <Widget>[
        TextButton(
          onPressed: () => _logout(context),
          child: Text(
            "Logout",
            style: TextStyle(
              color: Colors.white,
              fontSize: SizeConfig.defaultSize * 1.6, //16
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
