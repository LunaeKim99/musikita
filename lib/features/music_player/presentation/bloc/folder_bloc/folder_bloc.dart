import 'package:bloc/bloc.dart';
import 'package:musikita/features/music_player/domain/entities/folder.dart';
import 'package:musikita/features/music_player/domain/usecases/get_folders.dart';
import 'folder_event.dart';
import 'folder_state.dart';

class FolderBloc extends Bloc<FolderEvent, FolderState> {
  final GetFolders _getFolders;

  FolderBloc({
    required this._getFolders,
  }) : super(FolderInitial()) {
    on<LoadRootFolders>(_onLoadRootFolders);
    on<NavigateToFolder>(_onNavigateToFolder);
    on<NavigateUp>(_onNavigateUp);
  }

  Future<void> _onLoadRootFolders(LoadRootFolders event, Emitter<FolderState> emit) async {
    emit(FolderLoading());
    final result = await _getFolders();
    result.fold(
      (failure) => emit(FolderError(failure.message)),
       (folders) {
        emit(FoldersLoaded(
          rootFolders: folders,
          navigationStack: const [],
        ));
      },
    );
  }

  void _onNavigateToFolder(NavigateToFolder event, Emitter<FolderState> emit) {
    if (state is FoldersLoaded) {
      final currentState = state as FoldersLoaded;
      final newStack = List<Folder>.from(currentState.navigationStack)..add(event.folder);
      emit(currentState.copyWith(navigationStack: newStack));
    }
  }

  void _onNavigateUp(NavigateUp event, Emitter<FolderState> emit) {
    if (state is FoldersLoaded) {
      final currentState = state as FoldersLoaded;
      if (currentState.navigationStack.isNotEmpty) {
        final newStack = List<Folder>.from(currentState.navigationStack)..removeLast();
        emit(currentState.copyWith(navigationStack: newStack));
      }
    }
  }
}
