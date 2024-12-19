import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RecipeDetailPage extends StatefulWidget {
  final Map<String, dynamic> recipe;

  const RecipeDetailPage({required this.recipe, Key? key}) : super(key: key);

  @override
  _RecipeDetailPageState createState() => _RecipeDetailPageState();
}

class _RecipeDetailPageState extends State<RecipeDetailPage> {
  bool _isSaved = false;
  late final User _user;
  late final Stream<DocumentSnapshot> _savedStream;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser!;
    // Setup realtime listener untuk status saved
    _savedStream = FirebaseFirestore.instance
        .collection('users')
        .doc(_user.uid)
        .collection('saved_recipes')
        .doc(widget.recipe['id'])
        .snapshots();
  }

  Future<void> _toggleSaveRecipe(BuildContext context) async {
    try {
      final recipeRef = FirebaseFirestore.instance
          .collection('users')
          .doc(_user.uid)
          .collection('saved_recipes')
          .doc(widget.recipe['id']);

      if (_isSaved) {
        // Unsave recipe
        await recipeRef.delete();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Recipe removed from saved recipes"),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        // Save recipe
        await recipeRef.set({
          'name': widget.recipe['name'],
          'description': widget.recipe['description'],
          'category': widget.recipe['category'],
          'ingredients': widget.recipe['ingredients'],
          'instructions': widget.recipe['instructions'],
          'image_base64': widget.recipe['image_base64'],
          'saved_at': FieldValue.serverTimestamp(),
          'is_saved': true,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Recipe saved successfully!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print("Error saving/removing recipe: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to save/remove recipe"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final recipeName = widget.recipe['name'] ?? 'No Name';
    final recipeDescription = widget.recipe['description'] ?? 'No Description';
    final recipeCategory = widget.recipe['category'] ?? 'Uncategorized';
    final recipeInstructions = widget.recipe['instructions'] ?? 'No Instructions Available';

    var recipeIngredients = widget.recipe['ingredients'] ?? [];
    final recipeImageBase64 = widget.recipe['image_base64'];

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
        backgroundColor: Color(0xFF90AF17),
        actions: [
          StreamBuilder<DocumentSnapshot>(
            stream: _savedStream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                _isSaved = snapshot.data!.exists;
              }
              
              return IconButton(
                icon: SvgPicture.asset(
                  _isSaved
                      ? "assets/icons/bookmark_fill.svg"
                      : "assets/icons/bookmark.svg",
                  height: 24,
                  color: Colors.white,
                ),
                onPressed: () => _toggleSaveRecipe(context),
                tooltip: _isSaved ? "Remove from Saved" : "Save Recipe",
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              Text(
                recipeName,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8),
              Card(
                margin: EdgeInsets.symmetric(vertical: 10),
                elevation: 5,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
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
              Text(
                "Category: $recipeCategory",
                style: TextStyle(
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                  color: Colors.green[700],
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Ingredients:",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
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
                Text("No ingredients available.",
                    style: TextStyle(fontSize: 16, color: Colors.black54)),
              SizedBox(height: 20),
              Text(
                "Instructions:",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
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