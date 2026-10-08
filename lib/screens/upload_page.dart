import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class UploadPage extends StatefulWidget {
  final String department;
  const UploadPage({super.key, required this.department});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  PlatformFile? selectedFile;
  bool uploading = false;
  double progress = 0;

  Future<void> chooseFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'ppt', 'pptx', 'txt', 'jpg', 'jpeg', 'png'],
      withData: kIsWeb,
    );

    if (!mounted || result == null || result.files.isEmpty) return;

    setState(() {
      selectedFile = result.files.first;
      progress = 0;
    });
  }

  Future<void> uploadFile() async {
    if (selectedFile == null) return;

    setState(() {
      uploading = true;
      progress = 0;
    });

    for (int i = 1; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 120));
      if (!mounted) return;
      setState(() => progress = i / 10);
    }

    if (!mounted) return;
    setState(() => uploading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('File ready! Cloud upload will be connected with Firebase later.')),
    );
  }

  String fileSize(int? bytes) {
    if (bytes == null) return '';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final file = selectedFile;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Upload Notes', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            'Department: ${widget.department.isEmpty ? 'Not selected' : widget.department}',
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 24),
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: uploading ? null : chooseFile,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 38, horizontal: 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.blueAccent.withValues(alpha: .55)),
                color: Colors.blueAccent.withValues(alpha: .06),
              ),
              child: const Column(
                children: [
                  Icon(Icons.cloud_upload_rounded, size: 62, color: Colors.blueAccent),
                  SizedBox(height: 14),
                  Text('Choose a file', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 6),
                  Text(
                    'PDF, DOC, PPT, TXT or image files',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white60),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (file != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.insert_drive_file, color: Colors.blueAccent, size: 34),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                file.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 4),
                              Text(fileSize(file.size), style: const TextStyle(color: Colors.white60)),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: uploading ? null : () => setState(() => selectedFile = null),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    if (uploading) ...[
                      const SizedBox(height: 16),
                      LinearProgressIndicator(value: progress),
                      const SizedBox(height: 8),
                      Text('${(progress * 100).round()}%'),
                    ],
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton.icon(
                        onPressed: uploading ? null : uploadFile,
                        icon: const Icon(Icons.upload_rounded),
                        label: Text(uploading ? 'Uploading...' : 'Upload File'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (kIsWeb && file != null && file.bytes == null)
            const Padding(
              padding: EdgeInsets.only(top: 10),
              child: Text(
                'The browser selected the file successfully. Firebase/Cloud Storage can be connected later for permanent uploads.',
                style: TextStyle(color: Colors.white54),
              ),
            ),
        ],
      ),
    );
  }
}
