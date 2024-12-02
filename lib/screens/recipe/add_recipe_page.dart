import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image/image.dart' as img;
import 'package:firebase_auth/firebase_auth.dart';

class AddRecipePage extends StatefulWidget {
  final VoidCallback? onSave;

  const AddRecipePage({this.onSave});

  @override
  _AddRecipePageState createState() => _AddRecipePageState();
}

class _AddRecipePageState extends State<AddRecipePage> {
  final _formKey = GlobalKey<FormState>();
  late String name;
  late String description;
  late List<String> ingredients;
  late String instructions;
  late String category;
  String? imageBase64; // Simpan gambar dalam format Base64
  File? _imageFile;

  final List<String> categories = [
    'Breakfast',
    'Lunch',
    'Dinner',
    'Quick',
  ];

  @override
  void initState() {
    super.initState();
    name = '';
    description = '';
    ingredients = [];
    instructions = '';
    category = ''; // Default kategori
    imageBase64 = null;
    _imageFile = null;
  }

  Future<void> _convertImageToBase64(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    setState(() {
      imageBase64 = base64Encode(bytes);
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      setState(() {
        _imageFile = imageFile;
      });
      await _convertImageToBase64(imageFile);
    } else {
      print("No image selected.");
    }
  }

  String getCurrentUserId() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.uid;
    }
    return '';
  }

  String getCurrentUserName() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.displayName != null) {
      return user.displayName!;
    }
    return 'Unknown';
  }

  Future<void> _saveRecipe() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      String base64Image = '';
      if (_imageFile != null) {
        List<int> imageBytes = await _imageFile!.readAsBytes();
        base64Image = base64Encode(imageBytes);
      }

      final recipeData = {
        'name': name,
        'description': description,
        'ingredients': ingredients,
        'instructions': instructions,
        'category': category,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
        'image_base64': base64Image,
        'author_id': getCurrentUserId(),
        'created_by': getCurrentUserName(),
      };

      try {
        await FirebaseFirestore.instance.collection('recipes').add(recipeData);

        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        print("Error saving recipe: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to save recipe. Please try again.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Recipe')
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Input Name
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Recipe Name',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Name is required' : null,
                onSaved: (value) => name = value!,
              ),
              SizedBox(height: 16),
              
              // Input Description
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                maxLines: 3,
                onSaved: (value) => description = value!,
              ),
              SizedBox(height: 16),

              // Category Dropdown
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                value: category.isNotEmpty ? category : null,
                items: categories
                    .map((cat) =>
                        DropdownMenuItem(value: cat, child: Text(cat)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    category = value!;
                  });
                },
                validator: (value) =>
                    value == null || value.isEmpty ? 'Category is required' : null,
              ),
              SizedBox(height: 16),

              // Ingredients Input
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Ingredients (comma separated)',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                onSaved: (value) =>
                    ingredients = value?.split(',').map((e) => e.trim()).toList() ?? [],
              ),
              SizedBox(height: 16),

              // Instructions Input
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Instructions',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                maxLines: 3,
                onSaved: (value) => instructions = value!,
              ),
              SizedBox(height: 20),

              // Image Picker Section
              _imageFile != null
                  ? Column(
                      children: [
                        Image.file(
                          _imageFile!,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Image selected and converted to Base64',
                          style: TextStyle(color: Colors.green),
                        ),
                      ],
                    )
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        backgroundColor: Colors.grey,
                      ),
                      onPressed: _pickImage,
                      child: Text(
                        'Pick an image',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
              SizedBox(height: 20),

              // Save Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: _saveRecipe,
                child: Text(
                  'Save Recipe',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
