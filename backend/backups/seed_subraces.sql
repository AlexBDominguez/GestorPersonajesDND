-- Missing subraces seed
-- Existing: High Elf(id=1), Hill Dwarf(id=2), Lightfoot Halfling(id=3), Rock Gnome(id=4)
-- Race IDs: Dragonborn=1, Dwarf=2, Elf=3, Gnome=4, Half-Elf=5, Half-Orc=6, Halfling=7, Human=8, Tiefling=9
SET NAMES utf8mb4;

-- ── Mountain Dwarf ────────────────────────────────────────────────────────────
INSERT INTO subraces (index_name, name, description, race_id) VALUES
('mountain-dwarf','Mountain Dwarf',
 'As a mountain dwarf, you''re strong and hardy, accustomed to a difficult life in rugged terrain. You''re probably on the tall side (for a dwarf), and tend toward lighter coloration.',
 2);
SET @mtndwarf = LAST_INSERT_ID();
INSERT INTO subrace_ability_bonuses VALUES (@mtndwarf, 2, 'str'), (@mtndwarf, 2, 'con');
-- Traits: dwarven-armor-training (new), shares darkvision/resilience/combat/stonecunning with parent
INSERT INTO racial_traits (index_name, name) VALUES ('dwarven-armor-training','Dwarven Armor Training');
SET @dat_id = LAST_INSERT_ID();
INSERT INTO subrace_traits (subrace_id, trait_id) VALUES (@mtndwarf, @dat_id);

-- ── Wood Elf ──────────────────────────────────────────────────────────────────
INSERT INTO subraces (index_name, name, description, race_id) VALUES
('wood-elf','Wood Elf',
 'As a wood elf, you have keen senses and intuition, and your fleet feet carry you quickly and stealthily through your native forests. This category includes the wild elves of Greyhawk, the Kagonesti of Dragonlance, and the Bosmer of the Forgotten Realms. In Faerûn, wood elves (also called wild elves, green elves, or forest elves) are reclusive and distrusted outsiders.',
 3);
SET @woodelf = LAST_INSERT_ID();
INSERT INTO subrace_ability_bonuses VALUES (@woodelf, 1, 'wis');
-- Traits: elf-weapon-training (reuse id=22), fleet-of-foot (new), mask-of-the-wild (new)
INSERT INTO racial_traits (index_name, name) VALUES ('fleet-of-foot','Fleet of Foot');
SET @fof_id = LAST_INSERT_ID();
INSERT INTO racial_traits (index_name, name) VALUES ('mask-of-the-wild','Mask of the Wild');
SET @motw_id = LAST_INSERT_ID();
INSERT INTO subrace_traits (subrace_id, trait_id) VALUES (@woodelf, 22), (@woodelf, @fof_id), (@woodelf, @motw_id);

-- ── Dark Elf (Drow) ───────────────────────────────────────────────────────────
INSERT INTO subraces (index_name, name, description, race_id) VALUES
('drow','Dark Elf (Drow)',
 'Descended from an earlier subrace of dark-skinned elves, the drow were banished from the surface world for following the goddess Lolth down the path to evil and corruption. Now they have built their own civilization in the depths of the Underdark, patterned after the Way of Lolth. Also called dark elves, the drow have black skin that resembles polished obsidian and stark white or pale yellow hair.',
 3);
SET @drow = LAST_INSERT_ID();
INSERT INTO subrace_ability_bonuses VALUES (@drow, 1, 'cha');
-- Traits: superior-darkvision (new), sunlight-sensitivity (new), drow-magic (new), drow-weapon-training (new)
INSERT INTO racial_traits (index_name, name) VALUES ('superior-darkvision','Superior Darkvision');
SET @superdv = LAST_INSERT_ID();
INSERT INTO racial_traits (index_name, name) VALUES ('sunlight-sensitivity','Sunlight Sensitivity');
SET @sunsens = LAST_INSERT_ID();
INSERT INTO racial_traits (index_name, name) VALUES ('drow-magic','Drow Magic');
SET @drowmagic = LAST_INSERT_ID();
INSERT INTO racial_traits (index_name, name) VALUES ('drow-weapon-training','Drow Weapon Training');
SET @drowwt = LAST_INSERT_ID();
INSERT INTO subrace_traits (subrace_id, trait_id) VALUES (@drow, @superdv), (@drow, @sunsens), (@drow, @drowmagic), (@drow, @drowwt);

-- ── Stout Halfling ────────────────────────────────────────────────────────────
INSERT INTO subraces (index_name, name, description, race_id) VALUES
('stout-halfling','Stout Halfling',
 'As a stout halfling, you''re hardier than average and have some resistance to poison. Some say that stouts have dwarf blood. In the Forgotten Realms, these halflings are called stronghearts, and they''re most common in the south.',
 7);
SET @stout = LAST_INSERT_ID();
INSERT INTO subrace_ability_bonuses VALUES (@stout, 1, 'con');
-- Traits: stout-resilience (new)
INSERT INTO racial_traits (index_name, name) VALUES ('stout-resilience','Stout Resilience');
SET @stoutres = LAST_INSERT_ID();
INSERT INTO subrace_traits (subrace_id, trait_id) VALUES (@stout, @stoutres);

-- ── Forest Gnome ──────────────────────────────────────────────────────────────
INSERT INTO subraces (index_name, name, description, race_id) VALUES
('forest-gnome','Forest Gnome',
 'As a forest gnome, you have a natural knack for illusion and inherent quickness and stealth. Forest gnomes are rare and secretive. They gather in hidden communities in sylvan forests, using illusions and trickery to conceal themselves from threats or to mask their escape if endangered.',
 4);
SET @forestgnome = LAST_INSERT_ID();
INSERT INTO subrace_ability_bonuses VALUES (@forestgnome, 1, 'dex');
-- Traits: natural-illusionist (new), speak-with-small-beasts (new)
INSERT INTO racial_traits (index_name, name) VALUES ('natural-illusionist','Natural Illusionist');
SET @natill = LAST_INSERT_ID();
INSERT INTO racial_traits (index_name, name) VALUES ('speak-with-small-beasts','Speak with Small Beasts');
SET @swsb = LAST_INSERT_ID();
INSERT INTO subrace_traits (subrace_id, trait_id) VALUES (@forestgnome, @natill), (@forestgnome, @swsb);
