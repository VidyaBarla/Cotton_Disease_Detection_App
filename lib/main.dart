import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'languages.dart';
import 'image_processing.dart';

void main() => runApp(const CottonDiseaseDetectionApp());

class CottonDiseaseDetectionApp extends StatelessWidget {
  const CottonDiseaseDetectionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cotton Disease Detection',
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
  String _language = "English";
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    imageProcessor.loadModel();
  }

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

  Future<void> detectDisease(File image) async {
    try {
      final prediction = await imageProcessor.predictDisease(image, _language);
      setState(() {
        _disease = prediction['disease'] ?? "Unknown Disease"; // Provide a default value
        _remedy = prediction['remedy'] ?? "No remedy available";
      });
    } catch (e) {
      setState(() {
        _disease = languages[_language]!['model_error']!;
        _remedy = "$e";
      });
    }
    finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: _image != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _image = null;
                    _disease = "";
                    _remedy = "";
                  });
                },
              )
            : null,
        title: Text(languages[_language]!['title']!),
        actions: [
          PopupMenuButton<String>(
            onSelected: (String newLanguage) {
              setState(() {
                _language = newLanguage;
                _disease = "";
                _remedy = "";
              });
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: "English",
                child: Text("English"),
              ),
              const PopupMenuItem<String>(
                value: "Hindi",
                child: Text("हिंदी"),
              ),
              const PopupMenuItem<String>(
                value: "Telugu",
                child: Text("తెలుగు"),
              ),
              const PopupMenuItem<String>(
                value: "Marathi",
                child: Text("मराठी"),
              ),
            ],
            icon: const Icon(Icons.more_vert), // Three-dot menu icon
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Centers content vertically
            crossAxisAlignment: CrossAxisAlignment.center, // Centers content horizontally
            children: [
              if (_image == null) ...[
                Image.asset(
                  'assets/upload_placeholder.png', // Placeholder image
                  height: 200,
                  width: 200,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 80), // Increased space between image and buttons

                ElevatedButton.icon(
                  icon: const Icon(Icons.camera_alt, size: 28),
                  label: Text(
                    languages[_language]!['click_image']!,
                    style: const TextStyle(fontSize: 20),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 55),
                    textStyle: const TextStyle(fontSize: 45),
                  ),
                  onPressed: () => pickImage(ImageSource.camera),
                ),

                const SizedBox(height: 15),

                ElevatedButton.icon(
                  icon: const Icon(Icons.upload_file, size: 28),
                  label: Text(
                    languages[_language]!['upload_image']!,
                    style: const TextStyle(fontSize: 20),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 55),
                    textStyle: const TextStyle(fontSize: 40),
                  ),
                  onPressed: () => pickImage(ImageSource.gallery),
                ),
              ] else ...[
                Image.file(
                  _image!,
                  height: 300,
                  width: 300,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 40),

                _isLoading
                    ? const CircularProgressIndicator()
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "${languages[_language]!['disease_detected']!} $_disease",
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            "${languages[_language]!['remedy']!} $_remedy",
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
