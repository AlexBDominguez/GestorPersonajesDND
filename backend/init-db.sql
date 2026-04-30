-- Script de inicialización de Base de Datos MySQL para Gestor de Personajes D&D
-- Fecha de actualización: 18 de marzo de 2026

-- Recrear base de datos (se ejecuta al inicializar un contenedor nuevo)
DROP DATABASE IF EXISTS dnd_character_manager;
CREATE DATABASE dnd_character_manager CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE dnd_character_manager;

-- ============================================
-- Tabla: users (Usuarios)
-- ============================================
CREATE TABLE IF NOT EXISTS users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    created_at DATETIME NOT NULL,
    last_login DATETIME NULL,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    INDEX idx_users_username (username),
    INDEX idx_users_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

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
    num_skill_choices INT NOT NULL DEFAULT 0,
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
-- Tabla: class_skill_choices (Habilidades elegibles por clase)
-- ============================================
CREATE TABLE IF NOT EXISTS class_skill_choices (
    class_id BIGINT NOT NULL,
    num_choices INT NOT NULL,
    skill_index VARCHAR(100) NOT NULL,
    PRIMARY KEY (class_id, skill_index),
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
    description TEXT,
    INDEX idx_spell_level (level),
    INDEX idx_spell_name (name),
    INDEX idx_index_api (index_api)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Tabla: race_spells (Hechizos otorgados por Raza)
-- ============================================
CREATE TABLE IF NOT EXISTS race_spells (
    race_id BIGINT NOT NULL,
    spell_id BIGINT NOT NULL,
    PRIMARY KEY (race_id, spell_id),
    FOREIGN KEY (race_id) REFERENCES race(id) ON DELETE CASCADE,
    FOREIGN KEY (spell_id) REFERENCES spells(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Tabla: feat_spells (Hechizos otorgados por Feat)
-- ============================================
CREATE TABLE IF NOT EXISTS feat_spells (
    feat_id BIGINT NOT NULL,
    spell_id BIGINT NOT NULL,
    PRIMARY KEY (feat_id, spell_id),
    FOREIGN KEY (feat_id) REFERENCES feats(id) ON DELETE CASCADE,
    FOREIGN KEY (spell_id) REFERENCES spells(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ============================================
-- Tabla: languages (Idiomas)
-- ============================================
CREATE TABLE IF NOT EXISTS languages (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    index_name VARCHAR(255) UNIQUE,
    name VARCHAR(255),
    script VARCHAR(255),
    type VARCHAR(50),
    description TEXT,
    INDEX idx_languages_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Tabla: proficiencies (Competencias/Proficiencias)
-- ============================================
CREATE TABLE IF NOT EXISTS proficiencies (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    index_name VARCHAR(255) UNIQUE,
    name VARCHAR(255),
    type VARCHAR(100),
    description TEXT,
    INDEX idx_proficiencies_name (name),
    INDEX idx_proficiencies_type (type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Tabla: damage_types (Tipos de Daño)
-- ============================================
CREATE TABLE IF NOT EXISTS damage_types (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    index_name VARCHAR(255) UNIQUE,
    name VARCHAR(255),
    description TEXT,
    INDEX idx_damage_types_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Tabla: conditions (Condiciones)
-- ============================================
CREATE TABLE IF NOT EXISTS conditions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    index_name VARCHAR(255) UNIQUE,
    name VARCHAR(255),
    INDEX idx_conditions_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS condition_descriptions (
    condition_id BIGINT NOT NULL,
    description TEXT,
    FOREIGN KEY (condition_id) REFERENCES conditions(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Tabla: feats (Talentos)
-- ============================================
CREATE TABLE IF NOT EXISTS feats (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    index_name VARCHAR(255) UNIQUE,
    name VARCHAR(255),
    description TEXT,
    prerequisites TEXT,
    INDEX idx_feats_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Tabla: subclasses (Subclases)
-- ============================================
CREATE TABLE IF NOT EXISTS subclasses (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    class_id BIGINT NOT NULL,
    index_name VARCHAR(255) UNIQUE,
    name VARCHAR(255),
    description TEXT,
    subclass_flavor TEXT,
    FOREIGN KEY (class_id) REFERENCES classes(id) ON DELETE CASCADE,
    INDEX idx_subclasses_class (class_id),
    INDEX idx_subclasses_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Tabla: subclass_features (Rasgos de Subclase)
-- ============================================
CREATE TABLE IF NOT EXISTS subclass_features (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    subclass_id BIGINT NOT NULL,
    index_name VARCHAR(255),
    name VARCHAR(255),
    level INT NOT NULL,
    description TEXT,
    FOREIGN KEY (subclass_id) REFERENCES subclasses(id) ON DELETE CASCADE,
    INDEX idx_subclass_features_level (subclass_id, level)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Tabla: active_effects (Efectos Activos)
-- ============================================
CREATE TABLE IF NOT EXISTS active_effects (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    index_name VARCHAR(255) UNIQUE,
    name VARCHAR(255),
    description TEXT,
    modifier_value VARCHAR(255),
    duration VARCHAR(255),
    requires_concentration BOOLEAN NOT NULL DEFAULT FALSE,
    source VARCHAR(255),
    conditions TEXT,
    INDEX idx_active_effects_name (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS effect_modifiers (
    effect_id BIGINT NOT NULL,
    modifier_type VARCHAR(100),
    FOREIGN KEY (effect_id) REFERENCES active_effects(id) ON DELETE CASCADE
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
    user_id BIGINT NOT NULL,
    race_id BIGINT,
    class_id BIGINT,
    subclass_id BIGINT,
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
    alignment VARCHAR(255),
    temporary_hp INT NOT NULL DEFAULT 0,
    death_save_successes INT NOT NULL DEFAULT 0,
    death_save_failures INT NOT NULL DEFAULT 0,
    has_inspiration BOOLEAN NOT NULL DEFAULT FALSE,
    experience_points INT NOT NULL DEFAULT 0,
    speed_modifier INT NOT NULL DEFAULT 0,
    natural_armor_bonus INT NULL,
    initiative_bonus INT NOT NULL DEFAULT 0,
    available_hit_dice INT NOT NULL DEFAULT 0,
    age INT NULL,
    height VARCHAR(255),
    weight VARCHAR(255),
    eyes VARCHAR(255),
    skin VARCHAR(255),
    hair VARCHAR(255),
    appearance TEXT,
    allies_and_organizations TEXT,
    additional_treasure TEXT,
    character_history TEXT,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (race_id) REFERENCES race(id) ON DELETE SET NULL,
    FOREIGN KEY (class_id) REFERENCES classes(id) ON DELETE SET NULL,
    FOREIGN KEY (subclass_id) REFERENCES subclasses(id) ON DELETE SET NULL,
    FOREIGN KEY (background_id) REFERENCES backgrounds(id) ON DELETE SET NULL,
    INDEX idx_character_name (name),
    INDEX idx_character_level (level),
    INDEX idx_character_user (user_id)
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

-- Columna spell_source en character_spells
-- (si el script se ejecuta sobre una BD existente)
ALTER TABLE character_spells 
    ADD COLUMN IF NOT EXISTS spell_source VARCHAR(20) DEFAULT 'CLASS';

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
-- Tabla: character_languages (Idiomas del Personaje)
-- ============================================
CREATE TABLE IF NOT EXISTS character_languages (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    character_id BIGINT NOT NULL,
    language_id BIGINT NOT NULL,
    source VARCHAR(255) NULL,
    notes VARCHAR(255) NULL,
    FOREIGN KEY (character_id) REFERENCES characters(id) ON DELETE CASCADE,
    FOREIGN KEY (language_id) REFERENCES languages(id) ON DELETE CASCADE,
    UNIQUE KEY uq_character_language (character_id, language_id),
    INDEX idx_character_languages (character_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Tabla: character_proficiencies (Proficiencias del Personaje)
-- ============================================
CREATE TABLE IF NOT EXISTS character_proficiencies (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    character_id BIGINT NOT NULL,
    proficiency_id BIGINT NOT NULL,
    source VARCHAR(255) NULL,
    notes TEXT,
    FOREIGN KEY (character_id) REFERENCES characters(id) ON DELETE CASCADE,
    FOREIGN KEY (proficiency_id) REFERENCES proficiencies(id) ON DELETE CASCADE,
    UNIQUE KEY uq_character_proficiency (character_id, proficiency_id),
    INDEX idx_character_proficiencies (character_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Tabla: character_feats (Talentos del Personaje)
-- ============================================
CREATE TABLE IF NOT EXISTS character_feats (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    character_id BIGINT NOT NULL,
    feat_id BIGINT NOT NULL,
    level_obtained INT NOT NULL,
    notes TEXT,
    FOREIGN KEY (character_id) REFERENCES characters(id) ON DELETE CASCADE,
    FOREIGN KEY (feat_id) REFERENCES feats(id) ON DELETE CASCADE,
    UNIQUE KEY uq_character_feat (character_id, feat_id),
    INDEX idx_character_feats (character_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Tabla: character_conditions (Condiciones del Personaje)
-- ============================================
CREATE TABLE IF NOT EXISTS character_conditions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    character_id BIGINT NOT NULL,
    condition_id BIGINT NOT NULL,
    duration_rounds INT NULL,
    remaining_rounds INT NULL,
    has_saving_throw BOOLEAN NOT NULL DEFAULT FALSE,
    saving_throw_dc INT NULL,
    saving_throw_ability VARCHAR(20) NULL,
    source VARCHAR(255) NULL,
    notes TEXT,
    applied_at DATETIME NULL,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    FOREIGN KEY (character_id) REFERENCES characters(id) ON DELETE CASCADE,
    FOREIGN KEY (condition_id) REFERENCES conditions(id) ON DELETE CASCADE,
    INDEX idx_character_conditions (character_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Tabla: character_equipment (Equipo equipado por ranura del Personaje)
-- ============================================
CREATE TABLE IF NOT EXISTS character_equipment (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    character_id BIGINT NOT NULL UNIQUE,
    main_hand_item_id BIGINT NULL,
    off_hand_item_id BIGINT NULL,
    armor_id BIGINT NULL,
    helmet_id BIGINT NULL,
    gloves_id BIGINT NULL,
    boots_id BIGINT NULL,
    cloak_id BIGINT NULL,
    amulet_id BIGINT NULL,
    ring1_id BIGINT NULL,
    ring2_id BIGINT NULL,
    belt_id BIGINT NULL,
    FOREIGN KEY (character_id) REFERENCES characters(id) ON DELETE CASCADE,
    FOREIGN KEY (main_hand_item_id) REFERENCES items(id) ON DELETE SET NULL,
    FOREIGN KEY (off_hand_item_id) REFERENCES items(id) ON DELETE SET NULL,
    FOREIGN KEY (armor_id) REFERENCES items(id) ON DELETE SET NULL,
    FOREIGN KEY (helmet_id) REFERENCES items(id) ON DELETE SET NULL,
    FOREIGN KEY (gloves_id) REFERENCES items(id) ON DELETE SET NULL,
    FOREIGN KEY (boots_id) REFERENCES items(id) ON DELETE SET NULL,
    FOREIGN KEY (cloak_id) REFERENCES items(id) ON DELETE SET NULL,
    FOREIGN KEY (amulet_id) REFERENCES items(id) ON DELETE SET NULL,
    FOREIGN KEY (ring1_id) REFERENCES items(id) ON DELETE SET NULL,
    FOREIGN KEY (ring2_id) REFERENCES items(id) ON DELETE SET NULL,
    FOREIGN KEY (belt_id) REFERENCES items(id) ON DELETE SET NULL,
    INDEX idx_character_equipment (character_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Tabla: character_active_effects (Efectos Activos del Personaje)
-- ============================================
CREATE TABLE IF NOT EXISTS character_active_effects (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    character_id BIGINT NOT NULL,
    effect_id BIGINT NOT NULL,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    applied_at DATETIME NULL,
    remaining_rounds INT NULL,
    caster_level INT NULL,
    notes TEXT,
    FOREIGN KEY (character_id) REFERENCES characters(id) ON DELETE CASCADE,
    FOREIGN KEY (effect_id) REFERENCES active_effects(id) ON DELETE CASCADE,
    INDEX idx_character_active_effects (character_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Tabla: character_money (Dinero del Personaje)
-- ============================================
CREATE TABLE IF NOT EXISTS character_money (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    character_id BIGINT NOT NULL UNIQUE,
    platinum INT NOT NULL DEFAULT 0,
    gold INT NOT NULL DEFAULT 0,
    electrum INT NOT NULL DEFAULT 0,
    silver INT NOT NULL DEFAULT 0,
    copper INT NOT NULL DEFAULT 0,
    FOREIGN KEY (character_id) REFERENCES characters(id) ON DELETE CASCADE,
    INDEX idx_character_money (character_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Tabla: class_resources (Recursos de Clase)
-- ============================================
CREATE TABLE IF NOT EXISTS class_resources (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    class_id BIGINT NOT NULL,
    name VARCHAR(255) NOT NULL,
    index_name VARCHAR(255),
    description TEXT,
    max_formula VARCHAR(255),
    recovery_type VARCHAR(100),
    level_unlocked INT NOT NULL DEFAULT 1,
    FOREIGN KEY (class_id) REFERENCES classes(id) ON DELETE CASCADE,
    INDEX idx_class_resources_class (class_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Tabla: character_class_resources (Recursos de Clase del Personaje)
-- ============================================
CREATE TABLE IF NOT EXISTS character_class_resources (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    character_id BIGINT NOT NULL,
    class_resource_id BIGINT NOT NULL,
    max_amount INT NOT NULL DEFAULT 0,
    current_amount INT NOT NULL DEFAULT 0,
    FOREIGN KEY (character_id) REFERENCES characters(id) ON DELETE CASCADE,
    FOREIGN KEY (class_resource_id) REFERENCES class_resources(id) ON DELETE CASCADE,
    INDEX idx_character_class_resources (character_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Tabla: character_damage_relations (Relaciones de Daño del Personaje)
-- ============================================
CREATE TABLE IF NOT EXISTS character_damage_relations (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    character_id BIGINT NOT NULL,
    damage_type_id BIGINT NOT NULL,
    relation_type VARCHAR(50) NOT NULL,
    source VARCHAR(255),
    temporary BOOLEAN NOT NULL DEFAULT FALSE,
    conditions TEXT,
    notes TEXT,
    FOREIGN KEY (character_id) REFERENCES characters(id) ON DELETE CASCADE,
    FOREIGN KEY (damage_type_id) REFERENCES damage_types(id) ON DELETE CASCADE,
    UNIQUE KEY uq_character_damage (character_id, damage_type_id, relation_type),
    INDEX idx_character_damage_relations (character_id)
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

/*
-- Vista: Hechizos de personajes con detalles
CREATE OR REPLACE VIEW v_character_spells_detail AS
SELECT 
    cs.id,
    c.name AS character_name,
    s.name AS spell_name,
    s.level AS spell_level,
    s.school,
    cs.prepared,
    cs.times_cast
FROM character_spells cs
JOIN characters c ON cs.character_id = c.id
JOIN spells s ON cs.spell_id = s.id;

*/

CREATE OR REPLACE VIEW v_character_spells_detail AS
SELECT 
    cs.id,
    c.name AS character_name,
    s.name AS spell_name,
    s.level AS spell_level,
    s.school,
    s.casting_time,
    cs.prepared,
    cs.learned,
    cs.times_cast,
    cs.spell_source
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
-- - Tablas de recursos de clase: class_resources, character_class_resources
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
