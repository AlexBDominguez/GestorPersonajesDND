# Requisitos del Proyecto: Gestor de Personajes D&D 5e

> **Rama de trabajo:** `dev_pruebas`  
> **Fecha:** Marzo 2026

---

## 🎯 Propósito del Proyecto

Aplicación móvil/web para crear y gestionar personajes de D&D 5e. La idea es que un jugador pueda tener varios personajes y usar una **ficha digital interactiva y dinámica**: por ejemplo, que si el jugador usa un hechizo, la ficha lo reconozca y reduzca automáticamente el spell slot correspondiente.

---

## 🗄️ ANÁLISIS DE LA BASE DE DATOS – Preguntas y Respuestas

### ❓ Feats e Items están vacíos. ¿Por qué?

**Feats:**
La API `dnd5eapi.co` solo expone los feats del **SRD (System Reference Document)**, que son muy pocos (~6 feats: Alert, Grappler, Lucky, Mobile, Sentinel, Sharpshooter). El `FeatSyncService.java` está correctamente implementado y llama a `/api/feats`, pero la API simplemente no tiene más datos. Esto es una **limitación del proveedor de datos** (dnd5eapi). Si se quiere el catálogo completo de feats (más de 90), habría que añadir otra fuente de datos.

**Items:**
No existe ningún `ItemSyncService.java` en el backend. Los items están vacíos porque **nunca se implementó el servicio de sincronización**. La tabla `items` existe en la DB pero no se ha populado. La dnd5eapi sí tiene endpoints para ello: `/api/equipment`, `/api/magic-items`, etc. **Pendiente: crear `ItemSyncService.java`.**

---

### ❓ La tabla `race` parece incompleta. Faltan traits (darkvision, dwarven resilience...), subraza, age, languages, etc.

El `RaceSyncService.java` solo guarda: `name`, `size`, `speed`, `ability_bonuses`, `description`. Esto es porque el servicio fue implementado de forma básica y **no se desarrollaron las llamadas adicionales** que la API sí tiene disponibles:

| Dato faltante | Endpoint dnd5eapi disponible |
|---|---|
| Racial Traits (darkvision, etc.) | `/api/races/{index}/traits` |
| Subraces | `/api/races/{index}/subraces` + `/api/subraces/{index}` |
| Subrace traits | `/api/subraces/{index}/traits` |
| Languages | Incluido en `/api/races/{index}` como `languages` |
| Age, alignment description | Incluido en `/api/races/{index}` como `age`, `alignment` |

Además, **faltan tablas/entidades en la base de datos** para almacenar estos datos:
- `race_traits` (features de raza como darkvision, dwarven resilience, etc.)
- `subraces` (subrazas: Hill Dwarf, High Elf, etc.)
- `subrace_traits` (features ganadas por subraza)

Esto es análogo a como sí existen `class_features` para las clases, pero no para razas/subrazas. **Pendiente: ampliar entidad Race, crear entidades SubRace y RaceTrait, ampliar RaceSyncService.**

---

### ❓ `subclass_features` está completamente vacía. ¿Por qué?

**Bug encontrado en `SubclassSyncService.java`**, en el método `syncSubclassFeatures()`:

```java
// LÍNEA CON BUG (~línea 142):
Map<String, Object> featureDetail = restTemplate.getForObject("https://www.dnd5api.co" + featureUrl, Map.class);
//                                                                          ^^^
//                                                              FALTA la "e" => dnd5eapi.co

// CORRECTO:
Map<String, Object> featureDetail = restTemplate.getForObject("https://www.dnd5eapi.co" + featureUrl, Map.class);
```

La URL tiene un typo: `dnd5api.co` en lugar de `dnd5eapi.co`. Esto hace que todas las peticiones de detalles de subclass features fallen silenciosamente (el catch captura la excepción y continúa). **Corrección ya aplicada en el código.**

---

## 🎨 CAMBIOS VISUALES REQUERIDOS

### 1. Pantalla "Choose your Class" — Iconos Font Awesome por clase

