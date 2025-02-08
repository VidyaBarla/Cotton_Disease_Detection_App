import 'dart:io';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'languages.dart';

class ImageProcessor {
  Interpreter? _interpreter;

  // Load the TFLite model
  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/optimized_model.tflite');
      print("✅ Model successfully loaded.");
    } catch (e) {
      print("❌ Error loading model: $e");
      throw Exception("Error loading model: $e");
    }
  }

  // Preprocess image (Must match Colab processing exactly)
  Future<List<List<List<List<double>>>>> preprocessImage(File image) async {
    print("📷 Preprocessing image...");
    final bytes = await image.readAsBytes();
    img.Image? originalImage = img.decodeImage(bytes);

    if (originalImage == null) {
      throw Exception("❌ Unable to decode image.");
    }

    // Resize image to 224x224 (match model input size)
    final resizedImage = img.copyResize(originalImage, width: 224, height: 224);

    // Convert image to RGB format and normalize to [0,1]
    List<List<List<double>>> imageTensor = List.generate(
      224,
      (y) => List.generate(
        224,
        (x) {
          final pixel = resizedImage.getPixel(x, y);
          return [
            pixel.r.toDouble() / 255.0,  // Normalize Red channel
            pixel.g.toDouble() / 255.0,  // Normalize Green channel
            pixel.b.toDouble() / 255.0   // Normalize Blue channel
          ];
        },
      ),
    );

    print("✅ Image preprocessing completed.");
    
    // Debugging: Print first 5 diagonal pixel values
    print("🖼 First 5 pixel values from processed image in Flutter:");
    for (int i = 0; i < 5; i++) {
      print(imageTensor[i][i]);  // Ensure correct shape
    }

    return [imageTensor]; // Model expects [1, 224, 224, 3]
  }

  // Run prediction on the preprocessed image
  Future<Map<String, String>> predictDisease(File image, String language) async {
    if (_interpreter == null) {
      throw Exception("❌ Model not loaded.");
    }

    print("🔍 Running prediction...");
    var inputImage = await preprocessImage(image);

    var output = List.filled(4, 0.0).reshape([1, 4]);  // Ensure correct shape

    try {
      _interpreter!.run(inputImage, output);
      print("✅ Model inference completed.");
    } catch (e) {
      throw Exception("❌ Error during inference: $e");
    }

    List<double> outputList = List<double>.from(output[0]);
    print("🔢 Model raw output in Flutter: $outputList");

    // Print all class probabilities
    for (int i = 0; i < outputList.length; i++) {
      print("Class $i probability: ${outputList[i]}");
    }

    // Find the predicted class
    int predictedClass = outputList.indexWhere((x) => x == outputList.reduce((a, b) => a > b ? a : b));
    print("📌 Predicted class index in Flutter: $predictedClass");


    // Fetch the disease & remedy from the dictionary
    List<String> diseases = List<String>.from(languages[language]!["diseases"]);
    List<String> remedies = List<String>.from(languages[language]!["remedies"]);

    // Ensure predicted class is valid
    if (predictedClass < 0 || predictedClass >= diseases.length) {
      print("❌ Invalid class index: $predictedClass");
      return {
        "disease": "Unknown",
        "remedy": "No remedy available."
      };
    }

    print("🦠 Predicted Disease: ${diseases[predictedClass]}");
    print("💊 Recommended Remedy: ${remedies[predictedClass]}");

    return {
      "disease": diseases[predictedClass],  // ✅ Return actual disease name
      "remedy": remedies[predictedClass]    // ✅ Return actual remedy
    };
  }
}