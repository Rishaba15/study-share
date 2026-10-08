import 'package:flutter/material.dart';
import '../data/departments.dart';
import '../services/storage_service.dart';
import '../widgets/bottom_nav.dart';
import 'profile_page.dart';
import 'search_page.dart';
import 'upload_page.dart';
import 'ai_summarizer_page.dart';
import 'subject_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;
  String department = '';

  @override
  void initState() {
    super.initState();
    loadDepartment();
  }

  Future<void> loadDepartment() async {
    final value = await StorageService.getDepartment();
    if (!mounted) return;
    setState(() => department = value);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _HomeContent(department: department),
      SearchPage(department: department),
      UploadPage(department: department),
      const AiSummarizerPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: IndexedStack(index: selectedIndex, children: pages),
      bottomNavigationBar: BottomNav(
        currentIndex: selectedIndex,
        onTap: (index) => setState(() => selectedIndex = index),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  final String department;
  const _HomeContent({required this.department});

  @override
  Widget build(BuildContext context) {
    final titleDepartment = department.isEmpty ? 'Department' : department;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: const Color(0xFF0F1115),
            title: const Text('StudyShare', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: LinearGradient(
                    colors: [
                      Colors.blueAccent.withValues(alpha: .25),
                      Colors.blueAccent.withValues(alpha: .08),
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.blueAccent,
                      child: Icon(Icons.school, color: Colors.white),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Your Department', style: TextStyle(color: Colors.white70)),
                          const SizedBox(height: 3),
                          Text(
                            titleDepartment,
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
              child: Text(
                'Your 8 Semesters',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          if (department.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('Department not selected. Please complete your profile.'),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              sliver: SliverList.builder(
                itemCount: 8,
                itemBuilder: (context, index) {
                  final semester = index + 1;
                  final subjects = subjectsFor(department, semester);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ExpansionTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blueAccent.withValues(alpha: .15),
                        child: Text(
                          '$semester',
                          style: const TextStyle(color: Colors.blueAccent),
                        ),
                      ),
                      title: Text(
                        'Semester $semester',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text('${subjects.length} subjects'),
                      children: subjects
                          .map(
                            (subject) => ListTile(
                              leading: const Icon(
                                Icons.description_outlined,
                                color: Colors.blueAccent,
                              ),
                              title: Text(subject),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SubjectPage(
                                    department: department,
                                    semester: semester,
                                    subject: subject,
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
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
