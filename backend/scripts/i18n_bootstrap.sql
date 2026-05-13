-- i18n bootstrap + first-pass translations for D&D data.
-- Safe to run multiple times (idempotent).

-- 1) Ensure columns exist — MySQL-compatible (no ADD COLUMN IF NOT EXISTS).
DROP PROCEDURE IF EXISTS _add_col;
DELIMITER //
CREATE PROCEDURE _add_col(IN tbl VARCHAR(64), IN col VARCHAR(64), IN def TEXT)
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = tbl AND COLUMN_NAME = col
  ) THEN
    SET @s = CONCAT('ALTER TABLE `', tbl, '` ADD COLUMN `', col, '` ', def);
    PREPARE st FROM @s;
    EXECUTE st;
    DEALLOCATE PREPARE st;
  END IF;
END //
DELIMITER ;

CALL _add_col('spells','name_es','VARCHAR(255)');
CALL _add_col('spells','name_gl','VARCHAR(255)');
CALL _add_col('spells','description_es','TEXT');
CALL _add_col('spells','description_gl','TEXT');

CALL _add_col('classes','name_es','VARCHAR(255)');
CALL _add_col('classes','name_gl','VARCHAR(255)');
CALL _add_col('classes','description_es','TEXT');
CALL _add_col('classes','description_gl','TEXT');

CALL _add_col('race','name_es','VARCHAR(255)');
CALL _add_col('race','name_gl','VARCHAR(255)');
CALL _add_col('race','description_es','TEXT');
CALL _add_col('race','description_gl','TEXT');

CALL _add_col('subclasses','name_es','VARCHAR(255)');
CALL _add_col('subclasses','name_gl','VARCHAR(255)');
CALL _add_col('subclasses','subclass_flavor_es','VARCHAR(255)');
CALL _add_col('subclasses','subclass_flavor_gl','VARCHAR(255)');
CALL _add_col('subclasses','description_es','TEXT');
CALL _add_col('subclasses','description_gl','TEXT');

CALL _add_col('subraces','name_es','VARCHAR(255)');
CALL _add_col('subraces','name_gl','VARCHAR(255)');
CALL _add_col('subraces','description_es','TEXT');
CALL _add_col('subraces','description_gl','TEXT');

CALL _add_col('items','name_es','VARCHAR(255)');
CALL _add_col('items','name_gl','VARCHAR(255)');
CALL _add_col('items','description_es','TEXT');
CALL _add_col('items','description_gl','TEXT');

CALL _add_col('racial_traits','name_es','VARCHAR(255)');
CALL _add_col('racial_traits','name_gl','VARCHAR(255)');
CALL _add_col('racial_traits','description_es','TEXT');
CALL _add_col('racial_traits','description_gl','TEXT');

CALL _add_col('class_features','name_es','VARCHAR(255)');
CALL _add_col('class_features','name_gl','VARCHAR(255)');
CALL _add_col('class_features','description_es','TEXT');
CALL _add_col('class_features','description_gl','TEXT');

DROP PROCEDURE IF EXISTS _add_col;

-- 2) Base fallback EN -> ES/GL when translation is not present yet.
UPDATE spells
SET
  name_es = COALESCE(NULLIF(name_es, ''), name),
  name_gl = COALESCE(NULLIF(name_gl, ''), name),
  description_es = COALESCE(NULLIF(description_es, ''), description),
  description_gl = COALESCE(NULLIF(description_gl, ''), description);

UPDATE classes
SET
  name_es = COALESCE(NULLIF(name_es, ''), name),
  name_gl = COALESCE(NULLIF(name_gl, ''), name),
  description_es = COALESCE(NULLIF(description_es, ''), description),
  description_gl = COALESCE(NULLIF(description_gl, ''), description);

UPDATE race
SET
  name_es = COALESCE(NULLIF(name_es, ''), name),
  name_gl = COALESCE(NULLIF(name_gl, ''), name),
  description_es = COALESCE(NULLIF(description_es, ''), description),
  description_gl = COALESCE(NULLIF(description_gl, ''), description);

UPDATE subclasses
SET
  name_es = COALESCE(NULLIF(name_es, ''), name),
  name_gl = COALESCE(NULLIF(name_gl, ''), name),
  subclass_flavor_es = COALESCE(NULLIF(subclass_flavor_es, ''), subclass_flavor),
  subclass_flavor_gl = COALESCE(NULLIF(subclass_flavor_gl, ''), subclass_flavor),
  description_es = COALESCE(NULLIF(description_es, ''), description),
  description_gl = COALESCE(NULLIF(description_gl, ''), description);

