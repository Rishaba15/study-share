import 'package:flutter/material.dart';
import '../data/departments.dart';
import 'subject_page.dart';

class SearchPage extends StatefulWidget {
  final String department;
  const SearchPage({super.key, required this.department});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final controller = TextEditingController();
  String query = '';

  List<Map<String, String>> get results {
    final items = <Map<String, String>>[];
    for (int sem = 1; sem <= 8; sem++) {
      for (final subject in subjectsFor(widget.department, sem)) {
        items.add({'subject': subject, 'semester': 'Semester $sem'});
      }
    }

    if (query.trim().isEmpty) return items;

    return items.where((item) {
      return item['subject']!.toLowerCase().contains(query.toLowerCase()) ||
          item['semester']!.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = results;

    return SafeArea(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 20, 16, 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Search', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: controller,
              onChanged: (value) => setState(() => query = value),
              decoration: InputDecoration(
                hintText: 'Search your department subjects...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: query.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          controller.clear();
                          setState(() => query = '');
                        },
                        icon: const Icon(Icons.clear),
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: items.isEmpty
                ? const Center(child: Text('No subjects found.', style: TextStyle(color: Colors.white70)))
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.menu_book_outlined, color: Colors.blueAccent),
                          title: Text(item['subject']!),
                          subtitle: Text(item['semester']!),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SubjectPage(
                                department: widget.department,
                                semester: int.parse(item['semester']!.split(' ').last),
                                subject: item['subject']!,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