**Dependencia a añadir:** `font_awesome_flutter`

Reemplazar el badge `dX` (hit dice) por un icono temático de Font Awesome por clase:

| Clase | Icono FA sugerido |
|---|---|
| Barbarian | `FaIcon(FontAwesomeIcons.axe)` |
| Bard | `FaIcon(FontAwesomeIcons.guitarElectric)` o lute |
| Cleric | `FaIcon(FontAwesomeIcons.sun)` o `FaIcon(FontAwesomeIcons.cross)` |
| Druid | `FaIcon(FontAwesomeIcons.leaf)` o `FaIcon(FontAwesomeIcons.paw)` |
| Fighter | `FaIcon(FontAwesomeIcons.shield)` |
| Monk | `FaIcon(FontAwesomeIcons.handFist)` |
| Paladin | `FaIcon(FontAwesomeIcons.shieldHalved)` |
| Ranger | `FaIcon(FontAwesomeIcons.bow)` → `FaIcon(FontAwesomeIcons.personRifle)` |
| Rogue | `FaIcon(FontAwesomeIcons.userNinja)` |
| Sorcerer | `FaIcon(FontAwesomeIcons.fire)` o `FaIcon(FontAwesomeIcons.wand)` |
| Warlock | `FaIcon(FontAwesomeIcons.skull)` |
| Wizard | `FaIcon(FontAwesomeIcons.bookOpenReader)` o `FaIcon(FontAwesomeIcons.wandMagicSparkles)` |

---

### 2. Al pulsar una clase → Nueva pantalla "Class Detail"

En lugar de expandir una card inline, al pulsar una clase se navega a **`ClassDetailScreen`**, una pantalla que muestra:
- Nombre e icono de la clase
- Hit dice que usa
- Saving throws con proficiencia
- Features por cada nivel (1-20), con cada feature expandible para ver su descripción

Dos botones al pie:
- **"Cancel"** → vuelve a la lista de clases sin seleccionar
- **"Add Class"** → avanza a la pantalla de opciones de clase

Esta pantalla es **genérica** (no hardcodeada por clase), obtiene los datos del objeto `ClassOption` pasado como argumento.

---

### 3. Tras "Add Class" → Pantalla "Class Options" (nivel + HP + opciones)

Pantalla con:
- **Selector de nivel** (dropdown 1-20). Al cambiar el nivel, se recargan las opciones pero manteniendo las ya elegidas.
- **Features acumuladas hasta ese nivel**, cada una mostrando:
  - Nombre + descripción expandible al pulsarla
  - Badge "pendiente" si hay una elección que el usuario no ha hecho aún
  - Si la feature requiere selección (ej. Weapon Mastery, Subclass), un dropdown con las opciones
  - Si se elige subclase → carga también las features de esa subclase
- **Sección "Manage HP"**: formularios para escribir la tirada de dado por nivel (nivel 1 es automático = máximo; niveles 2+ son formularios con validación del rango del dado de golpe de esa clase)

Dos botones al pie:
- **"Cancel"** → vuelve a la lista de clases sin guardar nada (clase no seleccionada)
- **"Add"** → guarda la selección y vuelve a la lista de clases (con la clase marcada) para poder avanzar

---

### 4. Pantalla "Background" — Rediseño con Dropdown

En lugar de una lista de cards (que con muchos backgrounds sería demasiado larga), usar un **dropdown/selector** como entrada principal. Al escoger un background en el dropdown:
- Se muestra la descripción del background
- Se muestran las skill proficiencies que otorga
- Se muestran las tool proficiencies que otorga
- Se muestran las features seleccionables (con sus propios dropdowns)

También en esta pantalla: **formularios de texto libre** para:
- Características físicas (pelo, ojos, altura, peso, edad, piel, otros)
- Características personales: Personality traits, Ideals, Bonds, Flaws

---

### 5. Pantalla "Race" — Cards + Subraza + Página de detalle