UPDATE subraces
SET
  name_es = COALESCE(NULLIF(name_es, ''), name),
  name_gl = COALESCE(NULLIF(name_gl, ''), name),
  description_es = COALESCE(NULLIF(description_es, ''), description),
  description_gl = COALESCE(NULLIF(description_gl, ''), description);

UPDATE items
SET
  name_es = COALESCE(NULLIF(name_es, ''), name),
  name_gl = COALESCE(NULLIF(name_gl, ''), name),
  description_es = COALESCE(NULLIF(description_es, ''), description),
  description_gl = COALESCE(NULLIF(description_gl, ''), description);

UPDATE racial_traits
SET
  name_es = COALESCE(NULLIF(name_es, ''), name),
  name_gl = COALESCE(NULLIF(name_gl, ''), name),
  description_es = COALESCE(NULLIF(description_es, ''), description),
  description_gl = COALESCE(NULLIF(description_gl, ''), description);

UPDATE class_features
SET
  name_es = COALESCE(NULLIF(name_es, ''), name),
  name_gl = COALESCE(NULLIF(name_gl, ''), name),
  description_es = COALESCE(NULLIF(description_es, ''), description),
  description_gl = COALESCE(NULLIF(description_gl, ''), description);

-- 3) Canonical translations for classes.
UPDATE classes
SET
  name_es = CASE index_name
    WHEN 'barbarian' THEN 'Bárbaro'
    WHEN 'bard' THEN 'Bardo'
    WHEN 'cleric' THEN 'Clérigo'
    WHEN 'druid' THEN 'Druida'
    WHEN 'fighter' THEN 'Guerrero'
    WHEN 'monk' THEN 'Monje'
    WHEN 'paladin' THEN 'Paladín'
    WHEN 'ranger' THEN 'Explorador'
    WHEN 'rogue' THEN 'Pícaro'
    WHEN 'sorcerer' THEN 'Hechicero'
    WHEN 'warlock' THEN 'Brujo'
    WHEN 'wizard' THEN 'Mago'
    ELSE name_es
  END,
  name_gl = CASE index_name
    WHEN 'barbarian' THEN 'Bárbaro'
    WHEN 'bard' THEN 'Bardo'
    WHEN 'cleric' THEN 'Clérigo'
    WHEN 'druid' THEN 'Druída'
    WHEN 'fighter' THEN 'Guerreiro'
    WHEN 'monk' THEN 'Monxe'
    WHEN 'paladin' THEN 'Paladín'
    WHEN 'ranger' THEN 'Explorador'
    WHEN 'rogue' THEN 'Pícaro'
    WHEN 'sorcerer' THEN 'Feiticeiro'
    WHEN 'warlock' THEN 'Bruxo'
    WHEN 'wizard' THEN 'Mago'
    ELSE name_gl
  END;

-- 4) Canonical translations for races and subraces.
UPDATE race
SET
  name_es = CASE index_name
    WHEN 'dragonborn' THEN 'Dracónido'
    WHEN 'dwarf' THEN 'Enano'
    WHEN 'elf' THEN 'Elfo'
    WHEN 'gnome' THEN 'Gnomo'
    WHEN 'half-elf' THEN 'Semielfo'
    WHEN 'half-orc' THEN 'Semiorco'
    WHEN 'halfling' THEN 'Mediano'
    WHEN 'human' THEN 'Humano'
    WHEN 'tiefling' THEN 'Tiefling'
    ELSE name_es
  END,
  name_gl = CASE index_name
    WHEN 'dragonborn' THEN 'Dracónido'
    WHEN 'dwarf' THEN 'Anano'
    WHEN 'elf' THEN 'Elfo'
    WHEN 'gnome' THEN 'Gnomo'
    WHEN 'half-elf' THEN 'Semielfo'
    WHEN 'half-orc' THEN 'Semiorco'
    WHEN 'halfling' THEN 'Mediano'
    WHEN 'human' THEN 'Humano'
    WHEN 'tiefling' THEN 'Tiefling'
    ELSE name_gl
  END;

