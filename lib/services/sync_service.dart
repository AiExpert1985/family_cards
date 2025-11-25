// ============== services/sync_service.dart ==============
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import '../models/player.dart';
import '../models/game.dart';
import '../models/daily_team_history.dart';

class SyncService {
  // Export data to JSON file
  Future<String?> exportData({
    required List<Player> players,
    required List<Game> games,
    required DailyTeamHistory teamHistory,
  }) async {
    try {
      final data = {
        'players': players.map((p) => p.toJson()).toList(),
        'games': games.map((g) => g.toJson()).toList(),
        'teamHistory': teamHistory.toJson(),
        'exportDate': DateTime.now().toIso8601String(),
      };

      final jsonString = jsonEncode(data);
      final directory = await getApplicationDocumentsDirectory();
      final fileName =
          'cards_backup_${DateTime.now().millisecondsSinceEpoch}.json';
      final file = File('${directory.path}/$fileName');

      await file.writeAsString(jsonString);
      return file.path; // Return the path
    } catch (e) {
      return null;
    }
  }

  // Add a new method for sharing:
  Future<bool> shareFile(String filePath) async {
    try {
      final result = await Share.shareXFiles([
        XFile(filePath),
      ], text: 'نسخة احتياطية من بيانات اللعبة');
      return result.status == ShareResultStatus.success ||
          result.status == ShareResultStatus.dismissed;
    } catch (e) {
      return false;
    }
  }

  // Share exported file
  Future<bool> shareExport(String filePath) async {
    try {
      await Share.shareXFiles([
        XFile(filePath),
      ], text: 'نسخة احتياطية من بيانات اللعبة');
      return true;
    } catch (e) {
      return false;
    }
  }

  // Import and merge data from JSON file
  Future<Map<String, dynamic>?> importAndMerge({
    required List<Player> currentPlayers,
    required List<Game> currentGames,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.single.path == null) return null;

      final file = File(result.files.single.path!);
      final jsonString = await file.readAsString();
      final data = jsonDecode(jsonString);

      final importedPlayers =
          (data['players'] as List).map((p) => Player.fromJson(p)).toList();

      final importedGames =
          (data['games'] as List).map((g) => Game.fromJson(g)).toList();

      DailyTeamHistory? importedHistory;
      if (data['teamHistory'] != null) {
        importedHistory = DailyTeamHistory.fromJson(
          (data['teamHistory'] as Map).cast<String, dynamic>(),
        );
      }

      // Merge logic: avoid duplicates by ID
      final mergedPlayers = _mergePlayers(currentPlayers, importedPlayers);
      final mergedGames = _mergeGames(currentGames, importedGames);

      return {
        'players': mergedPlayers,
        'games': mergedGames,
        if (importedHistory != null) 'teamHistory': importedHistory,
        'addedPlayers': mergedPlayers.length - currentPlayers.length,
        'addedGames': mergedGames.length - currentGames.length,
      };
    } catch (e) {
      return null;
    }
  }

  List<Player> _mergePlayers(List<Player> current, List<Player> imported) {
    final merged = List<Player>.from(current);
    final existingIds = current.map((p) => p.id).toSet();

    for (var player in imported) {
      if (!existingIds.contains(player.id)) {
        merged.add(player);
      }
    }

    return merged;
  }

  List<Game> _mergeGames(List<Game> current, List<Game> imported) {
    final merged = List<Game>.from(current);
    final existingIds = current.map((g) => g.id).toSet();

    for (var game in imported) {
      if (!existingIds.contains(game.id)) {
        merged.add(game);
      }
    }

    return merged;
  }
}
