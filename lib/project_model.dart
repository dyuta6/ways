import 'package:hive/hive.dart';

part 'project_model.g.dart';

@HiveType(typeId: 2)
class Project extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  Project({required this.id, required this.name});
} 