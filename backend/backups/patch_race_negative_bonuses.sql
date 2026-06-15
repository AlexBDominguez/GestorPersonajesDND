-- Removes negative racial ability penalties stored by the old AuroraRaceMapper.
-- The mapper has been fixed to skip values <= 0 (D&D 5e has no negative racial modifiers).
-- Re-sync Aurora races after running this to repopulate race_ability_bonuses correctly.

SET NAMES utf8mb4;

DELETE FROM race_ability_bonuses WHERE bonus < 0;
