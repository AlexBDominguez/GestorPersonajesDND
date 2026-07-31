-- Multiclase (Aurora_Fixes.md #17, fase 4a): atribuir cada hechizo conocido/preparado a la
-- clase concreta que lo otorga, para poder aplicar límites de "conocidos"/"preparados" por
-- clase cuando el personaje tiene dos clases lanzadoras (p.ej. Cleric+Druid, o Sorcerer+Bard).
--
-- ddl-auto=update añadirá la columna class_id sola al reiniciar el backend, pero NO toca
-- constraints existentes -- el UNIQUE KEY antiguo (character_id, spell_id) bloquea que dos
-- clases distintas conozcan el mismo hechizo (p.ej. Fireball en Wizard y en Sorcerer), así
-- que hace falta este ALTER manual antes de desplegar.
--
-- Ejecutar UNA VEZ en el VPS, ANTES de reiniciar/reconstruir el backend de esta fase:
--   docker exec -i dnd-mysql mysql -u root -p$MYSQL_ROOT_PASSWORD dnd_character_manager < backend/scripts/patch_character_spells_class_id.sql

ALTER TABLE character_spells
    ADD COLUMN class_id BIGINT NULL,
    ADD CONSTRAINT fk_character_spells_class
        FOREIGN KEY (class_id) REFERENCES classes(id) ON DELETE SET NULL;

ALTER TABLE character_spells
    DROP INDEX unique_character_spell,
    ADD UNIQUE KEY unique_character_spell (character_id, spell_id, class_id);
