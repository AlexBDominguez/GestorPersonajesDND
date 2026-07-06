-- Resource-pool mechanics layer, phase 3 (#8.2): link the 4 "tiered" public-API class
-- features to the single collapsed ClassResource seeded in phase 2
-- (patch_resource_pool_migration_phase2.sql), so the frontend's _realResourceFor()
-- (character_sheet_viewmodel.dart, uses consumesResourceIndexName ?? indexName) finds the
-- real backend resource no matter which tier is currently unlocked/surviving the
-- frontend's own tier-dedupe.
-- Idempotente: puede volver a ejecutarse sin efecto tras la primera vez.
SET NAMES utf8mb4;

-- Bardic Inspiration (Bard): bardic-inspiration-d6/d8/d10/d12 -> bardic-inspiration
UPDATE class_features
SET consumes_resource_index_name = 'bardic-inspiration'
WHERE index_name IN ('bardic-inspiration-d6', 'bardic-inspiration-d8', 'bardic-inspiration-d10', 'bardic-inspiration-d12');

-- Channel Divinity (Cleric): channel-divinity-1-rest/-2-rest/-3-rest -> channel-divinity-cleric
UPDATE class_features
SET consumes_resource_index_name = 'channel-divinity-cleric'
WHERE index_name IN ('channel-divinity-1-rest', 'channel-divinity-2-rest', 'channel-divinity-3-rest');

-- Action Surge (Fighter): action-surge-1-use/-2-uses -> action-surge
UPDATE class_features
SET consumes_resource_index_name = 'action-surge'
WHERE index_name IN ('action-surge-1-use', 'action-surge-2-uses');

-- Indomitable (Fighter): indomitable-1-use/-2-uses/-3-uses -> indomitable
UPDATE class_features
SET consumes_resource_index_name = 'indomitable'
WHERE index_name IN ('indomitable-1-use', 'indomitable-2-uses', 'indomitable-3-uses');
