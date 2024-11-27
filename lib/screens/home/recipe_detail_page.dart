import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_proyek_kel02/size_config.dart';

class RecipeDetailPage extends StatelessWidget {
  final Map<String, dynamic> recipe;

  const RecipeDetailPage({required this.recipe, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Pastikan data memiliki nilai default jika tidak valid
    final recipeName = recipe['name'] ?? 'No Name';
    final recipeDescription = recipe['description'] ?? 'No Description';
    final recipeCategory = recipe['category'] ?? 'Uncategorized';
    final recipeInstructions =
        recipe['instructions'] ?? 'No Instructions Available';
    final recipeIngredients = recipe['ingredients'] ?? [];
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
      appBar: AppBar(title: Text(recipeName)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tampilkan gambar jika valid
              if (imageBytes != null)
                Image.memory(
                  imageBytes,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 200,
                )
              else
                Container(
                  width: double.infinity,
                  height: 200,
                  color: Colors.grey[300],
                  child: Icon(Icons.image, size: 100, color: Colors.grey[600]),
                ),
              SizedBox(height: 16),
              // Nama resep
              Text(
                recipeName,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              // Deskripsi resep
              Text(
                recipeDescription,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 8),
              // Kategori
              Text(
                "Category: $recipeCategory",
                style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
              ),
              SizedBox(height: 16),
              // Bahan-bahan
              Text(
                "Ingredients:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              if (recipeIngredients.isNotEmpty)
                ...recipeIngredients
                    .map((ingredient) => Text("• $recipeIngredients"))
              else
                Text("No ingredients available."),
              SizedBox(height: 16),
              // Instruksi
              Text(
                "Instructions:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(recipeInstructions),
            ],
          ),
        ),
      ),
    );
  }
}