- Cards de selección de raza
- Al pulsar una raza → abre una pantalla de detalle (similar a ClassDetailScreen) con:
  - Descripción de la raza
  - Todas las racial features (expandibles al pulsar)
  - Dropdowns para las features seleccionables (ej. extra languages, cantrips que puedes elegir)
  - Si la raza tiene subrazas: dropdown para elegir subrace, y al elegirla se muestran sus features adicionales

---

### 6. Pantalla "Ability Scores" — Añadir opción Manual

Añadir toggle entre:
- **Standard Array** (implementación actual: [15, 14, 13, 12, 10, 8])
- **Manual**: permite escribir los números que el usuario quiera (validación: máximo 18, mínimo 3 por ability)

**Bug activo:** Hay un error de `Assertion Failed` al navegar a esta pantalla. El problema está en el `DropdownButton` de asignación: cuando `takenByOther` es true, se asigna `value: null` a múltiples items, lo que duplica el valor null y provoca la assertion de Flutter. **Corrección ya aplicada.**

---

### 7. Pantalla "Inventory" (nueva, última del wizard)

- Si el backend envía `starting_equipment` para la clase/background seleccionado → mostrar lista checkeable para marcar qué equipo de inicio tiene
- Buscador de items (por nombre)
- Filtro por tipo: Armor, Potion, Ring, Rod, Scroll, Staff, Wand, Weapon, Wondrous, Other Gear
- Pendiente de datos: requiere implementar `ItemSyncService.java` primero

---

### 8. Modal "Discard Character" — Ajuste de botones (baja prioridad)

El botón "Keep Editing" es demasiado pequeño y está justificado a la derecha, mientras que "Discard" es grande. Se debe equilibrar para que ambos tengan el mismo peso visual y el usuario no pueda descartarlo sin querer.

---

## 📋 PENDIENTES TÉCNICOS (Backend)

| Tarea | Prioridad | Descripción |
|---|---|---|
| Crear `ItemSyncService.java` | Alta | Fetch desde `/api/equipment` y `/api/magic-items` de dnd5eapi |
| Ampliar `RaceSyncService.java` | Alta | Fetch de racial traits, subraces, subrace traits, languages, age |
| Crear entidades `RaceTrait`, `Subrace`, `SubraceTrait` | Alta | Acompañan a la ampliación de Race |
| ~~Fix typo en `SubclassSyncService.java`~~ | ~~Crítico~~ | ~~`dnd5api.co` → `dnd5eapi.co`~~ ✅ Corregido |
| Re-ejecutar sync de subclasses | Media | Una vez corregido el bug, borrar subclass_features y re-sincronizar |
| Endpoints para race traits/subraces | Alta | Que el frontend pueda consultar traits y subraces |
| Endpoint de starting equipment por clase | Media | Para la pantalla de inventario |

---

## 📋 PENDIENTES TÉCNICOS (Frontend)

| Tarea | Área | Estado |
|---|---|---|
| ~~Fix Assertion Failed en Ability Scores~~ | Bug | ✅ Corregido |
| Añadir `font_awesome_flutter` a pubspec.yaml | Dependencias | ✅ Añadido |
| Iconos FA por clase en step_class | UI | Pendiente |
| Crear `ClassDetailScreen` | UI | Pendiente |
| Crear `ClassOptionsScreen` | UI | Pendiente |
| Rediseñar step_background con dropdown | UI | Pendiente |
| Rediseñar step_race con subraces | UI | Pendiente |
| Añadir opción "Manual" en Ability Scores | UI | Pendiente |
| Añadir pantalla Inventory al wizard | UI | Pendiente |

---

## 🔮 FUTURO — Fuente de datos alternativa

Se plantea usar el repositorio **Aurora Legacy** (`https://github.com/AuroraLegacy/elements`) como fuente de datos completa de D&D, ya que la dnd5eapi solo tiene datos del SRD. Aurora Legacy tiene TODA la información en formato XML. **No implementar todavía** hasta confirmar si los datos actuales son suficientes para las funcionalidades en desarrollo.
