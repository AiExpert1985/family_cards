// ============== providers/providers.dart ==============
import 'package:family_cards/services/sync_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/player.dart';
import '../models/game.dart';
import '../models/player_stats.dart';
import '../services/storage_service.dart';
import '../services/team_generator_service.dart';
import '../services/statistics_service.dart';

// Services
final storageServiceProvider = Provider((ref) => StorageService());
final teamGeneratorServiceProvider = Provider((ref) => TeamGeneratorService());
final statisticsServiceProvider = Provider((ref) => StatisticsService());

// Players State
final playersProvider =
    StateNotifierProvider<PlayersNotifier, AsyncValue<List<Player>>>((ref) {
      return PlayersNotifier(ref.read(storageServiceProvider));
    });

class PlayersNotifier extends StateNotifier<AsyncValue<List<Player>>> {
  final StorageService _storage;

  PlayersNotifier(this._storage) : super(const AsyncValue.loading()) {
    loadPlayers();
  }

  Future<void> loadPlayers() async {
    state = const AsyncValue.loading();
    try {
      final players = await _storage.getPlayers();
      state = AsyncValue.data(players);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<bool> addPlayer(String name) async {
    if (name.trim().isEmpty) return false;

    final currentPlayers = state.value ?? [];
    final newPlayer = Player(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim(),
    );

    final updatedPlayers = [...currentPlayers, newPlayer];
    final success = await _storage.savePlayers(updatedPlayers);

    if (success) {
      state = AsyncValue.data(updatedPlayers);
    }
    return success;
  }

  Future<void> updatePlayers(List<Player> players) async {
    final success = await _storage.savePlayers(players);
    if (success) {
      state = AsyncValue.data(players);
    }
  }

  Future<bool> deletePlayer(String id) async {
    final currentPlayers = state.value ?? [];
    final updatedPlayers = currentPlayers.where((p) => p.id != id).toList();

    final success = await _storage.savePlayers(updatedPlayers);

    if (success) {
      state = AsyncValue.data(updatedPlayers);
    }
    return success;
  }
}

// Games State
final gamesProvider =
    StateNotifierProvider<GamesNotifier, AsyncValue<List<Game>>>((ref) {
      return GamesNotifier(ref.read(storageServiceProvider));
    });

class GamesNotifier extends StateNotifier<AsyncValue<List<Game>>> {
  final StorageService _storage;

  GamesNotifier(this._storage) : super(const AsyncValue.loading()) {
    loadGames();
  }

  // In GamesNotifier:
  Future<void> updateGames(List<Game> games) async {
    final success = await _storage.saveGames(games);
    if (success) {
      games.sort((a, b) => b.date.compareTo(a.date));
      state = AsyncValue.data(games);
    }
  }

  Future<void> loadGames() async {
    state = const AsyncValue.loading();
    try {
      final games = await _storage.getGames();
      games.sort((a, b) => b.date.compareTo(a.date));
      state = AsyncValue.data(games);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<bool> addGame(Game game) async {
    // Ensure games are loaded first
    if (!state.hasValue || state.value == null) {
      await loadGames();
    }

    final currentGames = state.value ?? [];

    // Double-check by reading from storage directly
    final storedGames = await _storage.getGames();
    final gamesToUpdate = storedGames.isNotEmpty ? storedGames : currentGames;

    final updatedGames = [...gamesToUpdate, game];
    final success = await _storage.saveGames(updatedGames);

    if (success) {
      updatedGames.sort((a, b) => b.date.compareTo(a.date));
      state = AsyncValue.data(updatedGames);
    }
    return success;
  }

  Future<bool> deleteGame(String id) async {
    // Ensure games are loaded first
    if (!state.hasValue || state.value == null) {
      await loadGames();
    }

    final currentGames = state.value ?? [];

    // Double-check by reading from storage directly
    final storedGames = await _storage.getGames();
    final gamesToUpdate = storedGames.isNotEmpty ? storedGames : currentGames;

    final updatedGames = gamesToUpdate.where((g) => g.id != id).toList();
    final success = await _storage.saveGames(updatedGames);

    if (success) {
      state = AsyncValue.data(updatedGames);
    }
    return success;
  }

  Future<bool> updateGame(Game game) async {
    if (!state.hasValue || state.value == null) {
      await loadGames();
    }

    final currentGames = state.value ?? [];
    final storedGames = await _storage.getGames();
    final gamesToUpdate = storedGames.isNotEmpty ? storedGames : currentGames;

    final updatedGames = gamesToUpdate.map((g) => g.id == game.id ? game : g).toList();
    final success = await _storage.saveGames(updatedGames);

    if (success) {
      updatedGames.sort((a, b) => b.date.compareTo(a.date));
      state = AsyncValue.data(updatedGames);
    }
    return success;
  }
}

// Statistics Provider
final statisticsProvider = Provider<AsyncValue<List<PlayerStats>>>((ref) {
  final playersAsync = ref.watch(playersProvider);
  final gamesAsync = ref.watch(gamesProvider);
  final statsService = ref.watch(statisticsServiceProvider);

  return playersAsync.when(
    data:
        (players) => gamesAsync.when(
          data: (games) {
            final stats = statsService.calculateStats(
              players: players,
              games: games,
            );
            return AsyncValue.data(stats);
          },
          loading: () => const AsyncValue.loading(),
          error: (e, stack) => AsyncValue.error(e, stack),
        ),
    loading: () => const AsyncValue.loading(),
    error: (e, stack) => AsyncValue.error(e, stack),
  );
});

final selectedStatisticsDateProvider = StateProvider<DateTime>((ref) => DateTime.now());
final selectedHeadToHeadPlayerProvider = StateProvider<String?>((ref) => null);

final dailyStatisticsProvider = Provider<AsyncValue<List<PlayerStats>>>((ref) {
  final selectedDate = ref.watch(selectedStatisticsDateProvider);
  final playersAsync = ref.watch(playersProvider);
  final gamesAsync = ref.watch(gamesProvider);
  final statsService = ref.watch(statisticsServiceProvider);

  return playersAsync.when(
    data: (players) => gamesAsync.when(
      data: (games) {
        final stats = statsService.calculateDailyStats(
          date: selectedDate,
          players: players,
          games: games,
        );
        final filteredStats = stats.where((stat) => stat.played > 0).toList();
        return AsyncValue.data(filteredStats);
      },
      loading: () => const AsyncValue.loading(),
      error: (e, stack) => AsyncValue.error(e, stack),
    ),
    loading: () => const AsyncValue.loading(),
    error: (e, stack) => AsyncValue.error(e, stack),
  );
});

// Selected Players State
final selectedPlayersProvider =
    StateNotifierProvider<SelectedPlayersNotifier, AsyncValue<Set<String>>>((
      ref,
    ) {
      return SelectedPlayersNotifier(ref.read(storageServiceProvider));
    });

class SelectedPlayersNotifier extends StateNotifier<AsyncValue<Set<String>>> {
  final StorageService _storage;

  SelectedPlayersNotifier(this._storage) : super(const AsyncValue.loading()) {
    loadSelectedPlayers();
  }

  Future<void> loadSelectedPlayers() async {
    state = const AsyncValue.loading();
    try {
      final selectedIds = await _storage.getSelectedPlayerIds();
      state = AsyncValue.data(selectedIds);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<bool> updateSelection(Set<String> newSelection) async {
    final success = await _storage.saveSelectedPlayerIds(newSelection);
    if (success) {
      state = AsyncValue.data(newSelection);
      // Reset cycle state when selection changes
      await _storage.saveRestedPlayerIds({});
      await _storage.saveLastSelectedPlayerIdsCheck(newSelection);
    }
    return success;
  }
}

// Rested Players State
final restedPlayersProvider =
    StateNotifierProvider<RestedPlayersNotifier, AsyncValue<Set<String>>>((
      ref,
    ) {
      return RestedPlayersNotifier(ref.read(storageServiceProvider));
    });

class RestedPlayersNotifier extends StateNotifier<AsyncValue<Set<String>>> {
  final StorageService _storage;

  RestedPlayersNotifier(this._storage) : super(const AsyncValue.loading()) {
    loadRestedPlayers();
  }

  Future<void> loadRestedPlayers() async {
    state = const AsyncValue.loading();
    try {
      final restedIds = await _storage.getRestedPlayerIds();
      state = AsyncValue.data(restedIds);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<bool> updateRested(Set<String> newRestedIds) async {
    final success = await _storage.saveRestedPlayerIds(newRestedIds);
    if (success) {
      state = AsyncValue.data(newRestedIds);
    }
    return success;
  }
}

final syncServiceProvider = Provider((ref) => SyncService());
