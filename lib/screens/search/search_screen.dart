import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_proyek_kel02/screens/home/recipe_detail_page.dart';
import 'package:flutter_proyek_kel02/screens/recipe/add_recipe_page.dart';
import 'package:flutter_proyek_kel02/size_config.dart';

import '../../components/my_bottom_nav_bar.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController searchController = TextEditingController();
  List<dynamic> recipes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRecipes();
  }

  Future<void> _fetchRecipes({String query = ""}) async {
    try {
      QuerySnapshot snapshot;
      if (query.isEmpty) {
        // Ambil hanya 5 resep jika tidak ada pencarian
        snapshot = await FirebaseFirestore.instance
            .collection('recipes')
            .limit(5)
            .get();
      } else {
        // Ambil semua resep yang cocok dengan pencarian
        snapshot = await FirebaseFirestore.instance
            .collection('recipes')
            .where('name', isGreaterThanOrEqualTo: query)
            .where('name', isLessThanOrEqualTo: query + '\uf8ff')
            .get();
      }

      setState(() {
        recipes = snapshot.docs.map((doc) {
          return {
            ...doc.data() as Map<String, dynamic>,
            'id': doc.id, // Tambahkan ID dokumen
          };
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching recipes: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  // Fungsi untuk menyaring resep berdasarkan kata kunci pencarian
  List<dynamic> getSearchedRecipes() {
    String searchQuery = searchController.text.toLowerCase();
    if (searchQuery.isEmpty) {
      return recipes; // Jika tidak ada pencarian, tampilkan semua resep
    }
    return recipes
        .where((recipe) =>
            recipe['name'].toLowerCase().contains(searchQuery) ||
            recipe['category']
                .toLowerCase()
                .contains(searchQuery)) // Mencocokkan nama atau kategori
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Search Recipes",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Color(0xFF90AF17),
        elevation: 5,
      ),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: SizeConfig.defaultSize * 2),
          child: Column(
            children: <Widget>[
              // Search bar with custom styling
              Padding(
                padding: EdgeInsets.only(top: SizeConfig.defaultSize * 2),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    labelText: 'Search by name or category',
                    labelStyle: TextStyle(color: Colors.black54),
                    prefixIcon: Icon(Icons.search, color: Color(0xFF90AF17)),
                    filled: true,
                    fillColor: Color(0xFFF4F7F6),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                  ),
                  onChanged: (value) {
                    setState(() {
                      isLoading = true;
                    });
                    _fetchRecipes(query: value);
                  },
                ),
              ),

              // Loading indicator or list view
              Expanded(
                child: isLoading
                    ? Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: getSearchedRecipes().length,
                        itemBuilder: (context, index) {
                          final recipe = getSearchedRecipes()[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      RecipeDetailPage(recipe: recipe),
                                ),
                              );
                            },
                            child: Card(
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              margin: EdgeInsets.symmetric(vertical: 10),
                              color: Colors.white,
                              child: Padding(
                                padding: EdgeInsets.all(
                                    SizeConfig.defaultSize * 1.5),
                                child: Row(
                                  children: <Widget>[
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Icon(
                                        Icons.food_bank,
                                        size: 40,
                                        color: Color(0xFF90AF17),
                                      ),
                                    ),
                                    SizedBox(width: SizeConfig.defaultSize * 2),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            recipe['name'],
                                            style: TextStyle(
                                              fontSize:
                                                  SizeConfig.defaultSize * 2.2,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(
                                              height:
                                                  SizeConfig.defaultSize * 0.5),
                                          Text(
                                            recipe['category'],
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize:
                                                  SizeConfig.defaultSize * 1.8,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
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
          _fetchRecipes();
        },
      ),
    );
  }
}
