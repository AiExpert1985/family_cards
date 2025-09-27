// ============== models/player.dart ==============
class Player {
  final String id;
  final String name;

  Player({required this.id, required this.name});

  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  factory Player.fromJson(Map<String, dynamic> json) =>
      Player(id: json['id'] ?? '', name: json['name'] ?? 'غير معروف');
}
