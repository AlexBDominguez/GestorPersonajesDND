-- Fix: "Ability Score Improvement" duplicada en Artificer (ERLW y TCE) + nivel incorrecto.
--
-- Causa raiz:
--   1. patch_artificer_progression.sql insertó manualmente filas en `class_features`
--      ("Ability Score Improvement", niveles 4/8/12/16/20) con index_name tipo
--      '<class>-asi-<nivel>'.
--   2. El sync de Aurora (AuroraClassFeatureMapper) también importa una feature
--      "Ability Score Improvement" para el Artificer (niveles 4/8/12/16/19, que son
--      los oficiales) con su propio index_name (el id del elemento Aurora).
--   Resultado: dos filas distintas con mismo nombre+nivel en 4/8/12/16 -> se ve
--   duplicado en el wizard. Además, el patch puso una ASI extra e incorrecta en
--   nivel 20 (el nivel 20 real del Artificer es el capstone "Soul of Artifice",
--   no una ASI).
--
-- IMPORTANTE: ejecuta primero el PASO 0 (solo SELECT) y revisa los resultados
-- antes de correr los DELETE/UPDATE de los pasos 1 y 2.

SET NAMES utf8mb4;

-- =====================================================================
-- PASO 0 — Diagnóstico (solo lectura). Ejecuta esto primero y revisa.
-- =====================================================================

-- 0a. Filas duplicadas de "Ability Score Improvement" por clase+nivel
SELECT cf.class_id, c.name AS class_name, cf.level, cf.index_name, cf.name
FROM class_features cf
JOIN classes c ON c.id = cf.class_id
WHERE LOWER(c.index_name) LIKE '%artificer%'
  AND cf.name = 'Ability Score Improvement'
ORDER BY cf.class_id, cf.level;

-- 0b. class_level_feature ASI_OR_FEAT actuales por clase+nivel
SELECT c.name AS class_name, p.level, f.id AS feature_id, f.type
FROM class_level_feature f
JOIN class_level_progression p ON p.id = f.progression_id
JOIN classes c ON c.id = p.dnd_class_id
WHERE LOWER(c.index_name) LIKE '%artificer%'
  AND f.type = 'ASI_OR_FEAT'
ORDER BY c.name, p.level;

-- =====================================================================
-- PASO 1 — Eliminar las filas de class_features insertadas por el patch manual
-- (las que tienen index_name '...-asi-<nivel>'), siempre que exista también
-- una fila de Aurora con el mismo nombre+nivel (para no dejar el nivel sin
-- ninguna tarjeta si Aurora no llegó a importarla).
-- =====================================================================

DELETE cf_patch FROM class_features cf_patch
JOIN classes c ON c.id = cf_patch.class_id
WHERE LOWER(c.index_name) LIKE '%artificer%'
  AND cf_patch.name = 'Ability Score Improvement'
  AND cf_patch.index_name LIKE '%-asi-%'
  AND EXISTS (
    SELECT 1 FROM class_features cf_other
    WHERE cf_other.class_id = cf_patch.class_id
      AND cf_other.level = cf_patch.level
      AND cf_other.name = 'Ability Score Improvement'
      AND cf_other.id <> cf_patch.id
  );

-- =====================================================================
-- PASO 2 — Mover el ASI_OR_FEAT del nivel 20 (incorrecto) al nivel 19 (oficial)
-- =====================================================================

-- 2a. Borra el ASI_OR_FEAT de nivel 20
DELETE f FROM class_level_feature f
JOIN class_level_progression p ON p.id = f.progression_id
JOIN classes c ON c.id = p.dnd_class_id
WHERE LOWER(c.index_name) LIKE '%artificer%'
  AND f.type = 'ASI_OR_FEAT'
  AND p.level = 20;

-- 2b. Inserta el ASI_OR_FEAT en nivel 19 si no existe ya
INSERT INTO class_level_feature (progression_id, type, requires_choice, metadata)
SELECT p.id, 'ASI_OR_FEAT', 1, NULL
FROM class_level_progression p
JOIN classes c ON c.id = p.dnd_class_id
WHERE LOWER(c.index_name) LIKE '%artificer%'
  AND p.level = 19
  AND NOT EXISTS (
    SELECT 1 FROM class_level_feature f
    WHERE f.progression_id = p.id AND f.type = 'ASI_OR_FEAT'
  );

-- 2c. Si la fila de class_features para nivel 20 también decía "Ability Score
-- Improvement" (creada por el patch, índice '...-asi-20'), bórrala y asegúrate
-- de que exista una equivalente en nivel 19.
DELETE cf FROM class_features cf
JOIN classes c ON c.id = cf.class_id
WHERE LOWER(c.index_name) LIKE '%artificer%'
  AND cf.name = 'Ability Score Improvement'
  AND cf.level = 20
  AND cf.index_name LIKE '%-asi-%';

INSERT INTO class_features (class_id, index_name, name, level, description)
SELECT a.id, CONCAT(a.index_name, '-asi-19'), 'Ability Score Improvement', 19,
       'Your ability scores improve. Increase one score by 2, or two scores by 1 each (max 20). As an optional rule, you may instead take a feat.'
FROM classes a
WHERE LOWER(a.index_name) LIKE '%artificer%'
  AND NOT EXISTS (
    SELECT 1 FROM class_features cf
    WHERE cf.class_id = a.id AND cf.level = 19 AND cf.name = 'Ability Score Improvement'
  );

-- =====================================================================
-- PASO 3 — Verificación final (vuelve a correr el PASO 0 y comprueba que
-- cada clase Artificer tiene exactamente 1 fila por nivel en 4/8/12/16/19,
-- y ninguna en nivel 20).
-- =====================================================================
