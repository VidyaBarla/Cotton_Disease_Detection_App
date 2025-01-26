import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
  String _language = "English";

  Future<void> _pickImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      setState(() {
        _result = "Processing image..."; // Placeholder for backend call
      });
      // TODO: Send the image to the backend and update _result with the output
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
        title: Text(_language == "English" ? 'Cotton Disease Detection' : 'कपास रोग पहचान'),
        actions: [
          IconButton(
            icon: Icon(Icons.language),
            onPressed: _toggleLanguage,
            tooltip: _language == "English" ? 'Switch to Hindi' : 'अंग्रेज़ी में स्विच करें',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _language == "English" ? 'Detect Cotton Diseases' : 'कपास रोगों का पता लगाएं',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              icon: Icon(Icons.camera_alt),
              label: Text(_language == "English" ? 'Click Image' : 'छवि क्लिक करें'),
              onPressed: () => _pickImage(ImageSource.camera),
            ),
            SizedBox(height: 10),
            ElevatedButton.icon(
              icon: Icon(Icons.upload_file),
              label: Text(_language == "English" ? 'Upload Image' : 'छवि अपलोड करें'),
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