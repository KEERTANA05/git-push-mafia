import 'package:flutter/material.dart';
import 'dart:io';

class PredictionPage extends StatelessWidget {
  final String breed;
  final String confidence;
  final String imagePath;

  const PredictionPage({
    super.key,
    required this.breed,
    required this.confidence,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Prediction Result", style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.green,
          centerTitle: true,
        ),
        body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Image preview
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.file(
                      File(imagePath),
                      height: 250,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Breed Name
                Text(
                  "Breed: $breed",
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),

                // Confidence Score
                Text(
                  "Confidence: $confidence%",
                  style: const TextStyle(fontSize: 18, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),

                // Back button
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: const Text("Back", style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ],
            ),
            ),
        );
    }
}
