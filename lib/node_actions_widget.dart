import 'package:flutter/material.dart';
import 'home_page.dart';

class NodeActionsWidget {
  static Future<void> _showCustomDialog({
    required BuildContext context,
    required String title,
    required Widget content,
    List<Widget>? actions,
  }) {
    return showDialog(
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
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 15),
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: content,
              ),
              if (actions != null && actions.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 15, 20, 20),
                  child: Row(
                    children: actions,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildDialogAction({
    required String text,
    required VoidCallback onPressed,
    bool isPrimary = false,
    Color? textColor,
    List<Color>? gradientColors,
  }) {
    return Expanded(
      child: Container(
        decoration: isPrimary
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: gradientColors ?? [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              )
            : null,
        child: TextButton(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          onPressed: onPressed,
          child: Text(
            text,
            style: TextStyle(
              color: textColor ?? (isPrimary ? Colors.white : Colors.grey[400]),
              fontSize: 16,
              fontWeight: isPrimary ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

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
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF2d2d2d),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
                child: Text(
                  isTr ? 'Node İşlemleri' : 'Node Actions',
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(color: Colors.grey, indent: 20, endIndent: 20),
              _buildMenuOption(
                context: context,
                icon: Icons.link_rounded,
                text: isTr ? 'Bağlantı Başlat' : 'Start Connection',
                color: const Color(0xFF6366F1),
                onTap: () {
                  Navigator.pop(context);
                  onStartConnection();
                },
              ),
              if (onConnectHere != null)
                _buildMenuOption(
                  context: context,
                  icon: Icons.link_off_rounded,
                  text: isTr ? 'Buraya Bağla' : 'Connect Here',
                  color: const Color(0xFF10B981),
                  onTap: () {
                    Navigator.pop(context);
                    onConnectHere();
                  },
                ),
              if (node.connections.isNotEmpty)
                _buildMenuOption(
                  context: context,
                  icon: Icons.clear_rounded,
                  text: isTr ? 'Bağlantıları Sil' : 'Delete Connections',
                  color: const Color(0xFFF59E0B),
                  onTap: () {
                    Navigator.pop(context);
                    onClearConnections();
                  },
                ),
              const Divider(color: Colors.grey, indent: 20, endIndent: 20),
              _buildMenuOption(
                context: context,
                icon: Icons.delete_rounded,
                text: isTr ? 'Node\'u Sil' : 'Delete Node',
                color: const Color(0xFFEF4444),
                onTap: () {
                  Navigator.pop(context);
                  onDeleteNode();
                },
              ),
            ],
          ),
        ),
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
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF2d2d2d),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
                child: Text(
                  isTr ? 'Bağlantı İşlemleri' : 'Connection Actions',
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(color: Colors.grey, indent: 20, endIndent: 20),
              _buildMenuOption(
                context: context,
                icon: Icons.link_rounded,
                text: isTr ? 'Bağlantı Başlat' : 'Start Connection',
                color: const Color(0xFF6366F1),
                onTap: () {
                  Navigator.pop(context);
                  onStartConnection();
                },
              ),
              if (onConnectHere != null)
                _buildMenuOption(
                  context: context,
                  icon: Icons.link_off_rounded,
                  text: isTr ? 'Buraya Bağla' : 'Connect Here',
                  color: const Color(0xFF10B981),
                  onTap: () {
                    Navigator.pop(context);
                    onConnectHere();
                  },
                ),
              if (node.connections.isNotEmpty)
                _buildMenuOption(
                  context: context,
                  icon: Icons.clear_rounded,
                  text: isTr ? 'Bağlantıları Temizle' : 'Clear Connections',
                  color: const Color(0xFFF59E0B),
                  onTap: () {
                    Navigator.pop(context);
                    onClearConnections();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildMenuOption({
    required BuildContext context,
    required IconData icon,
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 16),
            Text(text, style: const TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
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
    
    _showCustomDialog(
      context: context,
      title: isTr ? 'Node İsmini Değiştir' : 'Edit Node Name',
      content: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            colors: [Colors.grey[800]!, Colors.grey[700]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: TextField(
          controller: titleController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: isTr ? "Yeni İsim" : "New Name",
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
              onTitleChanged(value.trim());
              Navigator.pop(context);
            }
          },
        ),
      ),
      actions: [
        _buildDialogAction(
          text: isTr ? 'İptal' : 'Cancel',
          onPressed: () => Navigator.pop(context),
        ),
        const SizedBox(width: 12),
        _buildDialogAction(
          text: isTr ? 'Kaydet' : 'Save',
          isPrimary: true,
          onPressed: () {
            if (titleController.text.trim().isNotEmpty) {
              onTitleChanged(titleController.text.trim());
              Navigator.pop(context);
            }
          },
        ),
      ],
    );
  }

  static void showDeleteConfirmation({
    required BuildContext context,
    required String nodeName,
    required VoidCallback onConfirm,
  }) {
    final locale = Localizations.localeOf(context);
    final isTr = locale.languageCode == 'tr';
    
    _showCustomDialog(
      context: context,
      title: isTr ? 'Node\'u Sil' : 'Delete Node',
      content: Text(
        isTr 
          ? '"$nodeName" adlı node\'u ve tüm bağlantılarını silmek istediğinizden emin misiniz?' 
          : 'Are you sure you want to delete the node "$nodeName" and all its connections?',
        style: TextStyle(color: Colors.grey[300], fontSize: 16),
        textAlign: TextAlign.center,
      ),
      actions: [
        _buildDialogAction(
          text: isTr ? 'İptal' : 'Cancel',
          onPressed: () => Navigator.pop(context),
        ),
        const SizedBox(width: 12),
        _buildDialogAction(
          text: isTr ? 'Sil' : 'Delete',
          isPrimary: true,
          gradientColors: [const Color(0xFFF87171), const Color(0xFFDC2626)],
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
        ),
      ],
    );
  }
} 