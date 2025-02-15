import 'dart:io';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'languages.dart';

class ImageProcessor {
  Interpreter? _interpreter;

  // Load the TFLite model
  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/model.tflite');
      print("✅ Model successfully loaded.");
    } catch (e) {
      print("❌ Error loading model: $e");
      throw Exception("Error loading model: $e");
    }
  }

  // Preprocess image (Ensure it matches ResNet50 preprocessing)
  Future<List<List<List<List<double>>>>> preprocessImage(File image) async {
    print("📷 Preprocessing image...");
    final bytes = await image.readAsBytes();
    img.Image? originalImage = img.decodeImage(bytes);

    if (originalImage == null) {
      throw Exception("❌ Unable to decode image.");
    }

    // Resize image to 224x224 (model input size)
    final resizedImage = img.copyResize(originalImage, width: 224, height: 224);

    // Mean subtraction values for ResNet50
    const mean = [123.68, 116.78, 103.94];

    // Convert image to RGB format and apply ResNet50 preprocessing
    List<List<List<double>>> imageTensor = List.generate(
      224,
      (y) => List.generate(
        224,
        (x) {
          final pixel = resizedImage.getPixel(x, y);
          return [
            (pixel.r.toDouble() - mean[0]),  // Red channel
            (pixel.g.toDouble() - mean[1]),  // Green channel
            (pixel.b.toDouble() - mean[2])   // Blue channel
          ];
        },
      ),
    );

    print("✅ Image preprocessing completed.");
    return [imageTensor]; // Model expects [1, 224, 224, 3]
  }

  // Run prediction on the preprocessed image
  Future<Map<String, dynamic>> predictDisease(File image, String language) async {
    if (_interpreter == null) {
      throw Exception("❌ Model not loaded.");
    }

    print("🔍 Running prediction...");
    var inputImage = await preprocessImage(image);
    var output = List.filled(4, 0.0).reshape([1, 4]);

    try {
      _interpreter!.run(inputImage, output);
      print("✅ Model inference completed.");
    } catch (e) {
      throw Exception("❌ Error during inference: $e");
    }

    List<double> outputList = List<double>.from(output[0]);
    print("🔢 Model raw output in Flutter: $outputList");

    int predictedClass = outputList.indexWhere((x) => x == outputList.reduce((a, b) => a > b ? a : b));
    print("📌 Predicted class index in Flutter: $predictedClass");

    List<String> diseaseKeys = ["Bacterial Blight", "Curl Virus", "Fusarium Wilt", "Healthy"];

    if (predictedClass < 0 || predictedClass >= diseaseKeys.length) {
      print("❌ Invalid class index: $predictedClass");
      return {"index": -1, "remedy": "No remedy available."};
    }

    // Fetch disease data in the selected language
    Map<String, dynamic>? diseaseData = languages[language]?["disease_details"]?[diseaseKeys[predictedClass]];

    if (diseaseData == null) {
      print("❌ Disease data missing for: ${diseaseKeys[predictedClass]}");
      return {"index": predictedClass, "disease": diseaseKeys[predictedClass], "remedy": "No remedy available."};
    }

    print("🦠 Disease: ${diseaseData["name"]}");
    print("💊 Remedy: ${diseaseData["remedies"]}");

    return {
      "index": predictedClass,
      "disease": diseaseData["name"], // Translated disease name
      "remedy": diseaseData["remedies"] // Translated remedy
    };
  }
}
