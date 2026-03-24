class BackgroundOption {
    final int id;
    final String name;
    final String? description;

    const BackgroundOption({
        required this.id,
        required this.name,
        this.description,
    });

    factory BackgroundOption.fromJson(Map<String, dynamic> json) => BackgroundOption(
        id:           (json['id'] as num).toInt(),
        name:         json['name'] as String,
        description:  json['description'] as String?,
    );
}