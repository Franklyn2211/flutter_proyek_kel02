import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Untuk ikon SVG

class RecipeDetailPage extends StatelessWidget {
  final Map<String, dynamic> recipe;

  const RecipeDetailPage({required this.recipe, Key? key}) : super(key: key);

  Future<void> saveRecipe(BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Simpan resep ke subkoleksi `saved_recipes` milik pengguna
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('saved_recipes')
            .doc(recipe['id']) // Gunakan ID resep sebagai dokumen
            .set({
          'name': recipe['name'],
          'description': recipe['description'],
          'category': recipe['category'],
          'ingredients': recipe['ingredients'],
          'instructions': recipe['instructions'],
          'image_base64': recipe['image_base64'],
          'saved_at': DateTime.now(), // Waktu penyimpanan
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Recipe saved successfully!")),
        );
      } else {
        // Jika pengguna belum login
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please log in to save recipes.")),
        );
      }
    } catch (e) {
      print("Error saving recipe: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to save recipe.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Pastikan data memiliki nilai default jika tidak valid
    final recipeName = recipe['name'] ?? 'No Name';
    final recipeDescription = recipe['description'] ?? 'No Description';
    final recipeCategory = recipe['category'] ?? 'Uncategorized';
    final recipeInstructions = recipe['instructions'] ?? 'No Instructions Available';

    // Mengambil ingredients dan memastikan bentuknya adalah List
    var recipeIngredients = recipe['ingredients'] ?? [];

    final recipeImageBase64 = recipe['image_base64'];

    Uint8List? imageBytes;
    if (recipeImageBase64 != null && recipeImageBase64.isNotEmpty) {
      try {
        imageBytes = base64Decode(recipeImageBase64);
      } catch (e) {
        print("Error decoding image: $e");
        imageBytes = null;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(recipeName),
        backgroundColor: Colors.green[700],
        actions: [
          // Tambahkan ikon "Saved Recipes"
          IconButton(
            icon: SvgPicture.asset(
              "assets/icons/bookmark_fill.svg", // Ikon bookmark
              height: 24,
              color: Colors.white,
            ),
            onPressed: () async {
              await saveRecipe(context);
            },
            tooltip: "Save Recipe",
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tampilkan gambar jika valid
              if (imageBytes != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.memory(
                    imageBytes,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 250,
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  height: 250,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(Icons.image, size: 100, color: Colors.grey[600]),
                ),
              SizedBox(height: 20),

              // Nama resep
              Text(
                recipeName,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8),

              // Deskripsi resep
              Card(
                margin: EdgeInsets.symmetric(vertical: 10),
                elevation: 5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    recipeDescription,
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                    textAlign: TextAlign.justify,
                  ),
                ),
              ),
              SizedBox(height: 10),

              // Kategori
              Text(
                "Category: $recipeCategory",
                style: TextStyle(
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                  color: Colors.green[700],
                ),
              ),
              SizedBox(height: 20),

              // Bahan-bahan
              Text(
                "Ingredients:",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              SizedBox(height: 10),
              if (recipeIngredients.isNotEmpty)
                ...recipeIngredients.map<Widget>((ingredient) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: Row(
                      children: [
                        Icon(Icons.check, color: Colors.green[700]),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            ingredient,
                            style: TextStyle(fontSize: 16, color: Colors.black54),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList()
              else
                Text("No ingredients available.", style: TextStyle(fontSize: 16, color: Colors.black54)),
              SizedBox(height: 20),

              // Instruksi
              Text(
                "Instructions:",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              SizedBox(height: 10),
              Text(
                recipeInstructions,
                style: TextStyle(fontSize: 16, color: Colors.black54),
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
