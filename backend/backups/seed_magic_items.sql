-- =============================================================================
-- Magic Items seed — items mágicos de ejemplo con requiresAttunement = true
-- Para demostrar la funcionalidad de Attunement en la tab de inventario
-- Ejecutar contra la base de datos: dnd_character_manager
-- =============================================================================

USE dnd_character_manager;

INSERT INTO items
  (index_name, name, item_type, category, weight, cost_in_copper, description, rarity, requires_attunement, attunement_requierement,
   bonus_ac, bonus_to_hit, bonus_saving_throws, set_str_to, set_dex_to, set_con_to, set_int_to, set_wis_to, set_cha_to)
VALUES
  (
    'ring-of-protection',
    'Ring of Protection',
    'ring',
    'magic_item',
    0,
    500000,
    'You gain a +1 bonus to AC and saving throws while wearing this ring.',
    'Rare',
    TRUE,
    NULL,
    1, 0, 1, NULL, NULL, NULL, NULL, NULL, NULL
  ),
  (
    'cloak-of-elvenkind',
    'Cloak of Elvenkind',
    'wondrous_item',
    'magic_item',
    1,
    500000,
    'While you wear this cloak with its hood up, Wisdom (Perception) checks made to see you have disadvantage, and you have advantage on Dexterity (Stealth) checks made to hide, as the cloak''s color shifts to camouflage you.',
    'Uncommon',
    TRUE,
    NULL,
    0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL
  ),
  (
    'gauntlets-of-ogre-power',
    'Gauntlets of Ogre Power',
    'wondrous_item',
    'magic_item',
    1,
    800000,
    'Your Strength score is 19 while you wear these gauntlets. They have no effect on you if your Strength is already 19 or higher.',
    'Uncommon',
    TRUE,
    NULL,
    0, 0, 0, 19, NULL, NULL, NULL, NULL, NULL
  ),
  (
    'headband-of-intellect',
    'Headband of Intellect',
    'wondrous_item',
    'magic_item',
    0,
    800000,
    'Your Intelligence score is 19 while you wear this headband. It has no effect on you if your Intelligence is already 19 or higher.',
    'Uncommon',
    TRUE,
    NULL,
    0, 0, 0, NULL, NULL, NULL, 19, NULL, NULL
  ),
  (
    'necklace-of-adaptation',
    'Necklace of Adaptation',
    'wondrous_item',
    'magic_item',
    0,
    1500000,
    'While wearing this necklace, you can breathe normally in any environment, and you have advantage on saving throws made against harmful gases and vapors (such as cloudkill and stinking cloud effects, and inhaled poisons).',
    'Uncommon',
    TRUE,
    NULL,
    0, 0, 0, NULL, NULL, NULL, NULL, NULL, NULL
  );
