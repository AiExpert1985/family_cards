// ============== models/player.dart ==============
class Player {
  final String id;
  final String name;
  final bool needsToPlay;
  final Map<String, int> pairedWithToday;

  const Player({
    required this.id,
    required this.name,
    this.needsToPlay = false,
    this.pairedWithToday = const {},
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'needsToPlay': needsToPlay,
        'pairedWithToday': pairedWithToday,
      };

  factory Player.fromJson(Map<String, dynamic> json) => Player(
        id: json['id'] ?? '',
        name: json['name'] ?? 'غير معروف',
        needsToPlay: json['needsToPlay'] ?? false,
        pairedWithToday: json['pairedWithToday'] != null
            ? Map<String, int>.from(json['pairedWithToday'])
            : {},
      );

  Player copyWith({
    String? id,
    String? name,
    bool? needsToPlay,
    Map<String, int>? pairedWithToday,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      needsToPlay: needsToPlay ?? this.needsToPlay,
      pairedWithToday: pairedWithToday ?? this.pairedWithToday,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Player && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
