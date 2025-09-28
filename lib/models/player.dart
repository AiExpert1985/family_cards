// ============== models/player.dart ==============
class Player {
  final String id;
  final String name;
  final bool needsToPlay;

  const Player({required this.id, required this.name, this.needsToPlay = false});

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'needsToPlay': needsToPlay};

  factory Player.fromJson(Map<String, dynamic> json) => Player(
    id: json['id'] ?? '',
    name: json['name'] ?? 'غير معروف',
    needsToPlay: json['needsToPlay'] ?? false,
  );

  Player copyWith({String? id, String? name, bool? needsToPlay}) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      needsToPlay: needsToPlay ?? this.needsToPlay,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Player && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
