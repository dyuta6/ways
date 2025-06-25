import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vector_math;
import 'package:hive/hive.dart';
import 'color_picker_widget.dart';
import 'node_actions_widget.dart';

part 'home_page.g.dart';

class MyHomePage extends StatefulWidget {
  final String projectId;
  final String projectName;
  const MyHomePage({
    super.key,
    required this.projectId,
    required this.projectName,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<NodeItem> nodes = [];
  Offset? dragStartPosition;
  NodeItem? selectedNode;
  NodeItem? connectionStartNode;
  final TransformationController _transformationController = TransformationController();
  final TextEditingController _titleController = TextEditingController();
  late final String _nodeBoxName;

  @override
  void initState() {
    super.initState();
    _nodeBoxName = 'nodes_${widget.projectId}';
    _loadNodes();
  }

  Future<void> _loadNodes() async {
    final box = await Hive.openBox<NodeItem>(_nodeBoxName);
    var loadedNodes = box.values.toList();
    if (loadedNodes.isEmpty) {
      // Add initial node if the box is empty
      loadedNodes.add(NodeItem(
        id: '1',
        title: 'You',
        position: const Offset(3000, 3000), // Center of 6000x6000 container
        colorValue: Colors.blue.value,
      ));
    }

    if (!mounted) return;

    setState(() {
      nodes = loadedNodes;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && nodes.isNotEmpty) {
        _centerView();
      }
    });
  }

  Future<void> _saveNodes() async {
    final box = await Hive.openBox<NodeItem>(_nodeBoxName);
    await box.clear();
    for (var node in nodes) {
      box.put(node.id, node);
    }
    if (!mounted) return;
    final locale = Localizations.localeOf(context);
    final message =
        locale.languageCode == 'tr' ? 'Node\'lar kaydedildi!' : 'Nodes saved!';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _centerView() {
    if (!mounted || nodes.isEmpty) return;

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final nodeToCenterOn = nodes.first;
    const nodeWidth = 150.0;
    const nodeHeight = 100.0;

    final targetX = nodeToCenterOn.position.dx + nodeWidth / 2;
    final targetY = nodeToCenterOn.position.dy + nodeHeight / 2;

    _transformationController.value = vector_math.Matrix4.identity()
      ..translate(-targetX + screenWidth / 2, -targetY + screenHeight / 2);
  }

  @override
  void dispose() {
    _transformationController.dispose();
    if (Hive.isBoxOpen(_nodeBoxName)) {
      Hive.box<NodeItem>(_nodeBoxName).close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text(widget.projectName),
        backgroundColor: Colors.grey[800],
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Colors.white),
            onPressed: _saveNodes,
            tooltip: 'Save Layout',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _titleController.text = '';
          final locale = Localizations.localeOf(context);
          final isTr = locale.languageCode == 'tr';
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(isTr ? 'Yeni Node' : 'New Node'),
              content: TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: isTr ? 'Node İsmi' : 'Node Name',
                ),
                autofocus: true,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(isTr ? 'İptal' : 'Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    final screenWidth = MediaQuery.of(context).size.width;
                    final screenHeight = MediaQuery.of(context).size.height;
                    final matrix = _transformationController.value;
                    
                    final vector = vector_math.Vector3(screenWidth / 2, screenHeight / 2, 0);
                    final invertedMatrix = matrix.clone()..invert();
                    final transformedPoint = invertedMatrix.transform3(vector);
                    
                    setState(() {
                      final nodeId = DateTime.now().millisecondsSinceEpoch.toString();
                      nodes.add(NodeItem(
                        id: nodeId,
                        title: _titleController.text.isNotEmpty ? _titleController.text : 'New Node',
                        position: Offset(transformedPoint.x, transformedPoint.y),
                        colorValue: Colors.blue.value,
                      ));
                    });
                    Navigator.pop(context);
                  },
                  child: Text(isTr ? 'Oluştur' : 'Create'),
                ),
              ],
            ),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, size: 30,color: Colors.white),
      ),
      body: InteractiveViewer(
        transformationController: _transformationController,
        constrained: false,
        panEnabled: true,
        scaleEnabled: true,
        boundaryMargin: const EdgeInsets.all(double.infinity),
        minScale: 0.1,
        maxScale: 5.0,
        child: Stack(
          children: [
            Container(
              width: 6000,
              height: 6000,
              decoration: BoxDecoration(
                color: Colors.grey[900],
                border: Border.all(
                  color: Colors.red,
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            CustomPaint(
              painter: ConnectionPainter(nodes: nodes),
              size: const Size(3000, 3000),
            ),
            ...nodes.map((node) => Positioned(
              left: node.position.dx,
              top: node.position.dy,
              child: GestureDetector(
                onPanStart: (details) {
                  setState(() {
                    selectedNode = node;
                    final renderBox = context.findRenderObject() as RenderBox;
                    final localPosition = renderBox.globalToLocal(details.globalPosition);
                    dragStartPosition = localPosition - node.position;
                  });
                },
                onPanUpdate: (details) {
                  if (selectedNode == node) {
                    setState(() {
                      final renderBox = context.findRenderObject() as RenderBox;
                      final localPosition = renderBox.globalToLocal(details.globalPosition);
                      node.position = localPosition - dragStartPosition!;
                    });
                  }
                },
                onPanEnd: (_) {
                  setState(() {
                    if (selectedNode == node) {
                      selectedNode = null;
                      dragStartPosition = null;
                    }
                  });
                },
                onLongPress: () {
                  NodeActionsWidget.showActionsMenu(
                    context: context,
                    node: node,
                    onStartConnection: () {
                            setState(() {
                              connectionStartNode = node;
                            });
                          },
                    onConnectHere: (connectionStartNode != null && connectionStartNode != node) 
                      ? () {
                              setState(() {
                                if (!connectionStartNode!.connections.contains(node.id)) {
                                  connectionStartNode!.connections.add(node.id);
                                }
                                connectionStartNode = null;
                              });
                        }
                      : null,
                    onClearConnections: () {
                              setState(() {
                                node.connections.clear();
                                for (var otherNode in nodes) {
                                  otherNode.connections.remove(node.id);
                                }
                              });
                    },
                    onDeleteNode: () {
                      NodeActionsWidget.showDeleteConfirmation(
                              context: context,
                        nodeName: node.title,
                        onConfirm: () {
                                      setState(() {
                                        // Önce bu node'a olan tüm bağlantıları sil
                                        for (var otherNode in nodes) {
                                          otherNode.connections.remove(node.id);
                                        }
                                        // Sonra node'u listeden kaldır
                                        nodes.remove(node);
                                      });
                                    },
                            );
                          },
                  );
                },
                child: _buildNode(node),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildNode(NodeItem node) {
    return Container(
      width: 150,
      height: 100,
      child: Stack(
        children: [
          Container(
            width: 150,
            height: 100,
            decoration: BoxDecoration(
              color: node.color,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Text(
                node.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          // Bağlantı ikonu
          Positioned(
            top: 5,
            right: 5,
            child: GestureDetector(
              onTap: () {
                NodeActionsWidget.showConnectionActionsMenu(
                  context: context,
                  node: node,
                  onStartConnection: () {
                          setState(() {
                            connectionStartNode = node;
                          });
                        },
                  onConnectHere: (connectionStartNode != null && connectionStartNode != node) 
                    ? () {
                            setState(() {
                              if (!connectionStartNode!.connections.contains(node.id)) {
                                connectionStartNode!.connections.add(node.id);
                              }
                              connectionStartNode = null;
                            });
                      }
                    : null,
                  onClearConnections: () {
                            setState(() {
                              node.connections.clear();
                              for (var otherNode in nodes) {
                                otherNode.connections.remove(node.id);
                              }
                            });
                          },
                );
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.link,
                  size: 20,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
          // İsim değiştirme ikonu
          Positioned(
            top: 5,
            left: 5,
            child: GestureDetector(
              onTap: () {
                NodeActionsWidget.showEditDialog(
                  context: context,
                  currentTitle: node.title,
                  onTitleChanged: (newTitle) {
                          setState(() {
                      node.title = newTitle;
                          });
                        },
                );
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.edit,
                  size: 20,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
          // Silme ikonu
          Positioned(
            bottom: 5,
            left: 5,
            child: GestureDetector(
              onTap: () {
                NodeActionsWidget.showDeleteConfirmation(
                  context: context,
                  nodeName: node.title,
                  onConfirm: () {
                          setState(() {
                            // Önce bu node'a olan tüm bağlantıları sil
                            for (var otherNode in nodes) {
                              otherNode.connections.remove(node.id);
                            }
                            // Sonra node'u listeden kaldır
                            nodes.remove(node);
                          });
                        },
                );
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.delete,
                  size: 20,
                  color: Colors.red,
                ),
              ),
            ),
          ),
          // Renk değiştirme ikonu
          Positioned(
            bottom: 5,
            right: 5,
            child: GestureDetector(
              onTap: () {
                ColorPickerWidget.show(
                  context: context,
                  currentColor: node.color,
                  onColorSelected: (color) {
                    setState(() {
                      // Node'un colorValue'sunu güncelle
                      final nodeIndex = nodes.indexOf(node);
                      if (nodeIndex != -1) {
                        nodes[nodeIndex] = NodeItem(
                          id: node.id,
                          title: node.title,
                          position: node.position,
                          colorValue: color.value,
                        )..connections = node.connections;
                      }
                    });
                  },
                );
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.palette,
                  size: 20,
                  color: Colors.purple,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

@HiveType(typeId: 0)
class NodeItem extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  Offset position;

  @HiveField(3)
  final int colorValue;

  @HiveField(4)
  List<String> connections = [];

  NodeItem({
    required this.id,
    String? title,
    required this.position,
    required this.colorValue,
  }) : title = title ?? 'Node $id';
  
  Color get color => Color(colorValue);
}

class ConnectionPainter extends CustomPainter {
  final List<NodeItem> nodes;

  ConnectionPainter({required this.nodes});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (final node in nodes) {
      for (final connectionId in node.connections) {
        final connectedNode = nodes.firstWhere((n) => n.id == connectionId);
        final start = node.position + const Offset(150, 50);
        final end = connectedNode.position + const Offset(0, 50);

        canvas.drawLine(start, end, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}