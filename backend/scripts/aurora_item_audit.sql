-- Read-only audit query for #21: items sincronizados desde Aurora (no-PHB) y si sus
-- campos de bonus mecánico (bonusAc/bonusToHit/bonusSavingThrows/set*To) siguen a 0/null
-- (se espera que sí, ver comentario en AuroraItemMapper.java). No modifica nada.

-- 1. Resumen: cuántos items no-PHB hay y cuántos tienen algún bonus ya relleno.
SELECT
  source,
  COUNT(*) AS total_items,
  SUM(CASE WHEN bonus_ac <> 0 OR bonus_to_hit <> 0 OR bonus_saving_throws <> 0
           OR set_str_to IS NOT NULL OR set_dex_to IS NOT NULL OR set_con_to IS NOT NULL
           OR set_int_to IS NOT NULL OR set_wis_to IS NOT NULL OR set_cha_to IS NOT NULL
      THEN 1 ELSE 0 END) AS con_bonus_ya_relleno
FROM items
WHERE source <> 'PHB'
GROUP BY source
ORDER BY source;

-- 2. Items no-PHB con rareza/requiere-sintonización y su descripción completa
-- (para poder leer el texto libre y ver el patrón de frase que usa cada bonus).
SELECT
  id, index_name, name, source, item_type, rarity, requires_attunement,
  bonus_ac, bonus_to_hit, bonus_saving_throws,
  set_str_to, set_dex_to, set_con_to, set_int_to, set_wis_to, set_cha_to,
  description
FROM items
WHERE source <> 'PHB'
  AND (rarity IS NOT NULL AND rarity <> '' OR requires_attunement = 1)
ORDER BY item_type, name;
