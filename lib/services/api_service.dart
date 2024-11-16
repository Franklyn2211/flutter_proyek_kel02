import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String apiKey = '1833ae9fb3b04765b210829fc3c0b7ea'; // Gantilah dengan API key Anda

  // Fungsi untuk mengambil data resep
  Future<List<dynamic>> fetchRecipes(String query) async {
    final url = 'https://api.spoonacular.com/recipes/complexSearch?query=$query&apiKey=$apiKey';
    
    try {
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        // Parse data JSON dan kembalikan hasilnya
        var data = json.decode(response.body);
        return data['results'];  // Ambil hasil resep
      } else {
        throw Exception('Gagal mengambil data, status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
