import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';

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
        // Ambil subkoleksi saved_recipes
        QuerySnapshot savedDocs = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('saved_recipes')
            .get();

        List<String> recipeIds = savedDocs.docs.map((doc) => doc.id).toList();

        // Ambil detail resep dari koleksi recipes
        List<Map<String, dynamic>> fetchedRecipes = [];
        for (String id in recipeIds) {
          DocumentSnapshot recipeDoc = await FirebaseFirestore.instance
              .collection('recipes')
              .doc(id)
              .get();

          if (recipeDoc.exists) {
            fetchedRecipes.add(recipeDoc.data() as Map<String, dynamic>);
          }
        }
        if (mounted) {
          setState(() {
            savedRecipes = fetchedRecipes;
            isLoading = false;
          });
        }
      } else {
        // If no user is logged in
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Saved Recipes"),
        backgroundColor: Color(0xFF90AF17),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : savedRecipes.isEmpty
              ? Center(child: Text("No saved recipes"))
              : ListView.builder(
                  itemCount: savedRecipes.length,
                  itemBuilder: (context, index) {
                    final recipe = savedRecipes[index];
                    return ListTile(
                      leading: recipe['image_base64'] != null
                          ? Image.memory(
                              base64Decode(recipe['image_base64']),
                              fit: BoxFit.cover,
                              width: 50,
                              height: 50,
                            )
                          : Icon(Icons.image),
                      title: Text(recipe['name']),
                      subtitle: Text(recipe['description']),
                      onTap: () {
                        // Navigasi ke detail resep
                      },
                    );
                  },
                ),
    );
  }
}