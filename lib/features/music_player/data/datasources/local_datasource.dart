import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart' hide DatabaseException;
import 'package:path_provider/path_provider.dart';
import 'package:musikita/core/constants/app_constants.dart';
import 'package:musikita/core/errors/exceptions.dart';
import 'package:musikita/features/music_player/data/models/playlist_model.dart';
import 'package:musikita/features/music_player/data/models/recent_played_model.dart';
import 'package:musikita/features/music_player/data/models/song_model.dart';
import 'package:musikita/features/music_player/domain/entities/song.dart';

abstract class LocalDataSource {
  Future<void> init();
  Future<void> close();

  Future<int> insertSong(SongModel song);
  Future<List<SongModel>> getAllSongs();
  Future<List<SongModel>> searchSongs(String query);
  Future<SongModel?> getSongById(int id);
  Future<SongModel?> getSongByPath(String path);
  Future<int> updateSong(SongModel song);
  Future<int> deleteSong(int id);
  Future<int> insertAllSongs(List<SongModel> songs);
  Future<void> deleteAllSongs();

  Future<bool> isFavorite(int songId);
  Future<void> addFavorite(int songId);
  Future<void> removeFavorite(int songId);
  Future<List<SongModel>> getFavoriteSongs();

  Future<int> insertPlaylist(PlaylistModel playlist);
  Future<List<PlaylistModel>> getPlaylists();
  Future<PlaylistModel?> getPlaylistById(int id);
  Future<int> updatePlaylist(PlaylistModel playlist);
  Future<int> deletePlaylist(int id);
  Future<List<SongModel>> getPlaylistSongs(int playlistId);
  Future<int> getPlaylistSongCount(int playlistId);
  Future<void> addSongToPlaylist(int playlistId, int songId);
  Future<void> removeSongFromPlaylist(int playlistId, int songId);

  Future<void> addToRecentPlayed(int songId);
  Future<List<RecentPlayedModel>> getRecentPlayed({int limit = 50});
  Future<List<SongModel>> getRecentPlayedSongs({int limit = 50});

  Future<List<String>> getAllFilePaths();
  Future<Map<String, int>> getFolderStats();
}

class LocalDataSourceImpl implements LocalDataSource {
  Database? _database;

  @override
  Future<void> init() async {
    if (_database != null && _database!.isOpen) return;

    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, AppConstants.databaseName);

