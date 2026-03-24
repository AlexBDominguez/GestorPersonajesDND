class RaceOption {
  final int id;
  final String name;

  const RaceOption({required this.id, required this.name});

  factory RaceOption.fromJson(Map<String, dynamic> json) => RaceOption(
        id:   (json['id'] as num).toInt(),
        name: json['name'] as String,
      );
}