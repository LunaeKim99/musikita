import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:musikita/core/di/injection_container.dart';
import 'package:musikita/features/music_player/domain/entities/recent_played.dart';
import 'package:musikita/features/music_player/domain/entities/song.dart';
import 'package:musikita/features/music_player/domain/repositories/song_repository.dart';
import 'package:musikita/features/music_player/presentation/bloc/player_bloc/player_bloc.dart';
import 'package:musikita/features/music_player/presentation/bloc/player_bloc/player_event.dart';
import 'package:musikita/features/music_player/presentation/bloc/song_bloc/song_bloc.dart';
import 'package:musikita/features/music_player/presentation/bloc/song_bloc/song_event.dart';
import 'package:musikita/features/music_player/presentation/widgets/permission_dialog.dart';

class AppSidebar extends StatefulWidget {
  const AppSidebar({super.key});

  @override
  State<AppSidebar> createState() => _AppSidebarState();
}

class _AppSidebarState extends State<AppSidebar> {
  List<RecentPlayed> _recentPlayed = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecentPlayed();
  }

  Future<void> _loadRecentPlayed() async {
    final result = await sl<SongRepository>().getRecentPlayed(limit: 5);
    result.fold(
      (failure) {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      },
      (songs) {
        if (mounted) {
          setState(() {
            _recentPlayed = songs;
            _isLoading = false;
          });
        }
      },
    );
  }

  Future<void> _triggerScan() async {
    final hasPermission = await PermissionDialog.checkAndRequestStoragePermission(context);
    if (hasPermission && mounted) {
      Navigator.pop(context);
      context.read<SongBloc>().add(ScanSongsEvent());
    }
  }

  void _playSong(Song song) {
    Navigator.pop(context);
    context.read<PlayerBloc>().add(PlaySingleSong(song));
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildMenuItem(
                  icon: Icons.folder,
                  label: 'Folders',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/folder-browser');
                  },
                ),
                _buildMenuItem(
                  icon: Icons.library_music,
                  label: 'Scan Music',
                  onTap: _triggerScan,
                ),
                const Divider(),
                _buildMenuItem(
                  icon: Icons.settings,
                  label: 'Settings',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/settings');
                  },
                ),
              ],
            ),
          ),
          _buildRecentPlayedSection(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return DrawerHeader(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withAlpha(20),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/images/icon.png',
              width: 48,
              height: 48,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.music_note,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                );
              },
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'Musikita',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: onTap,
    );
  }

  Widget _buildRecentPlayedSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.history, size: 16),
              const SizedBox(width: 8),
              Text(
                'Recently Played',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _isLoading
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : _recentPlayed.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Belum ada lagu yang diputar',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: _recentPlayed
                          .where((r) => r.song != null)
                          .map((r) {
                        final song = r.song!;
                        return ListTile(
                          dense: true,
                          leading: const Icon(Icons.music_note, size: 20),
                          title: Text(
                            song.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13),
                          ),
                          subtitle: Text(
                            song.artist,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 11),
                          ),
                          onTap: () => _playSong(song),
                        );
                      }).toList(),
                    ),
        ],
      ),
    );
  }
}
