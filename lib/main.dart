import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'languages.dart'; // Import the languages file

void main() => runApp(CottonDiseaseDetectionApp());

class CottonDiseaseDetectionApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cotton Disease Detection',
      theme: ThemeData(primarySwatch: Colors.green),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _picker = ImagePicker();
  String _result = "No image selected.";
  String _language = "English"; // Default language is English

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _result = languages[_language]!['processing']!; // Show processing message
      });
      // TODO: Add backend call to process image and update _result with output
    } else {
      setState(() {
        _result = languages[_language]!['no_image']!; // Show no image selected message
      });
    }
  }

  void _toggleLanguage() {
    setState(() {
      _language = _language == "English" ? "Hindi" : "English";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(languages[_language]!['title']!),
        actions: [
          IconButton(
            icon: Icon(Icons.language),
            onPressed: _toggleLanguage,
            tooltip: languages[_language]!['switch_language']!,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              languages[_language]!['detect_diseases']!,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(Icons.camera_alt),
              label: Text(languages[_language]!['click_image']!),
              onPressed: () => _pickImage(ImageSource.camera),
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              icon: Icon(Icons.upload_file),
              label: Text(languages[_language]!['upload_image']!),
              onPressed: () => _pickImage(ImageSource.gallery),
            ),
            SizedBox(height: 20),
            Card(
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _result,
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}