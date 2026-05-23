import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:musikita/core/constants/app_constants.dart';
import 'package:musikita/core/theme/app_theme.dart';
import 'package:musikita/features/music_player/domain/entities/app_settings.dart';
import 'package:musikita/features/music_player/presentation/bloc/settings_bloc/settings_bloc.dart';
import 'package:musikita/features/music_player/presentation/bloc/settings_bloc/settings_event.dart';
import 'package:musikita/features/music_player/presentation/bloc/settings_bloc/settings_state.dart';
import 'package:musikita/features/music_player/presentation/widgets/settings_tile.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    context.read<SettingsBloc>().add(const LoadSettings());
  }

  Future<void> _exportData() async {
    context.read<SettingsBloc>().add(const ExportDataEvent());
  }

  Future<void> _pickImportFile() async {
    context.read<SettingsBloc>().add(const PickImportFile());
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: AppConstants.appName,
      applicationVersion: '0.1.0',
      applicationIcon: const Icon(Icons.music_note, size: 48),
      applicationLegalese: 'A local music player built with Flutter.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: BlocListener<SettingsBloc, SettingsState>(
        listener: (context, state) {
          if (state is ExportComplete) {
            _showShareDialog(state.jsonPath);
          }
          if (state is ImportFilePicked) {
            _confirmImport(context, state);
          }
          if (state is ImportComplete) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Imported ${state.importedSongsCount} songs'),
              ),
            );
          }
        },
        child: BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, state) {
            if (state is SettingsLoading || state is SettingsInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is SettingsError) {
              return Center(child: Text(state.message));
            }

            if (state is SettingsLoaded) {
              return _buildSettingsList(state.settings);
            }

            if (state is ExportInProgress) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Exporting data...'),
                  ],
                ),
              );
            }

            if (state is ImportInProgress) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Importing data...'),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildSettingsList(AppSettings settings) {
    return ListView(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 100,
      ),
      children: [
        _buildSectionHeader('Appearance'),
        SettingsTile(
          title: 'Theme',
          subtitle: _themeModeToString(settings.themeMode),
          icon: Icons.palette,
          type: SettingsTileType.dropdown,
          dropdownValue: _themeModeToString(settings.themeMode),
          dropdownItems: AppThemeMode.values.map(_themeModeToString).toList(),
          onDropdownChanged: (value) {
            if (value != null) {
              final themeMode = _stringToThemeMode(value);
              context.read<SettingsBloc>().add(UpdateThemeMode(themeMode));
            }
          },
        ),
        SettingsTile(
          title: 'Show Lyrics',
          subtitle: 'Display synchronized lyrics if available',
          icon: Icons.lyrics,
          type: SettingsTileType.toggle,
          toggleValue: settings.showLyrics,
          onToggle: (value) {
            context.read<SettingsBloc>().add(UpdateShowLyrics(value));
          },
        ),
        const Divider(height: 1),
        _buildSectionHeader('Audio'),
        _buildCodecSection(settings),
        SettingsTile(
          title: 'Crossfade',
          subtitle: 'Transition between songs',
          icon: Icons.track_changes,
          type: SettingsTileType.slider,
          sliderValue: settings.crossfadeDuration.toDouble(),
          minSlider: 0,
          maxSlider: 12,
          sliderDivisions: 12,
          sliderLabel: '${settings.crossfadeDuration}s',
          onSliderChanged: (value) {
            context.read<SettingsBloc>().add(UpdateCrossfadeDuration(value.round()));
          },
        ),
        SettingsTile(
          title: 'Sleep Timer',
          subtitle: _sleepTimerToString(settings.sleepTimer),
          icon: Icons.timer,
          type: SettingsTileType.dropdown,
          dropdownValue: _sleepTimerToString(settings.sleepTimer),
          dropdownItems: SleepTimerDuration.values.map(_sleepTimerToString).toList(),
          onDropdownChanged: (value) {
            if (value != null) {
              final timer = _stringToSleepTimer(value);
              context.read<SettingsBloc>().add(UpdateSleepTimer(timer));
            }
          },
        ),
        const Divider(height: 1),
        _buildSectionHeader('Data'),
        SettingsTile(
          title: 'Export Library',
          subtitle: 'Save your music library as JSON',
          icon: Icons.file_download,
          type: SettingsTileType.action,
          onTap: _exportData,
        ),
        SettingsTile(
          title: 'Import Library',
          subtitle: 'Restore from a JSON backup',
          icon: Icons.file_upload,
          type: SettingsTileType.action,
          onTap: _pickImportFile,
        ),
        const Divider(height: 1),
        _buildSectionHeader('About'),
        SettingsTile(
          title: 'About Musikita',
          subtitle: 'Version 0.1.0',
          icon: Icons.info_outline,
          type: SettingsTileType.navigation,
          onTap: () => _showAboutDialog(context),
        ),
      ],
    );
  }

  Widget _buildCodecSection(AppSettings settings) {
    return ExpansionTile(
      leading: const Icon(Icons.music_note),
      title: const Text('Enabled Codecs'),
      subtitle: Text('${settings.enabledCodecs.length} formats selected'),
      children: AppConstants.supportedCodecs.map((codec) {
        final isEnabled = settings.enabledCodecs.contains(codec);
        return CheckboxListTile(
          title: Text(codec.toUpperCase()),
          value: isEnabled,
          onChanged: (value) {
            final newList = List<String>.from(settings.enabledCodecs);
            if (value == true) {
              if (!newList.contains(codec)) {
                newList.add(codec);
              }
            } else {
              newList.remove(codec);
            }
            context.read<SettingsBloc>().add(UpdateEnabledCodecs(newList));
          },
          secondary: isEnabled
              ? Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                )
              : const Icon(Icons.check_circle_outline),
        );
      }).toList(),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  String _themeModeToString(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.system:
        return 'System';
      case AppThemeMode.light:
        return 'Light';
      case AppThemeMode.dark:
        return 'Dark';
      case AppThemeMode.amoled:
        return 'AMOLED Black';
    }
  }

  AppThemeMode _stringToThemeMode(String value) {
    switch (value) {
      case 'Light':
        return AppThemeMode.light;
      case 'Dark':
        return AppThemeMode.dark;
      case 'AMOLED Black':
        return AppThemeMode.amoled;
      default:
        return AppThemeMode.system;
    }
  }

  String _sleepTimerToString(SleepTimerDuration timer) {
    switch (timer) {
      case SleepTimerDuration.off:
        return 'Off';
      case SleepTimerDuration.fifteen:
        return '15 minutes';
      case SleepTimerDuration.thirty:
        return '30 minutes';
      case SleepTimerDuration.sixty:
        return '60 minutes';
      case SleepTimerDuration.endOfSong:
        return 'End of song';
    }
  }

  SleepTimerDuration _stringToSleepTimer(String value) {
    switch (value) {
      case '15 minutes':
        return SleepTimerDuration.fifteen;
      case '30 minutes':
        return SleepTimerDuration.thirty;
      case '60 minutes':
        return SleepTimerDuration.sixty;
      case 'End of song':
        return SleepTimerDuration.endOfSong;
      default:
        return SleepTimerDuration.off;
    }
  }

  void _showShareDialog(String path) {
    final file = File(path);
    if (file.existsSync()) {
      Share.shareXFiles([XFile(path)], text: 'Musikita Library Backup');
    }
  }

  void _confirmImport(BuildContext context, ImportFilePicked state) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Import Library'),
          content: const Text(
            'This will replace your current library. Are you sure?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<SettingsBloc>().add(ImportDataEvent(state.jsonContent));
              },
              child: const Text('Import'),
            ),
          ],
        );
      },
    );
  }
}
