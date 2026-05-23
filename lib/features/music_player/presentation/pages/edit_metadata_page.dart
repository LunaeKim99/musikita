import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:musikita/features/music_player/domain/entities/song.dart';
import 'package:musikita/features/music_player/domain/usecases/update_song_metadata.dart';
import 'package:musikita/features/music_player/presentation/bloc/song_bloc/song_bloc.dart';
import 'package:musikita/features/music_player/presentation/bloc/song_bloc/song_event.dart';
import 'package:musikita/core/di/injection_container.dart';

class EditMetadataPage extends StatefulWidget {
  final Song song;

  const EditMetadataPage({
    super.key,
    required this.song,
  });

  @override
  State<EditMetadataPage> createState() => _EditMetadataPageState();
}

class _EditMetadataPageState extends State<EditMetadataPage> {
  late TextEditingController _titleController;
  late TextEditingController _artistController;
  late TextEditingController _albumController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.song.title);
    _artistController = TextEditingController(text: widget.song.artist);
    _albumController = TextEditingController(text: widget.song.album);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _artistController.dispose();
    _albumController.dispose();
    super.dispose();
  }

  Future<void> _saveMetadata() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);

    final updateUseCase = sl<UpdateSongMetadata>();
    final result = await updateUseCase(
      song: widget.song,
      title: _titleController.text.trim(),
      artist: _artistController.text.trim(),
      album: _albumController.text.trim(),
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
            const SnackBar(content: Text('Metadata saved')),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Metadata'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveMetadata,
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
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
               color: Theme.of(context).colorScheme.surfaceContainerHighest,
               borderRadius: BorderRadius.circular(12),
             ),
             child: Icon(
               Icons.music_note,
               size: 80,
               color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
             ),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Title',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.title),
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _artistController,
            decoration: const InputDecoration(
              labelText: 'Artist',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _albumController,
            decoration: const InputDecoration(
              labelText: 'Album',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.album),
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 24),
          Text(
            'File Info',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          ListTile(
            title: const Text('File Path'),
            subtitle: Text(
              widget.song.filePath,
              maxLines: 2,
            ),
            dense: true,
          ),
          ListTile(
            title: const Text('Date Added'),
            subtitle: Text(widget.song.dateAdded?.toString() ?? 'Unknown'),
            dense: true,
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Note: Changes are saved locally in the app database and do not modify the original audio file.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
