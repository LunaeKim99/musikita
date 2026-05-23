import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:musikita/features/music_player/domain/entities/song.dart';
import 'package:musikita/features/music_player/domain/usecases/update_song_metadata.dart';
import 'package:musikita/features/music_player/presentation/bloc/song_bloc/song_bloc.dart';
import 'package:musikita/features/music_player/presentation/bloc/song_bloc/song_event.dart';
import 'package:musikita/core/di/injection_container.dart';
import 'package:path_provider/path_provider.dart';

class EditCoverPage extends StatefulWidget {
  final Song song;

  const EditCoverPage({
    super.key,
    required this.song,
  });

  @override
  State<EditCoverPage> createState() => _EditCoverPageState();
}

class _EditCoverPageState extends State<EditCoverPage> {
  File? _selectedImage;
  bool _isSaving = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<String> _copyImageToAppDir(File source) async {
    final appDir = await getApplicationDocumentsDirectory();
    final coversDir = Directory('${appDir.path}/covers');

    if (!await coversDir.exists()) {
      await coversDir.create(recursive: true);
    }

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = source.path.split('.').last.toLowerCase();
    final newPath = '${coversDir.path}/cover_$timestamp.$extension';

    await source.copy(newPath);
    return newPath;
  }

  Future<void> _saveCover() async {
    if (_isSaving || _selectedImage == null) return;

    setState(() => _isSaving = true);

    try {
      final newPath = await _copyImageToAppDir(_selectedImage!);

      final updateUseCase = sl<UpdateSongMetadata>();
      final result = await updateUseCase(
        song: widget.song,
        albumArtPath: newPath,
      );

      result.fold(
        (failure) {
          if (mounted) {
            setState(() => _isSaving = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to save: ${failure.message}')),
            );
          }
        },
         (updatedSong) {
          if (mounted) {
            context.read<SongBloc>().add(LoadSongs());
            Navigator.pop(context, updatedSong);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Cover saved')),
            );
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _clearCover() {
    setState(() {
      _selectedImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Cover Art'),
        actions: [
          if (_selectedImage != null)
            TextButton(
              onPressed: _isSaving ? null : _saveCover,
              child: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Container(
              width: 250,
              height: 250,
               decoration: BoxDecoration(
                 color: Theme.of(context).colorScheme.surfaceContainerHighest,
                 borderRadius: BorderRadius.circular(16),
                 boxShadow: [
                   BoxShadow(
                     color: Colors.black.withValues(alpha: 0.1),
                     blurRadius: 10,
                     offset: const Offset(0, 4),
                   ),
                 ],
               ),
               child: _selectedImage != null
                   ? ClipRRect(
                       borderRadius: BorderRadius.circular(16),
                       child: Image.file(
                         _selectedImage!,
                         fit: BoxFit.cover,
                       ),
                     )
                   : widget.song.albumArtPath != null &&
                           File(widget.song.albumArtPath!).existsSync()
                       ? ClipRRect(
                           borderRadius: BorderRadius.circular(16),
                           child: Image.file(
                             File(widget.song.albumArtPath!),
                             fit: BoxFit.cover,
                           ),
                         )
                       : Icon(
                           Icons.music_note,
                           size: 100,
                           color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                         ),
            ),
          ),
          const SizedBox(height: 8),
          if (_selectedImage != null)
            Center(
              child: TextButton.icon(
                onPressed: _clearCover,
                icon: const Icon(Icons.close),
                label: const Text('Remove Selected'),
              ),
            ),
          const SizedBox(height: 24),
          Card(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Choose from Gallery'),
                  subtitle: const Text('Select an existing image'),
                  onTap: _pickImage,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Take Photo'),
                  subtitle: const Text('Use camera to capture'),
                  onTap: _takePhoto,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tips',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• Square images work best for cover art\n'
                    '• Recommended size: 500x500 pixels or larger\n'
                    '• Supported formats: JPG, PNG',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
