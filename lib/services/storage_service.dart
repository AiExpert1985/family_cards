// ============== services/storage_service.dart ==============
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/player.dart';
import '../models/game.dart';

class StorageService {
  static const String playersKey = 'players';
  static const String gamesKey = 'games';
  static const String selectedPlayersKey = 'selectedPlayers'; // NEW KEY

  Future<List<Player>> getPlayers() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(playersKey);
    if (data == null || data.isEmpty) return [];
    try {
      final List decoded = jsonDecode(data);
      return decoded.map((e) => Player.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> savePlayers(List<Player> players) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(playersKey, jsonEncode(players.map((e) => e.toJson()).toList()));
  }

  Future<List<Game>> getGames() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(gamesKey);
    if (data == null || data.isEmpty) return [];
    try {
      final List decoded = jsonDecode(data);
      return decoded.map((e) => Game.fromJson(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveGames(List<Game> games) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(gamesKey, jsonEncode(games.map((e) => e.toJson()).toList()));
  }

  // NEW METHODS for selected players persistence
  Future<Set<String>> getSelectedPlayerIds() async {
    final prefs = await SharedPreferences.getInstance();
    // SharedPreferences.getStringList returns List<String>?, so we use it directly.
    final List<String>? data = prefs.getStringList(selectedPlayersKey); 
    return data?.toSet() ?? {};
  }

  Future<void> saveSelectedPlayerIds(Set<String> playerIds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(selectedPlayersKey, playerIds.toList());
  }
}