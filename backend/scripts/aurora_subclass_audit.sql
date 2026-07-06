-- Read-only audit query for #8.2: lists Aurora-sourced (non-PHB) subclasses and their
-- features, to find which ones need a class_resources row. Does not modify anything.

-- 1. Subclases que NO son PHB (es decir, llegaron vía Aurora), con su clase base.
SELECT s.id AS subclass_id, s.index_name, s.name, s.source, c.name AS class_name
FROM subclasses s
JOIN classes c ON c.id = s.class_id
WHERE s.source <> 'PHB'
ORDER BY c.name, s.name;

-- 2. Todas las features de esas subclases, con nivel y descripción completa
-- (para poder leer el texto y ver cuáles tienen pinta de recurso: "X veces por
-- descanso corto/largo", "gasta Y puntos", "cargas", etc.)
SELECT
  c.name  AS class_name,
  s.name  AS subclass_name,
  s.source,
  sf.level,
  sf.index_name,
  sf.name AS feature_name,
  sf.consumes_resource_index_name,
  sf.description
FROM subclass_features sf
JOIN subclasses s ON s.id = sf.subclass_id
JOIN classes c ON c.id = s.class_id
WHERE s.source <> 'PHB'
ORDER BY c.name, s.name, sf.level;

-- 2b. Igual que arriba pero solo las que "suenan" a recurso limitado (filtro rápido
-- por palabras clave en la descripción) para priorizar la revisión.
SELECT
  c.name  AS class_name,
  s.name  AS subclass_name,
  sf.level,
  sf.index_name,
  sf.name AS feature_name,
  sf.description
FROM subclass_features sf
JOIN subclasses s ON s.id = sf.subclass_id
JOIN classes c ON c.id = s.class_id
WHERE s.source <> 'PHB'
  AND (
    sf.description LIKE '%per short rest%' OR
    sf.description LIKE '%per long rest%' OR
    sf.description LIKE '%per day%' OR
    sf.description LIKE '%times per%' OR
    sf.description LIKE '%number of times%' OR
    sf.description LIKE '%expend a use%' OR
    sf.description LIKE '%regain%use%' OR
    sf.description LIKE '%charge%' OR
    sf.description LIKE '%points equal to%'
  )
ORDER BY c.name, s.name, sf.level;

-- 3. Recursos ya sembrados en class_resources (para no auditar dos veces lo mismo).
SELECT cr.id, c.name AS class_name, cr.name, cr.index_name, cr.max_formula,
       cr.recovery_type, cr.level_unlocked, cr.subclass_restriction
FROM class_resources cr
JOIN classes c ON c.id = cr.class_id
ORDER BY c.name, cr.level_unlocked;
