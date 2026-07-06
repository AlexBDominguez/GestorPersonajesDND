-- Fix Grit (Gunslinger) recovery_type: seeded as SHORT_REST-only in patch_blood_hunter_resources.sql,
-- but the Adept Marksman feature text says "Regain all grit on a short or long rest". Under
-- CharacterClassResourceRepository's recovery query, a SHORT_REST row does NOT refill on a Long
-- Rest -- only LONG_REST and SHORT_OR_LONG_REST rows do. Found while auditing #8.2 phase 5, not
-- Aurora-specific (grit was seeded in an earlier phase), so it's its own small patch.
SET NAMES utf8mb4;

UPDATE class_resources
SET recovery_type = 'SHORT_OR_LONG_REST'
WHERE index_name = 'grit' AND recovery_type = 'SHORT_REST';
