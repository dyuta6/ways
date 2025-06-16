import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ways/home_page.dart';
import 'package:ways/project_model.dart';

class SavedProjectsPage extends StatefulWidget {
  const SavedProjectsPage({super.key});

  @override
  State<SavedProjectsPage> createState() => _SavedProjectsPageState();
}

class _SavedProjectsPageState extends State<SavedProjectsPage> {
  late final Box<Project> _projectsBox;

  @override
  void initState() {
    super.initState();
    _projectsBox = Hive.box<Project>('projects');
  }

  void _deleteProject(Project project) {
    final locale = Localizations.localeOf(context);
    final isTr = locale.languageCode == 'tr';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isTr ? 'Projeyi Sil' : 'Delete Project'),
        content: Text(isTr
            ? '"${project.name}" projesini silmek istediğinizden emin misiniz? Bu, içindeki tüm düğümleri de silecektir.'
            : 'Are you sure you want to delete "${project.name}"? This will also delete all nodes inside it.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isTr ? 'İptal' : 'Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // Delete the node box associated with the project
              await Hive.deleteBoxFromDisk('nodes_${project.id}');
              // Delete the project itself
              await project.delete();
              Navigator.pop(context); // Close dialog
              setState(() {}); // Rebuild to reflect deletion
            },
            child: Text(isTr ? 'Sil' : 'Delete', style: const TextStyle(color: Colors.red)),
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
        title: Text(isTr ? 'Kaydedilmiş Projeler' : 'Saved Projects'),
        backgroundColor: Colors.grey[800],
      ),
      body: ValueListenableBuilder(
        valueListenable: _projectsBox.listenable(),
        builder: (context, Box<Project> box, _) {
          final projects = box.values.toList();
          if (projects.isEmpty) {
            return Center(
              child: Text(isTr ? 'Henüz kaydedilmiş proje yok.' : 'No saved projects yet.'),
            );
          }
          return ListView.builder(
            itemCount: projects.length,
            itemBuilder: (context, index) {
              final project = projects[index];
              return ListTile(
                title: Text(project.name),
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyHomePage(
                        projectId: project.id,
                        projectName: project.name,
                      ),
                    ),
                    (route) => route.isFirst,
                  );
                },
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: () => _deleteProject(project),
                ),
              );
            },
          );
        },
      ),
    );
  }
} 