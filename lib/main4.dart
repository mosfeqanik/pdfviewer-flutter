import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PDFLoader(),
    );
  }
}

class PDFLoader extends StatefulWidget {
  @override
  _PDFLoaderState createState() => _PDFLoaderState();
}

class _PDFLoaderState extends State<PDFLoader> {
  String? pdfPath;

  @override
  void initState() {
    super.initState();
    _downloadPDF();
  }

  Future<void> _downloadPDF() async {
    final url = "https://doctime-core-uat-storage.s3.ap-southeast-1.amazonaws.com/visits/424451/prescriptions/2024_08_13_130256.pdf?X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAZUG2TYIWF4I3LKNI%2F20240902%2Fap-southeast-1%2Fs3%2Faws4_request&X-Amz-Date=20240902T083731Z&X-Amz-SignedHeaders=host&X-Amz-Expires=900&X-Amz-Signature=20a2f3bf31206d179afc1265e5a7213012833354897e0e0ee7841372001ae69e";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final bytes = response.bodyBytes;
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/sample.pdf');

      await file.writeAsBytes(bytes, flush: true);
      setState(() {
        pdfPath = file.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("PDF Loader"),
      ),
      body: pdfPath != null
          ? PDFViewerPage(pdfPath: pdfPath!)
          : Center(child: CircularProgressIndicator()),
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await requestPermissions();
  runApp(MyApp());
}
Future<void> requestPermissions() async {
  await Permission.storage.request();
}
class PDFViewerPage extends StatefulWidget {
  final String pdfPath;

  PDFViewerPage({required this.pdfPath});

  @override
  _PDFViewerPageState createState() => _PDFViewerPageState();
}

class _PDFViewerPageState extends State<PDFViewerPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("PDF Viewer"),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _savePDF,
          ),
        ],
      ),
      body: PDFView(
        filePath: widget.pdfPath,
      ),
    );
  }

  Future<void> _savePDF() async {
    // Get external storage directory
    Directory? directory = await getExternalStorageDirectory();

    // Check for permissions (for Android)
    if (directory == null) {
      return;
    }

    // Define the new path for the saved PDF
    String newPath = '${directory.path}/saved_pdf.pdf';

    // Copy the PDF file to the new location
    File pdfFile = File(widget.pdfPath);
    await pdfFile.copy(newPath);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('PDF saved at $newPath'),
    ));
  }
}
