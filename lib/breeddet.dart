import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:livestock_lens_new/predictionpg.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img_lib;
import 'package:livestock_lens_new/predictionpg.dart';


class BreedDetectionPage extends StatefulWidget {
  const BreedDetectionPage({super.key});

  @override
  State<BreedDetectionPage> createState() => _BreedDetectionPageState();
}

class _BreedDetectionPageState extends State<BreedDetectionPage> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  Interpreter? _interpreter;
  List<String> _classNames = [];

  @override
  void initState() {
    super.initState();
    _loadModelAndLabels();
  }

  Future<void> _loadModelAndLabels() async {
    setState(() => _isLoading = true);

    try {
      // Load TFLite model
      _interpreter = await Interpreter.fromAsset('assets/breed_model.tflite');

      // Load class names from JSON file
      final jsonString = await rootBundle.loadString('assets/class_names.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      _classNames = jsonList.cast<String>();

      debugPrint("✅ Model & labels loaded successfully");
    } catch (e) {
      debugPrint('❌ Failed to load model or labels: $e');
      _showSnackBar("Failed to load model or labels.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _predictImage() async {
    if (_imageFile == null || _interpreter == null) {
      _showSnackBar("Please select an image first.");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final imageBytes = await _imageFile!.readAsBytes();
      final originalImage = img_lib.decodeImage(imageBytes);

      if (originalImage == null) {
        _showSnackBar("Failed to decode image.");
        return;
      }

      // Resize to model input size
      final resizedImage = img_lib.copyResize(originalImage, width: 224, height: 224);

      // Prepare input tensor
      final input = List.generate(
        1,
            (_) => List.generate(
          224,
              (y) => List.generate(
            224,
                (x) {
              final pixel = resizedImage.getPixel(x, y);
              return [
                pixel.r / 255.0,
                pixel.g / 255.0,
                pixel.b / 255.0,
              ];
            },
          ),
        ),
      );

      // Prepare output tensor
      final output = List.filled(1, List.filled(_classNames.length, 0.0));

      // Run inference
      _interpreter!.run(input, output);

      // Get highest probability
      final List<double> probabilities = output[0].cast<double>();
      double maxProbability = probabilities.reduce((a, b) => a > b ? a : b);
      int maxIndex = probabilities.indexOf(maxProbability);

      if (maxIndex != -1) {
        final breed = _classNames[maxIndex];
        final confidence = (maxProbability * 100).toStringAsFixed(2);

        // Navigate to PredictionPage
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PredictionPage(
              breed: breed,
              confidence: confidence,
              imagePath: _imageFile!.path,
            ),
          ),
        );
      } else {
        _showSnackBar("Prediction failed.");
      }
    } catch (e) {
      debugPrint('❌ Prediction error: $e');
      _showSnackBar("Prediction failed. Check console for details.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _capturePhoto() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadPhoto() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: Text(
            "breed_detection".tr(),
            style: const TextStyle(color: Colors.white, fontSize: 22),
          ),
          backgroundColor: Colors.green,
          elevation: 5,
          centerTitle: true,
        ),
        body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Image preview card
                Expanded(
                  child: Center(
                    child: Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Container(
                        width: double.infinity,
                        height: 280,
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.white,
                        ),
                        child: _imageFile != null
                            ? ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.file(
                            _imageFile!,
                            fit: BoxFit.cover,
                          ),
                        )
                            : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.image_outlined,
                                size: 80, color: Colors.grey),
                            const SizedBox(height: 15),
                            Text(
                              "no_image".tr(),
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Capture button
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _capturePhoto,
                  icon: const Icon(Icons.camera_alt, color: Colors.white),
                  label: Text("capture_photo".tr(),
                      style: const TextStyle(fontSize: 18, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    elevation: 4,
                  ),
                ),
                const SizedBox(height: 15),

                // Upload button
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _uploadPhoto,
                  icon: const Icon(Icons.upload_file, color: Colors.white),
                  label: Text("upload_photo".tr(),
                      style: const TextStyle(fontSize: 18, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    minimumSize: const Size(double.infinity, 55),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    elevation: 4,
                  ),
                ),
                const SizedBox(height: 25),

                // Predict (Next) button
                ElevatedButton(
                  onPressed: _isLoading ? null : _predictImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                  ),
                  child: Text("next".tr(),
                      style: const TextStyle(fontSize: 18, color: Colors.white)),
                ),
              ],
            ),
            ),
        );
    }
}
