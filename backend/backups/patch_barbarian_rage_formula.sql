-- Corrige la fórmula de máximo de usos de Furia del Bárbaro.
-- Antes usaba proficiency_bonus (incorrecto); ahora usa la tabla real de D&D 5e.
-- Tabla: niveles 1-2→2 usos, 3-5→3, 6-11→4, 12-16→5, 17-19→6, 20→ilimitado (999).
UPDATE class_resources
SET max_formula = 'barbarian_rage_table'
WHERE index_name = 'rage';
