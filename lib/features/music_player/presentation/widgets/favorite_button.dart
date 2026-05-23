import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:musikita/features/music_player/presentation/bloc/favorite_bloc/favorite_bloc.dart';
import 'package:musikita/features/music_player/presentation/bloc/favorite_bloc/favorite_event.dart';
import 'package:musikita/features/music_player/presentation/bloc/favorite_bloc/favorite_state.dart';

class FavoriteButton extends StatefulWidget {
  final int? songId;
  final double size;
  final bool showSnackbar;

  const FavoriteButton({
    super.key,
    required this.songId,
    this.size = 24,
    this.showSnackbar = true,
  });

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  bool? _isFavorite;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkFavorite();
  }

  void _checkFavorite() {
    if (widget.songId == null) return;

    final state = context.read<FavoriteBloc>().state;
    if (state is FavoritesLoaded) {
      setState(() {
        _isFavorite = state.isFavorite(widget.songId!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FavoriteBloc, FavoriteState>(
      listener: (context, state) {
        if (state is SingleFavoriteChecked && state.songId == widget.songId) {
          setState(() => _isFavorite = state.isFavorite);
        }
        if (state is FavoriteToggled && state.songId == widget.songId) {
          setState(() => _isFavorite = state.isNowFavorite);
          if (widget.showSnackbar) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.isNowFavorite
                      ? 'Added to favorites'
                      : 'Removed from favorites',
                ),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        }
      },
      child: _buildButton(context),
    );
  }

  Widget _buildButton(BuildContext context) {
    return IconButton(
      icon: Icon(
        (_isFavorite ?? false) ? Icons.favorite : Icons.favorite_border,
        color: (_isFavorite ?? false)
            ? Theme.of(context).colorScheme.primary
            : null,
        size: widget.size,
      ),
      onPressed: () {
        if (widget.songId != null) {
          context.read<FavoriteBloc>().add(ToggleFavorite(widget.songId!));
        }
      },
      splashRadius: widget.size + 8,
    );
  }
}
