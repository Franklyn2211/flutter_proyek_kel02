import 'package:flutter/material.dart';

class RecipeBundle {
  final int id;
  final String title, description, imageSrc, category;
  final Color color;

  // Constructor
  RecipeBundle({
    required this.id,
    required this.title,
    required this.description,
    required this.imageSrc,
    required this.color,
    required this.category,
  });

  // Factory constructor untuk membuat objek dari data JSON
  factory RecipeBundle.fromJson(Map<String, dynamic> json) {
    // Menyesuaikan dengan data yang ada di API
    return RecipeBundle(
      id: json['id'] ?? 0,  // Jika id tidak ada, default 0
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? 'No description available',  // Jika description tidak ada
      imageSrc: json['image'] ?? '',  // Jika tidak ada gambar
      color: Color(0xFFFFFFFF),  // Default warna putih, bisa disesuaikan
      category: json['category'] ?? 'Unknown',  // Jika kategori tidak ada
    );
  }
}

