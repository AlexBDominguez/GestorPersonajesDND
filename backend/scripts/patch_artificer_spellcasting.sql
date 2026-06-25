-- Artificer (ERLW/TCE) tiene spellcasting_ability = NULL en la BD, así que el wizard
-- nunca lo detecta como lanzador de conjuros (CharacterCreatorViewModel.isSpellcaster
-- depende de selectedClass.spellCastingAbility) y el step de Spells nunca se activa
-- al crear un Artificiero. Ver Aurora_Fixes.md punto #18.
--
-- Artificer lanza conjuros con Inteligencia (PHB no aplica, pero la regla es la misma
-- en Eberron: Rising from the Last War y Tasha's Cauldron of Everything).
--
-- Ejecutar con:
--   docker exec -i dnd-mysql mysql -u root -p$MYSQL_ROOT_PASSWORD dnd_character_manager < backend/scripts/patch_artificer_spellcasting.sql

UPDATE classes
SET spellcasting_ability = 'int'
WHERE index_name IN ('ID_WOTC_TCOE_CLASS_ARTIFICER', 'ID_WOTC_ERLW_CLASS_ARTIFICER');
