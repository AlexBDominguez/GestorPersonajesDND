-- Patch: populate subclass_flavor for Aurora-imported subclasses that lack it.
-- Safe to re-run: only touches rows where subclass_flavor is NULL or empty.
-- Maps each class to its canonical archetype category label.
SET NAMES utf8mb4;

UPDATE subclasses s
INNER JOIN classes c ON s.class_id = c.id
SET s.subclass_flavor = CASE c.name
    WHEN 'Barbarian'    THEN 'Primal Path'
    WHEN 'Bard'         THEN 'Bard College'
    WHEN 'Cleric'       THEN 'Divine Domain'
    WHEN 'Druid'        THEN 'Druid Circle'
    WHEN 'Fighter'      THEN 'Martial Archetype'
    WHEN 'Monk'         THEN 'Monastic Tradition'
    WHEN 'Paladin'      THEN 'Sacred Oath'
    WHEN 'Ranger'       THEN 'Ranger Archetype'
    WHEN 'Rogue'        THEN 'Roguish Archetype'
    WHEN 'Sorcerer'     THEN 'Sorcerous Origin'
    WHEN 'Warlock'      THEN 'Otherworldly Patron'
    WHEN 'Wizard'       THEN 'Arcane Tradition'
    WHEN 'Artificer'    THEN 'Artificer Specialist'
    WHEN 'Blood Hunter' THEN 'Blood Hunter Order'
    ELSE s.subclass_flavor
END
WHERE s.subclass_flavor IS NULL OR s.subclass_flavor = '';
