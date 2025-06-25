import 'package:flutter/material.dart';
import 'home_page.dart';

class NodeActionsWidget {
  static void showActionsMenu({
    required BuildContext context,
    required NodeItem node,
    required VoidCallback onStartConnection,
    required VoidCallback? onConnectHere,
    required VoidCallback onClearConnections,
    required VoidCallback onDeleteNode,
  }) {
    final locale = Localizations.localeOf(context);
    final isTr = locale.languageCode == 'tr';
    
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(isTr ? 'Node İşlemleri' : 'Node Actions'),
        children: [
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              onStartConnection();
            },
            child: Row(
              children: [
                const Icon(Icons.link, color: Colors.blue),
                const SizedBox(width: 8),
                Text(isTr ? 'Bağlantı Başlat' : 'Start Connection'),
              ],
            ),
          ),
          if (onConnectHere != null)
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                onConnectHere();
              },
              child: Row(
                children: [
                  const Icon(Icons.link_off, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(isTr ? 'Buraya Bağla' : 'Connect Here'),
                ],
              ),
            ),
          if (node.connections.isNotEmpty)
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                onClearConnections();
              },
              child: Row(
                children: [
                  const Icon(Icons.clear, color: Colors.orange),
                  const SizedBox(width: 8),
                  Text(isTr ? 'Bağlantıları Sil' : 'Delete Connections'),
                ],
              ),
            ),
          const Divider(),
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              onDeleteNode();
            },
            child: Row(
              children: [
                const Icon(Icons.delete, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  isTr ? 'Node\'u Sil' : 'Delete Node',
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static void showConnectionActionsMenu({
    required BuildContext context,
    required NodeItem node,
    required VoidCallback onStartConnection,
    required VoidCallback? onConnectHere,
    required VoidCallback onClearConnections,
  }) {
    final locale = Localizations.localeOf(context);
    final isTr = locale.languageCode == 'tr';
    
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(isTr ? 'Bağlantı İşlemleri' : 'Connection Actions'),
        children: [
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              onStartConnection();
            },
            child: Row(
              children: [
                const Icon(Icons.link, color: Colors.blue),
                const SizedBox(width: 8),
                Text(isTr ? 'Bağlantı Başlat' : 'Start Connection'),
              ],
            ),
          ),
          if (onConnectHere != null)
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                onConnectHere();
              },
              child: Row(
                children: [
                  const Icon(Icons.link_off, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(isTr ? 'Buraya Bağla' : 'Connect Here'),
                ],
              ),
            ),
          if (node.connections.isNotEmpty)
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                onClearConnections();
              },
              child: Row(
                children: [
                  const Icon(Icons.clear, color: Colors.orange),
                  const SizedBox(width: 8),
                  Text(isTr ? 'Bağlantıları Sil' : 'Delete Connections'),
                ],
              ),
            ),
        ],
      ),
    );
  }

  static void showEditDialog({
    required BuildContext context,
    required String currentTitle,
    required Function(String) onTitleChanged,
  }) {
    final titleController = TextEditingController(text: currentTitle);
    final locale = Localizations.localeOf(context);
    final isTr = locale.languageCode == 'tr';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isTr ? 'Node İsmini Değiştir' : 'Edit Node Name'),
        content: TextField(
          controller: titleController,
          decoration: InputDecoration(
            labelText: isTr ? 'Yeni İsim' : 'New Name',
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isTr ? 'İptal' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.trim().isNotEmpty) {
                onTitleChanged(titleController.text.trim());
                Navigator.pop(context);
              }
            },
            child: Text(isTr ? 'Kaydet' : 'Save'),
          ),
        ],
      ),
    );
  }

  static void showDeleteConfirmation({
    required BuildContext context,
    required String nodeName,
    required VoidCallback onConfirm,
  }) {
    final locale = Localizations.localeOf(context);
    final isTr = locale.languageCode == 'tr';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isTr ? 'Node\'u Sil' : 'Delete Node'),
        content: Text(
          isTr 
            ? '"$nodeName" adlı node\'u silmek istediğinizden emin misiniz?' 
            : 'Are you sure you want to delete the node "$nodeName"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isTr ? 'İptal' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(isTr ? 'Sil' : 'Delete'),
          ),
        ],
      ),
    );
  }
} 