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
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.9,
            maxHeight: MediaQuery.of(context).size.height * 0.7,
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
              // Title
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 15),
                child: Text(
                  title ?? (isTr ? 'Renk Seç' : 'Choose Color'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
              ),
              // Color Grid
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ColorPickerWidget(
                    currentColor: currentColor,
                    onColorSelected: (color) {
                      onColorSelected(color);
                      Navigator.pop(dialogContext);
                    },
                  ),
                ),
              ),
              // Cancel Button
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 15, 20, 20),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () => Navigator.pop(dialogContext),
                        child: Text(
                          isTr ? 'İptal' : 'Cancel',
                          style: TextStyle(color: Colors.grey[400], fontSize: 16),
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

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        children: _availableColors.map((color) => GestureDetector(
          onTap: () => onColorSelected(color),
          child: Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: currentColor.value == color.value ? Colors.white : Colors.transparent,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: currentColor.value == color.value
                ? Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  )
                : null,
          ),
        )).toList(),
      ),
    );
  }
} 