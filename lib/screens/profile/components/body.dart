import 'package:flutter/material.dart';
import 'package:flutter_proyek_kel02/size_config.dart';
import 'package:flutter_proyek_kel02/database/user_db.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'info.dart';
import 'profile_menu_item.dart';

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  String username = "";
  String email = "";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final usernamePref = prefs.getString('username');

    if (usernamePref != null) {
      final user = await UserDB().getUserByUsername(usernamePref);
      if (user != null) {
        setState(() {
          username = user['username'];
          email = "${user['username']}@gmail.com";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Info(
            image: "assets/images/pic.jpg",
            name: username.isEmpty ? "Loading..." : username,
            email: email.isEmpty ? "Loading..." : email,
          ),
          SizedBox(height: SizeConfig.defaultSize * 2), //20
          ProfileMenuItem(
            iconSrc: "assets/icons/bookmark_fill.svg",
            title: "Saved Recipes",
            press: () {},
          ),
          ProfileMenuItem(
            iconSrc: "assets/icons/chef_color.svg",
            title: "Super Plan",
            press: () {},
          ),
          ProfileMenuItem(
            iconSrc: "assets/icons/language.svg",
            title: "Change Language",
            press: () {},
          ),
          ProfileMenuItem(
            iconSrc: "assets/icons/info.svg",
            title: "Help",
            press: () {},
          ),
        ],
      ),
    );
  }
}
