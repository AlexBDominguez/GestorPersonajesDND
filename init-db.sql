-- Script de inicialización de Base de Datos MySQL para Gestor de Personajes D&D
-- Fecha de creación: 4 de marzo de 2026

-- Crear base de datos
CREATE DATABASE IF NOT EXISTS dnd_character_manager CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE dnd_character_manager;

-- ============================================
-- Tabla: classes (Clases de D&D)
-- ============================================
CREATE TABLE IF NOT EXISTS classes (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    index_name VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    hit_die INT NOT NULL,
    spellcasting_ability VARCHAR(255),
    subclass_level INT,
    description TEXT,
    INDEX idx_index_name (index_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Tabla: class_proficiencies (Competencias de Clases)
-- ============================================
CREATE TABLE IF NOT EXISTS class_proficiencies (
    class_id BIGINT NOT NULL,
    proficiency VARCHAR(255) NOT NULL,
    PRIMARY KEY (class_id, proficiency),
    FOREIGN KEY (class_id) REFERENCES classes(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Tabla: class_saving_throws (Salvaciones de Clases)
-- ============================================
CREATE TABLE IF NOT EXISTS class_saving_throws (
    class_id BIGINT NOT NULL,
    saving_throw VARCHAR(255) NOT NULL,
    PRIMARY KEY (class_id, saving_throw),
    FOREIGN KEY (class_id) REFERENCES classes(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Tabla: race (Razas de D&D)
-- ============================================
CREATE TABLE IF NOT EXISTS race (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    index_name VARCHAR(255) NOT NULL,
    name VARCHAR(255) NOT NULL,
    size VARCHAR(50),
    speed INT NOT NULL,
    description TEXT,
    INDEX idx_race_index (index_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Tabla: race_ability_bonuses (Bonificadores de Habilidad por Raza)
-- ============================================
CREATE TABLE IF NOT EXISTS race_ability_bonuses (
    race_id BIGINT NOT NULL,
    ability VARCHAR(255) NOT NULL,
    bonus INT NOT NULL,
    PRIMARY KEY (race_id, ability),
    FOREIGN KEY (race_id) REFERENCES race(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Tabla: spells (Hechizos)
-- ============================================
CREATE TABLE IF NOT EXISTS spells (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    index_api VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    level INT NOT NULL,
    school VARCHAR(255),
    casting_time VARCHAR(255),
    `range` VARCHAR(255),
    duration VARCHAR(255),
    components VARCHAR(255),
    description VARCHAR(2000),
    INDEX idx_spell_level (level),
    INDEX idx_spell_name (name),
    INDEX idx_index_api (index_api)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Tabla: backgrounds (Trasfondos)
-- ============================================
CREATE TABLE IF NOT EXISTS backgrounds (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    index_name VARCHAR(255) UNIQUE,
    name VARCHAR(255) UNIQUE,
    language_options INT NOT NULL DEFAULT 0,
    feature TEXT,
    feature_description TEXT,
    description TEXT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS background_skill_proficiencies (
    background_id BIGINT NOT NULL,
    skill VARCHAR(255) NOT NULL,
    PRIMARY KEY (background_id, skill),
    FOREIGN KEY (background_id) REFERENCES backgrounds(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS background_tool_proficiencies (
    background_id BIGINT NOT NULL,
    tool VARCHAR(255) NOT NULL,
    PRIMARY KEY (background_id, tool),
    FOREIGN KEY (background_id) REFERENCES backgrounds(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS background_languages (
    background_id BIGINT NOT NULL,
    language VARCHAR(255) NOT NULL,
    PRIMARY KEY (background_id, language),
    FOREIGN KEY (background_id) REFERENCES backgrounds(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS background_personality_traits (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    background_id BIGINT NOT NULL,
    trait TEXT,
    FOREIGN KEY (background_id) REFERENCES backgrounds(id) ON DELETE CASCADE,
    INDEX idx_background_personality_traits_background (background_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS background_ideals (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    background_id BIGINT NOT NULL,
    ideal TEXT,
    FOREIGN KEY (background_id) REFERENCES backgrounds(id) ON DELETE CASCADE,
    INDEX idx_background_ideals_background (background_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS background_bonds (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    background_id BIGINT NOT NULL,
    bond TEXT,
    FOREIGN KEY (background_id) REFERENCES backgrounds(id) ON DELETE CASCADE,
    INDEX idx_background_bonds_background (background_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS background_flaws (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    background_id BIGINT NOT NULL,
    flaw TEXT,
    FOREIGN KEY (background_id) REFERENCES backgrounds(id) ON DELETE CASCADE,
    INDEX idx_background_flaws_background (background_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Tabla: items (Objetos)
-- ============================================
CREATE TABLE IF NOT EXISTS items (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    index_name VARCHAR(255) UNIQUE,
    name VARCHAR(255),
    item_type VARCHAR(255),
    category VARCHAR(255),
    weight DOUBLE NOT NULL DEFAULT 0,
    cost_in_copper INT NOT NULL DEFAULT 0,
    description TEXT,
    damage_dice VARCHAR(50),
    damage_type VARCHAR(100),
    weapon_range VARCHAR(100),
    armor_class INT,
    armor_type VARCHAR(100),
    max_dex_bonus INT,
    minimum_strength INT,
    stealth_disadvantage BOOLEAN NOT NULL DEFAULT FALSE,
    rarity VARCHAR(100),
    requires_attunement BOOLEAN NOT NULL DEFAULT FALSE,
    attunement_requierement VARCHAR(255),
    INDEX idx_items_name (name),
    INDEX idx_items_item_type (item_type),
    INDEX idx_items_category (category)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS item_properties (
    item_id BIGINT NOT NULL,
    property VARCHAR(255) NOT NULL,
    PRIMARY KEY (item_id, property),
    FOREIGN KEY (item_id) REFERENCES items(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Tabla: skills (Habilidades)
-- ============================================
CREATE TABLE IF NOT EXISTS skills (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    index_name VARCHAR(255) UNIQUE,
    name VARCHAR(255),
    ability_score VARCHAR(10),
    description TEXT,
    INDEX idx_skills_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Tabla: characters (Personajes de Jugador)
-- ============================================
CREATE TABLE IF NOT EXISTS characters (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    level INT NOT NULL DEFAULT 1,
    race_id BIGINT,
    class_id BIGINT,
    background_id BIGINT,
    copper_pieces INT NOT NULL DEFAULT 0,
    silver_pieces INT NOT NULL DEFAULT 0,
    electrum_pieces INT NOT NULL DEFAULT 0,
    gold_pieces INT NOT NULL DEFAULT 0,
    platinum_pieces INT NOT NULL DEFAULT 0,
    personality_traits TEXT,
    ideals TEXT,
    bonds TEXT,
    flaws TEXT,
    max_hp INT NOT NULL DEFAULT 0,
    current_hp INT NOT NULL DEFAULT 0,
    proficiency_bonus INT NOT NULL DEFAULT 2,
    backstory TEXT,
    FOREIGN KEY (race_id) REFERENCES race(id) ON DELETE SET NULL,
    FOREIGN KEY (class_id) REFERENCES classes(id) ON DELETE SET NULL,
    FOREIGN KEY (background_id) REFERENCES backgrounds(id) ON DELETE SET NULL,
    INDEX idx_character_name (name),
    INDEX idx_character_level (level)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Tabla: character_abilities (Puntuaciones de Habilidad del Personaje)
-- ============================================
CREATE TABLE IF NOT EXISTS character_abilities (
    character_id BIGINT NOT NULL,
    ability VARCHAR(255) NOT NULL,
    score INT NOT NULL,
    PRIMARY KEY (character_id, ability),
    FOREIGN KEY (character_id) REFERENCES characters(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Tabla: character_spells (Hechizos del Personaje)
-- ============================================
CREATE TABLE IF NOT EXISTS character_spells (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    character_id BIGINT NOT NULL,
    spell_id BIGINT NOT NULL,
    prepared BOOLEAN NOT NULL DEFAULT FALSE,
    learned BOOLEAN NOT NULL DEFAULT FALSE,
    times_cast INT NOT NULL DEFAULT 0,
    FOREIGN KEY (character_id) REFERENCES characters(id) ON DELETE CASCADE,
    FOREIGN KEY (spell_id) REFERENCES spells(id) ON DELETE CASCADE,
    UNIQUE KEY unique_character_spell (character_id, spell_id),
    INDEX idx_character_spells_char (character_id),
    INDEX idx_character_spells_spell (spell_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Tabla: character_spell_slots (Espacios de Hechizo del Personaje)
-- ============================================
CREATE TABLE IF NOT EXISTS character_spell_slots (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    character_id BIGINT NOT NULL,
    spell_level INT NOT NULL,
    max_slots INT NOT NULL DEFAULT 0,
    used_slots INT NOT NULL DEFAULT 0,
    FOREIGN KEY (character_id) REFERENCES characters(id) ON DELETE CASCADE,
    UNIQUE KEY unique_character_spell_level (character_id, spell_level),
    INDEX idx_char_spell_slots (character_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Tabla: character_inventories (Inventario de Personaje)
-- ============================================
CREATE TABLE IF NOT EXISTS character_inventories (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    character_id BIGINT NOT NULL,
    item_id BIGINT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    equipped BOOLEAN NOT NULL DEFAULT FALSE,
    attuned BOOLEAN NOT NULL DEFAULT FALSE,
    notes TEXT,
    FOREIGN KEY (character_id) REFERENCES characters(id) ON DELETE CASCADE,
    FOREIGN KEY (item_id) REFERENCES items(id) ON DELETE CASCADE,
    INDEX idx_character_inventory_character (character_id),
    INDEX idx_character_inventory_item (item_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Tabla: character_skills (Skills de Personaje)
-- ============================================
CREATE TABLE IF NOT EXISTS character_skills (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    character_id BIGINT NOT NULL,
    skill_id BIGINT NOT NULL,
    proficient BOOLEAN NOT NULL DEFAULT FALSE,
    expertise BOOLEAN NOT NULL DEFAULT FALSE,
    FOREIGN KEY (character_id) REFERENCES characters(id) ON DELETE CASCADE,
    FOREIGN KEY (skill_id) REFERENCES skills(id) ON DELETE CASCADE,
    UNIQUE KEY uq_character_skill (character_id, skill_id),
    INDEX idx_character_skills_character (character_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Tabla: character_saving_throws (TS de Personaje)
-- ============================================
CREATE TABLE IF NOT EXISTS character_saving_throws (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    character_id BIGINT NOT NULL,
    ability_score VARCHAR(10) NOT NULL,
    proficient BOOLEAN NOT NULL DEFAULT FALSE,
    FOREIGN KEY (character_id) REFERENCES characters(id) ON DELETE CASCADE,
    UNIQUE KEY uq_character_saving_throw (character_id, ability_score),
    INDEX idx_character_saving_throws_character (character_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Tabla: pending_tasks (Tareas Pendientes)
-- ============================================
CREATE TABLE IF NOT EXISTS pending_tasks (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    character_id BIGINT NOT NULL,
    task_type VARCHAR(100),
    related_level INT NOT NULL,
    description TEXT,
    completed BOOLEAN NOT NULL DEFAULT FALSE,
    metadata TEXT,
    FOREIGN KEY (character_id) REFERENCES characters(id) ON DELETE CASCADE,
    INDEX idx_pending_tasks_character (character_id),
    INDEX idx_pending_tasks_completed (completed)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Tabla: spell_slot_progression (Progresión de Espacios de Hechizo por Clase)
-- ============================================
CREATE TABLE IF NOT EXISTS spell_slot_progression (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    class_id BIGINT NOT NULL,
    character_level INT NOT NULL,
    spell_level INT NOT NULL,
    slots INT NOT NULL DEFAULT 0,
    FOREIGN KEY (class_id) REFERENCES classes(id) ON DELETE CASCADE,
    UNIQUE KEY unique_class_char_spell_level (class_id, character_level, spell_level),
    INDEX idx_spell_slot_prog_class (class_id),
    INDEX idx_spell_slot_prog_level (character_level)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Tabla: class_features (Rasgos de Clase)
-- ============================================
CREATE TABLE IF NOT EXISTS class_features (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    class_id BIGINT NOT NULL,
    index_name VARCHAR(255),
    name VARCHAR(255),
    level INT NOT NULL,
    description TEXT,
    api_url VARCHAR(255),
    FOREIGN KEY (class_id) REFERENCES classes(id) ON DELETE CASCADE,
    UNIQUE KEY uq_class_feature_index_name (index_name),
    INDEX idx_class_features_class_level (class_id, level)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Tabla: character_features (Rasgos obtenidos por personaje)
-- ============================================
CREATE TABLE IF NOT EXISTS character_features (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    character_id BIGINT NOT NULL,
    class_feature_id BIGINT NOT NULL,
    level_obtained INT NOT NULL,
    notes TEXT,
    FOREIGN KEY (character_id) REFERENCES characters(id) ON DELETE CASCADE,
    FOREIGN KEY (class_feature_id) REFERENCES class_features(id) ON DELETE CASCADE,
    INDEX idx_character_features_character (character_id),
    INDEX idx_character_features_feature (class_feature_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Tabla: class_level_progression (Progresión de Nivel de Clase)
-- ============================================
CREATE TABLE IF NOT EXISTS class_level_progression (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    dnd_class_id BIGINT NOT NULL,
    level INT NOT NULL,
    FOREIGN KEY (dnd_class_id) REFERENCES classes(id) ON DELETE CASCADE,
    UNIQUE KEY unique_class_level (dnd_class_id, level),
    INDEX idx_class_level_prog (dnd_class_id, level)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Tabla: class_level_feature (Características de Nivel de Clase)
-- ============================================
CREATE TABLE IF NOT EXISTS class_level_feature (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    progression_id BIGINT NOT NULL,
    type VARCHAR(50) NOT NULL,
    requires_choice BOOLEAN NOT NULL DEFAULT FALSE,
    metadata TEXT,
    FOREIGN KEY (progression_id) REFERENCES class_level_progression(id) ON DELETE CASCADE,
    INDEX idx_class_feature_prog (progression_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Tabla: level_up_task (Tareas de Subida de Nivel)
-- ============================================
CREATE TABLE IF NOT EXISTS level_up_task (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    character_id BIGINT NOT NULL,
    target_level INT NOT NULL,
    type VARCHAR(50) NOT NULL,
    completed BOOLEAN NOT NULL DEFAULT FALSE,
    feature_type VARCHAR(50),
    metadata TEXT,
    FOREIGN KEY (character_id) REFERENCES characters(id) ON DELETE CASCADE,
    INDEX idx_levelup_char (character_id),
    INDEX idx_levelup_completed (completed)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Vistas útiles para consultas comunes
-- ============================================

-- Vista: Personajes con información completa
CREATE OR REPLACE VIEW v_character_full_info AS
SELECT 
    c.id,
    c.name,
    c.level,
    c.max_hp,
    c.current_hp,
    c.proficiency_bonus,
    r.name AS race_name,
    cl.name AS class_name,
    b.name AS background_name,
    cl.hit_die
FROM characters c
LEFT JOIN race r ON c.race_id = r.id
LEFT JOIN classes cl ON c.class_id = cl.id
LEFT JOIN backgrounds b ON c.background_id = b.id;

-- Vista: Hechizos de personajes con detalles
CREATE OR REPLACE VIEW v_character_spells_detail AS
SELECT 
    cs.id,
    c.name AS character_name,
    s.name AS spell_name,
    s.level AS spell_level,
    s.school,
    cs.prepared,
    cs.learned,
    cs.times_cast
FROM character_spells cs
JOIN characters c ON cs.character_id = c.id
JOIN spells s ON cs.spell_id = s.id;

-- ============================================
-- Índices adicionales para optimización
-- ============================================

-- Índices compuestos para búsquedas frecuentes
CREATE INDEX idx_char_race_class ON characters(race_id, class_id);
CREATE INDEX idx_spell_level_school ON spells(level, school);

-- ============================================
-- Comentarios informativos
-- ============================================

-- Este script crea la estructura completa de la base de datos para el gestor de personajes D&D
-- Incluye:
-- - Tablas principales: classes, race, spells, characters
-- - Tablas de relación: character_spells, character_spell_slots
-- - Tablas de progresión: spell_slot_progression, class_level_progression, class_level_feature
-- - Tablas de elementos de colección: class_proficiencies, class_saving_throws, race_ability_bonuses, character_abilities
-- - Tabla de gestión: level_up_task
-- - Vistas para facilitar consultas comunes
-- 
-- Para usar este script:
-- 1. Asegúrate de tener MySQL instalado y en ejecución
-- 2. Ejecuta: mysql -u tu_usuario -p < init-db.sql
-- 3. Configura tu application.properties con los datos de conexión:
--    spring.datasource.url=jdbc:mysql://localhost:3306/dnd_character_manager
--    spring.datasource.username=tu_usuario
--    spring.datasource.password=tu_contraseña

COMMIT;
