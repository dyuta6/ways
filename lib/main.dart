import 'package:flutter/material.dart';
import 'package:ways/home_page.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ways/project_model.dart';
import 'package:ways/startup_page.dart';
import 'package:ways/type_adapters.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDir.path);
  Hive.registerAdapter(NodeItemAdapter());
  Hive.registerAdapter(OffsetAdapter());
  Hive.registerAdapter(ProjectAdapter());
  await Hive.openBox<Project>('projects');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ways',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
      ),
      home: const StartupPage(),
    );
  }
}

