class ContentSource {
  final int id;
  final String shortName;
  final String fullName;
  final String description;
  final bool isBase;

  const ContentSource({
    required this.id,
    required this.shortName,
    required this.fullName,
    required this.description,
    required this.isBase,
  });

  factory ContentSource.fromJson(Map<String, dynamic> json) => ContentSource(
        id: json['id'] as int,
        shortName: json['shortName'] as String,
        fullName: json['fullName'] as String,
        description: json['description'] as String? ?? '',
        isBase: json['base'] as bool? ?? false,
      );
}
