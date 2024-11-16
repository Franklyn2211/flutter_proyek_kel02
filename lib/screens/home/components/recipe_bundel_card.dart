import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_proyek_kel02/size_config.dart';

class RecipeBundelCard extends StatelessWidget {
  final dynamic recipeBundle;  // Menggunakan dynamic karena data yang diterima dari API bisa beragam
  final VoidCallback press;

  const RecipeBundelCard({
    Key? key,
    required this.recipeBundle,
    required this.press,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double defaultSize = SizeConfig.defaultSize;
    return GestureDetector(
      onTap: press,
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFF90AF17),
          borderRadius: BorderRadius.circular(defaultSize * 1.8),
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(defaultSize * 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Spacer(),
                    Text(
                      recipeBundle['title'] ?? 'No Title',  // Menggunakan title dari API
                      style: TextStyle(
                        fontSize: defaultSize * 2.2,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: defaultSize * 0.5),
                    Text(
                      recipeBundle['summary'] ?? 'No description available',  // Menggunakan summary dari API
                      style: TextStyle(color: Colors.white54),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Spacer(),
                    // Menampilkan waktu masak dan jumlah porsi dari API
                    buildInfoRow(
                      defaultSize,
                      iconSrc: "assets/icons/pot.svg",
                      text: "${recipeBundle['readyInMinutes']} mins",  // Waktu memasak
                    ),
                    SizedBox(height: defaultSize * 0.5),
                    buildInfoRow(
                      defaultSize,
                      iconSrc: "assets/icons/chef.svg",
                      text: "${recipeBundle['servings']} servings",  // Jumlah porsi
                    ),
                    Spacer(),
                  ],
                ),
              ),
            ),
            SizedBox(width: defaultSize * 0.5),
            AspectRatio(
              aspectRatio: 0.71,
              child: recipeBundle['image'] != null
                  ? Image.network(
                      recipeBundle['image'],
                      fit: BoxFit.cover,
                      alignment: Alignment.centerLeft,
                    )
                  : Icon(Icons.image),  // Menampilkan ikon jika tidak ada gambar
            )
          ],
        ),
      ),
    );
  }

  Row buildInfoRow(double defaultSize, {String? iconSrc, text}) {
    return Row(
      children: <Widget>[
        SvgPicture.asset(iconSrc!),
        SizedBox(width: defaultSize),
        Text(
          text,
          style: TextStyle(
            color: Colors.white,
          ),
        )
      ],
    );
  }
}
