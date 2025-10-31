import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';

class PdfViewerScreen extends StatefulWidget {
  final String fileName;
  final String? filePath; // For mobile
  final Uint8List? fileBytes; // For web

  const PdfViewerScreen({
    super.key,
    required this.fileName,
    this.filePath,
    this.fileBytes,
  });

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  PdfController? _pdfController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    try {
      if (widget.filePath != null) {
        // Mobile: load from file path
        _pdfController = PdfController(
          document: PdfDocument.openFile(widget.filePath!),
        );
      } else if (widget.fileBytes != null) {
        // Web: load from bytes
        _pdfController = PdfController(
          document: PdfDocument.openData(widget.fileBytes!),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load PDF: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _pdfController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.fileName),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_pdfController != null)
            IconButton(
              icon: const Icon(Icons.zoom_in),
              onPressed: () {
                // Zoom functionality can be added if needed
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pdfController == null
              ? const Center(child: Text('Failed to load PDF'))
              : PdfView(
                  controller: _pdfController!,
                  scrollDirection: Axis.vertical,
                ),
    );
  }
}
