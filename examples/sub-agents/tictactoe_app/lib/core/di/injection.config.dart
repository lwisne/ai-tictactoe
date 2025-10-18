// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:tictactoe_app/data/repositories/game_mode_repository.dart'
    as _i840;
import 'package:tictactoe_app/data/repositories/game_state_persistence_repository.dart'
    as _i505;
import 'package:tictactoe_app/data/repositories/theme_repository.dart' as _i947;
import 'package:tictactoe_app/domain/services/game_service.dart' as _i941;
import 'package:tictactoe_app/presentation/blocs/game/game_bloc.dart' as _i130;
import 'package:tictactoe_app/presentation/blocs/settings/settings_bloc.dart'
    as _i1050;
import 'package:tictactoe_app/presentation/blocs/theme/theme_bloc.dart'
    as _i126;
import 'package:tictactoe_app/presentation/cubits/game_mode_cubit.dart'
    as _i293;
import 'package:tictactoe_app/presentation/cubits/game_ui_cubit.dart' as _i999;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.factory<_i1050.SettingsBloc>(() => _i1050.SettingsBloc());
    gh.factory<_i999.GameUICubit>(() => _i999.GameUICubit());
    gh.lazySingleton<_i947.ThemeRepository>(() => _i947.ThemeRepository());
    gh.lazySingleton<_i840.GameModeRepository>(
      () => _i840.GameModeRepository(),
    );
    gh.lazySingleton<_i941.GameService>(() => _i941.GameService());
    gh.lazySingleton<_i505.GameStatePersistenceRepository>(
      () => _i505.GameStatePersistenceRepository(),
    );
    gh.factory<_i130.GameBloc>(
      () => _i130.GameBloc(
        gameService: gh<_i941.GameService>(),
        persistenceRepository: gh<_i505.GameStatePersistenceRepository>(),
      ),
    );
    gh.factory<_i126.ThemeBloc>(
      () => _i126.ThemeBloc(gh<_i947.ThemeRepository>()),
    );
    gh.factory<_i293.GameModeCubit>(
      () => _i293.GameModeCubit(gh<_i840.GameModeRepository>()),
    );
    return this;
  }
}
