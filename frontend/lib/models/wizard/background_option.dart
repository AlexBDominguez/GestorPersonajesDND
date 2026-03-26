class BackgroundOption {
  final int id;
  final String indexName;
  final String name;
  final String description;
  final String feature;
  final String featureDescription;
  final List<String> skillProficiencies;
  final List<String> toolProficiencies;
  final List<String> languages;
  final List<String> personalityTraits;
  final List<String> ideals;
  final List<String> bonds;
  final List<String> flaws;

  const BackgroundOption({
    required this.id,
    required this.indexName,
    required this.name,
    required this.description,
    required this.feature,
    required this.featureDescription,
    required this.skillProficiencies,
    required this.toolProficiencies,
    required this.languages,
    required this.personalityTraits,
    required this.ideals,
    required this.bonds,
    required this.flaws
  });

  factory BackgroundOption.fromJson(Map<String, dynamic> j) => BackgroundOption(
    id: j['id'] as int,
    indexName: j['indexName'] as String,
    name: j['name'] as String,
    description: j['description'] as String? ?? '',
    feature: j['feature'] as String? ?? '',
    featureDescription: j['featureDescription'] as String? ?? '',
    skillProficiencies: List<String>.from(j['skillProficiencies'] as List? ?? []),
    toolProficiencies: List<String>.from(j['toolProficiencies'] as List? ?? []),
    languages: List<String>.from(j['languages'] as List? ?? []),
    personalityTraits: List<String>.from(j['personalityTraits'] as List? ?? []),
    ideals: List<String>.from(j['ideals'] as List? ?? []),
    bonds: List<String>.from(j['bonds'] as List? ?? []),
    flaws: List<String>.from(j['flaws'] as List? ?? []),
  );

}