-- =============================================================================
-- Migración: efectos funcionales de items mágicos existentes
-- Ejecutar UNA VEZ contra dnd_character_manager tras reiniciar el backend
-- (Hibernate añade las columnas set_str_to..set_cha_to con ddl-auto=update)
-- =============================================================================

USE dnd_character_manager;

-- Ring of Protection: +1 AC y +1 a todas las saving throws
UPDATE items
SET bonus_ac = 1,
    bonus_saving_throws = 1
WHERE index_name = 'ring-of-protection';

-- Gauntlets of Ogre Power: STR = 19 (no efecto si STR >= 19)
UPDATE items
SET set_str_to = 19
WHERE index_name = 'gauntlets-of-ogre-power';

-- Headband of Intellect: INT = 19 (no efecto si INT >= 19)
UPDATE items
SET set_int_to = 19
WHERE index_name = 'headband-of-intellect';

-- Cloak of Elvenkind y Necklace of Adaptation: sin stats numéricas modificables,
-- sus efectos (advantage/disadvantage, respirar en cualquier entorno) son situacionales
-- y están descritos en la descripción del item.
