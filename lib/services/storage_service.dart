// ============== services/storage_service.dart ==============
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/player.dart';
import '../models/game.dart';

class StorageService {
  static const String _playersKey = 'players';
  static const String _gamesKey = 'games';
  static const String _selectedPlayersKey = 'selectedPlayers';
  static const String _restedPlayersKey = 'restedPlayers';
  static const String _lastSelectedKey = 'lastSelectedPlayersCheck';

  // Players
  Future<List<Player>> getPlayers() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_playersKey);
    if (data == null || data.isEmpty) return [];
    try {
      final List decoded = jsonDecode(data);
      return decoded.map((e) => Player.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> savePlayers(List<Player> players) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _playersKey,
        jsonEncode(players.map((e) => e.toJson()).toList()),
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  // Games
  Future<List<Game>> getGames() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_gamesKey);
    if (data == null || data.isEmpty) return [];
    try {
      final List decoded = jsonDecode(data);
      return decoded.map((e) => Game.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> saveGames(List<Game> games) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _gamesKey,
        jsonEncode(games.map((e) => e.toJson()).toList()),
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  // Selected Players
  Future<Set<String>> getSelectedPlayerIds() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? data = prefs.getStringList(_selectedPlayersKey);
    return data?.toSet() ?? {};
  }

  Future<bool> saveSelectedPlayerIds(Set<String> playerIds) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_selectedPlayersKey, playerIds.toList());
      return true;
    } catch (e) {
      return false;
    }
  }

  // Rested Players (Cycle State)
  Future<Set<String>> getRestedPlayerIds() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? data = prefs.getStringList(_restedPlayersKey);
    return data?.toSet() ?? {};
  }

  Future<bool> saveRestedPlayerIds(Set<String> playerIds) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_restedPlayersKey, playerIds.toList());
      return true;
    } catch (e) {
      return false;
    }
  }

  // Last Selected Check
  Future<Set<String>> getLastSelectedPlayerIdsCheck() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? data = prefs.getStringList(_lastSelectedKey);
    return data?.toSet() ?? {};
  }

  Future<bool> saveLastSelectedPlayerIdsCheck(Set<String> playerIds) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_lastSelectedKey, playerIds.toList());
      return true;
    } catch (e) {
      return false;
    }
  }

  // Clear all data
  Future<bool> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      return true;
    } catch (e) {
      return false;
    }
  }

  static const String _lastTeamResultKey = 'lastTeamResult';

  Future<Map<String, dynamic>?> getLastTeamResult() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_lastTeamResultKey);
    if (data == null || data.isEmpty) return null;
    try {
      return jsonDecode(data);
    } catch (e) {
      return null;
    }
  }

  Future<bool> saveLastTeamResult(Map<String, dynamic> result) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastTeamResultKey, jsonEncode(result));
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> clearLastTeamResult() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_lastTeamResultKey);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> removePlayedMatch({
    required String team1Player1,
    required String team1Player2,
    required String team2Player1,
    required String team2Player2,
  }) async {
    try {
      final lastResult = await getLastTeamResult();
      if (lastResult == null) return true;

      final teams = lastResult['teams'] as List;
      final restingPlayers = lastResult['restingPlayers'] as List;

      // Find and remove the two teams that match
      final updatedTeams =
          teams.where((team) {
            final teamList = team as List;
            // Check if this is team 1 or team 2
            final isTeam1 =
                teamList.contains(team1Player1) &&
                teamList.contains(team1Player2);
            final isTeam2 =
                teamList.contains(team2Player1) &&
                teamList.contains(team2Player2);
            return !isTeam1 && !isTeam2; // Keep teams that don't match
          }).toList();

      // If no teams left, clear everything
      if (updatedTeams.isEmpty) {
        return await clearLastTeamResult();
      }

      // Save updated result
      final updatedResult = {
        'teams': updatedTeams,
        'restingPlayers': restingPlayers,
        'timestamp': DateTime.now().toIso8601String(),
      };

      return await saveLastTeamResult(updatedResult);
    } catch (e) {
      return false;
    }
  }
}
