import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../services/file_download.dart';
import '../services/storage_service.dart';

class SubjectPage extends StatefulWidget {
  final String department;
  final int semester;
  final String subject;

  const SubjectPage({
    super.key,
    required this.department,
    required this.semester,
    required this.subject,
  });

  @override
  State<SubjectPage> createState() => _SubjectPageState();
}

class _SubjectPageState extends State<SubjectPage> {
  static const _blue = Color(0xFF287DFF);
  int selectedUnit = 1;
  List<StoredStudyFile> files = [];
  bool loading = true;
  bool uploading = false;

  @override
  void initState() {
    super.initState();
    loadFiles();
  }

  Future<void> loadFiles() async {
    final result = await StorageService.getFiles(
      department: widget.department,
      semester: widget.semester,
      subject: widget.subject,
    );
    if (!mounted) return;
    setState(() {
      files = result;
      loading = false;
    });
  }

  Future<void> uploadFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'ppt', 'pptx', 'txt', 'jpg', 'jpeg', 'png'],
      withData: true,
    );
    if (!mounted || result == null || result.files.isEmpty) return;
    final picked = result.files.first;
    if (picked.bytes == null) {
      showMessage('This file could not be read in the browser. Please try again.');
      return;
    }

    setState(() => uploading = true);
    await StorageService.saveFile(
      department: widget.department,
      semester: widget.semester,
      subject: widget.subject,
      unit: selectedUnit,
      name: picked.name,
      size: picked.size,
      bytes: picked.bytes!,
    );
    await loadFiles();
    if (!mounted) return;
    setState(() => uploading = false);
    showMessage('${picked.name} uploaded successfully.');
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  String formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String formatDate(String value) {
    final date = DateTime.tryParse(value)?.toLocal();
    if (date == null) return value;
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> viewFile(StoredStudyFile file) async {
    final bytes = base64Decode(file.bytesBase64);
    final isImage = ['jpg', 'jpeg', 'png'].contains(file.extension);
    final isText = file.extension == 'txt';
    if (!isImage && !isText) {
      openFile(file.name, Uint8List.fromList(bytes));
      if (mounted) showMessage('Opening ${file.name} in a new tab.');
      return;
    }
    if (!mounted) return;
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(file.name),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600, maxHeight: 500),
          child: isImage
              ? Image.memory(Uint8List.fromList(bytes), fit: BoxFit.contain)
              : isText
                  ? SingleChildScrollView(child: Text(utf8.decode(bytes, allowMalformed: true)))
                  : const Text('Preview is available for images and text files. Download this file to open it.'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  Future<void> deleteFile(StoredStudyFile file) async {
    await StorageService.deleteFile(file.id);
    await loadFiles();
    if (mounted) showMessage('${file.name} removed.');
  }

  @override
  Widget build(BuildContext context) {
    final unitFiles = files.where((file) => file.id.contains('|$selectedUnit|')).toList();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subject, style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              onPressed: uploading ? null : uploadFile,
              icon: const Icon(Icons.cloud_upload_outlined),
              label: const Text('Upload'),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
        children: [
          Text('Semester ${widget.semester}', style: const TextStyle(color: Colors.white70, fontSize: 16)),
          const SizedBox(height: 18),
          SizedBox(
            height: 52,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final unit = index + 1;
                return ChoiceChip(
                  label: Text('Unit $unit'),
                  selected: unit == selectedUnit,
                  onSelected: (_) => setState(() => selectedUnit = unit),
                  selectedColor: _blue,
                  labelStyle: TextStyle(color: unit == selectedUnit ? Colors.white : Colors.white70),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(color: const Color(0xFF1B1F25), borderRadius: BorderRadius.circular(14)),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                Container(
                  color: const Color(0xFF22262C),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: const Row(
                    children: [
                      Expanded(flex: 5, child: Text('File Name', style: TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(flex: 2, child: Text('Uploaded On', style: TextStyle(fontWeight: FontWeight.bold))),
                      Expanded(flex: 2, child: Text('Size', style: TextStyle(fontWeight: FontWeight.bold))),
                      Text('Actions', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                if (loading)
                  const Padding(padding: EdgeInsets.all(28), child: CircularProgressIndicator())
                else if (unitFiles.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 20),
                    child: Column(
                      children: [
                        const Icon(Icons.folder_open_outlined, size: 48, color: Colors.white30),
                        const SizedBox(height: 12),
                        Text('No files uploaded for Unit $selectedUnit', style: const TextStyle(color: Colors.white70)),
                      ],
                    ),
                  )
                else
                  ...unitFiles.map(
                    (file) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.description_outlined, color: _blue),
                          const SizedBox(width: 10),
                          Expanded(flex: 4, child: Text(file.name, overflow: TextOverflow.ellipsis)),
                          Expanded(flex: 2, child: Text(formatDate(file.uploadedOn), style: const TextStyle(color: Colors.white60))),
                          Expanded(flex: 2, child: Text(formatSize(file.size), style: const TextStyle(color: Colors.white60))),
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'view') viewFile(file);
                              if (value == 'download') downloadFile(file.name, Uint8List.fromList(base64Decode(file.bytesBase64)));
                              if (value == 'delete') deleteFile(file);
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(value: 'view', child: Text('View')),
                              PopupMenuItem(value: 'download', child: Text('Download')),
                              PopupMenuItem(value: 'delete', child: Text('Delete')),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: uploading ? null : uploadFile,
            icon: const Icon(Icons.cloud_upload_rounded),
            label: Text(uploading ? 'Uploading...' : 'Upload File'),
            style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(54)),
          ),
        ],
      ),
    );
  }
}