UPDATE subraces
SET
  name_es = CASE index_name
    WHEN 'high-elf' THEN 'Alto Elfo'
    WHEN 'hill-dwarf' THEN 'Enano de las Colinas'
    WHEN 'lightfoot-halfling' THEN 'Mediano Piesligeros'
    WHEN 'rock-gnome' THEN 'Gnomo de las Rocas'
    WHEN 'mountain-dwarf' THEN 'Enano de las Montañas'
    WHEN 'wood-elf' THEN 'Elfo de los Bosques'
    WHEN 'drow' THEN 'Elfo Oscuro (Drow)'
    WHEN 'stout-halfling' THEN 'Mediano Fornido'
    WHEN 'forest-gnome' THEN 'Gnomo del Bosque'
    ELSE name_es
  END,
  name_gl = CASE index_name
    WHEN 'high-elf' THEN 'Alto Elfo'
    WHEN 'hill-dwarf' THEN 'Anano das Outeiras'
    WHEN 'lightfoot-halfling' THEN 'Mediano Péslixeiros'
    WHEN 'rock-gnome' THEN 'Gnomo das Rochas'
    WHEN 'mountain-dwarf' THEN 'Anano das Montañas'
    WHEN 'wood-elf' THEN 'Elfo dos Bosques'
    WHEN 'drow' THEN 'Elfo Escuro (Drow)'
    WHEN 'stout-halfling' THEN 'Mediano Fornido'
    WHEN 'forest-gnome' THEN 'Gnomo do Bosque'
    ELSE name_gl
  END;

