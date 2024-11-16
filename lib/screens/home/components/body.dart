// lib/screens/home/components/body.dart
import 'package:flutter/material.dart';
import 'package:flutter_proyek_kel02/services/api_service.dart';
import 'package:flutter_proyek_kel02/size_config.dart';
import 'categories.dart';
import 'recipe_bundel_card.dart';

class Body extends StatefulWidget {
  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  String selectedCategory = "All";
  bool isLoading = true;
  List<dynamic> recipes = [];

  // Fungsi untuk mengambil data resep berdasarkan kategori
  void loadRecipes(String category) async {
    ApiService apiService = ApiService();
    try {
      var fetchedRecipes = await apiService.fetchRecipes(category);  // Ambil resep berdasarkan kategori
      setState(() {
        recipes = fetchedRecipes;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    loadRecipes(selectedCategory);  // Ambil resep saat halaman dimuat
  }

  List<dynamic> getFilteredRecipes() {
    // Fungsi ini tetap ada jika Anda ingin filter berdasarkan kategori yang lebih lanjut
    if (selectedCategory == "All") {
      return recipes;
    }
    return recipes
        .where((recipe) => recipe['category'] == selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: <Widget>[
          // Menggunakan kategori untuk memilih resep
          Categories(
            onCategorySelected: (category) {
              setState(() {
                selectedCategory = category;
                isLoading = true;
              });
              loadRecipes(category);  // Ambil resep berdasarkan kategori yang dipilih
            },
          ),
          Expanded(
            child: Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: SizeConfig.defaultSize * 2),
              child: isLoading
                  ? Center(child: CircularProgressIndicator())  // Menampilkan loading
                  : GridView.builder(
                      itemCount: getFilteredRecipes().length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount:
                            SizeConfig.orientation == Orientation.landscape ? 2 : 1,
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
                          // Aksi ketika card ditekan
                          print("Card ${getFilteredRecipes()[index]['title']} pressed");
                        },
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
