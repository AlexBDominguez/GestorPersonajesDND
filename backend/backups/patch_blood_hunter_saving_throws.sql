-- Fixes Blood Hunter saving throw proficiencies.
-- The original seed used 'dexterity' and 'intelligence' but the code checks 'dex' and 'int'.
-- Step 1: correct the raw data in class_saving_throws.
-- Step 2: set proficient = true on existing character saving throws for Blood Hunter characters.

-- Fix the class_saving_throws table (wrong full names → correct abbreviations)
DELETE FROM class_saving_throws
WHERE class_id = (SELECT id FROM classes WHERE index_name = 'blood-hunter')
  AND saving_throw IN ('dexterity', 'intelligence');

INSERT IGNORE INTO class_saving_throws (class_id, saving_throw)
SELECT id, 'dex' FROM classes WHERE index_name = 'blood-hunter';

INSERT IGNORE INTO class_saving_throws (class_id, saving_throw)
SELECT id, 'int' FROM classes WHERE index_name = 'blood-hunter';

-- Fix existing Blood Hunter characters: mark DEX and INT saving throws as proficient
UPDATE character_saving_throws cst
JOIN characters pc ON cst.character_id = pc.id
JOIN classes c ON pc.class_id = c.id
SET cst.proficient = 1
WHERE c.index_name = 'blood-hunter'
  AND cst.ability_score IN ('dex', 'int');
