import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'languages.dart';
import 'image_processing.dart';

void main() => runApp(const CottonShieldApp());

class CottonShieldApp extends StatelessWidget {
  const CottonShieldApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cotton Shield',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const DiseaseDetectionScreen(),
    );
  }
}

class DiseaseDetectionScreen extends StatefulWidget {
  const DiseaseDetectionScreen({super.key});

  @override
  _DiseaseDetectionScreenState createState() => _DiseaseDetectionScreenState();
}

class _DiseaseDetectionScreenState extends State<DiseaseDetectionScreen> {
  final ImagePicker picker = ImagePicker();
  final ImageProcessor imageProcessor = ImageProcessor();

  File? _image;
  String _disease = "";
  String _remedy = "";
  bool _isLoading = false;
  String _language = "English"; // Default language

  final List<String> _languages = ["English", "Hindi", "Telugu", "Marathi"];
  final List<String> diseaseKeys = ["Bacterial Blight", "Curl Virus", "Fusarium Wilt", "Healthy"];

  @override
  void initState() {
    super.initState();
    imageProcessor.loadModel();
  }

  /// Select a language from dropdown menu
  void _selectLanguage(String selectedLanguage) {
    setState(() {
      _language = selectedLanguage;
    });
  }

  /// Pick an image from camera/gallery
  Future<void> pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _disease = "";
        _remedy = "";
        _isLoading = true;
      });
      await detectDisease(File(pickedFile.path));
    }
  }

  /// Detect disease in selected image
  Future<void> detectDisease(File image) async {
    try {
      print("🌍 Selected Language: $_language");
      print("📡 Sending image for prediction...");
      final prediction = await imageProcessor.predictDisease(image, _language);

      print("🦠 Detected Disease: ${prediction['disease']}");
      print("💊 Suggested Remedy: ${prediction['remedy']}");

      setState(() {
        _disease = prediction['disease'] ?? languages[_language]?["healthy"] ?? "Healthy";
        _remedy = prediction['remedy'] ?? languages[_language]?["no_remedy"] ?? "No remedy available";
      });
    } catch (e) {
      print("❌ Error in disease detection: $e");
      setState(() {
        _disease = "Error";
        _remedy = "Error: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const CircleAvatar(
              backgroundImage: AssetImage('assets/logo.jpg'),
            ),
            Text(
              languages[_language]?["title"] ?? "CottonShield",
              style: const TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            PopupMenuButton<String>(
              onSelected: _selectLanguage,
              icon: const Icon(Icons.more_vert, color: Colors.black),
              itemBuilder: (context) {
                return _languages
                    .map((String lang) => PopupMenuItem<String>(
                          value: lang,
                          child: Text(lang),
                        ))
                    .toList();
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 200,
                width: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _image == null
                    ? const Icon(Icons.camera_alt, size: 50, color: Colors.black)
                    : Image.file(_image!, fit: BoxFit.cover),
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : Column(
                      children: [
                        ElevatedButton(
                          onPressed: () => pickImage(ImageSource.camera),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          child: Text(
                            languages[_language]?["click_image"] ?? "Capture Image",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () => pickImage(ImageSource.gallery),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          child: Text(
                            languages[_language]?["upload_image"] ?? "Upload Image",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
              const SizedBox(height: 20),
              if (_disease.isNotEmpty) ...[
                Text(
                  "${languages[_language]?["disease_detected"] ?? "Detected Disease"}: $_disease",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  "${languages[_language]?["remedy"] ?? "Remedy"}: $_remedy",
                  style: const TextStyle(fontSize: 18, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: _buildCircleButton(diseaseKeys[index], _getIconForDisease(diseaseKeys[index])),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Function to get an appropriate icon for each disease
  IconData _getIconForDisease(String disease) {
    switch (disease) {
      case "Bacterial Blight":
        return Icons.bug_report;
      case "Curl Virus":
        return Icons.local_florist;
      case "Fusarium Wilt":
        return Icons.warning;
      default:
        return Icons.health_and_safety;
    }
  }

  /// Function to build the circular disease buttons
  Widget _buildCircleButton(String label, IconData icon) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _disease = label;
          _remedy = languages[_language]?["disease_details"]?[label]?["remedies"] ?? "No remedy available.";
        });
      },
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: _disease == label ? Colors.green[700] : Colors.green,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(icon, color: Colors.white),
            ),
          ),
          const SizedBox(height: 5),
          Text(
            languages[_language]?["disease_details"]?[label]?["name"] ?? label,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
