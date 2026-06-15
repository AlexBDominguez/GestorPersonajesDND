-- Blood Hunter class_level_progression + class_level_feature seed
-- Idempotente: borra la progresión anterior si existe y la recrea completa.
-- Ejecutar DESPUÉS de que el backend haya arrancado al menos una vez (para que existan las tablas).
SET NAMES utf8mb4;

SET @bh_id = (SELECT id FROM classes WHERE index_name = 'blood-hunter');

-- Helper: procedure para crear un progression row + sus features en un solo bloque.
-- Como MySQL no soporta bloques anónimos fácilmente, usamos INSERT + @last_prog.

-- =====================================================================
-- Borrar progresión existente para Blood Hunter (cascade borra features)
-- =====================================================================
DELETE FROM class_level_feature
WHERE progression_id IN (
    SELECT id FROM class_level_progression WHERE dnd_class_id = @bh_id
);
DELETE FROM class_level_progression WHERE dnd_class_id = @bh_id;

-- =====================================================================
-- LEVEL 1
-- =====================================================================
INSERT INTO class_level_progression (dnd_class_id, level) VALUES (@bh_id, 1);
SET @p1 = LAST_INSERT_ID();
INSERT INTO class_level_feature (progression_id, type, requires_choice, metadata) VALUES
  (@p1, 'HP_INCREASE',       0, NULL),
  (@p1, 'BLOOD_CURSE_CHOICE',1, NULL);

-- =====================================================================
-- LEVEL 2
-- =====================================================================
INSERT INTO class_level_progression (dnd_class_id, level) VALUES (@bh_id, 2);
SET @p2 = LAST_INSERT_ID();
INSERT INTO class_level_feature (progression_id, type, requires_choice, metadata) VALUES
  (@p2, 'HP_INCREASE',    0, NULL),
  (@p2, 'FIGHTING_STYLE', 1, NULL);

-- =====================================================================
-- LEVEL 3 — Subclass choice
-- =====================================================================
INSERT INTO class_level_progression (dnd_class_id, level) VALUES (@bh_id, 3);
SET @p3 = LAST_INSERT_ID();
INSERT INTO class_level_feature (progression_id, type, requires_choice, metadata) VALUES
  (@p3, 'HP_INCREASE',    0, NULL),
  (@p3, 'SUBCLASS_CHOICE',1, NULL);

-- =====================================================================
-- LEVEL 4 — ASI/Feat
-- =====================================================================
INSERT INTO class_level_progression (dnd_class_id, level) VALUES (@bh_id, 4);
SET @p4 = LAST_INSERT_ID();
INSERT INTO class_level_feature (progression_id, type, requires_choice, metadata) VALUES
  (@p4, 'HP_INCREASE', 0, NULL),
  (@p4, 'ASI_OR_FEAT', 1, NULL);

-- =====================================================================
-- LEVELS 5 — plain HP
-- =====================================================================
INSERT INTO class_level_progression (dnd_class_id, level) VALUES (@bh_id, 5);
SET @p5 = LAST_INSERT_ID();
INSERT INTO class_level_feature (progression_id, type, requires_choice, metadata) VALUES
  (@p5, 'HP_INCREASE', 0, NULL);

-- =====================================================================
-- LEVEL 6 — Blood Curse
-- =====================================================================
INSERT INTO class_level_progression (dnd_class_id, level) VALUES (@bh_id, 6);
SET @p6 = LAST_INSERT_ID();
INSERT INTO class_level_feature (progression_id, type, requires_choice, metadata) VALUES
  (@p6, 'HP_INCREASE',       0, NULL),
  (@p6, 'BLOOD_CURSE_CHOICE',1, NULL);

-- =====================================================================
-- LEVELS 7
-- =====================================================================
INSERT INTO class_level_progression (dnd_class_id, level) VALUES (@bh_id, 7);
SET @p7 = LAST_INSERT_ID();
INSERT INTO class_level_feature (progression_id, type, requires_choice, metadata) VALUES
  (@p7, 'HP_INCREASE', 0, NULL);

-- =====================================================================
-- LEVEL 8 — ASI/Feat
-- =====================================================================
INSERT INTO class_level_progression (dnd_class_id, level) VALUES (@bh_id, 8);
SET @p8 = LAST_INSERT_ID();
INSERT INTO class_level_feature (progression_id, type, requires_choice, metadata) VALUES
  (@p8, 'HP_INCREASE', 0, NULL),
  (@p8, 'ASI_OR_FEAT', 1, NULL);

