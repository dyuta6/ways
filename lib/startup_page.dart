import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:ways/home_page.dart';
import 'package:ways/project_model.dart';
import 'package:ways/saved_projects_page.dart';

class StartupPage extends StatelessWidget {
  const StartupPage({super.key});

  void _createNewProject(BuildContext context) {
    final projectNameController = TextEditingController();
    final locale = Localizations.localeOf(context);
    final isTr = locale.languageCode == 'tr';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isTr ? 'Yeni Proje' : 'New Project'),
        content: TextField(
          controller: projectNameController,
          decoration: InputDecoration(hintText: isTr ? "Proje Adı" : "Project Name"),
          autofocus: true,
        ),
        actions: [
          TextButton(
            child: Text(isTr ? 'İptal' : 'Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text(isTr ? 'Oluştur' : 'Create'),
            onPressed: () {
              final projectName = projectNameController.text.trim();
              if (projectName.isNotEmpty) {
                final projectsBox = Hive.box<Project>('projects');
                final newProject = Project(
                  id: const Uuid().v4(),
                  name: projectName,
                );
                projectsBox.put(newProject.id, newProject);
                Navigator.pop(context); // Close dialog
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyHomePage(
                      projectId: newProject.id,
                      projectName: newProject.name,
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final isTr = locale.languageCode == 'tr';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ways'),
        backgroundColor: Colors.grey[800],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.add_circle_outline),
              label: Text(isTr ? 'Yeni Proje Oluştur' : 'Create New Project'),
              onPressed: () => _createNewProject(context),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.folder_open),
              label: Text(isTr ? 'Kaydedilenlerden Aç' : 'Open from Saved'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SavedProjectsPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 