    _database = await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE songs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        artist TEXT DEFAULT 'Unknown Artist',
        album TEXT DEFAULT 'Unknown Album',
        duration INTEGER DEFAULT 0,
        file_path TEXT UNIQUE NOT NULL,
        album_art_path TEXT,
        date_added TEXT DEFAULT (datetime('now'))
      )
    ''');

    await db.execute('''
      CREATE TABLE playlists (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        created_at TEXT DEFAULT (datetime('now'))
      )
    ''');

    await db.execute('''
      CREATE TABLE playlist_songs (
        playlist_id INTEGER NOT NULL,
        song_id INTEGER NOT NULL,
        position INTEGER,
        FOREIGN KEY (playlist_id) REFERENCES playlists(id) ON DELETE CASCADE,
        FOREIGN KEY (song_id) REFERENCES songs(id) ON DELETE CASCADE,
        PRIMARY KEY (playlist_id, song_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE favorites (
        song_id INTEGER PRIMARY KEY,
        added_at TEXT DEFAULT (datetime('now')),
        FOREIGN KEY (song_id) REFERENCES songs(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE recent_played (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        song_id INTEGER NOT NULL,
        played_at TEXT DEFAULT (datetime('now')),
        FOREIGN KEY (song_id) REFERENCES songs(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('CREATE INDEX idx_songs_title ON songs(title)');
    await db.execute('CREATE INDEX idx_songs_artist ON songs(artist)');
    await db.execute('CREATE INDEX idx_songs_album ON songs(album)');
    await db.execute('CREATE INDEX idx_songs_file_path ON songs(file_path)');
    await db.execute('CREATE INDEX idx_recent_played_played_at ON recent_played(played_at DESC)');
  }

  @override
  Future<void> close() async {
    if (_database != null && _database!.isOpen) {
      await _database!.close();
      _database = null;
    }
  }

  @override
  Future<int> insertSong(SongModel song) async {
    try {
      return await _database!.insert(
        'songs',
        song.toMap(includeId: false),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw DatabaseException('Failed to insert song: $e');
    }
  }

  @override
  Future<int> insertAllSongs(List<SongModel> songs) async {
    try {
      int count = 0;
      final batch = _database!.batch();
      for (final song in songs) {
        batch.insert(
          'songs',
          song.toMap(includeId: false),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
        count++;
      }
      await batch.commit(noResult: true);
      return count;
    } catch (e) {
      throw DatabaseException('Failed to insert songs: $e');
    }
  }

  @override
  Future<List<SongModel>> getAllSongs() async {
    try {
      final List<Map<String, dynamic>> maps = await _database!.query(
        'songs',
        orderBy: 'title ASC',
      );
      return maps.map(SongModel.fromMap).toList();
    } catch (e) {
      throw DatabaseException('Failed to get songs: $e');
    }
  }

  @override
  Future<List<SongModel>> searchSongs(String query) async {
    try {
      final searchQuery = '%$query%';
      final List<Map<String, dynamic>> maps = await _database!.query(
        'songs',
        where: 'title LIKE ? OR artist LIKE ? OR album LIKE ?',
        whereArgs: [searchQuery, searchQuery, searchQuery],
        orderBy: 'title ASC',
      );
      return maps.map(SongModel.fromMap).toList();
    } catch (e) {
      throw DatabaseException('Failed to search songs: $e');
    }
  }

  @override
  Future<SongModel?> getSongById(int id) async {
    try {
      final List<Map<String, dynamic>> maps = await _database!.query(
        'songs',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      return maps.isNotEmpty ? SongModel.fromMap(maps.first) : null;
    } catch (e) {
      throw DatabaseException('Failed to get song: $e');
    }
  }

  @override
  Future<SongModel?> getSongByPath(String path) async {
    try {
      final List<Map<String, dynamic>> maps = await _database!.query(
        'songs',
        where: 'file_path = ?',
        whereArgs: [path],
        limit: 1,
      );
      return maps.isNotEmpty ? SongModel.fromMap(maps.first) : null;
    } catch (e) {
      throw DatabaseException('Failed to get song: $e');
    }
  }

  @override
  Future<int> updateSong(SongModel song) async {
    try {
      if (song.id == null) throw const DatabaseException('Song ID is null');
      return await _database!.update(
        'songs',
        song.toMap(includeId: false),
        where: 'id = ?',
        whereArgs: [song.id],
      );
    } catch (e) {
      throw DatabaseException('Failed to update song: $e');
    }
  }

  @override
  Future<int> deleteSong(int id) async {
    try {
      return await _database!.delete(
        'songs',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw DatabaseException('Failed to delete song: $e');
    }
  }

  @override
  Future<void> deleteAllSongs() async {
    try {
      await _database!.delete('favorites');
      await _database!.delete('playlist_songs');
      await _database!.delete('recent_played');
      await _database!.delete('songs');
    } catch (e) {
      throw DatabaseException('Failed to delete all songs: $e');
    }
  }

  @override
  Future<bool> isFavorite(int songId) async {
    try {
      final List<Map<String, dynamic>> maps = await _database!.query(
        'favorites',
        where: 'song_id = ?',
        whereArgs: [songId],
        limit: 1,
      );
      return maps.isNotEmpty;
    } catch (e) {
      throw DatabaseException('Failed to check favorite: $e');
    }
  }

  @override
  Future<void> addFavorite(int songId) async {
    try {
      await _database!.insert(
        'favorites',
        {
          'song_id': songId,
          'added_at': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw DatabaseException('Failed to add favorite: $e');
    }
  }

  @override
  Future<void> removeFavorite(int songId) async {
    try {
      await _database!.delete(
        'favorites',
        where: 'song_id = ?',
        whereArgs: [songId],
      );
    } catch (e) {
      throw DatabaseException('Failed to remove favorite: $e');
    }
  }

  @override
  Future<List<SongModel>> getFavoriteSongs() async {
    try {
      final List<Map<String, dynamic>> maps = await _database!.rawQuery('''
        SELECT s.* FROM songs s
        INNER JOIN favorites f ON s.id = f.song_id
        ORDER BY f.added_at DESC
      ''');
      return maps.map(SongModel.fromMap).toList();
    } catch (e) {
      throw DatabaseException('Failed to get favorites: $e');
    }
  }

  @override
  Future<int> insertPlaylist(PlaylistModel playlist) async {
    try {
      return await _database!.insert(
        'playlists',
        playlist.toMap(includeId: false),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw DatabaseException('Failed to create playlist: $e');
    }
  }

  @override
  Future<List<PlaylistModel>> getPlaylists() async {
    try {
      final List<Map<String, dynamic>> maps = await _database!.query(
        'playlists',
        orderBy: 'name ASC',
      );
      final playlists = <PlaylistModel>[];
      for (final map in maps) {
        final playlist = PlaylistModel.fromMap(map);
        final songCount = await getPlaylistSongCount(playlist.id!);
        playlists.add(PlaylistModel(
          id: playlist.id,
          name: playlist.name,
          createdAt: playlist.createdAt,
          songCount: songCount,
        ));
      }
      return playlists;
    } catch (e) {
      throw DatabaseException('Failed to get playlists: $e');
    }
  }

  @override
  Future<PlaylistModel?> getPlaylistById(int id) async {
    try {
      final List<Map<String, dynamic>> maps = await _database!.query(
        'playlists',
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (maps.isEmpty) return null;
      final playlist = PlaylistModel.fromMap(maps.first);
      final songCount = await getPlaylistSongCount(id);
      return PlaylistModel(
        id: playlist.id,
        name: playlist.name,
        createdAt: playlist.createdAt,
        songCount: songCount,
      );
    } catch (e) {
      throw DatabaseException('Failed to get playlist: $e');
    }
  }

  @override
  Future<int> updatePlaylist(PlaylistModel playlist) async {
    try {
      if (playlist.id == null) throw const DatabaseException('Playlist ID is null');
      return await _database!.update(
        'playlists',
        playlist.toMap(includeId: false),
        where: 'id = ?',
        whereArgs: [playlist.id],
      );
    } catch (e) {
      throw DatabaseException('Failed to update playlist: $e');
    }
  }

  @override
  Future<int> deletePlaylist(int id) async {
    try {
      return await _database!.delete(
        'playlists',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw DatabaseException('Failed to delete playlist: $e');
    }
  }

  @override
  Future<List<SongModel>> getPlaylistSongs(int playlistId) async {
    try {
      final List<Map<String, dynamic>> maps = await _database!.rawQuery('''
        SELECT s.* FROM songs s
        INNER JOIN playlist_songs ps ON s.id = ps.song_id
        WHERE ps.playlist_id = ?
        ORDER BY ps.position ASC
      ''', [playlistId]);
      return maps.map(SongModel.fromMap).toList();
    } catch (e) {
      throw DatabaseException('Failed to get playlist songs: $e');
    }
  }

  @override
  Future<int> getPlaylistSongCount(int playlistId) async {
    try {
      final List<Map<String, dynamic>> result = await _database!.rawQuery('''
        SELECT COUNT(*) as count FROM playlist_songs
        WHERE playlist_id = ?
      ''', [playlistId]);
      return result.first['count'] as int? ?? 0;
    } catch (e) {
      throw DatabaseException('Failed to get playlist song count: $e');
    }
  }

  @override
  Future<void> addSongToPlaylist(int playlistId, int songId) async {
    try {
      final countResult = await _database!.rawQuery('''
        SELECT COUNT(*) as count FROM playlist_songs
        WHERE playlist_id = ?
      ''', [playlistId]);
      final position = countResult.first['count'] as int? ?? 0;

      await _database!.insert(
        'playlist_songs',
        {
          'playlist_id': playlistId,
          'song_id': songId,
          'position': position,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    } catch (e) {
      throw DatabaseException('Failed to add song to playlist: $e');
    }
  }

  @override
  Future<void> removeSongFromPlaylist(int playlistId, int songId) async {
    try {
      await _database!.delete(
        'playlist_songs',
        where: 'playlist_id = ? AND song_id = ?',
        whereArgs: [playlistId, songId],
      );
    } catch (e) {
      throw DatabaseException('Failed to remove song from playlist: $e');
    }
  }

  @override
  Future<void> addToRecentPlayed(int songId) async {
    try {
      await _database!.insert(
        'recent_played',
        {
          'song_id': songId,
          'played_at': DateTime.now().toIso8601String(),
        },
      );
      await _database!.rawDelete('''
        DELETE FROM recent_played
        WHERE id NOT IN (
          SELECT id FROM recent_played
          ORDER BY played_at DESC
          LIMIT ?
        )
      ''', [AppConstants.recentPlayedLimit]);
    } catch (e) {
      throw DatabaseException('Failed to add to recent played: $e');
    }
  }

  @override
  Future<List<RecentPlayedModel>> getRecentPlayed({int limit = 50}) async {
    try {
      final List<Map<String, dynamic>> maps = await _database!.query(
        'recent_played',
        orderBy: 'played_at DESC',
        limit: limit,
      );
      return maps.map(RecentPlayedModel.fromMap).toList();
    } catch (e) {
      throw DatabaseException('Failed to get recent played: $e');
    }
  }

  @override
  Future<List<SongModel>> getRecentPlayedSongs({int limit = 50}) async {
    try {
      final List<Map<String, dynamic>> maps = await _database!.rawQuery('''
        SELECT s.*, rp.played_at FROM songs s
        INNER JOIN recent_played rp ON s.id = rp.song_id
        GROUP BY s.id
        ORDER BY MAX(rp.played_at) DESC
        LIMIT ?
      ''', [limit]);
      return maps.map(SongModel.fromMap).toList();
    } catch (e) {
      throw DatabaseException('Failed to get recent played songs: $e');
    }
  }

  @override
  Future<List<String>> getAllFilePaths() async {
    try {
      final List<Map<String, dynamic>> maps = await _database!.query(
        'songs',
        columns: ['file_path'],
      );
      return maps.map((map) => map['file_path'] as String).toList();
    } catch (e) {
      throw DatabaseException('Failed to get file paths: $e');
    }
  }

  @override
  Future<Map<String, int>> getFolderStats() async {
    try {
      final paths = await getAllFilePaths();
      final folderMap = <String, int>{};

      for (final path in paths) {
        final directory = path.substring(0, path.lastIndexOf(RegExp(r'[\\/]')));
        folderMap[directory] = (folderMap[directory] ?? 0) + 1;
      }
      return folderMap;
    } catch (e) {
      throw DatabaseException('Failed to get folder stats: $e');
    }
  }
}
