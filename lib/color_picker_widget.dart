import 'package:flutter/material.dart';

class ColorPickerWidget extends StatelessWidget {
  final Color currentColor;
  final Function(Color) onColorSelected;
  final String? title;

  const ColorPickerWidget({
    super.key,
    required this.currentColor,
    required this.onColorSelected,
    this.title,
  });

  static final List<Color> _availableColors = [
    // Koyu renkler (yazıların görünürlüğü için)
    Colors.blue[700]!,
    Colors.red[700]!,
    Colors.green[700]!,
    Colors.purple[700]!,
    Colors.orange[700]!,
    Colors.teal[700]!,
    Colors.indigo[700]!,
    Colors.pink[700]!,
    Colors.brown[700]!,
    Colors.blueGrey[700]!,
    Colors.deepOrange[700]!,
    Colors.cyan[700]!,
    Colors.lime[800]!,
    Colors.amber[800]!,
    Colors.deepPurple[700]!,
    Colors.grey[700]!,
  ];

  static void show({
    required BuildContext context,
    required Color currentColor,
    required Function(Color) onColorSelected,
    String? title,
  }) {
    final locale = Localizations.localeOf(context);
    final isTr = locale.languageCode == 'tr';
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title ?? (isTr ? 'Renk Seç' : 'Choose Color')),
        content: ColorPickerWidget(
          currentColor: currentColor,
          onColorSelected: (color) {
            onColorSelected(color);
            Navigator.pop(dialogContext);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(isTr ? 'İptal' : 'Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 200,
      child: GridView.count(
        crossAxisCount: 4,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        children: _availableColors.map((color) => GestureDetector(
          onTap: () => onColorSelected(color),
          child: Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: currentColor.value == color.value ? Colors.white : Colors.transparent,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: currentColor.value == color.value
                ? const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 24,
                  )
                : null,
          ),
        )).toList(),
      ),
    );
  }
} 