-- 5) Subclass flavor types (shown often in UI).
UPDATE subclasses
SET
  name_es = CASE index_name
    WHEN 'berserker' THEN 'Berserker'
    WHEN 'champion' THEN 'Campeón'
    WHEN 'devotion' THEN 'Devoción'
    WHEN 'draconic' THEN 'Línea Dracónica'
    WHEN 'evocation' THEN 'Escuela de Evocación'
    WHEN 'fiend' THEN 'Infernal'
    WHEN 'hunter' THEN 'Cazador'
    WHEN 'land' THEN 'Círculo de la Tierra'
    WHEN 'life' THEN 'Dominio de la Vida'
    WHEN 'lore' THEN 'Colegio del Saber'
    WHEN 'open-hand' THEN 'Mano Abierta'
    WHEN 'thief' THEN 'Ladrón'
    WHEN 'path-of-the-totem-warrior' THEN 'Senda del Guerrero Totémico'
    WHEN 'college-of-valor' THEN 'Colegio del Valor'
    WHEN 'knowledge-domain' THEN 'Dominio del Conocimiento'
    WHEN 'light-domain' THEN 'Dominio de la Luz'
    WHEN 'nature-domain' THEN 'Dominio de la Naturaleza'
    WHEN 'tempest-domain' THEN 'Dominio de la Tempestad'
    WHEN 'trickery-domain' THEN 'Dominio del Engaño'
    WHEN 'war-domain' THEN 'Dominio de la Guerra'
    WHEN 'circle-of-the-moon' THEN 'Círculo de la Luna'
    WHEN 'battle-master' THEN 'Maestro de Batalla'
    WHEN 'eldritch-knight' THEN 'Caballero Arcano'
    WHEN 'way-of-shadow' THEN 'Camino de la Sombra'
    WHEN 'way-of-the-four-elements' THEN 'Camino de los Cuatro Elementos'
    WHEN 'oath-of-the-ancients' THEN 'Juramento de los Ancestros'
    WHEN 'oath-of-vengeance' THEN 'Juramento de Venganza'
    WHEN 'beast-master' THEN 'Maestro de Bestias'
    WHEN 'assassin' THEN 'Asesino'
    WHEN 'arcane-trickster' THEN 'Tramposo Arcano'
    WHEN 'wild-magic' THEN 'Magia Salvaje'
    WHEN 'the-archfey' THEN 'Archifae'
    WHEN 'the-great-old-one' THEN 'Gran Primigenio'
    WHEN 'school-of-abjuration' THEN 'Escuela de Abjuración'
    WHEN 'school-of-conjuration' THEN 'Escuela de Conjuración'
    WHEN 'school-of-divination' THEN 'Escuela de Adivinación'
    WHEN 'school-of-enchantment' THEN 'Escuela de Encantamiento'
    WHEN 'school-of-illusion' THEN 'Escuela de Ilusión'
    WHEN 'school-of-necromancy' THEN 'Escuela de Nigromancia'
    WHEN 'school-of-transmutation' THEN 'Escuela de Transmutación'
    ELSE name_es
  END,
  name_gl = CASE index_name
    WHEN 'berserker' THEN 'Berserker'
    WHEN 'champion' THEN 'Campión'
    WHEN 'devotion' THEN 'Devoción'
    WHEN 'draconic' THEN 'Liñaxe Dracónica'
    WHEN 'evocation' THEN 'Escola de Evocación'
    WHEN 'fiend' THEN 'Infernal'
    WHEN 'hunter' THEN 'Cazador'
    WHEN 'land' THEN 'Círculo da Terra'
    WHEN 'life' THEN 'Dominio da Vida'
    WHEN 'lore' THEN 'Colexio do Saber'
    WHEN 'open-hand' THEN 'Mán Aberta'
    WHEN 'thief' THEN 'Ladrón'
    WHEN 'path-of-the-totem-warrior' THEN 'Senda do Guerreiro Totémico'
    WHEN 'college-of-valor' THEN 'Colexio do Valor'
    WHEN 'knowledge-domain' THEN 'Dominio do Coñecemento'
    WHEN 'light-domain' THEN 'Dominio da Luz'
    WHEN 'nature-domain' THEN 'Dominio da Natureza'
    WHEN 'tempest-domain' THEN 'Dominio da Tempestade'
    WHEN 'trickery-domain' THEN 'Dominio do Engano'
    WHEN 'war-domain' THEN 'Dominio da Guerra'
    WHEN 'circle-of-the-moon' THEN 'Círculo da Lúa'
    WHEN 'battle-master' THEN 'Mestre de Batalla'
    WHEN 'eldritch-knight' THEN 'Cabaleiro Arcano'
    WHEN 'way-of-shadow' THEN 'Camiño da Sombra'
    WHEN 'way-of-the-four-elements' THEN 'Camiño dos Catro Elementos'
    WHEN 'oath-of-the-ancients' THEN 'Xuramento dos Ancestrais'
    WHEN 'oath-of-vengeance' THEN 'Xuramento de Vinganza'
    WHEN 'beast-master' THEN 'Mestre das Bestas'
    WHEN 'assassin' THEN 'Asasino'
    WHEN 'arcane-trickster' THEN 'Trapalleiro Arcano'
    WHEN 'wild-magic' THEN 'Maxia Salvaxe'
    WHEN 'the-archfey' THEN 'Arquifeérico'
    WHEN 'the-great-old-one' THEN 'Gran Primixenio'
    WHEN 'school-of-abjuration' THEN 'Escola de Abxuración'
    WHEN 'school-of-conjuration' THEN 'Escola de Conxuración'
    WHEN 'school-of-divination' THEN 'Escola de Adiviñación'
    WHEN 'school-of-enchantment' THEN 'Escola de Encantamento'
    WHEN 'school-of-illusion' THEN 'Escola de Ilusión'
    WHEN 'school-of-necromancy' THEN 'Escola de Nigromancia'
    WHEN 'school-of-transmutation' THEN 'Escola de Transmutación'
    ELSE name_gl
  END,
  subclass_flavor_es = CASE subclass_flavor
    WHEN 'Primal Path' THEN 'Senda Primigenia'
    WHEN 'Martial Archetype' THEN 'Arquetipo Marcial'
    WHEN 'Sacred Oath' THEN 'Juramento Sagrado'
    WHEN 'Sorcerous Origin' THEN 'Origen Sortílego'
    WHEN 'Arcane Tradition' THEN 'Tradición Arcana'
    WHEN 'Otherworldly Patron' THEN 'Patrón Sobrenatural'
    WHEN 'Ranger Archetype' THEN 'Arquetipo de Explorador'
    WHEN 'Druid Circle' THEN 'Círculo Druídico'
    WHEN 'Divine Domain' THEN 'Dominio Divino'
    WHEN 'Bard College' THEN 'Colegio de Bardos'
    WHEN 'Monastic Tradition' THEN 'Tradición Monástica'
    WHEN 'Roguish Archetype' THEN 'Arquetipo de Pícaro'
    ELSE subclass_flavor_es
  END,
  subclass_flavor_gl = CASE subclass_flavor
    WHEN 'Primal Path' THEN 'Senda Primixenia'
    WHEN 'Martial Archetype' THEN 'Arquetipo Marcial'
    WHEN 'Sacred Oath' THEN 'Xuramento Sagrado'
    WHEN 'Sorcerous Origin' THEN 'Orixe Sortílega'
    WHEN 'Arcane Tradition' THEN 'Tradición Arcana'
    WHEN 'Otherworldly Patron' THEN 'Patrón Sobrenatural'
    WHEN 'Ranger Archetype' THEN 'Arquetipo de Explorador'
    WHEN 'Druid Circle' THEN 'Círculo Druídico'
    WHEN 'Divine Domain' THEN 'Dominio Divino'
    WHEN 'Bard College' THEN 'Colexio de Bardos'
    WHEN 'Monastic Tradition' THEN 'Tradición Monástica'
    WHEN 'Roguish Archetype' THEN 'Arquetipo de Pícaro'
    ELSE subclass_flavor_gl
  END;

