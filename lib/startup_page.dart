import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import 'package:ways/home_page.dart';
import 'package:ways/project_model.dart';
import 'package:ways/saved_projects_page.dart';

class StartupPage extends StatefulWidget {
  const StartupPage({super.key});

  @override
  State<StartupPage> createState() => _StartupPageState();
}

class _StartupPageState extends State<StartupPage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _createNewProject(BuildContext context) {
    final projectNameController = TextEditingController();
    final locale = Localizations.localeOf(context);
    final isTr = locale.languageCode == 'tr';
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title Section
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 15),
                  child: Text(
                    isTr ? 'Yeni Proje' : 'New Project',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ),
                
                // Content Section
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        gradient: LinearGradient(
                          colors: [Colors.grey[800]!, Colors.grey[700]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: TextField(
                        controller: projectNameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: isTr ? "Proje Adı" : "Project Name",
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.transparent,
                          contentPadding: const EdgeInsets.all(16),
                          isDense: true,
                        ),
                        autofocus: true,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (value) {
                          if (value.trim().isNotEmpty) {
                            final projectsBox = Hive.box<Project>('projects');
                            final newProject = Project(
                              id: const Uuid().v4(),
                              name: value.trim(),
                            );
                            projectsBox.put(newProject.id, newProject);
                            Navigator.pop(context);
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
                    ),
                  ),
                ),
                
                // Actions Section
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 15, 20, 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            isTr ? 'İptal' : 'Cancel',
                            style: TextStyle(color: Colors.grey[400], fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: TextButton(
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () {
                              final projectName = projectNameController.text.trim();
                              if (projectName.isNotEmpty) {
                                final projectsBox = Hive.box<Project>('projects');
                                final newProject = Project(
                                  id: const Uuid().v4(),
                                  name: projectName,
                                );
                                projectsBox.put(newProject.id, newProject);
                                Navigator.pop(context);
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
                            child: Text(
                              isTr ? 'Oluştur' : 'Create',
                              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernButton({
    required IconData icon,
    required String text,
    required VoidCallback onPressed,
    required List<Color> gradientColors,
    required Color shadowColor,
  }) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Container(
              width: double.infinity,
              height: 60,
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: shadowColor.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: onPressed,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          icon,
                          color: Colors.white,
                          size: 28,
                        ),
                        const SizedBox(width: 15),
                        Text(
                          text,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final isTr = locale.languageCode == 'tr';
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1a1a1a),
              Color(0xFF2d2d2d),
              Color(0xFF404040),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header Section
              Expanded(
                flex: 2,
                child: Container(
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6366F1).withOpacity(0.3),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.account_tree_rounded,
                            size: 60,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                          ).createShader(bounds),
                          child: const Text(
                            'Ways',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Text(
                          isTr ? 'Düşüncelerinizi görselleştirin' : 'Visualize your thoughts',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[400],
                            fontWeight: FontWeight.w300,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Buttons Section
              Flexible(
                child: ClipRect(
                  child: Container(
                    constraints: BoxConstraints(
                      minHeight: 155,
                      maxHeight: MediaQuery.of(context).size.height * 0.3,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildModernButton(
                          icon: Icons.add_circle_outline_rounded,
                          text: isTr ? 'Yeni Proje Oluştur' : 'Create New Project',
                          onPressed: () => _createNewProject(context),
                          gradientColors: const [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                          shadowColor: const Color(0xFF6366F1),
                        ),
                        _buildModernButton(
                          icon: Icons.folder_open_rounded,
                          text: isTr ? 'Kaydedilenlerden Aç' : 'Open from Saved',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const SavedProjectsPage()),
                            );
                          },
                          gradientColors: const [Color(0xFF059669), Color(0xFF10B981)],
                          shadowColor: const Color(0xFF059669),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              // Footer
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Text(
                    isTr ? 'İdealeri gerçeğe dönüştürün' : 'Turn ideas into reality',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 