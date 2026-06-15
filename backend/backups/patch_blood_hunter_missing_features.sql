-- Blood Hunter: añade features de clase que faltan en class_features y corrige progression.
-- Idempotente: usa WHERE NOT EXISTS / INSERT IGNORE para evitar duplicados.
-- Ejecutar DESPUÉS de seed_blood_hunter_class_features.sql y patch_blood_hunter_progression.sql
SET NAMES utf8mb4;

SET @bh_id = (SELECT id FROM classes WHERE index_name = 'blood-hunter');

-- =====================================================================
-- 1.  class_features — Ability Score Improvement (lv 4, 8, 12, 16, 19)
--     El wizard las necesita para mostrar el selector ASI/Feat.
-- =====================================================================
INSERT INTO class_features (class_id, index_name, name, level, description)
SELECT @bh_id, 'blood-hunter-asi-4', 'Ability Score Improvement', 4,
  'Your ability scores improve. Increase one score by 2, or two scores by 1 each (max 20). As an optional rule, you may instead take a feat.'
WHERE NOT EXISTS (
  SELECT 1 FROM class_features WHERE class_id = @bh_id AND index_name = 'blood-hunter-asi-4'
);

INSERT INTO class_features (class_id, index_name, name, level, description)
SELECT @bh_id, 'blood-hunter-asi-8', 'Ability Score Improvement', 8,
  'Your ability scores improve. Increase one score by 2, or two scores by 1 each (max 20). As an optional rule, you may instead take a feat.'
WHERE NOT EXISTS (
  SELECT 1 FROM class_features WHERE class_id = @bh_id AND index_name = 'blood-hunter-asi-8'
);

INSERT INTO class_features (class_id, index_name, name, level, description)
SELECT @bh_id, 'blood-hunter-asi-12', 'Ability Score Improvement', 12,
  'Your ability scores improve. Increase one score by 2, or two scores by 1 each (max 20). As an optional rule, you may instead take a feat.'
WHERE NOT EXISTS (
  SELECT 1 FROM class_features WHERE class_id = @bh_id AND index_name = 'blood-hunter-asi-12'
);

INSERT INTO class_features (class_id, index_name, name, level, description)
SELECT @bh_id, 'blood-hunter-asi-16', 'Ability Score Improvement', 16,
  'Your ability scores improve. Increase one score by 2, or two scores by 1 each (max 20). As an optional rule, you may instead take a feat.'
WHERE NOT EXISTS (
  SELECT 1 FROM class_features WHERE class_id = @bh_id AND index_name = 'blood-hunter-asi-16'
);

INSERT INTO class_features (class_id, index_name, name, level, description)
SELECT @bh_id, 'blood-hunter-asi-19', 'Ability Score Improvement', 19,
  'Your ability scores improve. Increase one score by 2, or two scores by 1 each (max 20). As an optional rule, you may instead take a feat.'
WHERE NOT EXISTS (
  SELECT 1 FROM class_features WHERE class_id = @bh_id AND index_name = 'blood-hunter-asi-19'
);

-- =====================================================================
-- 2.  class_features — Blood Curse (lv 6, 10, 14, 18)
--     El wizard las necesita para mostrar el selector de Blood Curse.
--     El nivel 1 ya tiene "Blood Maledict" (que el wizard matchea también).
-- =====================================================================
INSERT INTO class_features (class_id, index_name, name, level, description)
SELECT @bh_id, 'blood-hunter-blood-curse-6', 'Blood Curse', 6,
  'You learn one additional Blood Curse of your choice.'
WHERE NOT EXISTS (
  SELECT 1 FROM class_features WHERE class_id = @bh_id AND index_name = 'blood-hunter-blood-curse-6'
);

INSERT INTO class_features (class_id, index_name, name, level, description)
SELECT @bh_id, 'blood-hunter-blood-curse-10', 'Blood Curse', 10,
  'You learn one additional Blood Curse of your choice.'
WHERE NOT EXISTS (
  SELECT 1 FROM class_features WHERE class_id = @bh_id AND index_name = 'blood-hunter-blood-curse-10'
);

INSERT INTO class_features (class_id, index_name, name, level, description)
SELECT @bh_id, 'blood-hunter-blood-curse-14', 'Blood Curse', 14,
  'You learn one additional Blood Curse of your choice.'
WHERE NOT EXISTS (
  SELECT 1 FROM class_features WHERE class_id = @bh_id AND index_name = 'blood-hunter-blood-curse-14'
);

INSERT INTO class_features (class_id, index_name, name, level, description)
SELECT @bh_id, 'blood-hunter-blood-curse-18', 'Blood Curse', 18,
  'You learn one additional Blood Curse of your choice.'
WHERE NOT EXISTS (
  SELECT 1 FROM class_features WHERE class_id = @bh_id AND index_name = 'blood-hunter-blood-curse-18'
);

-- =====================================================================
-- 3.  class_level_progression — añadir BLOOD_CURSE_CHOICE en lv 10 y 18
--     (el script original los omitió)
-- =====================================================================
INSERT INTO class_level_feature (progression_id, type, requires_choice, metadata)
SELECT p.id, 'BLOOD_CURSE_CHOICE', 1, NULL
FROM class_level_progression p
WHERE p.dnd_class_id = @bh_id AND p.level = 10
  AND NOT EXISTS (
    SELECT 1 FROM class_level_feature f
    WHERE f.progression_id = p.id AND f.type = 'BLOOD_CURSE_CHOICE'
  );

INSERT INTO class_level_feature (progression_id, type, requires_choice, metadata)
SELECT p.id, 'BLOOD_CURSE_CHOICE', 1, NULL
FROM class_level_progression p
WHERE p.dnd_class_id = @bh_id AND p.level = 18
  AND NOT EXISTS (
    SELECT 1 FROM class_level_feature f
    WHERE f.progression_id = p.id AND f.type = 'BLOOD_CURSE_CHOICE'
  );
