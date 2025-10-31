import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../services/api_service.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  File? _selectedFile;            // For mobile
  Uint8List? _selectedBytes;      // For web
  String? _fileName;
  bool _isUploading = false;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true, // ensure we get bytes for web
    );

    if (result != null && result.files.isNotEmpty) {
      if (mounted) {
        setState(() {
          _fileName = result.files.single.name;

          if (kIsWeb) {
            _selectedBytes = result.files.single.bytes;
          } else {
            _selectedFile = File(result.files.single.path!);
          }
        });
      }
    }
  }

  Future<void> _uploadFile() async {
    if ((!kIsWeb && _selectedFile == null) ||
        (kIsWeb && _selectedBytes == null)) {
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final appProvider = Provider.of<AppProvider>(context, listen: false);
      final apiService = ApiService();

      // Use correct upload method based on platform
      final response = kIsWeb
          ? await apiService.uploadNotesWeb(
              appProvider.userId,
              _selectedBytes!,
              _fileName!,
            )
          : await apiService.uploadNotes(
              appProvider.userId,
              _selectedFile!,
            );

      appProvider.addFile(_fileName ?? 'Untitled.pdf');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload successful: ${response.message}')),
        );

        setState(() {
          _selectedFile = null;
          _selectedBytes = null;
          _fileName = null;
        });

        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Notes'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Select a PDF file to upload',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _pickFile,
              icon: const Icon(Icons.file_upload),
              label: const Text('Choose PDF File'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 20),
            if (_fileName != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.picture_as_pdf, size: 48, color: Colors.red),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _fileName!,
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const Text('PDF Document'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isUploading ? null : _uploadFile,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isUploading
                    ? const CircularProgressIndicator()
                    : const Text('Upload Notes'),
              ),
            ] else if (_isUploading) ...[
              const Center(child: CircularProgressIndicator()),
            ],
          ],
        ),
      ),
    );
  }
}
