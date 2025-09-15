import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class PredictionResult {
  final String breed;
  final double confidence;

  PredictionResult(this.breed, this.confidence);

  @override
  String toString() {
    return '$breed: ${confidence.toStringAsFixed(2)}%';
  }
}

class TfliteService {
  late Interpreter _interpreter;
  late List<String> _classNames;

  // Initialize the TFLite model and class names
  Future<void> init() async {
    try {
      // Load model
      _interpreter = await Interpreter.fromAsset('breed_model.tflite');
      print('Model loaded successfully.');

      // Load class names
      final String jsonString = await rootBundle.loadString('assets/class_names.json');
      _classNames = (json.decode(jsonString) as List).cast<String>();
      print('Class names loaded successfully.');
    } catch (e) {
      print('Error initializing TFLite model: $e');
    }
  }

  // Preprocess the image to match model input requirements
  Uint8List _preprocessImage(File imageFile) {
    // Read the image file
    final originalImage = img.decodeImage(imageFile.readAsBytesSync());
    if (originalImage == null) {
      throw Exception('Could not decode image.');
    }

    // Resize the image to 224x224 and convert to RGB format
    final resizedImage = img.copyResize(originalImage, width: 224, height: 224);

    // Get the image bytes
    final imageBytes = resizedImage.getBytes();

    // The TFLite model is likely expecting a Float32List, but for some models,
    // a Uint8List is used with a normalization layer. Your Python script
    // normalizes the data to [0, 1] after converting to float32.
    // The TFLite Flutter package handles this conversion automatically if your
    // model expects a different data type. We'll use the raw bytes and let the
    // TFLite interpreter handle the data type conversion.
    return Uint8List.fromList(imageBytes);
  }

  // Simple softmax function to convert logits to probabilities
  List<double> _softmax(List<double> logits) {
    final maxLogit = logits.reduce(max);
    double expSum = 0.0;
    for (var value in logits) {
      expSum += exp(value - maxLogit);
    }
    return logits.map((e) => exp(e - maxLogit) / expSum).toList();
  }

  // Run the inference and get top 3 predictions
  Future<List<PredictionResult>> getTop3Predictions(File imageFile) async {
    if (_interpreter == null || _classNames.isEmpty) {
      throw Exception('TFLite service not initialized.');
    }

    // Preprocess the image
    final inputTensor = _preprocessImage(imageFile);

    // Prepare the output tensor based on the number of classes
    final output = List<double>.filled(_classNames.length, 0);

    // Get input and output details from the interpreter
    final inputDetails = _interpreter.getInputTensors();
    final outputDetails = _interpreter.getOutputTensors();

    // Create input and output buffers
    final inputBuffer = Uint8List.fromList(inputTensor).buffer;
    final outputBuffer = Float32List(_classNames.length).buffer;

    // Run inference
    _interpreter.run(inputBuffer, outputBuffer);

    // Get the output as a list of doubles
    final outputPredictions = outputBuffer.asFloat32List();

    // Apply softmax to get probabilities
    final predictions = _softmax(outputPredictions.toList());

    final Map<int, double> indexedPredictions = {};
    for (var i = 0; i < predictions.length; i++) {
      indexedPredictions[i] = predictions[i];
    }

    final sortedEntries = indexedPredictions.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final top3 = sortedEntries.take(3).toList();

    return top3.map((entry) {
      final breedName = _classNames[entry.key];
      final confidence = entry.value * 100;
      return PredictionResult(breedName, confidence);
    }).toList();
    }
}
