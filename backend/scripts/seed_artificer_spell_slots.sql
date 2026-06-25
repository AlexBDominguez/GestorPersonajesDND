-- Artificer (ERLW/TCE, class_id 13 y 14) no tenía ninguna fila en spell_slot_progression
-- (0 filas confirmadas) — sin esto, aunque se arregle spellcasting_ability (ver
-- patch_artificer_spellcasting.sql), el personaje no tendría slots de conjuro calculados.
-- Ver Aurora_Fixes.md punto #18.
--
-- Tabla oficial "The Artificer" (Tasha's Cauldron of Everything pg. 60 / Eberron: Rising
-- from the Last War pg. 56) — único caso de lanzador que empieza en nivel 1 con progresión
-- propia (no es ni full ni half caster estándar), tope de nivel de hechizo: 4º (nivel 18+).
--
-- Ejecutar con:
--   docker exec -i dnd-mysql mysql -u root -p$MYSQL_ROOT_PASSWORD dnd_character_manager < backend/scripts/seed_artificer_spell_slots.sql

INSERT INTO spell_slot_progression (class_id, character_level, spell_level, slots)
SELECT c.id, t.character_level, t.spell_level, t.slots
FROM (SELECT 13 AS id UNION ALL SELECT 14) c
CROSS JOIN (
  SELECT 1  AS character_level, 1 AS spell_level, 2 AS slots
  UNION ALL SELECT 2,  1, 2
  UNION ALL SELECT 3,  1, 3
  UNION ALL SELECT 4,  1, 3
  UNION ALL SELECT 5,  1, 3
  UNION ALL SELECT 6,  1, 3
  UNION ALL SELECT 7,  1, 4
  UNION ALL SELECT 7,  2, 2
  UNION ALL SELECT 8,  1, 4
  UNION ALL SELECT 8,  2, 2
  UNION ALL SELECT 9,  1, 4
  UNION ALL SELECT 9,  2, 2
  UNION ALL SELECT 10, 1, 4
  UNION ALL SELECT 10, 2, 3
  UNION ALL SELECT 11, 1, 4
  UNION ALL SELECT 11, 2, 3
  UNION ALL SELECT 12, 1, 4
  UNION ALL SELECT 12, 2, 3
  UNION ALL SELECT 13, 1, 4
  UNION ALL SELECT 13, 2, 3
  UNION ALL SELECT 13, 3, 2
  UNION ALL SELECT 14, 1, 4
  UNION ALL SELECT 14, 2, 3
  UNION ALL SELECT 14, 3, 2
  UNION ALL SELECT 15, 1, 4
  UNION ALL SELECT 15, 2, 3
  UNION ALL SELECT 15, 3, 2
  UNION ALL SELECT 16, 1, 4
  UNION ALL SELECT 16, 2, 3
  UNION ALL SELECT 16, 3, 3
  UNION ALL SELECT 17, 1, 4
  UNION ALL SELECT 17, 2, 3
  UNION ALL SELECT 17, 3, 3
  UNION ALL SELECT 18, 1, 4
  UNION ALL SELECT 18, 2, 3
  UNION ALL SELECT 18, 3, 3
  UNION ALL SELECT 18, 4, 1
  UNION ALL SELECT 19, 1, 4
  UNION ALL SELECT 19, 2, 3
  UNION ALL SELECT 19, 3, 3
  UNION ALL SELECT 19, 4, 1
  UNION ALL SELECT 20, 1, 4
  UNION ALL SELECT 20, 2, 3
  UNION ALL SELECT 20, 3, 3
  UNION ALL SELECT 20, 4, 2
) t (character_level, spell_level, slots);
