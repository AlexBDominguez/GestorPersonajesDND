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
-- Tabla: characters (Personajes de Jugador)
-- ============================================
CREATE TABLE IF NOT EXISTS characters (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    level INT NOT NULL DEFAULT 1,
    race_id BIGINT,
    class_id BIGINT,
    max_hp INT NOT NULL DEFAULT 0,
    current_hp INT NOT NULL DEFAULT 0,
    proficiency_bonus INT NOT NULL DEFAULT 2,
    backstory TEXT,
    FOREIGN KEY (race_id) REFERENCES race(id) ON DELETE SET NULL,
    FOREIGN KEY (class_id) REFERENCES classes(id) ON DELETE SET NULL,
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
    cl.hit_die
FROM characters c
LEFT JOIN race r ON c.race_id = r.id
LEFT JOIN classes cl ON c.class_id = cl.id;

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
