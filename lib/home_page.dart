import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vector_math;
import 'package:hive/hive.dart';
import 'dart:typed_data';
import 'color_picker_widget.dart';
import 'node_actions_widget.dart';
import 'services/background_image_service.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
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
  Uint8List? _backgroundImage;

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
        colorValue: const Color(0xFF6366F1).value,
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

    final settingsBox = await Hive.openBox('project_settings_${widget.projectId}');
    final bgImage = settingsBox.get('background_image');
    if (bgImage != null && mounted) {
      setState(() {
        _backgroundImage = bgImage;
      });
    }
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
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF6366F1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );

    final settingsBox = await Hive.openBox('project_settings_${widget.projectId}');
    if (_backgroundImage != null) {
      await settingsBox.put('background_image', _backgroundImage);
    } else {
      await settingsBox.delete('background_image');
    }
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

  void _addNode(String title) {
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
        title: title,
        position: Offset(transformedPoint.x, transformedPoint.y),
        colorValue: const Color(0xFF6366F1).value,
      ));
    });
  }

  Future<void> _pickBackgroundImage() async {
    final bytes = await BackgroundImageService.pickImageFromGallery();
    if (bytes != null) {
      setState(() {
        _backgroundImage = bytes;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF2d2d2d),
                Color(0xFF404040),
              ],
            ),
          ),
          child: AppBar(
            title: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              ).createShader(bounds),
              child: Text(
                widget.projectName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: IconButton(
                  icon: const Icon(Icons.save, color: Colors.white),
                  onPressed: _onSavePressed,
                  tooltip: 'Save Layout',
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6366F1).withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            _titleController.text = '';
            final locale = Localizations.localeOf(context);
            final isTr = locale.languageCode == 'tr';
            _showManualCreateNodeDialog(isTr);
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, size: 30, color: Colors.white),
        ),
      ),
      body: Stack(
        children: [
          InteractiveViewer(
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
                    image: _backgroundImage != null
                        ? DecorationImage(
                            image: MemoryImage(_backgroundImage!),
                            fit: BoxFit.contain,
                          )
                        : null,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF1a1a1a),
                        Color(0xFF2d2d2d),
                        Color(0xFF404040),
                      ],
                    ),
                    border: Border.all(
                      color: const Color(0xFF6366F1).withOpacity(0.3),
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
          Positioned(
            left: 16,
            bottom: 16,
            child: GestureDetector(
              onTap: _pickBackgroundImage,
              child: Container(
                width: 56, // Standart FAB boyutu
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.image, color: Colors.white, size: 28),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNode(NodeItem node) {
    final Color darkerColor = Color.lerp(node.color, Colors.black, 0.4)!;
    return Container(
      width: 150,
      height: 100,
      child: Stack(
        children: [
          Container(
            width: 150,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  node.color,
                  darkerColor,
                ],
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Container(
              margin: const EdgeInsets.all(8),
              child: Center(
                child: Text(
                  node.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black54,
                        offset: Offset(1, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          // Bağlantı ikonu
          Positioned(
            top: 6,
            right: 6,
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
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.9),
                      Colors.white.withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.link_rounded,
                  size: 16,
                  color: Color(0xFF6366F1),
                ),
              ),
            ),
          ),
          // İsim değiştirme ikonu
          Positioned(
            top: 6,
            left: 6,
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
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.9),
                      Colors.white.withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.edit_rounded,
                  size: 16,
                  color: Color(0xFF059669),
                ),
              ),
            ),
          ),
          // Silme ikonu
          Positioned(
            bottom: 6,
            left: 6,
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
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.9),
                      Colors.white.withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.delete_rounded,
                  size: 16,
                  color: Color(0xFFDC2626),
                ),
              ),
            ),
          ),
          // Renk değiştirme ikonu
          Positioned(
            bottom: 6,
            right: 6,
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
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.9),
                      Colors.white.withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.palette_rounded,
                  size: 16,
                  color: Color(0xFF8B5CF6),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showManualCreateNodeDialog(bool isTr) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF2d2d2d),
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
                  isTr ? 'Yeni Node' : 'New Node',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ),
              
              // Content Section
              Padding(
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
                    controller: _titleController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: isTr ? "Node İsmi" : "Node Name",
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
                        _addNode(value.trim());
                        Navigator.pop(context);
                      }
                    },
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
                            final nodeTitle = _titleController.text.trim();
                            if (nodeTitle.isNotEmpty) {
                              _addNode(nodeTitle);
                              Navigator.pop(context);
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
    );
  }

  Future<bool> _isUserSubscribed() async {
    try {
      // Platform kontrolü - sadece iOS'ta subscription kontrolü yap
      if (Theme.of(context).platform == TargetPlatform.iOS) {
        final purchaserInfo = await Purchases.getCustomerInfo();
        return purchaserInfo.entitlements.active.containsKey('premium');
      } else {
        // Android'de şimdilik false döndür (test için)
        print('Android platform - subscription kontrolü devre dışı');
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  void _onSavePressed() async {
    final isSubscribed = await _isUserSubscribed();
    if (!isSubscribed) {
      // Abone değilse, abone olma ekranına yönlendir
      _showSubscriptionDialog();
      return;
    }
    await _saveNodes();
  }

  void _showSubscriptionDialog() {
    final locale = Localizations.localeOf(context);
    final isTurkish = locale.languageCode == 'tr';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2d2d2d),
        title: Text(
          isTurkish ? 'Abone Olun' : 'Subscribe',
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          isTurkish 
            ? 'Bu özellik Premium abonesi için açık. Abone olmak ister misiniz?'
            : 'This feature is available for Premium subscribers. Would you like to subscribe?',
          style: TextStyle(color: Colors.grey[400]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              isTurkish ? 'İptal' : 'Cancel',
              style: TextStyle(color: Colors.grey[400], fontSize: 16),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _purchaseSubscription();
            },
            child: Text(
              isTurkish ? 'Abone Ol' : 'Subscribe',
              style: const TextStyle(color: Color(0xFF6366F1), fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _debugOfferings() async {
    try {
      // Platform kontrolü - sadece iOS'ta debug yap
      if (Theme.of(context).platform == TargetPlatform.iOS) {
        final offerings = await Purchases.getOfferings();
        print('=== REVENUECAT DEBUG (iOS) ===');
        print('All offerings: ${offerings.all.keys}');
        
        if (offerings.current != null) {
          print('Current offering: ${offerings.current!.identifier}');
          print('Available packages: ${offerings.current!.availablePackages.length}');
          
          for (var package in offerings.current!.availablePackages) {
            print('Package: ${package.identifier}');
            print('  - Title: ${package.storeProduct.title}');
            print('  - Description: ${package.storeProduct.description}');
            print('  - Price: ${package.storeProduct.priceString}');
            print('  - Product ID: ${package.storeProduct.identifier}');
          }
        } else {
          print('No current offering available');
        }
        
        // Customer info kontrolü
        final customerInfo = await Purchases.getCustomerInfo();
        print('Customer entitlements: ${customerInfo.entitlements.active.keys}');
        
        final locale = Localizations.localeOf(context);
        final debugMessage = locale.languageCode == 'tr' 
            ? 'iOS Debug bilgileri console\'da görüntülendi'
            : 'iOS Debug information displayed in console';
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              debugMessage,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.blue,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      } else {
        // Android'de platform bilgisi göster
        print('=== PLATFORM DEBUG ===');
        print('Platform: Android');
        print('Subscription özelliği şu anda sadece iOS\'ta aktif');
        
        final locale = Localizations.localeOf(context);
        final platformMessage = locale.languageCode == 'tr' 
            ? 'Subscription özelliği sadece iOS\'ta aktif'
            : 'Subscription feature is only available on iOS';
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              platformMessage,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      print('Debug error: $e');
    }
  }

  Future<void> _purchaseSubscription() async {
    try {
      // Platform kontrolü - sadece iOS'ta satın alma yap
      if (Theme.of(context).platform == TargetPlatform.iOS) {
        // Debug: Mevcut offerings'leri kontrol et
        final offerings = await Purchases.getOfferings();
        print('Available offerings: ${offerings.all.keys}');
        
        if (offerings.current != null) {
          print('Current offering: ${offerings.current!.identifier}');
          print('Available packages: ${offerings.current!.availablePackages.length}');
          
          for (var package in offerings.current!.availablePackages) {
            print('Package: ${package.identifier} - ${package.storeProduct.title} - ${package.storeProduct.priceString}');
          }
        } else {
          print('No current offering available');
        }
        
        if (offerings.current != null && offerings.current!.availablePackages.isNotEmpty) {
          final package = offerings.current!.availablePackages.first;
          
          // Satın alma işlemini başlat
          final purchaserInfo = await Purchases.purchasePackage(package);
          
          if (purchaserInfo.entitlements.active.containsKey('premium')) {
            // Başarılı satın alma
            final locale = Localizations.localeOf(context);
            final successMessage = locale.languageCode == 'tr' 
                ? 'Premium aboneliğiniz aktif!' 
                : 'Your Premium subscription is active!';
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  successMessage,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.all(16),
              ),
            );
          }
        } else {
          // Ürün bulunamadı - daha detaylı hata mesajı
          final locale = Localizations.localeOf(context);
          String errorMessage = locale.languageCode == 'tr' ? 'Ürün bulunamadı.' : 'Product not found.';
          if (offerings.current == null) {
            errorMessage += locale.languageCode == 'tr' ? ' Current offering yok.' : ' Current offering not available.';
          } else if (offerings.current!.availablePackages.isEmpty) {
            errorMessage += locale.languageCode == 'tr' ? ' Available packages yok.' : ' Available packages not found.';
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                errorMessage,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      } else {
        // Android'de bilgi mesajı göster
        final locale = Localizations.localeOf(context);
        final androidMessage = locale.languageCode == 'tr' 
            ? 'Subscription özelliği şu anda sadece iOS\'ta mevcut'
            : 'Subscription feature is currently only available on iOS';
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              androidMessage,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      // Hata durumu
      print('Purchase error: $e');
      final locale = Localizations.localeOf(context);
      final errorMessage = locale.languageCode == 'tr' 
          ? 'Satın alma işlemi başarısız: ${e.toString()}'
          : 'Purchase failed: ${e.toString()}';
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            errorMessage,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
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
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (final node in nodes) {
      for (final connectionId in node.connections) {
        final connectedNode = nodes.firstWhere((n) => n.id == connectionId);
        final start = node.position + const Offset(150, 50);
        final end = connectedNode.position + const Offset(0, 50);

        // Gradient effect for connection lines
        final gradient = LinearGradient(
          colors: [
            const Color(0xFF6366F1).withOpacity(0.8),
            const Color(0xFF8B5CF6).withOpacity(0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );

        paint.shader = gradient.createShader(Rect.fromPoints(start, end));
        
        // Draw connection with slight curve for better aesthetics
        final controlPoint1 = Offset(start.dx + (end.dx - start.dx) * 0.3, start.dy);
        final controlPoint2 = Offset(start.dx + (end.dx - start.dx) * 0.7, end.dy);
        
        final path = Path()
          ..moveTo(start.dx, start.dy)
          ..cubicTo(controlPoint1.dx, controlPoint1.dy, controlPoint2.dx, controlPoint2.dy, end.dx, end.dy);
        
        canvas.drawPath(path, paint);
        
        // Draw connection points
        final pointPaint = Paint()
          ..color = const Color(0xFF6366F1)
          ..style = PaintingStyle.fill;
        
        canvas.drawCircle(start, 4, pointPaint);
        canvas.drawCircle(end, 4, pointPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}