-- Patch: replace Aurora-imported class descriptions with clean flavor text.
-- Aurora descriptions embed the full rulebook chapter (proficiencies, tables, etc.).
-- Safe to re-run.
SET NAMES utf8mb4;

-- Artificer — Eberron: Rising from the Last War (ERLW, 2019 original)
UPDATE classes
SET description =
'The Artificer is a master of magical invention who uses tools and ingenuity to channel arcane power. They treat magic as a technical discipline, applying scholarly rigor to understand and harness its principles.\nArtificers imbue mundane objects with magical energy, creating temporary and permanent wonders. Their craft covers everything from alchemical elixirs to arcane firearms, and they support allies with magically enhanced equipment known as infusions.'
WHERE name LIKE 'Artificer%' AND source = 'ERLW';

-- Artificer — Tasha's Cauldron of Everything (TCE, 2020 revised)
UPDATE classes
SET description =
'Masters of invention, artificers use ingenuity and magic to unlock extraordinary capabilities in objects. They see magic as a complex system waiting to be decoded and controlled.\nArtificers use tools to channel arcane power, crafting temporary and permanent magical objects. To cast a spell, an artificer could use alchemist''s supplies to create a potent elixir, calligrapher''s supplies to inscribe a sigil of power, or tinker''s tools to craft a temporary charm.\nArtificers understand magic on a technical level, treating it as a system to be decoded. They combine technical knowledge with magical mastery to produce armaments, craft magical items, and support their allies with infused equipment.'
WHERE name LIKE 'Artificer%' AND source = 'TCE';