-- =====================================================================
-- LEVELS 9-11 — plain HP
-- =====================================================================
INSERT INTO class_level_progression (dnd_class_id, level) VALUES (@bh_id, 9);
SET @p9 = LAST_INSERT_ID();
INSERT INTO class_level_feature (progression_id, type, requires_choice, metadata) VALUES
  (@p9, 'HP_INCREASE', 0, NULL);

INSERT INTO class_level_progression (dnd_class_id, level) VALUES (@bh_id, 10);
SET @p10 = LAST_INSERT_ID();
INSERT INTO class_level_feature (progression_id, type, requires_choice, metadata) VALUES
  (@p10, 'HP_INCREASE', 0, NULL);

INSERT INTO class_level_progression (dnd_class_id, level) VALUES (@bh_id, 11);
SET @p11 = LAST_INSERT_ID();
INSERT INTO class_level_feature (progression_id, type, requires_choice, metadata) VALUES
  (@p11, 'HP_INCREASE', 0, NULL);

-- =====================================================================
-- LEVEL 12 — ASI/Feat
-- =====================================================================
INSERT INTO class_level_progression (dnd_class_id, level) VALUES (@bh_id, 12);
SET @p12 = LAST_INSERT_ID();
INSERT INTO class_level_feature (progression_id, type, requires_choice, metadata) VALUES
  (@p12, 'HP_INCREASE', 0, NULL),
  (@p12, 'ASI_OR_FEAT', 1, NULL);

-- =====================================================================
-- LEVEL 13 — plain HP
-- =====================================================================
INSERT INTO class_level_progression (dnd_class_id, level) VALUES (@bh_id, 13);
SET @p13 = LAST_INSERT_ID();
INSERT INTO class_level_feature (progression_id, type, requires_choice, metadata) VALUES
  (@p13, 'HP_INCREASE', 0, NULL);

-- =====================================================================
-- LEVEL 14 — Blood Curse
-- =====================================================================
INSERT INTO class_level_progression (dnd_class_id, level) VALUES (@bh_id, 14);
SET @p14 = LAST_INSERT_ID();
INSERT INTO class_level_feature (progression_id, type, requires_choice, metadata) VALUES
  (@p14, 'HP_INCREASE',       0, NULL),
  (@p14, 'BLOOD_CURSE_CHOICE',1, NULL);

-- =====================================================================
-- LEVELS 15-18 — plain HP
-- =====================================================================
INSERT INTO class_level_progression (dnd_class_id, level) VALUES (@bh_id, 15);
SET @p15 = LAST_INSERT_ID();
INSERT INTO class_level_feature (progression_id, type, requires_choice, metadata) VALUES
  (@p15, 'HP_INCREASE', 0, NULL);

INSERT INTO class_level_progression (dnd_class_id, level) VALUES (@bh_id, 16);
SET @p16 = LAST_INSERT_ID();
INSERT INTO class_level_feature (progression_id, type, requires_choice, metadata) VALUES
  (@p16, 'HP_INCREASE', 0, NULL),
  (@p16, 'ASI_OR_FEAT', 1, NULL);

INSERT INTO class_level_progression (dnd_class_id, level) VALUES (@bh_id, 17);
SET @p17 = LAST_INSERT_ID();
INSERT INTO class_level_feature (progression_id, type, requires_choice, metadata) VALUES
  (@p17, 'HP_INCREASE', 0, NULL);

INSERT INTO class_level_progression (dnd_class_id, level) VALUES (@bh_id, 18);
SET @p18 = LAST_INSERT_ID();
INSERT INTO class_level_feature (progression_id, type, requires_choice, metadata) VALUES
  (@p18, 'HP_INCREASE', 0, NULL);

-- =====================================================================
-- LEVEL 19 — ASI/Feat
-- =====================================================================
INSERT INTO class_level_progression (dnd_class_id, level) VALUES (@bh_id, 19);
SET @p19 = LAST_INSERT_ID();
INSERT INTO class_level_feature (progression_id, type, requires_choice, metadata) VALUES
  (@p19, 'HP_INCREASE', 0, NULL),
  (@p19, 'ASI_OR_FEAT', 1, NULL);

-- =====================================================================
-- LEVEL 20
-- =====================================================================
INSERT INTO class_level_progression (dnd_class_id, level) VALUES (@bh_id, 20);
SET @p20 = LAST_INSERT_ID();
INSERT INTO class_level_feature (progression_id, type, requires_choice, metadata) VALUES
  (@p20, 'HP_INCREASE', 0, NULL);
