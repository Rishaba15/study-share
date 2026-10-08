import 'package:flutter/material.dart';
import '../data/departments.dart';
import '../services/storage_service.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String name = '';
  String email = '';
  String department = '';

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final n = await StorageService.getName();
    final e = await StorageService.getEmail();
    final d = await StorageService.getDepartment();

    if (!mounted) return;
    setState(() {
      name = n;
      email = e;
      department = d;
    });
  }

  Future<void> logout() async {
    await StorageService.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  Future<void> changeDepartment() async {
    String? selected = department.isEmpty ? null : department;

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change Department'),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return DropdownButtonFormField<String>(
                initialValue: selected,
                decoration: const InputDecoration(labelText: 'Department'),
                items: departments
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (value) => setDialogState(() => selected = value),
              );
            },
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            FilledButton(
              onPressed: () => Navigator.pop(context, selected),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result == null || result == department) return;

    final password = await StorageService.getPassword();
    await StorageService.saveUser(
      name: name,
      email: email,
      password: password,
      department: result,
    );
    await loadProfile();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Department updated. Your subjects are now updated too.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayName = name.isEmpty ? 'Student' : name;
    final initial = displayName.trim().isEmpty ? 'S' : displayName.trim()[0].toUpperCase();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Profile', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 28),
          Center(
            child: CircleAvatar(
              radius: 48,
              backgroundColor: Colors.blueAccent,
              child: Text(
                initial,
                style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              displayName,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 4),
          Center(child: Text(email, style: const TextStyle(color: Colors.white70))),
          const SizedBox(height: 30),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text('Name'),
                  subtitle: Text(displayName),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.email_outlined),
                  title: const Text('Email'),
                  subtitle: Text(email),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.school_outlined),
                  title: const Text('Department'),
                  subtitle: Text(department.isEmpty ? 'Not selected' : department),
                  trailing: IconButton(
                    onPressed: changeDepartment,
                    icon: const Icon(Icons.edit_outlined),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: logout,
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
