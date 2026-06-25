-- Añade las 7 armas de fuego del archetype Gunslinger (homebrew de Matt Mercer / Critical
-- Role) que ya se mencionan por nombre y stats en la descripción de su feature
-- "Firearm Proficiency" (seed_blood_hunter_gunslinger.sql), pero que nunca existieron como
-- items reales en la BD — ver Aurora_Fixes.md punto #16.
--
-- Stats (dado de daño, tipo, alcance) tomados literalmente de esa descripción ya existente.
-- Coste y peso son los valores estándar publicados del documento homebrew original (no hay
-- una fuente "canon" oficial de WotC para este archetype) — revisar si se prefiere otro valor.
--
-- Esta app no modela mecánicamente "Reload"/"Misfire" (no hay campos para ello), así que esos
-- datos quedan solo como texto descriptivo, igual que ya ocurría en la feature de la subclase.
--
-- Ejecutar con:
--   docker exec -i dnd-mysql mysql -u root -p<MYSQL_ROOT_PASSWORD> dnd_character_manager < scripts/seed_gunslinger_firearms.sql

INSERT INTO items (index_name, name, item_type, category, weight, cost_in_copper, description, damage_dice, damage_type, weapon_range, source)
VALUES ('gunslinger-palm-pistol', 'Palm Pistol', 'WEAPON', 'Firearm', 1, 25000,
        'A compact firearm easily concealed in one hand. Range 40/160 ft. Reload 1, Misfire 1.',
        '1d8', 'Piercing', 'Ranged', 'UA');
INSERT INTO item_properties (item_id, property) VALUES
  (LAST_INSERT_ID(), 'Ammunition'),
  (LAST_INSERT_ID(), 'Light');

INSERT INTO items (index_name, name, item_type, category, weight, cost_in_copper, description, damage_dice, damage_type, weapon_range, source)
VALUES ('gunslinger-pistol', 'Pistol', 'WEAPON', 'Firearm', 3, 25000,
        'A reliable sidearm favored by gunslingers. Range 60/240 ft. Reload 4, Misfire 1.',
        '1d10', 'Piercing', 'Ranged', 'UA');
INSERT INTO item_properties (item_id, property) VALUES
  (LAST_INSERT_ID(), 'Ammunition');

INSERT INTO items (index_name, name, item_type, category, weight, cost_in_copper, description, damage_dice, damage_type, weapon_range, source)
VALUES ('gunslinger-musket', 'Musket', 'WEAPON', 'Firearm', 10, 50000,
        'A long-barreled two-handed firearm. Range 120/480 ft. Reload 1, Misfire 2.',
        '1d12', 'Piercing', 'Ranged', 'UA');
INSERT INTO item_properties (item_id, property) VALUES
  (LAST_INSERT_ID(), 'Ammunition'),
  (LAST_INSERT_ID(), 'Two-Handed');

INSERT INTO items (index_name, name, item_type, category, weight, cost_in_copper, description, damage_dice, damage_type, weapon_range, source)
VALUES ('gunslinger-pepperbox', 'Pepperbox', 'WEAPON', 'Firearm', 5, 75000,
        'A pistol with multiple rotating barrels, allowing several shots before reloading. Range 80/320 ft. Reload 6, Misfire 2.',
        '1d10', 'Piercing', 'Ranged', 'UA');
INSERT INTO item_properties (item_id, property) VALUES
  (LAST_INSERT_ID(), 'Ammunition');

INSERT INTO items (index_name, name, item_type, category, weight, cost_in_copper, description, damage_dice, damage_type, weapon_range, source)
VALUES ('gunslinger-blunderbuss', 'Blunderbuss', 'WEAPON', 'Firearm', 7, 45000,
        'A wide-barreled firearm that sprays shot in a short-range spread. Range 15/60 ft. Reload 1, Misfire 2.',
        '2d8', 'Piercing', 'Ranged', 'UA');
INSERT INTO item_properties (item_id, property) VALUES
  (LAST_INSERT_ID(), 'Ammunition');

INSERT INTO items (index_name, name, item_type, category, weight, cost_in_copper, description, damage_dice, damage_type, weapon_range, source)
VALUES ('gunslinger-bad-news', 'Bad News', 'WEAPON', 'Firearm', 15, 75000,
        'An oversized two-handed firearm capable of devastating damage at long range. Range 200/800 ft. Reload 1, Misfire 3.',
        '2d12', 'Piercing', 'Ranged', 'UA');
INSERT INTO item_properties (item_id, property) VALUES
  (LAST_INSERT_ID(), 'Ammunition'),
  (LAST_INSERT_ID(), 'Two-Handed'),
  (LAST_INSERT_ID(), 'Heavy');

INSERT INTO items (index_name, name, item_type, category, weight, cost_in_copper, description, damage_dice, damage_type, weapon_range, source)
VALUES ('gunslinger-hand-mortar', 'Hand Mortar', 'WEAPON', 'Firearm', 10, 50000,
        'A short-barreled launcher that fires an explosive shell. Range 30/60 ft. Reload 1, Misfire 3. On hit, all creatures within a 5-ft radius of the target must make a DEX save (DC 8 + proficiency bonus + DEX modifier) or take 1d8 fire damage.',
        '2d8', 'Fire', 'Ranged', 'UA');
INSERT INTO item_properties (item_id, property) VALUES
  (LAST_INSERT_ID(), 'Ammunition'),
  (LAST_INSERT_ID(), 'Heavy');
