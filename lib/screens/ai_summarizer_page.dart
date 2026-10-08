
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../services/ai_service.dart';

class AiSummarizerPage extends StatefulWidget {
  const AiSummarizerPage({super.key});

  @override
  State<AiSummarizerPage> createState() => _AiSummarizerPageState();
}

class _AiSummarizerPageState extends State<AiSummarizerPage> {
  PlatformFile? selectedFile;
  String sourceText = '';
  Map<String, dynamic>? analysis;
  String? errorMessage;
  final questionController = TextEditingController();
  bool analyzing = false;

  Future<void> chooseNote() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
      withData: true,
    );

    if (!mounted || result == null || result.files.isEmpty) return;

    setState(() {
      selectedFile = result.files.first;
      sourceText = '';
      analysis = null;
      errorMessage = null;
    });
  }

  Future<void> summarize() async {
    if (selectedFile == null) return;

    setState(() {
      analyzing = true;
      analysis = null;
      errorMessage = null;
    });

    try {
      final result = await AiService.summarize(selectedFile!);
      if (!mounted) return;
      setState(() {
        analyzing = false;
        analysis = result;
      });
      return;
    } catch (error) {
      if (!mounted) return;
      setState(() {
        analyzing = false;
        errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    }

    // Keep the demo result available when the backend is not running yet.
    final bytes = selectedFile!.bytes;
    if (bytes != null && selectedFile!.extension?.toLowerCase() == 'txt') {
      sourceText = utf8.decode(bytes, allowMalformed: true);
      setState(() => analysis = buildAnalysis(sourceText));
    }
  }

  Map<String, dynamic> buildAnalysis(String text) {
    final cleaned = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    final sentences = cleaned.isEmpty
        ? <String>[]
        : cleaned.split(RegExp(r'(?<=[.!?])\s+')).where((item) => item.trim().length > 20).toList();
    final lines = text
        .split(RegExp(r'[\n.!?]'))
        .map((item) => item.trim())
        .where((item) => item.length > 18)
        .toList();
    final points = (lines.isNotEmpty ? lines : sentences).take(5).toList();
    final summary = sentences.isNotEmpty
        ? sentences.take(3).join(' ')
        : 'Upload a TXT file with readable notes to generate a content-based summary.';
    final words = cleaned.isEmpty ? <String>[] : cleaned.toLowerCase().split(RegExp(r'[^a-z0-9]+')).where((w) => w.length > 5).toList();
    final counts = <String, int>{};
    for (final word in words) {
      if (!['because', 'should', 'which', 'there', 'about', 'these', 'their', 'using'].contains(word)) {
        counts[word] = (counts[word] ?? 0) + 1;
      }
    }
    final keywords = counts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final topics = keywords.take(5).map((entry) => entry.key).toList();
    return {
      'summary': summary,
      'points': points.isEmpty ? ['The uploaded file is ready for analysis.'] : points,
      'topics': topics.isEmpty ? ['Add readable note content'] : topics,
      'tips': [
        'Revise the main ideas: ${topics.take(3).join(', ')}.',
        'Create a short definition and one example for every important topic.',
        'Test yourself without looking at the notes, then review the missed points.',
      ],
      'explanation': sentences.length > 1
          ? '${sentences.first} In simple terms, the notes connect the ideas so you can understand the topic step by step.'
          : 'The notes need more readable text for a detailed explanation.',
      'examples': topics.take(3).map((topic) => 'Example: Think of $topic as a real-world process with an input, a change, and an outcome.').toList(),
      'questions': topics.take(3).map((topic) => 'Explain $topic in your own words and give one example.').toList(),
    };
  }

  @override
  void dispose() {
    questionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withValues(alpha: .14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.blueAccent,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'StudyShare AI',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Make your notes easy to understand',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Upload card
          InkWell(
            onTap: analyzing ? null : chooseNote,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.blueAccent.withValues(alpha: .55),
                ),
                color: Colors.blueAccent.withValues(alpha: .06),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.picture_as_pdf_outlined,
                    size: 54,
                    color: Colors.blueAccent,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    selectedFile == null
                        ? 'Upload your notes'
                        : selectedFile!.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'PDF, DOC, DOCX or TXT',
                    style: TextStyle(color: Colors.white60),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: analyzing ? null : chooseNote,
                    icon: const Icon(Icons.attach_file),
                    label: Text(
                      selectedFile == null ? 'Choose Notes' : 'Change File',
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (selectedFile != null) ...[
            const SizedBox(height: 16),
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: analyzing ? null : summarize,
                icon: analyzing
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.auto_awesome),
                label: Text(
                  analyzing ? 'AI is analyzing...' : 'Summarize with AI',
                ),
              ),
            ),
          ],

          if (errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(errorMessage!, style: const TextStyle(color: Colors.orangeAccent)),
          ],

          if (analyzing) ...[
            const SizedBox(height: 22),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: const [
                    LinearProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Reading your notes...',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Finding important concepts and preparing an easy explanation.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white60),
                    ),
                  ],
                ),
              ),
            ),
          ],

          if (analysis != null) ...[
            const SizedBox(height: 26),
            const Text(
              'AI Summary',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _ResultCard(
              icon: Icons.summarize_outlined,
              title: 'Simple Summary',
              child: Text(analysis!['summary'] as String),
            ),
            _ResultCard(
              icon: Icons.school_outlined,
              title: 'Easy Explanation',
              child: Text(analysis!['explanation'] as String),
            ),
            _ResultCard(
              icon: Icons.star_outline,
              title: 'Important Points',
              child: _bulletList(_stringList(analysis!['points'])),
            ),
            _ResultCard(
              icon: Icons.lightbulb_outline,
              title: 'Study Tips',
              child: _bulletList(_stringList(analysis!['tips'])),
            ),
            _ResultCard(
              icon: Icons.auto_stories_outlined,
              title: 'Examples',
              child: _bulletList(_stringList(analysis!['examples'])),
            ),
            _ResultCard(
              icon: Icons.quiz_outlined,
              title: 'Practice Questions',
              child: _bulletList(_stringList(analysis!['questions'])),
            ),
          ],

          const SizedBox(height: 12),
          const Text(
            'AI tools',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _MiniTool(
                  icon: Icons.menu_book_outlined,
                  title: 'Quick Revision',
                  onTap: () => _showQuickRevision(context),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniTool(
                  icon: Icons.question_answer_outlined,
                  title: 'Ask AI',
                  onTap: () => _showAskAi(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bulletList(List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.isEmpty
          ? [const Text('No content found yet.')]
          : items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text('• $item'),
              )).toList(),
    );
  }

  List<String> _stringList(Object? value) {
    if (value is! List) return [];
    return value.map((item) => item.toString()).where((item) => item.trim().isNotEmpty).toList();
  }

  void _showQuickRevision(BuildContext context) {
    if (analysis == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Upload and summarize a note first.')));
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Quick Revision', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text('Topics: ${_stringList(analysis!['topics']).join(', ')}'),
          const SizedBox(height: 10),
          _bulletList(_stringList(analysis!['points']).take(3).toList()),
          const SizedBox(height: 12),
        ]),
      ),
    );
  }

  void _showAskAi(BuildContext context) {
    if (analysis == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Upload and summarize a note first.')));
      return;
    }
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Ask AI about this file'),
        content: TextField(
          controller: questionController,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Example: Explain the main topic'),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final question = questionController.text.trim();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(question.isEmpty ? 'Ask a question about your notes.' : 'Based on your notes: ${(analysis!['explanation'] as String)}')));
              questionController.clear();
            },
            child: const Text('Answer'),
          ),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _ResultCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blueAccent),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _MiniTool extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _MiniTool({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, color: Colors.blueAccent, size: 28),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
