import 'package:flutter/material.dart';

class StorageSelectionDialog extends StatefulWidget {
  final List<String> storagePaths;
  final List<String> initiallySelected;

  const StorageSelectionDialog({
    super.key,
    required this.storagePaths,
    required this.initiallySelected,
  });

  @override
  State<StorageSelectionDialog> createState() => _StorageSelectionDialogState();
}

class _StorageSelectionDialogState extends State<StorageSelectionDialog> {
  late Set<String> selectedPaths;

  @override
  void initState() {
    super.initState();
    selectedPaths = Set.from(widget.initiallySelected);
  }

  String _getStorageLabel(String path) {
    if (path == '/storage/emulated/0' || path == '/sdcard' || path == '/storage/sdcard0') {
      return 'Internal Storage';
    }
    if (path.contains('extSdCard') || path.contains('sdcard1')) {
      return 'SD Card';
    }
    if (path.contains('usb')) {
      return 'USB Storage';
    }
    if (path.contains('-')) {
      final parts = path.split('/');
      final lastPart = parts.last;
      if (RegExp(r'^[A-Z0-9]{4}-[A-Z0-9]{4}$').hasMatch(lastPart)) {
        return 'SD Card ($lastPart)';
      }
    }
    return path;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pilih Storage'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Pilih storage mana yang akan di-scan untuk file musik:'),
          const SizedBox(height: 16),
          ...widget.storagePaths.map((path) {
            final isSelected = selectedPaths.contains(path);
            return CheckboxListTile(
              title: Text(_getStorageLabel(path)),
              subtitle: Text(path),
              value: isSelected,
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    selectedPaths.add(path);
                  } else {
                    selectedPaths.remove(path);
                  }
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
            );
          }).toList(),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('Batal'),
        ),
        TextButton(
          onPressed: selectedPaths.isEmpty
              ? null
              : () => Navigator.pop(context, selectedPaths.toList()),
          child: const Text('Scan'),
        ),
      ],
    );
  }
}
