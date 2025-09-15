import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class KnowledgeHubPage extends StatelessWidget {
  const KnowledgeHubPage({super.key});

  @override
  Widget build(BuildContext context) {
    final breeds = [
      {
        "name": "gir_name".tr(),
        "desc": "gir_desc".tr(),
        "details": "gir_details".tr(),
        "image": "assets/gir.jpg"
      },
      {
        "name": "sahiwal_name".tr(),
        "desc": "sahiwal_desc".tr(),
        "details": "sahiwal_details".tr(),
        "image": "assets/sahiwal.jpg"
      },
      {
        "name": "murrah_name".tr(),
        "desc": "murrah_desc".tr(),
        "details": "murrah_details".tr(),
        "image": "assets/indianmurrah.jpg"
      },
      {
        "name": "ongole_name".tr(),
        "desc": "ongole_desc".tr(),
        "details": "ongole_details".tr(),
        "image": "assets/ongolecow.jpg"
      },
      {
        "name": "jaffarabadi_name".tr(),
        "desc": "jaffarabadi_desc".tr(),
        "details": "jaffarabadi_details".tr(),
        "image": "assets/jafarabadibuffalo.jpeg"
      },
    ];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("knowledge_hub".tr(),
            style: const TextStyle(color: Colors.white, fontSize: 22)),
        backgroundColor: Colors.green,
        centerTitle: true,
        elevation: 5,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: breeds.length,
        itemBuilder: (context, index) {
          final breed = breeds[index];
          return Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: InkWell(
              borderRadius: BorderRadius.circular(15),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => BreedDetailPage(breed: breed)),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15)),
                    child: Image.asset(
                      breed["image"]!,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          breed["name"]!,
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          breed["desc"]!,
                          style: const TextStyle(
                              fontSize: 14, color: Colors.black54),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
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
    );
  }
}

class BreedDetailPage extends StatelessWidget {
  final Map<String, String> breed;

  const BreedDetailPage({super.key, required this.breed});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(breed["name"]!,
              style: const TextStyle(color: Colors.white, fontSize: 26)),
          backgroundColor: Colors.green,
          centerTitle: true,
        ),
        body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.asset(
                    breed["image"]!,
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  breed["name"]!,
                  style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),
                const SizedBox(height: 10),
                Text(
                  breed["details"]!,
                  style: const TextStyle(fontSize: 18, color: Colors.black87),
                ),
              ],
            ),
            ),
        );
    }
}
