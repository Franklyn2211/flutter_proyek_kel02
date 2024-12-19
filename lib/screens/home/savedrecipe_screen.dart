import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';

import '../../components/my_bottom_nav_bar.dart';
import '../recipe/add_recipe_page.dart';
import '../home/recipe_detail_page.dart';  // Import halaman detail resep

class SavedRecipesScreen extends StatefulWidget {
  @override
  _SavedRecipesScreenState createState() => _SavedRecipesScreenState();
}

class _SavedRecipesScreenState extends State<SavedRecipesScreen> {
  List<Map<String, dynamic>> savedRecipes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSavedRecipes();
  }

  Future<void> _fetchSavedRecipes() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Ambil data dari koleksi saved_recipes
        QuerySnapshot savedDocs = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('saved_recipes')
            .orderBy('saved_at', descending: true)  // Urutkan berdasarkan waktu penyimpanan
            .get();

        List<Map<String, dynamic>> recipes = [];
        for (var doc in savedDocs.docs) {
          // Tambahkan ID dokumen ke data resep
          Map<String, dynamic> recipeData = doc.data() as Map<String, dynamic>;
          recipeData['id'] = doc.id;  // Tambahkan ID untuk keperluan hapus/edit
          recipes.add(recipeData);
        }

        if (mounted) {
          setState(() {
            savedRecipes = recipes;
            isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print("Error fetching saved recipes: $e");
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal memuat resep tersimpan. Silakan coba lagi.")),
      );
    }
  }

  // Fungsi untuk menghapus resep dari daftar tersimpan
  Future<void> _removeRecipe(String recipeId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('saved_recipes')
            .doc(recipeId)
            .delete();

        // Refresh daftar setelah menghapus
        _fetchSavedRecipes();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Resep berhasil dihapus dari daftar tersimpan')),
        );
      }
    } catch (e) {
      print('Error removing recipe: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus resep')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Resep Tersimpan"),
        backgroundColor: Color(0xFF90AF17),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : savedRecipes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.bookmark_border, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        "Belum ada resep tersimpan",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: savedRecipes.length,
                  itemBuilder: (context, index) {
                    final recipe = savedRecipes[index];
                    return Card(
                      margin: EdgeInsets.only(bottom: 16),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RecipeDetailPage(recipe: recipe),
                            ),
                          ).then((_) => _fetchSavedRecipes()); // Refresh setelah kembali
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (recipe['image_base64'] != null)
                              ClipRRect(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(12),
                                ),
                                child: Image.memory(
                                  base64Decode(recipe['image_base64']),
                                  width: double.infinity,
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          recipe['name'] ?? 'Resep Tanpa Nama',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete_outline),
                                        onPressed: () => _removeRecipe(recipe['id']),
                                        color: Colors.red,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    recipe['description'] ?? 'Tidak ada deskripsi',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Color(0xFF90AF17).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      recipe['category'] ?? 'Tidak Berkategori',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF90AF17),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      bottomNavigationBar: MyBottomNavBar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add, color: Colors.white),
        backgroundColor: const Color(0xFF90AF17),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddRecipePage()),
          ).then((_) => _fetchSavedRecipes()); // Refresh setelah menambah resep baru
        },
      ),
    );
  }
}