-- Multiclase (Aurora_Fixes.md #17), fase 1: backfill único de la nueva tabla puente
-- `player_character_classes`. Cada personaje existente mono-clase se refleja como una
-- única fila con class_order=0 (clase original, proficiencies/saves completas), a partir
-- de sus columnas class_id/subclass_id/level actuales en `characters`. A partir de este
-- backfill, `create()` ya escribe esta fila automáticamente para personajes nuevos.
--
-- Idempotente (NOT EXISTS) — se puede volver a ejecutar sin duplicar filas.
--
-- IMPORTANTE: ejecutar SOLO después de desplegar y reiniciar el backend con la entidad
-- PlayerCharacterClass ya desplegada (confirmar antes con
-- `SHOW TABLES LIKE 'player_character_classes';`), si no falla con "table doesn't exist".
--
-- Ejecutar con:
--   docker exec -i dnd-mysql mysql -u root -p$MYSQL_ROOT_PASSWORD dnd_character_manager < backend/scripts/backfill_player_character_classes.sql

INSERT INTO player_character_classes (character_id, class_id, subclass_id, level, class_order)
SELECT c.id, c.class_id, c.subclass_id, c.level, 0
FROM characters c
WHERE c.class_id IS NOT NULL
  AND NOT EXISTS (
      SELECT 1 FROM player_character_classes pcc WHERE pcc.character_id = c.id
  );
