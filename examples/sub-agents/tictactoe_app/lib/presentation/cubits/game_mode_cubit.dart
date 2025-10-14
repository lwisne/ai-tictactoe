import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../data/repositories/game_mode_repository.dart';
import '../../domain/models/game_mode.dart';

/// State for game mode selection and tracking
class GameModeState extends Equatable {
  final GameMode? lastPlayedMode;
  final bool isLoading;

  const GameModeState({this.lastPlayedMode, this.isLoading = false});

  GameModeState copyWith({
    GameMode? lastPlayedMode,
    bool? isLoading,
    bool clearLastPlayedMode = false,
  }) {
    return GameModeState(
      lastPlayedMode: clearLastPlayedMode
          ? null
          : (lastPlayedMode ?? this.lastPlayedMode),
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [lastPlayedMode, isLoading];
}

/// Cubit for managing game mode selection and persistence
/// Follows Clean Architecture - coordinates repository only, no business logic
@injectable
class GameModeCubit extends Cubit<GameModeState> {
  final GameModeRepository _gameModeRepository;

  GameModeCubit(this._gameModeRepository) : super(const GameModeState());

  /// Initialize by loading the last played mode from storage
  Future<void> initializeLastPlayedMode() async {
    emit(state.copyWith(isLoading: true));

    try {
      final lastMode = await _gameModeRepository.loadLastPlayedMode();
      emit(GameModeState(lastPlayedMode: lastMode, isLoading: false));
    } catch (e) {
      // On error, emit state with no last played mode
      emit(const GameModeState(isLoading: false));
    }
  }

  /// Save the selected game mode as the last played mode
  Future<void> selectGameMode(GameMode mode) async {
    emit(state.copyWith(isLoading: true));

    try {
      await _gameModeRepository.saveLastPlayedMode(mode);
      emit(GameModeState(lastPlayedMode: mode, isLoading: false));
    } catch (e) {
      // On error, revert to previous state
      emit(state.copyWith(isLoading: false));
    }
  }

  /// Clear the last played mode from storage
  Future<void> clearLastPlayedMode() async {
    emit(state.copyWith(isLoading: true));

    try {
      await _gameModeRepository.deleteLastPlayedMode();
      emit(state.copyWith(clearLastPlayedMode: true, isLoading: false));
    } catch (e) {
      // On error, revert to previous state
      emit(state.copyWith(isLoading: false));
    }
  }
}
