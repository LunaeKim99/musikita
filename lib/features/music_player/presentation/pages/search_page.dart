import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:musikita/features/music_player/domain/entities/song.dart';
import 'package:musikita/features/music_player/presentation/bloc/player_bloc/player_bloc.dart';
import 'package:musikita/features/music_player/presentation/bloc/player_bloc/player_event.dart';
import 'package:musikita/features/music_player/presentation/bloc/search_bloc/search_bloc.dart';
import 'package:musikita/features/music_player/presentation/bloc/search_bloc/search_event.dart';
import 'package:musikita/features/music_player/presentation/bloc/search_bloc/search_state.dart';
import 'package:musikita/features/music_player/presentation/widgets/song_tile.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  void _playSong(Song song) {
    context.read<PlayerBloc>().add(PlaySingleSong(song));
  }

  void _onSearchChanged(String query) {
    context.read<SearchBloc>().add(SearchQueryChanged(query));
  }

  void _clearSearch() {
    _searchController.clear();
    context.read<SearchBloc>().add(const ClearSearch());
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: 'Search songs, artists, albums...',
            border: InputBorder.none,
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: _clearSearch,
                  )
                : null,
          ),
          onChanged: _onSearchChanged,
          onSubmitted: (query) {
            context.read<SearchBloc>().add(SearchSubmitted(query));
          },
          textInputAction: TextInputAction.search,
        ),
      ),
      body: BlocBuilder<SearchBloc, SearchState>(
        builder: (context, state) {
          if (state is SearchInitial) {
            return _buildInitialState();
          }

          if (state is SearchLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is SearchEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                    Icon(
                      Icons.search_off,
                      size: 64,
                      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    'No results for "${state.query}"',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Try a different search term',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                  ),
                ],
              ),
            );
          }

          if (state is SearchError) {
            return Center(
              child: Text(state.message),
            );
          }

          if (state is SearchResultsLoaded) {
            return _buildResults(state);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
            Icon(
              Icons.search,
              size: 64,
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
            ),
          const SizedBox(height: 16),
          Text(
            'Search your music',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(SearchResultsLoaded state) {
    final songs = state.songs;
    final artists = state.artistResults;
    final albums = state.albumResults;

    return CustomScrollView(
      slivers: [
        if (artists.isNotEmpty) ...[
          const SliverToBoxAdapter(
            child: ListTile(
              title: Text('Artists'),
              dense: true,
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final song = artists[index];
                return ListTile(
                  leading: CircleAvatar(
                    child: const Icon(Icons.person),
                  ),
                  title: Text(song.artist),
                  onTap: () {
                    _searchController.text = song.artist;
                    _onSearchChanged(song.artist);
                  },
                );
              },
              childCount: artists.length,
            ),
          ),
        ],
        if (albums.isNotEmpty) ...[
          const SliverToBoxAdapter(
            child: ListTile(
              title: Text('Albums'),
              dense: true,
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final song = albums[index];
                return ListTile(
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.album),
                  ),
                  title: Text(song.album),
                  subtitle: Text(song.artist),
                  onTap: () {
                    _searchController.text = song.album;
                    _onSearchChanged(song.album);
                  },
                );
              },
              childCount: albums.length,
            ),
          ),
        ],
        if (songs.isNotEmpty) ...[
          const SliverToBoxAdapter(
            child: ListTile(
              title: Text('Songs'),
              dense: true,
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final song = songs[index];
                return SongTile(
                  song: song,
                  index: index,
                  queueContext: songs,
                  onTap: () => _playSong(song),
                  showFavorite: true,
                );
              },
              childCount: songs.length,
            ),
          ),
        ],
        SliverToBoxAdapter(
          child: SizedBox(height: MediaQuery.of(context).padding.bottom + 100),
        ),
      ],
    );
  }
}
