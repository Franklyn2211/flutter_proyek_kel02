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

  @override
  void initState() {
    super.initState();
    name = '';
    description = '';
    ingredients = [];
    instructions = '';
    category = '';
    imageBase64 = null;
    _imageFile = null;
  }

  // Fungsi untuk mengonversi file menjadi Base64
  Future<void> _convertImageToBase64(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    setState(() {
      imageBase64 = base64Encode(bytes);
    });
  }

  // Fungsi untuk memilih gambar dari galeri perangkat
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      setState(() {
        _imageFile = imageFile;
      });
      // Konversi gambar ke Base64
      await _convertImageToBase64(imageFile);
    } else {
      print("No image selected.");
    }
  }

  // Fungsi untuk mengambil ID pengguna yang sedang login
  String getCurrentUserId() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.uid; // Mengambil ID pengguna
    }
    return ''; // Kembalikan string kosong jika tidak ada pengguna yang login
  }

  // Fungsi untuk mengambil nama pengguna yang sedang login
  String getCurrentUserName() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.displayName != null) {
      return user.displayName!; // Mengambil displayName pengguna
    }
    return 'Unknown'; // Kembalikan 'Unknown' jika tidak ada nama pengguna
  }

  Future<void> _saveRecipe() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Konversi gambar ke Base64
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
        'image_base64': base64Image, // Simpan hanya Base64
        'author_id': getCurrentUserId(), // Menyimpan ID pengguna yang sedang login
        'created_by': getCurrentUserName(), // Menyimpan nama pengguna yang membuat resep
      };

      try {
        // Menambahkan data ke Firestore
        await FirebaseFirestore.instance.collection('recipes').add(recipeData);

        // Kembali ke layar sebelumnya
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
        title: Text('Add Recipe'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Name is required' : null,
                onSaved: (value) => name = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 3,
                onSaved: (value) => description = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Category'),
                onSaved: (value) => category = value!,
              ),
              TextFormField(
                decoration:
                    InputDecoration(labelText: 'Ingredients (comma separated)'),
                onSaved: (value) =>
                    ingredients = value?.split(',').map((e) => e.trim()).toList() ?? [],
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Instructions'),
                maxLines: 3,
                onSaved: (value) => instructions = value!,
              ),
              SizedBox(height: 10),
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
                  : TextButton(
                      onPressed: _pickImage,
                      child: Text('Pick an image'),
                    ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveRecipe,
                child: Text('Save Recipe'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
