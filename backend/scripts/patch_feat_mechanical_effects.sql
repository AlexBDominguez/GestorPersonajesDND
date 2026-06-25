-- Backfill de bonos numéricos estructurados para feats que no tenían lógica dedicada
-- en PendingTaskService.applyFeatEffects (caían en el "default:" y no hacían nada).
-- Ver FeatMechanicalEffectService: si un feat tiene effect_modifier_type/effect_modifier_value,
-- se aplica automáticamente como CharacterActiveEffect al asignarlo.
SET NAMES utf8mb4;

-- Mobile (PHB): +10 ft de velocidad.
UPDATE feats
SET effect_modifier_type = 'SPEED', effect_modifier_value = '+10'
WHERE index_name = 'mobile';