-- 6) Hechizos: traducción de términos estandarizados.
UPDATE spells
SET
  school = CASE school
    WHEN 'Abjuration' THEN 'Abjuración'
    WHEN 'Conjuration' THEN 'Conjuración'
    WHEN 'Divination' THEN 'Adivinación'
    WHEN 'Enchantment' THEN 'Encantamiento'
    WHEN 'Evocation' THEN 'Evocación'
    WHEN 'Illusion' THEN 'Ilusión'
    WHEN 'Necromancy' THEN 'Nigromancia'
    WHEN 'Transmutation' THEN 'Transmutación'
    ELSE school
  END,
  damage_type = CASE damage_type
    WHEN 'Acid' THEN 'Ácido'
    WHEN 'Bludgeoning' THEN 'Contundente'
    WHEN 'Cold' THEN 'Frío'
    WHEN 'Fire' THEN 'Fuego'
    WHEN 'Force' THEN 'Fuerza'
    WHEN 'Lightning' THEN 'Eléctrico'
    WHEN 'Necrotic' THEN 'Necrótico'
    WHEN 'Piercing' THEN 'Perforante'
    WHEN 'Poison' THEN 'Veneno'
    WHEN 'Psychic' THEN 'Psíquico'
    WHEN 'Radiant' THEN 'Radiante'
    WHEN 'Slashing' THEN 'Cortante'
    WHEN 'Thunder' THEN 'Trueno'
    ELSE damage_type
  END;

-- 7) Spells/items names: lexical first-pass to reduce remaining EN text.
-- NOTE: This does not replace human review; it massively reduces untranslated UI text.
UPDATE spells
SET
  name_es = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(name_es,
    'Fire', 'Fuego'),
    'Cold', 'Frío'),
    'Lightning', 'Relámpago'),
    'Thunder', 'Trueno'),
    'Acid', 'Ácido'),
    'Poison', 'Veneno'),
    'Shield', 'Escudo'),
    'Armor', 'Armadura'),
    'Bolt', 'Rayo'),
    'Arrow', 'Flecha'),
  name_gl = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(name_gl,
    'Fire', 'Lume'),
    'Cold', 'Frío'),
    'Lightning', 'Lóstrego'),
    'Thunder', 'Trono'),
    'Acid', 'Ácido'),
    'Poison', 'Veleno'),
    'Shield', 'Escudo'),
    'Armor', 'Armadura'),
    'Bolt', 'Raio'),
    'Arrow', 'Frecha');

UPDATE items
SET
  name_es = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(name_es,
    'Potion', 'Poción'),
    'Scroll', 'Pergamino'),
    'Ring', 'Anillo'),
    'Shield', 'Escudo'),
    'Armor', 'Armadura'),
    'Sword', 'Espada'),
  name_gl = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(name_gl,
    'Potion', 'Poción'),
    'Scroll', 'Pergamiño'),
    'Ring', 'Anel'),
    'Shield', 'Escudo'),
    'Armor', 'Armadura'),
    'Sword', 'Espada');

-- 8) Common description terms (safe replacements, first pass).
UPDATE spells
SET
  description_es = REPLACE(REPLACE(REPLACE(REPLACE(description_es,
    'saving throw', 'tirada de salvación'),
    'spell attack', 'ataque de conjuro'),
    'damage', 'daño'),
    'creature', 'criatura'),
  description_gl = REPLACE(REPLACE(REPLACE(REPLACE(description_gl,
    'saving throw', 'tirada de salvación'),
    'spell attack', 'ataque de feitizo'),
    'damage', 'dano'),
    'creature', 'criatura');

UPDATE items
SET
  description_es = REPLACE(REPLACE(REPLACE(description_es,
    'damage', 'daño'),
    'creature', 'criatura'),
    'action', 'acción'),
  description_gl = REPLACE(REPLACE(REPLACE(description_gl,
    'damage', 'dano'),
    'creature', 'criatura'),
    'action', 'acción');

-- Done. You can rerun this file safely after each new sync.
