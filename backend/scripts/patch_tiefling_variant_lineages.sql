-- Las subrazas/linajes variantes de Tiefling (SCAG "Feral Tiefling" y los 7 linajes de
-- diablo arcano de MToF: Asmodeus, Baalzebub, Dispater, Fierna, Glasya, Levistus, Mammon,
-- Mephistopheles, Zariel) sustituyen por completo el bono de característica del Tiefling
-- base (PHB: +2 CHA +1 INT) en vez de sumarse a él. Antes de este fix, PlayerCharacterService
-- sumaba ambos, duplicando el +2 CHA (ver bug reportado: Tiefling con subraza salía con
-- demasiados bonificadores).
-- Tras ejecutar este script, hace falta reiniciar/redeploy del backend para que
-- replacesRaceAbilityBonus se lea correctamente en personajes nuevos.

SET NAMES utf8mb4;

UPDATE subraces s
JOIN race r ON s.race_id = r.id
SET s.replaces_race_ability_bonus = TRUE
WHERE r.name = 'Tiefling'
  AND (s.name = 'Feral Tiefling' OR s.name LIKE 'Tiefling (%');
