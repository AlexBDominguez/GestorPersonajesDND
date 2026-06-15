-- Artificer class_level_progression + class_level_feature seed
-- Aplica a TODAS las clases cuyo index_name contiene 'artificer' (ERLW y TCE).
-- Idempotente: sólo inserta si no existe ya la progresión para ese artífice + nivel.
--
-- ASIs del Artificer: 4, 8, 12, 16, 20 (no 19 como la mayoría de clases).
-- Subclase (Specialist): nivel 3.
-- Spellcaster de tercio: los huecos de hechizo los gestiona el backend ya por la tabla SpellSlotProgression.
SET NAMES utf8mb4;

-- Procesamos cada clase de Artificer que esté en la BD
-- (puede haber una sola si sólo una fuente está activa, o dos si hay ERLW y TCE)
DROP TEMPORARY TABLE IF EXISTS tmp_artificer_ids;
CREATE TEMPORARY TABLE tmp_artificer_ids AS
  SELECT id, index_name FROM classes WHERE LOWER(index_name) LIKE '%artificer%';

-- Helper: tabla de niveles 1-20
DROP TEMPORARY TABLE IF EXISTS tmp_art_levels;
CREATE TEMPORARY TABLE tmp_art_levels (lvl INT);
INSERT INTO tmp_art_levels VALUES (1),(2),(3),(4),(5),(6),(7),(8),(9),(10),
  (11),(12),(13),(14),(15),(16),(17),(18),(19),(20);

-- Para cada artífice y cada nivel, inserta la progresión si no existe
INSERT INTO class_level_progression (dnd_class_id, level)
SELECT a.id, l.lvl
FROM tmp_artificer_ids a
JOIN tmp_art_levels l ON TRUE
WHERE NOT EXISTS (
  SELECT 1 FROM class_level_progression p
  WHERE p.dnd_class_id = a.id AND p.level = l.lvl
);

-- HP_INCREASE en todos los niveles (si no existe ya)
INSERT INTO class_level_feature (progression_id, type, requires_choice, metadata)
SELECT p.id, 'HP_INCREASE', 0, NULL
FROM class_level_progression p
JOIN tmp_artificer_ids a ON p.dnd_class_id = a.id
WHERE NOT EXISTS (
  SELECT 1 FROM class_level_feature f
  WHERE f.progression_id = p.id AND f.type = 'HP_INCREASE'
);

-- SPELL_SLOT_UPDATE en todos los niveles (artífice lanza hechizos desde nivel 1)
INSERT INTO class_level_feature (progression_id, type, requires_choice, metadata)
SELECT p.id, 'SPELL_SLOT_UPDATE', 0, NULL
FROM class_level_progression p
JOIN tmp_artificer_ids a ON p.dnd_class_id = a.id
WHERE NOT EXISTS (
  SELECT 1 FROM class_level_feature f
  WHERE f.progression_id = p.id AND f.type = 'SPELL_SLOT_UPDATE'
);

-- SUBCLASS_CHOICE en nivel 3
INSERT INTO class_level_feature (progression_id, type, requires_choice, metadata)
SELECT p.id, 'SUBCLASS_CHOICE', 1, NULL
FROM class_level_progression p
JOIN tmp_artificer_ids a ON p.dnd_class_id = a.id
WHERE p.level = 3
  AND NOT EXISTS (
    SELECT 1 FROM class_level_feature f
    WHERE f.progression_id = p.id AND f.type = 'SUBCLASS_CHOICE'
  );

-- ASI_OR_FEAT en niveles 4, 8, 12, 16, 20  (el artífice tiene ASI en 20, no 19)
INSERT INTO class_level_feature (progression_id, type, requires_choice, metadata)
SELECT p.id, 'ASI_OR_FEAT', 1, NULL
FROM class_level_progression p
JOIN tmp_artificer_ids a ON p.dnd_class_id = a.id
WHERE p.level IN (4, 8, 12, 16, 20)
  AND NOT EXISTS (
    SELECT 1 FROM class_level_feature f
    WHERE f.progression_id = p.id AND f.type = 'ASI_OR_FEAT'
  );

-- =====================================================================
-- class_features — Ability Score Improvement (lv 4, 8, 12, 16, 20)
-- El wizard las necesita para mostrar el selector ASI/Feat.
-- Usa el index_name de la clase para que cada artífice tenga su propio
-- index_name y no colisionen (p.ej. "artificer-erlw-asi-8" vs "artificer-tce-asi-8").
-- =====================================================================
INSERT INTO class_features (class_id, index_name, name, level, description)
SELECT a.id,
       CONCAT(a.index_name, '-asi-', l.lvl),
       'Ability Score Improvement', l.lvl,
       'Your ability scores improve. Increase one score by 2, or two scores by 1 each (max 20). As an optional rule, you may instead take a feat.'
FROM tmp_artificer_ids a
JOIN (SELECT 4 AS lvl UNION SELECT 8 UNION SELECT 12 UNION SELECT 16 UNION SELECT 20) l ON TRUE
WHERE NOT EXISTS (
  SELECT 1 FROM class_features cf
  WHERE cf.index_name = CONCAT(a.index_name, '-asi-', l.lvl)
);

DROP TEMPORARY TABLE IF EXISTS tmp_artificer_ids;
DROP TEMPORARY TABLE IF EXISTS tmp_art_levels;
