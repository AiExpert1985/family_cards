// ============== models/player.dart ==============
class Player {
  final String id;
  final String name;
  final bool needsToPlay; // NEW FIELD

  Player({required this.id, required this.name, this.needsToPlay = false}); // UPDATED CONSTRUCTOR

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'needsToPlay': needsToPlay,
      };

  factory Player.fromJson(Map<String, dynamic> json) => Player(
        id: json['id'] ?? '',
        name: json['name'] ?? 'غير معروف',
        needsToPlay: json['needsToPlay'] ?? false,
      );
  
  Player copyWith({bool? needsToPlay}) {
    return Player(
      id: id,
      name: name,
      needsToPlay: needsToPlay ?? this.needsToPlay,
    );
  }
}