-- Blood Hunter class resources: Blood Maledict + Grit (Gunslinger Fighter)
-- Idempotente: usa INSERT ... WHERE NOT EXISTS para no duplicar.
SET NAMES utf8mb4;

SET @bh_id      = (SELECT id FROM classes WHERE index_name = 'blood-hunter');
SET @fighter_id = (SELECT id FROM classes WHERE index_name = 'fighter');

-- Blood Maledict: proficiency_bonus uses, recovered on Long Rest
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @bh_id,
       'Blood Maledict',
       'blood-maledict',
       'Uses per proficiency bonus. Expend a use as a bonus action to activate a Blood Curse. Recovered on Long Rest.',
       'proficiency_bonus',
       'LONG_REST',
       1,
       NULL
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'blood-maledict');

-- Grit: wisdom_modifier (min 1), recovered on Short Rest. Only for Gunslinger subclass.
INSERT INTO class_resources (class_id, name, index_name, description, max_formula, recovery_type, level_unlocked, subclass_restriction)
SELECT @fighter_id,
       'Grit',
       'grit',
       'Grit points equal to your Wisdom modifier (minimum 1). Spend to use Trick Shots. Recovered on Short Rest.',
       'wisdom_modifier_min1',
       'SHORT_REST',
       3,
       'gunslinger'
WHERE NOT EXISTS (SELECT 1 FROM class_resources WHERE index_name = 'grit');
