# Documentación de Tablas de la Base de Datos D&D

Este documento describe el propósito de cada tabla en la base de datos `dnd_character_manager`. Las tablas están agrupadas por funcionalidad para facilitar su comprensión.

## 👤 Usuarios y Sistema

| Tabla | Descripción |
|-------|-------------|
| `users` | Almacena la información de las cuentas de usuario (login, email, estado). |

## 🦸 Personajes (Core)

Estas tablas almacenan la información principal de los personajes creados por los usuarios.

| Tabla | Descripción |
|-------|-------------|
| `characters` | La tabla central del personaje. Contiene stats básicos (nombre, nivel, HP, XP, alineamiento, historia, etc.) y referencias a su raza, clase y trasfondo. |
| `character_abilities` | Guarda las puntuaciones de características (Fuerza, Destreza, etc.) de cada personaje. |
| `character_money` | Almacena la cantidad de dinero (monedas de cobre, plata, oro, etc.) que tiene cada personaje. |
| `character_saving_throws` | Indica en qué tiradas de salvación es competente el personaje. |
| `pending_tasks` | Registra tareas pendientes para el personaje, como elecciones no tomadas al subir de nivel. |
| `level_up_task` | Tareas específicas relacionadas con el proceso de subida de nivel. |

## 🛡️ Clases y Subclases

Definición de las clases (Mago, Guerrero...) y sus mecánicas.

| Tabla | Descripción |
|-------|-------------|
| `classes` | Define las clases disponibles (ej. Bárbaro, Bardo) y sus atributos base (dado de golpe, estadística de conjuro). |
| `subclasses` | Define las especializaciones o arquetipos de cada clase. |
| `class_proficiencies` | Competencias (armaduras, armas) que otorga cada clase base. |
| `class_saving_throws` | Competencias en tiradas de salvación que otorga cada clase. |
| `class_features` | Rasgos y habilidades especiales que otorgan las clases. |
| `subclass_features` | Rasgos y habilidades especiales que otorgan las subclases. |
| `class_level_progression` | Define qué se obtiene en cada nivel de una clase. |
| `class_level_feature` | Detalla características específicas ganadas en ciertos niveles. |
| `class_resources` | Define recursos limitados de clase (ej. Puntos de Ki, Furia, Espacios de Conjuro). |
| `spell_slot_progression` | Tabla de referencia para saber cuántos espacios de conjuro tiene una clase en cada nivel. |
| `character_features` | Registra qué rasgos de clase ha obtenido y desbloqueado un personaje específico. |
| `character_class_resources` | Lleva la cuenta del uso de recursos de clase por personaje (ej. cuántas Furias le quedan). |

## 🧝 Razas

Definición de las razas (Humano, Elfo...) y sus bonificadores.

| Tabla | Descripción |
|-------|-------------|
| `race` | Define las razas disponibles, su velocidad, tamaño y descripción. |
| `race_ability_bonuses` | Bonificadores a las características que otorga cada raza (ej. +2 Destreza para Elfos). |

## 📜 Trasfondos (Backgrounds)

Historias de origen de los personajes.

| Tabla | Descripción |
|-------|-------------|
| `backgrounds` | Define los trasfondos disponibles (ej. Criminal, Soldado). |
| `background_skill_proficiencies` | Competencias en habilidades que otorga el trasfondo. |
| `background_tool_proficiencies` | Competencias en herramientas que otorga el trasfondo. |
| `background_languages` | Idiomas que otorga el trasfondo. |
| `background_personality_traits` | Listas de rasgos de personalidad sugeridos para el trasfondo. |
| `background_ideals` | Listas de ideales sugeridos. |
| `background_bonds` | Listas de vínculos sugeridos. |
| `background_flaws` | Listas de defectos sugeridos. |

## ✨ Magia y Hechizos

| Tabla | Descripción |
|-------|-------------|
| `spells` | Catálogo completo de hechizos, con su nivel, escuela, tiempo de lanzamiento, etc. |
| `character_spells` | Relación de qué hechizos conoce, tiene preparados o ha lanzado cada personaje. |
| `character_spell_slots` | Estado actual de los espacios de conjuro de un personaje (cuántos tiene y cuántos ha gastado). |

## 🎒 Inventario y Equipo

| Tabla | Descripción |
|-------|-------------|
| `items` | Catálogo de todos los objetos, armas y armaduras disponibles en el juego. |
| `item_properties` | Propiedades especiales de los objetos (ej. Versátil, Sutil). |
| `character_inventories` | Inventario del personaje: qué objetos tiene, cantidad, y si están equipados o sintonizados. |
| `character_equipment` | Representación detallada del equipo "puesto" en slots específicos (mano derecha, armadura, cabeza, etc.). |

## 🎯 Habilidades, Talentos y Proficiencias

| Tabla | Descripción |
|-------|-------------|
| `skills` | Lista de habilidades (Atletismo, Sigilo, Persuasión...). |
| `proficiencies` | Catálogo general de competencias (idiomas, herramientas, armas, armaduras). |
| `feats` | Catálogo de dotes o talentos opcionales. |
| `character_skills` | Qué habilidades tiene entrenadas cada personaje (o con pericia). |
| `character_proficiencies` | Otras competencias del personaje (idiomas, herramientas). |
| `character_feats` | Qué dotes ha escogido el personaje. |

## 💔 Condiciones, Efectos y Daño

Mecánicas de combate y estados alterados.

| Tabla | Descripción |
|-------|-------------|
| `damage_types` | Tipos de daño (Fuego, Cortante, Psíquico...). |
| `character_damage_relations` | Resistencias, inmunidades o vulnerabilidades de un personaje a ciertos tipos de daño. |
| `conditions` | Estados alterados (Cegado, Hechizado, Envenenado...). |
| `condition_descriptions` | Descripciones detalladas de los efectos de cada condición. |
| `character_conditions` | Condiciones que afectan actualmente a un personaje (y su duración). |
| `active_effects` | Efectos mágicos o temporales genéricos. |
| `effect_modifiers` | Cómo modifican las estadísticas los efectos activos. |
| `character_active_effects` | Efectos activos aplicados actualmente a un personaje. |

## 🗣️ Otros

| Tabla | Descripción |
|-------|-------------|
| `languages` | Catálogo de idiomas (Común, Élfico, Dracónico...). |
| `character_languages` | Idiomas que un personaje sabe hablar. |
