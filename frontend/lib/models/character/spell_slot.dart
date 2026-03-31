class SpellSlot {
  final int spellLevel;
  final int maxSlots;
  final int usedSlots;

  const SpellSlot({
    required this.spellLevel,
    required this.maxSlots,
    required this.usedSlots,
  });

  factory SpellSlot.fromJson(Map<String, dynamic> j) => SpellSlot(
        spellLevel: (j['spellLevel'] as num).toInt(),
        maxSlots:   (j['maxSlots'] as num).toInt(),
        usedSlots:  (j['usedSlots'] as num).toInt(),
      );
}
