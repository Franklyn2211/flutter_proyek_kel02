import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_proyek_kel02/screens/recipe/add_recipe_page.dart';
import 'package:flutter_proyek_kel02/size_config.dart';
import 'package:flutter_proyek_kel02/components/my_bottom_nav_bar.dart';
import 'dart:convert';
import 'dart:typed_data';

import 'recipe_detail_page.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCategory = "All"; // Default category is "All"
  bool isLoading = true;
  List<dynamic> recipes = [];
  String userName = '';

  @override
  void initState() {
    super.initState();
    _fetchRecipes();
    _getUserName();
  }

  Future<void> _getUserName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userName = user.displayName ?? 'User';
      });
    }
  }

  // Fungsi untuk mengambil resep dari Firestore
  Future<void> _fetchRecipes() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('recipes').get();
      setState(() {
        recipes = snapshot.docs.map((doc) => doc.data()).toList();
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching recipes: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  List<dynamic> getFilteredRecipes() {
    if (selectedCategory == "All") {
      return recipes;
    }
    return recipes
        .where((recipe) => recipe['category'] == selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: buildAppBar(),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Categories(
              onCategorySelected: (category) {
                setState(() {
                  selectedCategory = category;
                  isLoading = true;
                });
                _fetchRecipes(); // Refresh data when category changes
              },
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.defaultSize * 2,
                ),
                child: isLoading
                    ? Center(child: CircularProgressIndicator())
                    : GridView.builder(
                        itemCount: getFilteredRecipes().length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount:
                              SizeConfig.orientation == Orientation.landscape
                                  ? 2
                                  : 1,
                          mainAxisSpacing: 20,
                          crossAxisSpacing:
                              SizeConfig.orientation == Orientation.landscape
                                  ? SizeConfig.defaultSize * 2
                                  : 0,
                          childAspectRatio: 1.65,
                        ),
                        itemBuilder: (context, index) => RecipeBundelCard(
                          recipeBundle: getFilteredRecipes()[index],
                          press: () {
                            final recipeBundle = getFilteredRecipes()[index];

                            // Validasi data sebelum diteruskan
                            final validatedRecipe = {
                              'name': recipeBundle['name'] is String
                                  ? recipeBundle['name']
                                  : 'No Name',
                              'description':
                                  recipeBundle['description'] is String
                                      ? recipeBundle['description']
                                      : 'No Description',
                              'image_base64':
                                  recipeBundle['image_base64'] is String
                                      ? recipeBundle['image_base64']
                                      : '',
                              'category': recipeBundle['category'] is String
                                  ? recipeBundle['category']
                                  : 'Uncategorized',
                              'instructions':
                                  recipeBundle['instructions'] is String
                                      ? recipeBundle['instructions']
                                      : 'No Instructions Available',
                              'ingredients':
                                  recipeBundle['ingredients'] is List<dynamic>
                                      ? List<String>.from(
                                          recipeBundle['ingredients'])
                                      : [],
                            };

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    RecipeDetailPage(recipe: validatedRecipe),
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: MyBottomNavBar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add, color: Colors.white),
        backgroundColor: Color(0xFF90AF17),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddRecipePage()),
          );
          _fetchRecipes(); // Refresh data after adding new recipe
        },
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      centerTitle:
          false, // Ubah centerTitle menjadi false agar judul tidak di tengah
      title: Row(
        children: [
          Image.asset(
            "assets/images/logo.png",
            width: 40, // Sesuaikan ukuran logo jika diperlukan
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Halo, $userName!", // Menampilkan nama pengguna
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Mau masak apa hari ini?",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[400], // Warna teks yang lebih lembut
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class Categories extends StatefulWidget {
  final Function(String) onCategorySelected;

  Categories({required this.onCategorySelected});

  @override
  _CategoriesState createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  List<String> categories = ["All", "Breakfast", "Lunch", "Dinner", "Quick"];
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: SizeConfig.defaultSize * 2),
      child: SizedBox(
        height: SizeConfig.defaultSize * 3.5,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: categories.length,
          itemBuilder: (context, index) => buildCategoryItem(index),
        ),
      ),
    );
  }

  Widget buildCategoryItem(int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
          widget.onCategorySelected(categories[index]);
        });
      },
      child: Container(
        alignment: Alignment.center,
        margin: EdgeInsets.only(left: SizeConfig.defaultSize * 2),
        padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.defaultSize * 2,
          vertical: SizeConfig.defaultSize * 0.5,
        ),
        decoration: BoxDecoration(
          color:
              selectedIndex == index ? Color(0xFFEFF3EE) : Colors.transparent,
          borderRadius: BorderRadius.circular(SizeConfig.defaultSize * 1.6),
        ),
        child: Text(
          categories[index],
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: selectedIndex == index ? Colors.black : Color(0xFFC2C2B5),
          ),
        ),
      ),
    );
  }
}

class RecipeBundelCard extends StatelessWidget {
  final dynamic recipeBundle;
  final VoidCallback press;

  const RecipeBundelCard({
    Key? key,
    required this.recipeBundle,
    required this.press,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double defaultSize = SizeConfig.defaultSize;

    Widget displayImage;
    if (recipeBundle['image_base64'] != null &&
        recipeBundle['image_base64'].isNotEmpty) {
      Uint8List imageBytes = base64Decode(recipeBundle['image_base64']);
      displayImage = Image.memory(
        imageBytes,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
      );
    } else {
      displayImage = Container(
        color: Colors.grey[300],
        child: Icon(
          Icons.image,
          size: defaultSize * 6,
          color: Colors.grey[500],
        ),
      );
    }

    return GestureDetector(
      onTap: press,
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFF90AF17),
          borderRadius: BorderRadius.circular(defaultSize * 1.8),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 3,
              child: Padding(
                padding: EdgeInsets.all(defaultSize * 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      recipeBundle['name'] ?? 'No Title',
                      style: TextStyle(
                        fontSize: defaultSize * 2.2,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: defaultSize * 0.5),
                    Text(
                      recipeBundle['description'] ?? 'No description available',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: defaultSize * 1.8,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Spacer(), // Menambahkan Spacer untuk mendorong teks ke bawah
                    Text(
                      'By ${recipeBundle['created_by']}',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: defaultSize * 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(defaultSize * 1.8),
                bottomRight: Radius.circular(defaultSize * 1.8),
              ),
              child: Container(
                width: defaultSize * 15,
                height: double.infinity,
                child: displayImage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
