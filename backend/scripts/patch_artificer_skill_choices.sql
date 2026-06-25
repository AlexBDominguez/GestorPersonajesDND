-- Artificer (ERLW/TCE, class_id 13 y 14) tiene num_skill_choices=2 en `classes`, pero
-- `class_skill_choices` no tenía ninguna fila — pide elegir 2 skills sin ofrecer ninguna
-- opción, así que el wizard nunca puede satisfacer classSkillPicksDone y el botón "Next"
-- en el step de Clase queda bloqueado para siempre. Ver Aurora_Fixes.md punto #18.
--
-- Lista oficial de skills del Artificer (TCE pg. 60 / ERLW pg. 56): elige 2 de Arcana,
-- History, Investigation, Medicine, Nature, Perception, Sleight of Hand.
--
-- Ejecutar con:
--   docker exec -i dnd-mysql mysql -u root -p$MYSQL_ROOT_PASSWORD dnd_character_manager < backend/scripts/patch_artificer_skill_choices.sql

INSERT INTO class_skill_choices (class_id, num_choices, skill_index) VALUES
  (13, 2, 'arcana'),
  (13, 2, 'history'),
  (13, 2, 'investigation'),
  (13, 2, 'medicine'),
  (13, 2, 'nature'),
  (13, 2, 'perception'),
  (13, 2, 'sleight-of-hand'),
  (14, 2, 'arcana'),
  (14, 2, 'history'),
  (14, 2, 'investigation'),
  (14, 2, 'medicine'),
  (14, 2, 'nature'),
  (14, 2, 'perception'),
  (14, 2, 'sleight-of-hand');
