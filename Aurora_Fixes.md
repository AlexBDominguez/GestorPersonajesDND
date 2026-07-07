# Aurora Fixes — Backlog de incidencias y mejoras (DungeonScroll)

Lista de bugs y mejoras pendientes, organizados por área. Cada entrada incluye contexto del proyecto (módulos/archivos probablemente implicados) para facilitar el triage y la implementación. Las prioridades son las indicadas por el usuario.

---

## 📋 Estado para retomar (última actualización 2026-07-06)

**Resuelto y confirmado por el usuario en producción:** #1, #2, #4, #5, #6, #7, #10, #14, #16, #19, y dentro de #18: Fighting Style, reactivación de `PendingTasksScreen`, Artificiero no activaba Spells, background se perdía al editar, error 500 al guardar cambios, step de Spells sin tick al editar, hechizos de expansión sin clase vinculada (+ components vacíos de Aurora), Battle Master maneuvers ya elegidas sin deshabilitar en el selector, bonificadores de subraza de Tiefling duplicados, `subraceId` nunca enviado en creación (bug mucho más grave encontrado de paso — ninguna subraza se aplicaba nunca al crear personaje), "Save Changes" en cada paso del wizard en modo edición. Todos con commits ya hechos en `dev` (confirmado con `git log`/`git status`: sincronizados con `origin/dev`, no solo locales).

**Resuelto, pendiente de que el usuario lo pruebe en producción:** #3 (Drakewarden/Thaumaturgy y attunement de Artificiero resultaron ya estar arreglados desde antes, solo faltaba anotarlo; Mutagen Formula del Blood Hunter Mutante ahora sí se persiste, ver detalle en #3/#8.1), #20 (N+1 de class features/Raza/Spells/Items, ver detalle abajo), #8.2 fases 3 y 5 (ver detalle abajo) y, dentro de #8.1: Channel Divinity (Clérigo/Paladín), Bardic Inspiration (Bardo), Ki points (Monje) — recursos base ya funcionaban vía frontend, se conectaron las features sueltas que faltaban al fondo compartido —, Wild Shape (Druida, dedupe de usos), Indomitable y Superiority Dice (Guerrero, indexNames corregidos), y Sorcery Points (Hechicero, indexName corregido). Todos con commits en `dev`/`origin/dev` (`982463b`, `97cb640`, `27e0b67`) salvo Mutagen Formula, hecho en esta sesión (sin commit todavía).

**Sin empezar / pendiente, por tamaño/prioridad:**
- **#8 / #8.1** — la auditoría grande de features de clase/subclase sin efecto mecánico. Ya hecho (ver arriba): Channel Divinity, Bardic Inspiration, Ki points, Wild Shape (dedupe), Indomitable, Superiority Dice, Sorcery Points, Mutagen Formula, y ahora (vía #8.2 fase 5) la mayoría de recursos limitados de las subclases de Aurora. Queda: Infusions del Artificiero (el gap más grande, sistema entero inexistente), Rune Knight (diseño pendiente, ver #8.2 fase 5), y el resto de clases/gaps listados en #8.1 (Bárbaro: Totemic Attunement/Frenzy; Bardo: Additional Magical Secrets; Druida: reglas extra de Circle of the Moon; Mago: School features; Guerrero: Champion; Pícaro: Fast Hands; Warlock: Pact Magic/Agonizing Blast; Hechicero: Flexible Casting/Metamagic point spend/Draconic Bloodline; Blood Hunter: Crimson Rite/Order of the Lycan).
- **#8.2** — de los 4 tipos de mecánica de la idea original: **`RESOURCE_POOL` ✅ y `GRANT_PROFICIENCY` ✅ tienen infraestructura real (ambos hechos en 2026-07-06); `NUMERIC_BONUS` sigue 100% hardcodeado; `GRANT_SPELL` ya era parcialmente declarativo desde antes de #8.2 (vía #8.1) y hoy además cubre los 2 casos PHB que faltaban.** Dentro de `RESOURCE_POOL`: fases 1-5 hechas, cubre PHB + las ~88 subclases de Aurora (fase 3/5 + fix de `grit` **ya ejecutados por el usuario en el VPS** — falta `docker compose up -d --build backend` para las fórmulas DSL nuevas). Dentro de `GRANT_PROFICIENCY`: `RacialTraitService`/`SubclassProficiencyService` reescritos para leer de tablas nuevas en vez de switch/if hardcodeado, script `patch_generalize_proficiency_grants.sql` sin ejecutar todavía en el VPS (incluye un fix de un bug real: War Domain nunca recibía su bonificador de competencia). Rune Knight: decisión tomada (un recurso por runa) pero es su propio desarrollo, no implementado. `NUMERIC_BONUS`: siguiente pieza pendiente, más grande que las otras dos porque cruza backend (AC/ataque) y frontend (daño/pruebas de habilidad) — ver detalle completo en el punto #8.2 más abajo.
- **#9** — panel de admin. Ahora con requisito explícito anotado: los formularios deben adaptarse al "tipo de mecánica" elegido (depende de generalizar #8.2 primero), más la idea de una API propia con datos ya separados — ver detalle en #9. Sigue sin empezar.
- **#21** — items de Aurora sin bonificadores mecánicos (`bonusAc`/`bonusToHit`/`set*To` siempre en 0/null), mismo patrón que #10 pero para items. Identificado, consulta de auditoría ya preparada (`aurora_item_audit.sql`, volcado generado pero no leído a fondo todavía). Sin empezar.
- **#11** — Combat tab vs Spells al añadir hechizos: no reproducible la última vez, dejar abierto por si reaparece con un repro más preciso.
- **#12** — limpieza de `withOpacity` (deprecado, no urgente, no rompe nada hoy).
- **#13** — dominio/despliegue, no es código, para cuando se acerque release.
- **#15** — permitir cambiar username (nueva funcionalidad, no compleja).
- **#17** — multiclase (grande, dejar para el final a propósito).

**Importante para quien retome:** el backend/BD viven solo en el VPS del usuario (ver sección "Local environment" de `CLAUDE.md`) — nunca intentar levantarlos en local. Para consultas SQL puntuales, pide al usuario que ejecute el comando y pegue el resultado (usar siempre `-p$MYSQL_ROOT_PASSWORD`, ya exportado en su shell). Tras cambios de backend en Java, hace falta `docker compose up -d --build backend` (no solo `restart`/`up -d`, que reutiliza la imagen vieja). El registro de Aurora es en memoria — tras reiniciar el backend hay que volver a llamar a `/api/sync/aurora/fetch` antes de cualquier `/persist/*`.

---

## 🐛 Creación y edición de personajes

### 1. La edición de un personaje reinicia datos ya configurados ✅HECHO.
**Prioridad: Alta**

Al entrar en modo edición del wizard (`frontend/lib/views/screens/wizard/`), algunos datos se pierden o se recalculan desde cero (skills, expertise, puntos de vida y otros valores derivados), en vez de partir del estado real del personaje.

**Comportamiento esperado:**
- Al editar, todas las selecciones previas deben conservarse.
- La pantalla de edición debe inicializarse con el estado completo y actual del personaje (no con valores por defecto del wizard de creación).
- Solo deben cambiar los campos que el usuario modifique explícitamente.

**Dónde mirar probablemente:** `CharacterCreatorViewModel` (carga inicial en modo edición) y cómo se hidrata desde `PlayerCharacter` / DTOs al entrar al wizard en modo "editar" en vez de "crear".

**Resumen de lo arreglado (2026-06-19), varias causas independientes:**
- `loadEditData()` no pre-rellenaba `featureChoices` desde las `PendingTask` ya resueltas (Fighting Style, Favored Enemy, Metamagic, Invocations, elecciones de raza...). Añadido `_prePopulateFeatureChoicesForEdit()`.
- **Class skills y Expertise se aplican directamente en la creación (`PlayerCharacterService.create()`, vía `dto.getClassSkillIndices()`/`dto.getExpertiseSkillNames()`) y NUNCA pasan por una `PendingTask`** — por eso el fix de arriba no las cubría. Añadidos `_prePopulateClassSkillsForEdit()`/`_prePopulateExpertiseForEdit()` (reconstruyen desde `character.skills`, no desde PendingTasks) + sincronización real al guardar (`_syncClassSkillChanges()`/`_syncExpertiseChanges()`, usando los endpoints `PUT /skills/{id}/proficiency` y `/expertise` que ya existían en el backend pero nadie llamaba desde el wizard). Expertise se sincroniza también en modo nivel-up (p.ej. Rogue ganando Expertise nuevo en nivel 6), no solo en edición.
- **Bug más profundo encontrado de paso: el wizard nunca enviaba el formato que el backend espera para resolver `ASI_OR_FEAT`** (mandaba el texto del badge "Str / Con" / "Feat" en vez de "ASI:STR:+1+DEX:+1" / "FEAT:NombreDote") — el ASI/Feat elegido en el wizard no se aplicaba mecánicamente, desde siempre, ni en creación ni en edición. Corregido en `_resolveAsiOrFeatChoice`/`_prePopulateAsiOrFeatChoice`. El mismo bug existía en `PendingTasksScreen` (enviaba nombre completo de habilidad en vez de abreviatura) — corregido también.
- Mismatches de nombre/formato entre el wizard y las `PendingTask` reales: `TOTEMIC_ATTUNEMENT` (frontend) vs `TOTEM_ATTUNEMENT` (backend); Battle Master Maneuvers / Four Elements Disciplines / Trick Shots, que el wizard modela como slots individuales pero el backend espera una sola tarea por nivel con lista separada por comas. Corregido con `_resolveSlottedChoice`/`_prePopulateSlottedChoice`.
- HP por nivel: el backend nunca usó las tiradas manuales del jugador, ni siquiera en creación — siempre calculó con la media del dado. Nueva columna `character_hp_rolls`, expuesta en el DTO; creación y level-up (`POST /level-up?hpRoll=N`) ya respetan la tirada real si se envía.
- Reactivada `PendingTasksScreen` (estaba deshabilitada, ver #18) — los feats elegidos por ASI/Feat ya aparecen en `tab_features`.

**Gaps conocidos sin arreglar (necesitan trabajo de backend nuevo, no solo de envío):** `LORE_BONUS_PROF` (College of Lore Bard) no tiene ninguna `PendingTask` creada en el backend. (`MUTAGEN_CHOICE` del Blood Hunter Mutante ya se arregló, ver #3.)

**Limitación conocida de HP por nivel:** personajes creados/subidos de nivel *antes* de este fix no tienen tiradas guardadas (la columna no existía), así que "Manage HP" seguirá vacío para esos niveles ya existentes; solo los niveles nuevos a partir de ahora se guardan.

---

### 2. Cambiar las Sources (paso de Preferencias) rompe la configuración del personaje ✅HECHO.
**Prioridad: Muy alta**

Si el usuario vuelve al paso de Preferencias (`step_preferences.dart`) y cambia las fuentes (sources) activas, se producen inconsistencias:
- Se pierden clases ya seleccionadas.
- Se alteran selecciones de habilidades.
- Aparecen requisitos incorrectos (p. ej. el sistema pide elegir 2 skills pero solo deja seleccionar 1).

**Comportamiento esperado:**
- No permitir desactivar una source si hay elementos seleccionados actualmente que pertenecen a ella (clase, subclase, raza, hechizos, etc.).
- Mostrar un aviso claro indicando qué debe eliminarse antes de poder desactivar esa source.
- Mantener la integridad de todas las selecciones posteriores del wizard.

**Sugerencia de mensaje UX:** *"No puedes desactivar esta fuente porque contiene elementos actualmente utilizados por tu personaje. Elimina primero esos elementos."*

**Dónde mirar probablemente:** lógica de validación en `step_preferences.dart` / `CharacterCreatorViewModel`, y cómo se recalculan los pasos dependientes (clase, skills) al cambiar el set de sources activas.

**Resumen de lo arreglado:** `_clearCatalogSelections()` ahora limpia correctamente clase/subclase/raza/background/skills/featureChoices (vía el mismo núcleo que usan `clearClass()`/`deselectRace()`, pero sin marcar esos pasos como "dirty" si el usuario no los había visitado todavía, para no mostrar el icono "!" prematuramente). Confirmado funcionando por el usuario.

---

### 3. Algunas features de clase/subclase no se aplican correctamente en la ficha ✅ MAYORMENTE HECHO (redescubierto 2026-07-03, arreglado sin que quedara anotado en 2026-06-16/17).
**Prioridad: Alta**

Casos detectados (no exhaustivo, ver puntos 8 y 8.1 para la auditoría completa):
- **Ranger → Drakewarden**: otorga *Thaumaturgy*. El hechizo aparece en la descripción de la subclase pero nunca se añade realmente a la ficha del personaje. — **✅ HECHO** (commit `30470f3`/`5d145e8`, 2026-06-15/16). `AuroraSubclassMapper.grantFeatureSpells()` (`backend/src/main/java/sync/aurora/AuroraSubclassMapper.java:258-275`) recorre las reglas `<grant type="Spell">` de cada feature de subclase sincronizada desde Aurora (genérico, no específico de Drakewarden) y crea una fila `SubclassSpell`, que `SubclassSpellService.applySubclassSpells()` ya aplicaba a la ficha en creación/nivel-up. El nivel se lee dinámicamente de la regla de Aurora, no hardcodeado. **Pendiente de verificación manual del usuario**: crear/subir un Ranger Drakewarden hasta el nivel de "Drake Companion" y confirmar que Thaumaturgy aparece solo en la pestaña Spells.
- **Artificer → Magic Item Adept**: debería aumentar el máximo de *attunement* de 3 a 4. — **✅ HECHO** (mismo commit `5d145e8`). `PlayerCharacter.getMaxAttunementSlots()` (`entities/PlayerCharacter.java:556-565`) devuelve 4 si la clase empieza por "artificer" y el nivel ≥10. Es un check hardcodeado por nombre de clase + nivel (no lee `SubclassFeature`/`indexName='magic-item-adept'`), pero es correcto según reglas reales — Magic Item Adept es una feature de **clase base** de Artificiero (no de subclase), fija en nivel 10, así que el hardcodeo no es un hack real aquí.
- **Blood Hunter → Mutagen Formula**: la cantidad de fórmulas conocidas depende del modificador de INT y debe gestionarse como un recurso escalable, no fijo. — **✅ HECHO (2026-07-04).** El wizard (`character_creator_viewmodel.dart:1622-1633`) ya calculaba `pickCount: abilityModifier('INT').clamp(1, 99)` para el selector `MUTAGEN_CHOICE` y ya sabía enviarlo (mecanismo genérico `_autoResolveFeatureChoices`/`class_options_screen.dart`, igual que Metamagic/Maneuvers) — el único hueco real era que el **backend nunca creaba la `PendingTask`** para que hubiera algo que resolver (confirmado, cero referencias a `MUTAGEN_CHOICE` en `backend/src` antes de este fix). Corregido:
  - `PlayerCharacterService.createSubclassLevelTasks()` (`services/PlayerCharacterService.java`): nuevo caso `"order-of-the-mutant"` en nivel 3, que crea la `PendingTask` `MUTAGEN_CHOICE` con `count` = `Math.max(1, character.calculateAbilityModifier("int"))` en el metadata JSON (mismo formato `{"count":N}` que ya leen `_MultiPickOptionResolver` en el frontend y el resto de choices multi-selección tipo Battle Master Maneuvers/Four Elements Disciplines). Se dispara tanto en creación (nivel inicial ≥3) como en level-up, igual que el resto de tareas de subclase.
  - `PendingTaskService.applyChoice()`: añadido `"MUTAGEN_CHOICE"` al grupo de choices puramente descriptivas (mismo patrón que `BLOOD_CURSE_CHOICE`/`TRICK_SHOT_CHOICE` — no hay ningún efecto numérico que aplicar, solo se guarda la elección en metadata al resolver).
  - `pending_tasks_screen.dart`: añadido el caso `'MUTAGEN_CHOICE'` → `_MultiPickOptionResolver(options: kMutagens)`, para que un Blood Hunter que llega a nivel 3 vía level-up (no solo creando el personaje desde el wizard) también pueda resolver la elección desde `PendingTasksScreen`.
  - Backend compila (`mvn -o compile`, exit 0) y `flutter analyze` sobre los ficheros tocados no introduce warnings nuevos (solo los `withOpacity`/lint preexistentes del punto #12). **Pendiente de que el usuario lo despliegue (`docker compose up -d --build backend`) y lo pruebe en producción** con un Blood Hunter Order of the Mutant real llegando a nivel 3 (creación y, si es posible, level-up).

**Comportamiento esperado:**
- Todos los beneficios automáticos otorgados por clases y subclases (hechizos gratuitos, bonificadores, cambios de límites como el de attunement, recursos escalables por modificador) deben aplicarse y reflejarse correctamente en la ficha, no solo aparecer como texto descriptivo.

**Dónde mirar probablemente:** lógica de aplicación de features de clase/subclase en el backend (servicios de creación/nivel) — posiblemente en `PlayerCharacterService` o un servicio dedicado a aplicar `ClassFeature`/`SubclassFeature` al personaje.

---

### 4. Escalado incorrecto de hechizos al subir el nivel de lanzamiento ✅HECHO.
**Prioridad: Media**

Revisar si, al seleccionar un nivel de lanzamiento superior para un hechizo, los dados de daño se actualizan conforme a la escala definida por el hechizo.

**Comportamiento esperado:** el daño mostrado en la ficha debe reflejar el nivel de lanzamiento seleccionado, no quedarse fijo en el nivel base.

**Dónde mirar probablemente:** `tab_spells.dart` (frontend) y la lógica de cálculo de daño de hechizos en el ViewModel del character sheet.

**Confirmado (2026-06-19):** `CharacterSpell.damageAtLevel(castLevel)` (`character_spell.dart:47-48`) busca en `damageAtSlotLevel` por nivel de lanzamiento, con fallback a `damageBase`; usado en `_DamageCell` de `tab_spells.dart`. Solo cubre PHB (ver #10, hechizos de Aurora sin estos datos).

---

## 🎨 UX / Interfaz

### 5. Comportamiento de los desplegables en el paso de Razas ✅HECHO.
**Prioridad: Media**

Problemas en `step_race.dart`:
- Un desplegable abierto no se cierra al volver a pulsarlo (falta el toggle).
- Al abrir una raza, el scroll salta automáticamente al final de la lista de subrazas en vez de mantenerse sobre el elemento seleccionado.
- El icono del Artificiero no se muestra correctamente (en ninguno de los dos casos en que debería aparecer — revisar asset/mapeo de iconos por clase).

**Comportamiento esperado:**
- Un segundo clic sobre el desplegable abierto debe contraerlo.
- El foco visual debe mantenerse sobre la raza seleccionada, sin auto-scroll al final.
- El icono de Artificiero debe renderizarse correctamente.

**Confirmado (2026-06-19):** toggle en `step_race.dart:382`; `Scrollable.ensureVisible(alignment: 0.0)` en `_onRaceTap()` mantiene el foco sin saltar al final; iconos de Artificiero (ERLW/TCE) mapeados en `class_icons.dart:17,52-53`.

---

### 6. Ordenación de Backgrounds ✅HECHO.
**Prioridad: Baja**

En `step_background.dart`, los backgrounds se muestran ordenados según el orden de las sources cargadas en vez de alfabéticamente.

**Comportamiento esperado:** mostrar siempre los backgrounds en orden alfabético, independientemente de su source de origen.

**Confirmado (2026-06-19):** `backgrounds.sort((a, b) => a.name.compareTo(b.name))` en `CharacterCreatorViewModel:868`, justo tras cargar desde la API.

---

## ⚙️ Reglas de D&D / mecánicas

### 7. Sneak Attack se clasifica como Action ✅HECHO.
**Prioridad: Media**

Sneak Attack aparece en la ficha como una acción independiente (pestaña Combat / Features), cuando es una característica pasiva/condicional que se aplica como parte de un ataque, no una acción en sí misma.

**Comportamiento esperado:** debe mostrarse como característica pasiva/condicional y excluirse de la categoría "Action" en `config/combat_features.dart` y donde se clasifique el tipo de feature.

**Confirmado (2026-06-19):** `sneak-attack` no aparece en ningún set de `combat_features.dart` (`kCombatActionFeatures`/`kCombatBonusFeatures`/`kCombatReactionFeatures`), así que cae por defecto en `FeatureCategory.passive` — correctamente excluida de "Action".

---

### 8. Auditoría general de automatizaciones mecánicas
**Prioridad: Media-Alta**

Dado que ya se han encontrado errores puntuales (Drakewarden + Thaumaturgy, ver punto 3), conviene una revisión sistemática de todo lo que se aplica automáticamente al personaje:
- Features de clase.
- Features de subclase.
- Hechizos otorgados automáticamente.
- Competencias (proficiencies).
- Habilidades (skills).
- Modificadores derivados.

**Objetivo:** detectar y corregir casos similares al de Drakewarden/Thaumaturgy antes de que aparezcan reportados como bugs aislados.

---

### 8.1. Inventario de features de clase/subclase que requieren implementación mecánica (recursos, bonificadores, skills, hechizos)
**Prioridad: Media-Alta** — Detalle del punto 8, con casos concretos detectados clase por clase

Detectado a raíz de revisar Psi-Warrior (Fighter): la feature "Psionic Power" da una reserva de dados a gastar, igual que Action Surge o Second Wind, pero no tiene ningún contador de usos implementado — ni siquiera el tracker frontend-only que sí tienen Action Surge/Second Wind/Rage. Al tirar de esto hacia atrás, queda claro que **el problema es estructural, no puntual**: hoy existen tres mecanismos paralelos y todos requieren registro manual por feature, sin ninguna fuente de verdad única ni detección automática desde el texto de la feature.

**Cómo funciona hoy (y por qué cualquier feature nueva se queda "solo descriptiva" por defecto):**
- **Recursos con usos limitados** (`ClassResource` / `CharacterClassResource`, `entities/`): el modelo de datos existe (`maxFormula`, `recoveryType`, `levelUnlocked`, `subclassRestriction`...) pero **solo hay 2 filas reales en la BD**: `blood-maledict` (Blood Hunter) y `grit` (Blood Hunter/Gunslinger). Todo lo demás que parece "tener usos" en la ficha (Action Surge, Second Wind, Rage, Bardic Inspiration, Wild Shape, Superiority Dice...) funciona porque está **hardcodeado en el frontend**, en el mapa `_kConsumableFeatures` de `CharacterSheetViewModel` (`frontend/lib/viewmodels/characters/character_sheet_viewmodel.dart`), con fórmulas mágicas por constantes negativas (-1 = mod. CHA, -3 = nivel, -4 = tabla Barbarian, -6 = tabla Superiority Dice...) y prefijos tipo `bardic-inspiration-*`/`wild-shape-*`. El backend no valida ni repone estos usos: es solo UI.
- **Bonificadores numéricos** (ej. Fighting Style): hardcodeados como `if/else` sobre el string del nombre elegido en `PlayerCharacterService.java` (ver punto 18). Cualquier estilo/feature nuevo necesita una rama nueva escrita a mano.
- **Otorgar skills/competencias/hechizos automáticamente**: tres vías distintas y no homogéneas — `RacialTraitService.java` (switch hardcodeado por `indexName` de rasgo racial), `SubclassSpellService.java` (sí es data-driven vía tabla `subclass_spells` + `seed_subclass_spells.sql`, salvo Circle of the Land que tiene un switch hardcodeado aparte por tipo de terreno), y features de clase sueltas resueltas caso por caso en `PlayerCharacterService` (aquí es donde vivía el bug de Drakewarden/Thaumaturgy del punto 3).
- **Conclusión:** dar de alta una feature nueva con efecto mecánico requiere "triple registro" manual (BD/recurso, backend si es bonificador o grant, frontend si es un recurso con usos) y nada avisa si falta alguno de los tres — de ahí que Psi-Warrior se haya quedado sin tracker sin que nadie lo notara hasta mirarlo a mano.

**Lista por clase de qué necesita mecánica (no solo texto) y su estado conocido.** Basado en lo confirmado en código + conocimiento de reglas de 5e; las subclases que llegan vía Aurora (contenido dinámico, no en SQL estático del repo — `AuroraSyncService.java`) no se han podido verificar feature a feature contra la BD real, así que esta lista es un punto de partida para auditar, no un resultado cerrado:

- **Bárbaro** — *Rage*: ⚠️ usos trackeados solo en frontend (constante -4 + tabla), sin `ClassResource` real ni reposición validada por backend. *Path of the Totem Warrior*: bonificadores de Totemic Attunement (oso/águila/lobo/elk) — revisar si dan efecto real o solo texto, más allá del fix de nombre `TOTEM_ATTUNEMENT` ya hecho en el punto #1. *Frenzy* (Berserker): atacar con bonus action y ganar exhaustion al salir de Rage — sin implementar.
- **Bardo** — *Bardic Inspiration*: ✅ **HECHO (2026-07-03).** Dos bugs reales encontrados al auditar esto (mismo patrón que Channel Divinity/Ki, ver #8.1 arriba):
  - **Duplicación de usos:** la API pública desbloquea Bardic Inspiration como 4 `ClassFeature` independientes según el dado (`bardic-inspiration-d6` nv.1, `-d8` nv.5, `-d10` nv.10, `-d12` nv.15), verificado contra `dnd5eapi.co`. Sin dedupe, un Bardo nivel 15 veía 4 tarjetas simultáneas, cada una con su propio contador de "mod. CHA" usos — hasta 4× los usos reales disponibles. Arreglado añadiendo la familia a `_kTieredFeatureFamilies`.
  - **Cutting Words (College of Lore) y Combat Inspiration (College of Valor) no descontaban nada:** sus indexName reales son `lore-cutting-words` y `valor-combat-inspiration` (`seed_sc_features_p1.sql`) — no `cutting-words` a secas, que es lo que tenía tanto `combat_features.dart` (clasificación de Combat) como la ausencia total en `_kConsumableFeatures`. Ninguna de las dos aparecía como interactiva. Arreglado: `combat_features.dart` corregido a `lore-cutting-words`, y ambas redirigidas al fondo `bardic-inspiration-dN` activo vía `_kBardicInspirationConsumingFeatures`.
  - **Sin verificar por el usuario todavía.** *Additional Magical Secrets* (Lore, nivel 6): otorga 2 hechizos de cualquier clase — sigue sin confirmar si existe alguna `PendingTask` para esta elección o se pierde (no tocado en esta pasada).
- **Clérigo** — Channel Divinity: **✅ HECHO (2026-07-03), corregido más de lo que el enunciado original suponía.** Redescubierto al investigar este punto: el recurso base (`channel-divinity-1-rest`/`-2-rest`/`-3-rest`, sincronizado desde la API pública igual que cualquier otra `ClassFeature` de Clérigo) **ya estaba trackeado y usable** desde hace meses vía el mecanismo frontend-only de `_kConsumableFeatures` (mismo patrón que Rage/Ki/Second Wind) — la premisa de "gap entero, no aparece en ningún sitio" era incorrecta, solo faltaba comprobar el frontend además del backend `ClassResource`. Lo que sí eran bugs reales, encontrados y arreglados en esta pasada (`character_sheet_viewmodel.dart`, `combat_features.dart`):
  - **Bug de duplicación de usos:** la API pública representa cada mejora de nivel como un `indexName` propio (`channel-divinity-1-rest` en nv.2, `-2-rest` en nv.6, `-3-rest` en nv.18) en vez de una sola feature que escala. El filtro `level <= characterLevel` los acumulaba TODOS a la vez como tarjetas independientes con contador propio — un Clérigo nivel 6+ veía 1+2=3 usos disponibles en vez de 2, y a nivel 18, 1+2+3=6 en vez de 3. Mismo bug confirmado en Action Surge (`action-surge-1-use`/`-2-uses`) e Indomitable (`indomitable-1-use`/`-2-uses`/`-3-uses`) del Guerrero. Arreglado con `_dedupeTieredFeatures()`, aplicado tras el filtro de nivel en `_loadClassFeaturesIfNeeded()`/`_loadSubclassFeaturesIfNeeded()`: se queda solo con la variante de mayor nivel ya desbloqueada por familia.
  - **Las opciones de Dominio/Juramento (Preserve Life, Turn Undead, Sacred Weapon, Knowledge of the Ages...) no consumían del fondo compartido.** Cada una es su propia `ClassFeature`/`SubclassFeature` con descripción de texto, pero no tenía entrada en `_kConsumableFeatures`, así que no mostraban botón "Use" ni descontaban nada — el jugador tenía que llevar la cuenta a mano de cuántos usos de Channel Divinity le quedaban tras usar una opción concreta. Arreglado con `_sharedResourcePoolKey()`: cualquier feature `channel-divinity-*` que no sea una de las claves base se redirige al fondo correcto según clase/nivel del personaje (Clérigo: la variante 1/2/3-rest que tenga desbloqueada; Paladín: `channel-divinity`), así que "usar" Preserve Life y "usar" Turn Undead gastan del mismo contador, no de dos independientes.
  - **Bug de clasificación:** `combat_features.dart` listaba `'turn-undead'` a secas en `kCombatActionFeatures`, pero el indexName real es `channel-divinity-turn-undead` — nunca coincidía, así que Turn Undead cayó siempre en "passive" (no aparecía en Combat). Corregido simplificando la entrada a `'channel-divinity'` a secas, que ya cubre por prefijo cualquier opción de Dominio/Juramento sin necesidad de listarlas una a una (confirmado que esto ya cubría Preserve Life/Sacred Weapon/etc., que estaban listadas explícitamente de forma redundante — limpiado).
  - **Seguimos sin backend `ClassResource` real** (mismo límite conocido que Rage/Ki/Second Wind/Sorcery Points — solo `blood-maledict` y `grit` lo tienen hoy): los usos se resetean si se recarga la app entre descansos, no persisten entre dispositivos/sesiones. No abordado en esta pasada — construirlo para Channel Divinity implicaría construirlo para todos los demás recursos frontend-only a la vez, y es un cambio de arquitectura mayor (ver #8.2), no algo específico de Channel Divinity.
  - **Sin verificar por el usuario todavía** — pendiente de probar en producción con un Clérigo/Paladín real: confirmar que el contador de Channel Divinity no se duplica al subir de nivel 2→6→18, y que usar una opción de Dominio descuenta del mismo fondo que la feature base.
- **Druida** — *Wild Shape*: ✅ **duplicación de usos arreglada (2026-07-03)**, resto sigue pendiente. La API pública desbloquea Wild Shape como 3 `ClassFeature` independientes por tramo de CR (`wild-shape-cr-1-4-or-below-no-flying-or-swim-speed` nv.2, `wild-shape-cr-1-2-or-below-no-flying-speed` nv.4, `wild-shape-cr-1-or-below` nv.8), verificado contra `dnd5eapi.co` — mismo bug que Channel Divinity/Bardic Inspiration: sin dedupe, un Druida nivel 8+ veía 3 tarjetas con 2 usos cada una (6 en vez de 2). Arreglado añadiendo la familia a `_kTieredFeatureFamilies`. **Sin enforcement de CR/restricciones de forma por nivel** (sigue pendiente, no es un bug de contador sino de qué formas se pueden elegir). *Circle of the Moon* (Combat Wild Shape: gasto de slot de hechizo para recuperar usos de Wild Shape en combate, curación al cambiar de forma, acceso a CR superior) — no hay evidencia de que estas reglas extra estén implementadas más allá del Wild Shape base. *Circle of the Land*: ya es data-driven (`subclass_spells` + switch de terreno) — único caso de subclase con grant de hechizos correctamente resuelto.
- **Guerrero** — *Action Surge*/*Second Wind*: ⚠️ solo frontend, sin `ClassResource` (funcionan bien, límite conocido y aceptado, ver Channel Divinity arriba). *Indomitable*: ✅ **HECHO (2026-07-03)** — no tenía NINGUNA entrada en `_kConsumableFeatures` (a diferencia de Action Surge), así que no se trackeaba en absoluto; añadidas `indomitable-1-use`/`-2-uses`/`-3-uses` (ya estaba correctamente registrado como familia escalonada al arreglar Channel Divinity, pero le faltaban las entradas de recurso). *Fighting Style*: solo Defense+Archery con efecto real (punto 18). *Battle Master* (Superiority Dice): ✅ **arreglado (2026-07-03)** — el indexName real es `battlemaster-combat-superiority` (`seed_sc_features_p1.sql`), no `combat-superiority`/`superiority-dice` como tenía el frontend; con la clave vieja el recurso no funcionaba en absoluto (ni siquiera duplicado, directamente ausente). Las maniobras ya se resolvieron a nivel de selección (punto #1) y no deshabilitarlas ya se arregló (punto 18), pero sigue sin verificar que cada maniobra aplique su efecto real, no solo consuma el dado. *Champion* (Improved/Superior Critical: ampliar rango de crítico; Remarkable Athlete: bonificador a pruebas de habilidad) — sin evidencia de implementación, son cambios de regla numérica que normalmente se calculan en frontend al tirar dados. *Eldritch Knight*: spellcasting de subclase + War Magic (nivel 7, atacar con bonus action tras lanzar conjuro de acción) — la parte de economía de acciones no está modelada. **Psi-Warrior** (Psionic Power): ❌ sin ningún tracker de usos, ni siquiera frontend-only — el hallazgo que originó este punto, sigue sin implementar (no es un fix de clave, hay que decidir la fórmula/tabla de usos real de Psi-Warrior primero).
- **Mago** — School features (7 escuelas seedeadas): revisar caso por caso, pero al menos *Evocation* (Sculpt Spells: excluir aliados del área; Empowered Evocation: +mod. INT al daño una vez por turno; Overchannel: daño extra con coste de daño necrótico acumulativo y usos limitados por día) son bonificadores/recursos que no aparecen en ningún sitio confirmado del backend.
- **Mediano (Monje)** — *Ki points*: ✅ **HECHO (2026-07-03), corregido más de lo que el enunciado suponía** (mismo patrón que Channel Divinity, ver #8.1 Clérigo/Paladín arriba). El fondo base ("ki", `_kConsumableFeatures['ki'] = -3` = nivel de personaje) **ya existía y funcionaba** desde antes — la premisa de "no hay evidencia de que exista como recurso" era incorrecta, solo faltaba comprobar el frontend. Lo que sí era un bug real: *Flurry of Blows*, *Patient Defense* y *Step of the Wind* (que cuestan 1 punto de ki cada una) no tenían botón "Usar" ni descontaban nada del fondo — igual que las opciones de Channel Divinity antes del fix. Arreglado extendiendo `_sharedResourcePoolKey()` con un set `_kKiConsumingFeatures` que las redirige al fondo `ki` compartido. **Pendiente de que el usuario lo pruebe** con un Monje real (confirmar que usar Flurry of Blows descuenta del mismo contador que muestra la feature "ki").
  - **Sigue sin implementar (gap real, no solo de anotación):** *Way of Shadow* (Shadow Arts: gastar 2 ki para lanzar Darkness/Darkvision/Pass without Trace/Silence) y *Way of the Four Elements* (Disciple of the Elements: ~16 disciplinas con coste de ki variable por disciplina elegida) — ambas están seedeadas como una sola `SubclassFeature` descriptiva (`shadow-shadow-arts`, `4e-disciple-of-the-elements` en `seed_sc_features_p2.sql`), no como una lista de acciones individuales con su propio coste. A diferencia de "gastar 1 ki" (redirección simple de contador), esto necesitaría un selector de opción + coste variable por opción — mismo nivel de complejidad que Metamagic/Eldritch Invocations, no una redirección de contador. Requiere su propio diseño, no se ha tocado en esta pasada.
- **Paladín** — Channel Divinity: ✅ arreglado junto con el del Clérigo (ver arriba) — Sacred Weapon/Turn the Unholy (Devotion), Abjure Enemy/Vow of Enmity (Vengeance) ya descuentan del fondo base `channel-divinity` del personaje. *Auras* (Devotion, Protection... según nivel) son pasivas de rango que no implican recurso pero sí lógica de "aplica a aliados a X pies", a confirmar si existe.
- **Pícaro** — *Sneak Attack* ya señalado como mal clasificado (punto 7), pero además revisar que el cálculo de dados escale con nivel correctamente. *Thief* (Fast Hands, Second-Story Work) y *Arcane Trickster* (Mage Hand Legerdemain) son en su mayoría utilidad pasiva, impacto mecánico bajo pero a confirmar que Fast Hands realmente permita una acción de objeto adicional.
- **Brujo (Warlock)** — *Pact Magic* (slots de hechizo independientes, se recuperan en descanso corto, no largo) — confirmar que el sistema de slots no los mezcle con los de un multiclase de lanzador (relevante también para el punto #17). *Eldritch Invocations* ya resueltas a nivel de elección (punto #1) pero cada invocation puede tener efecto mecánico propio (p. ej. Agonizing Blast: +mod. CHA al daño de Eldritch Blast) — confirmar que estos efectos se aplican y no solo se registra la elección. *Fiend* (Dark One's Blessing: PG temporales al matar) — trigger basado en evento de combate, normalmente no implementado en apps de ficha.
- **Hechicero (Sorcerer)** — *Sorcery Points*: ✅ **HECHO (2026-07-03) — era un bug real, no solo una duda.** El indexName real de la API pública es `font-of-magic` (verificado contra `dnd5eapi.co`), no `sorcery-points` como tenía el frontend — con la clave vieja el recurso **no funcionaba en absoluto** (ni duplicado, directamente inexistente como opción interactiva: sin botón "Usar", sin contador). Corregido el key en `_kConsumableFeatures`/`isPoolResource`; la fórmula en sí (= nivel de personaje) ya era correcta. **Sin verificar por el usuario todavía.** **Sin tocar (gap real, mismo tipo que Way of Shadow/Four Elements del Monje):** *Flexible Casting* (convertir slots↔puntos de hechicería, coste variable por nivel de slot) y gastar puntos en *Metamagic* al lanzar un hechizo — ambos son "elige una opción con coste variable", no una redirección simple de contador; necesitan su propio selector. *Draconic Bloodline* (Draconic Resilience: +1 PG por nivel + CA base alternativa; Elemental Affinity: +mod. CHA al daño de hechizos de un tipo elegido) — bonificadores numéricos que necesitan lógica dedicada, no solo texto; no tocado en esta pasada.
- **Artificiero** (2 variantes, TCE/ERLW) — *Infusions*: sistema completo de "número de infusiones conocidas según nivel" + "vincular un efecto mágico a un objeto" — no hay evidencia de que exista nada parecido a un sistema de infusiones; probablemente el gap más grande de todo este inventario porque es una mecánica entera, no una feature suelta. *Magic Item Adept* (+1 a attunement máximo) ya señalado en el punto #3.
- **Blood Hunter** (homebrew, Critical Role) — *Blood Maledict*: ✅ es el único recurso de clase con `ClassResource` real en BD. *Crimson Rite* (convierte daño del arma + daño extra, coste de PG por uso) — mezcla de bonificador y recurso, confirmar si el coste de PG y el daño extra se aplican. *Order of the Lycan* (Hybrid Transformation, usos limitados) — sin implementar. *Order of the Mutant* (Mutagen Formula): ✅ **HECHO (2026-07-04)**, ver detalle en #3 — ya se crea la `PendingTask` en nivel 3 con el conteo escalado por INT y se resuelve tanto desde el wizard como desde `PendingTasksScreen`. *Order of the Gunslinger*: ✅ `grit` sí tiene `ClassResource` real.

**Nota sobre alcance:** esta lista cubre las subclases confirmadas en `seed_subclasses.sql` (28, todas PHB) más los casos ya detectados fuera de ese fichero (Psi-Warrior vía Aurora). Las subclases que llegan dinámicamente desde Aurora (`AuroraSyncService.java`) no están en el repo como datos estáticos, así que cualquier subclase de esa fuente (probablemente la mayoría del contenido "expandido" tipo Tasha's) necesita pasar por esta misma auditoría una vez se pueda inspeccionar en una base de datos real — no se puede confirmar desde el código solo.

### 8.2 Construir capa de mecánicas como infraestructura reutilizable — 🔶 EN PROGRESO, alcance corregido 2026-07-06
**Idea original (destino final, sigue siendo válida):** en vez de seguir resolviendo cada gap a mano feature por feature, construir una capa de "mecánicas" como infraestructura reutilizable: un esquema/API interna donde cada feature se describe de forma declarativa según el tipo de efecto que produce — al menos 4 tipos:
- `RESOURCE_POOL` — fórmula de usos + tipo de descanso para reponerlos (Rage, Ki, Channel Divinity...).
- `NUMERIC_BONUS` — a qué campo suma y bajo qué condición (Fighting Style, bonificadores de items mágicos...).
- `GRANT_SPELL` — qué hechizo otorga y a qué nivel (Drakewarden → Thaumaturgy).
- `GRANT_PROFICIENCY` — qué competencia otorga y a qué nivel.

Tanto el backend como el frontend leerían esa descripción para activar el comportamiento automáticamente, sin necesitar una rama de código nueva por feature. Esto es lo que conecta con #9 (panel de admin): si crear una clase/subclase/feat desde un formulario te deja elegir "qué tipo de mecánica" tiene cada feature, el formulario puede pedir exactamente los campos que ese tipo necesita (Hit/DC/Daño/escalado si es un hechizo, fórmula de usos si es un recurso, etc.) y la app la aplica sola — sin ese esquema común, un panel de admin sería solo una forma más bonita de escribir SQL a mano. También conecta con la idea de una API propia con los datos ya separados en campos estructurados (ver #9 más abajo) en vez de texto libre a interpretar cada vez.

**⚠️ Estado real (no confundir con "#8.2 hecho"): de los 4 tipos de mecánica, hoy solo existe infraestructura real para `RESOURCE_POOL`.** Es lo único que se ha construido esta sesión y en las anteriores (fases 1-5 abajo). Los otros tres siguen exactamente igual que antes de empezar #8.2:
- `GRANT_SPELL` ya era parcialmente declarativo *antes* de #8.2 (tabla `subclass_spells` + `SubclassSpellService`, ver #8.1) — no se ha tocado ni generalizado en esta sesión.
- `NUMERIC_BONUS` sigue 100% hardcodeado por `if/else` en `PlayerCharacterService.java` para features de clase/subclase (Fighting Style, etc.). Los items sí tienen campos estructurados propios (`bonusAc`, `bonusToHit`, `setStrTo`...) que ya se aplican solos al equipar cualquier item — pero es infraestructura específica de items, no un esquema general reutilizable por cualquier feature.
- `GRANT_PROFICIENCY` sigue hardcodeado en `RacialTraitService.java` (switch por `indexName`).
- **#9 (panel de admin) no se ha empezado en absoluto** — sigue siendo solo la idea de siempre.

Para Aurora, esta capa tampoco sustituye al parseador de descripción de hechizos (punto #10, ya hecho) ni al que le falta a items (punto #21, sin empezar) — esos extraen datos estructurados del texto libre; la capa de mecánicas es sobre qué *tipo* de mecánica describe una feature y cómo aplicarla, un paso más arriba.

---

**A partir de aquí, todo lo que sigue es exclusivamente la pieza `RESOURCE_POOL`.** Nada de lo de abajo generaliza `NUMERIC_BONUS`/`GRANT_PROFICIENCY` ni construye ninguna parte del panel de admin.

**Lo que ya se implementó (2026-07-04, tres commits en `dev`/`origin/dev`, hecho desde otra máquina — no llegó a anotarse en este documento hasta ahora):**
- **Fase 1** (`2c59b23`, "DSL + schema groundwork"): columna `consumesResourceIndexName` (nullable) en `ClassFeature`/`SubclassFeature` — permite que una feature gaste de un pool compartido sin ser ella misma el recurso. Extendida la DSL de fórmulas de `calculateMaxAmount()` con `twice_proficiency_bonus`, `level_times_5`, `one_plus_charisma_modifier`, `intelligence_modifier_min1` y tablas por umbral de nivel (Channel Divinity Clérigo, Action Surge, Indomitable, Superiority Dice), vía un helper compartido `levelThresholdTable()`. Nuevo tipo de recuperación `SHORT_OR_LONG_REST`.
- **Fase 2** (`c9a5a59`, `backend/scripts/patch_resource_pool_migration_phase2.sql`): siembra 11 filas `class_resources` para los recursos que hoy solo viven en el mapa efímero del frontend (`_kConsumableFeatures`) — Rage, Ki, Bardic Inspiration, Channel Divinity (Paladín y Clérigo, cada uno su propia fila), Sorcery Points/`font-of-magic`, Superiority Dice, Action Surge, Indomitable, Second Wind, Lay on Hands, Divine Sense, Arcane Recovery. Solo backend/datos, sin cambio de frontend todavía.
- **Fase 4** (`cd2231b`, "wire frontend to real resources"): `CharacterSheetViewModel` ahora carga `CharacterClassResource` al entrar en la ficha y tras descansos, y `featureMaxUses`/`featureUsesRemaining`/`useFeature`/`restoreFeature` resuelven cada feature contra un recurso real de backend primero (por `consumesResourceIndexName` o por su propio `indexName`), con persistencia real de gasto/recuperación vía `/api/characters/{id}/resources*`. Cae de vuelta al mapa efímero antiguo para cualquier feature que aún no tenga fila sembrada — así nada retrocede a mitad de migración. De los 13 recursos sembrados en fase 2, 9 ya resuelven directamente (su `indexName` coincide tal cual con el recurso sembrado): `rage`, `ki`, `channel-divinity` (Paladín), `font-of-magic`, `battlemaster-combat-superiority`, `second-wind`, `lay-on-hands`, `divine-sense`, `arcane-recovery`.

**Fase 3 (enlazar los 4 recursos "tiered") — ✅ HECHO (2026-07-06).** Bardic Inspiration, Channel Divinity (Clérigo), Action Surge e Indomitable se desbloquean en la API pública como 3-4 `ClassFeature` independientes por tramo de nivel (p. ej. `bardic-inspiration-d6`/`-d8`/`-d10`/`-d12`, `channel-divinity-1-rest`/`-2-rest`/`-3-rest`), mientras que la fase 2 los sembró como **un solo** recurso colapsado (`bardic-inspiration`, `channel-divinity-cleric`, `action-surge`, `indomitable`). Sin `consumesResourceIndexName` en esas filas de `ClassFeature`, `_realResourceFor()` (`character_sheet_viewmodel.dart:669-670`) nunca encontraba el recurso sembrado para estos 4 y seguían cayendo al tracker efímero de siempre. Añadido `backend/scripts/patch_resource_pool_migration_phase3.sql` (4 `UPDATE class_features SET consumes_resource_index_name = '...' WHERE index_name IN (...)`, idempotente). **Pendiente de que el usuario lo ejecute en el VPS** (`docker exec -i dnd-mysql mysql -u root -p$MYSQL_ROOT_PASSWORD dnd_character_manager < backend/scripts/patch_resource_pool_migration_phase3.sql`) y confirme que Bardic Inspiration/Channel Divinity(Clérigo)/Action Surge/Indomitable persisten sus usos entre recargas.

**Gap relacionado, no parte de la fase 3 tal cual se diseñó (a decidir si se aborda ahora o después):** las *opciones* de Dominio/Juramento que gastan del mismo fondo de Channel Divinity (Preserve Life, Sacred Weapon, Turn Undead...) son `SubclassFeature` con su propio `indexName` (`channel-divinity-preserve-life`, etc.) y siguen sin `consumesResourceIndexName` — hoy resuelven al fondo correcto solo vía el `_sharedResourcePoolKey()` efímero del frontend (ver #8.1 Channel Divinity), no contra el `ClassResource` real. Migrar esto sería un `UPDATE subclass_features SET consumes_resource_index_name = 'channel-divinity-cleric'/'channel-divinity' WHERE index_name LIKE 'channel-divinity-%' AND index_name NOT IN (las 3 tiered)`, análogo a lo de arriba pero sobre `subclass_features`. Igual para las features de Monje que cuestan 1 ki (Flurry of Blows, etc., ya en `_kKiConsumingFeatures`) — mismo patrón, aún sin migrar al backend real.

**Fase 5 (auditoría de las ~88 subclases de Aurora) — ✅ HECHO (2026-07-06).** Era el trabajo grande que motivó todo #8.2. Auditadas las 88 subclases no-PHB (consulta SQL contra el VPS, `backend/scripts/aurora_subclass_audit.sql`, volcada a `.txt` y leída directamente). Añadido `backend/scripts/patch_resource_pool_migration_phase5_aurora.sql`:
- **82 `class_resources` nuevos** + **88 `UPDATE` de enlace** (`consumes_resource_index_name`), mismo estilo idempotente que las fases anteriores. Cada `index_name` de feature/subclase referenciado se verificó por script contra el volcado real (124/124 encontrados, incluyendo un caso que parece typo — `ID_WOTC_SCAG_ARCHETYPEFEATURE_MASTER_DUELIST`, sin guion bajo entre ARCHETYPE y FEATURE — pero es el valor real que guarda el sync de Aurora, no un error de transcripción). Toda referencia a un recurso se verificó contra su creación (ni huérfanos ni referencias colgando).
- **Gap encontrado de paso: Wild Shape (Druida, PHB) nunca se sembró** en las fases 1/2/4 (Druida ni siquiera estaba en la lista de clases de esas fases) — necesario porque varias subclases de Aurora ("Circle of Spores"/"Circle of Stars"/"Circle of Wildfire") gastan un uso de Wild Shape en vez de transformarse. Añadido como prerequisito en la Sección 0 del script.
- **3 fórmulas nuevas en la DSL** (`services/CharacterClassResourceService.java`, mismo patrón que `wisdom_modifier_min1`/`intelligence_modifier_min1`/`one_plus_charisma_modifier` ya existentes): `constitution_modifier_min1` (Cavalier: Warding Maneuver; Echo Knight: Unleash Incarnation/Reclaim Potential), `strength_modifier_min1` (Cavalier: Unwavering Mark), `one_plus_level` (Celestial: Healing Light, "1 + nivel de Brujo").
- **Features deliberadamente NO modeladas como recurso** (no encajan en el modelo actual de descanso corto/largo, o no son un "pool de usos" en absoluto): compañeros/invocaciones con su propia vida (Steel Defender, Eldritch Cannon, wildfire spirit), features ligadas a Rage que no son un recurso aparte (Battlerager, Ancestral Guardian, Storm Herald, Beast, Wild Magic), recarga por trigger en vez de descanso (Keeper of Souls, Ever-ready Shot, Tireless Spirit), acumulación por evento (Tokens of the Departed), reseteo a un valor fijo en vez de al máximo (Power Surge), recarga aleatoria "1d4 descansos largos" (Limited Wish, Necrotic Husk), y opciones de Blood Curse que ya usan el pool `blood-maledict` existente.
- **Rune Knight — decisión tomada (2026-07-06): opción A, un recurso por runa (6 en total), fiel a las reglas reales.** Investigado el alcance real tras la decisión, y es mayor de lo que parecía: **las 6 runas individuales (Cloud, Fire, Frost, Hill, Stone, Storm) no existen en la BD como filas separadas** — `subclass_features` solo tiene una fila "Rune Carver" con el resumen ("aprendes 2 runas de las descritas más abajo"), sin las descripciones de cada runa (el sync de Aurora no las capturó estructuradas). Tampoco hay ningún mecanismo de elección en el wizard (`frontend/lib/config/dnd_choice_options.dart` no tiene ninguna entrada de runas), a diferencia de Battle Master Maneuvers/Metamagic que sí tienen su propio selector. Para implementarlo de verdad hacen falta, en este orden:
  1. Redactar a mano las 6 runas (nombre + descripción + efecto pasivo/activado) desde el manual TCE, vía un script de seed nuevo (mismo patrón que `seed_gunslinger_firearms.sql`) — contenido que Aurora nunca trajo.
  2. Un tipo de elección nuevo en el wizard (`RUNE_CHOICE` o similar) para que el jugador elija qué runas conoce, con su `PendingTask` correspondiente en `PlayerCharacterService.createSubclassLevelTasks()` — mismo patrón que Battle Master Maneuvers.
  3. Una fórmula DSL nueva para "1 uso, o 2 a partir de nivel 15" (mismo `levelThresholdTable()` que ya usan `action_surge_table`/`indomitable_table`).
  4. 6 filas `class_resources` (una por runa), y enlazar el uso de cada runa solo si el personaje la conoce.
  Es del mismo tamaño que Way of Shadow/Four Elements del Monje o Metamagic point-spend del Hechicero (#8.1) — necesita su propio diseño y sesión de trabajo, no es una extensión de la fase 5. Dejado como su propio punto de trabajo, no incluido en `patch_resource_pool_migration_phase5_aurora.sql`.
- **Bug preexistente encontrado de paso — ✅ HECHO (2026-07-06).** El recurso `grit` (Gunslinger) ya sembrado tenía `recovery_type = SHORT_REST`, pero su propio texto dice "Regain all grit on a short **or long** rest" — con la query de recuperación de antes, no se reponía en descanso largo. Corregido con `backend/scripts/patch_fix_grit_recovery_type.sql` (`UPDATE class_resources SET recovery_type = 'SHORT_OR_LONG_REST' WHERE index_name = 'grit'`). No es contenido de Aurora (se sembró en una fase anterior), pero se encontró auditando #8.2 fase 5. **Pendiente de que el usuario lo ejecute en el VPS.**
- **Duplicados por sourcebook** (Artificer ERLW/TCE, Order Domain GGtR/TCE, Bladesinging SCAG/TCE, Oath of Glory TCE/MOT, College of Eloquence TCE/MOT, Circle of Spores TCE/GGtR...): cada variante de sourcebook es una fila de `Subclass` distinta en la BD, y `subclass_restriction` es una comparación de un solo valor — así que cada variante tiene su propia fila de recurso (p. ej. `universal-speech-mot` / `universal-speech-tce`), no una compartida.
- **Verificado:** `mvn -o compile`/`mvn -o test` (exit 0). **Pendiente de que el usuario ejecute el script en el VPS** (`docker exec -i dnd-mysql mysql -u root -p$MYSQL_ROOT_PASSWORD dnd_character_manager < backend/scripts/patch_resource_pool_migration_phase5_aurora.sql`, tras desplegar el backend con el cambio de Java) y pruebe con algún personaje real de subclase Aurora.

**Dónde mirar probablemente (pieza `RESOURCE_POOL`):** `entities/ClassResource.java`, `entities/CharacterClassResource.java`, `entities/ClassFeature.java`/`SubclassFeature.java` (`consumesResourceIndexName`), `services/CharacterClassResourceService.java` (DSL en `calculateMaxAmount()`), `frontend/lib/viewmodels/characters/character_sheet_viewmodel.dart` (`_realResourceFor`, `_kConsumableFeatures`, `_sharedResourcePoolKey`), `frontend/lib/services/characters/character_class_resource_service.dart`, `backend/scripts/patch_resource_pool_migration_phase2.sql`/`phase3.sql`/`phase5_aurora.sql`.

---

### 8.2 — pieza `GRANT_PROFICIENCY` — ✅ HECHO (2026-07-06)

Migrados los dos focos de proficiencias otorgadas automáticamente (sin elección del jugador) de estar hardcodeados en Java a ser datos, mismo patrón que `RESOURCE_POOL`: una tabla de enlace + el código de aplicación pasa a ser un simple `findBy...`/bucle genérico, sin ningún `if`/`switch` por nombre.

- **`RacialTraitService.java`** — reescrito por completo. Antes: un `switch(indexName)` con 4 casos (`natural-illusionist`, `dwarven-armor-training`, `drow-weapon-training`, `drow-magic`), mezclando grants de hechizo y de competencia, solo para razas PHB (las razas de Aurora ya usaban una tabla genérica, `racial_trait_spells`, poblada por `AuroraRaceMapper` — pero **solo para hechizos**, nunca hubo equivalente para competencias). Ahora: el switch ha desaparecido entero. Los hechizos (los 4 casos, incluidos los 2 de PHB que antes eran hardcodeados) se resuelven todos vía `racial_trait_spells` (con `required_level`, así que Drow Magic sigue escalonando 1/3/5 correctamente); nueva tabla `racial_trait_proficiencies` (nueva entidad `RacialTraitProficiency`) cubre las competencias. `RacialTraitService` queda con dos bucles genéricos y cero conocimiento de qué raza es cuál.
- **`SubclassProficiencyService.java`** — la parte de grants automáticos (heavy armor, martial weapons, herramientas de artesano...) migrada a una tabla nueva `subclass_proficiency_grants` (nueva entidad `SubclassProficiencyGrant`), aplicada con un bucle genérico antes del resto del método. La parte de **elecciones** del jugador (Knowledge Domain: 2 skills + 2 idiomas; Nature Domain: elegir cantrip; College of Lore: 3 skills; Battle Master: herramienta/idioma; Lycan: tipo; Profane Soul: patrón) se queda tal cual, vía `PendingTask` — es un mecanismo distinto (una elección, no un grant automático) que el sistema de tareas pendientes ya resuelve genéricamente desde hace tiempo, no es parte de lo que `GRANT_PROFICIENCY` necesita cubrir.
- **Bug encontrado y corregido de paso:** War Domain (Clérigo) nunca recibía su bonificador de competencia (heavy armor + martial weapons) — la condición vieja comprobaba `idx.equals("war") || idx.contains("oath-of-the-war")`, pero el `index_name` real es `"war-domain"`, que no coincide con ninguna de las dos. Llevaba así desde siempre. Corregido al migrar a datos.
- **Script:** `backend/scripts/patch_generalize_proficiency_grants.sql` (idempotente, `WHERE NOT EXISTS`) — siembra las filas de las 4 razas/rasgos PHB, más 7 subclases (Tempest Domain, War Domain, Nature Domain, College of Valor, Armorer, Battle Smith, Alchemist, Artillerist — con sus variantes ERLW/TCE donde existen).
- **Verificado:** `mvn -o compile`/`mvn -o test` (exit 0). Nada cambia en el frontend — las competencias ya se muestran genéricamente desde `CharacterProficiency` sin importar su origen. **Pendiente de que el usuario ejecute el script en el VPS** y compruebe un Clérigo War/Tempest/Nature Domain, un Bardo College of Valor, un Enano de Montaña y un Drow.

**Alcance restante de `GRANT_PROFICIENCY` (fuera de esta pasada):** las razas/subclases de Aurora no se han auditado para ver si alguna otorga una competencia automática que el sync nunca capturó (mismo tipo de gap que #21 para items) — no detectado ningún caso concreto todavía, solo no descartado.

**Dónde mirar (pieza `GRANT_PROFICIENCY`):** `entities/RacialTraitProficiency.java`, `entities/SubclassProficiencyGrant.java`, `services/RacialTraitService.java`, `services/SubclassProficiencyService.java`, `backend/scripts/patch_generalize_proficiency_grants.sql`.

---

### 8.2 — pieza `NUMERIC_BONUS` — 🔶 sin empezar

Sigue 100% hardcodeada. Dos focos identificados, de tamaño y naturaleza distintos:
- **Backend** (`PlayerCharacterService.java:494-509`): Fighting Style Defense (+1 AC si hay armadura equipada) y Archery (+2 a ataques a distancia) — un `if/else` sobre el string elegido, folded directamente en el cálculo de `armorClass`/`rangedAttackBonus` del DTO del personaje. Es el único caso backend hoy.
- **Frontend** (`tab_combat.dart` y similares): Fighting Style Dueling (+2 daño cma) ya vive aquí; y es donde tendrían que vivir los bonificadores de daño que #8.1 deja sin implementar — Agonizing Blast (Warlock, +mod. CHA al daño de Eldritch Blast), Elemental Affinity (Hechicero Draconic, +mod. CHA a daño de un tipo elegido), Empowered Evocation (Mago Evocación, +mod. INT una vez por turno). Las bonificaciones a pruebas de habilidad (Remarkable Athlete del Campeón) también se calculan en el frontend (`tab_skills.dart`), no en el backend.

**Por qué no se ha tocado en esta sesión:** a diferencia de `RESOURCE_POOL` (autocontenido: una tabla + una fórmula + un endpoint) y `GRANT_PROFICIENCY` (autocontenido: una tabla + un bucle, sin tocar el frontend), un `NUMERIC_BONUS` reutilizable tendría que cubrir bonificadores que hoy se calculan en **dos sitios distintos** (AC/ataque en el backend, daño/pruebas de habilidad en el frontend) — generalizarlo de verdad necesita diseñar el esquema (a qué campo suma, con qué fórmula, bajo qué condición — "mientras lleve armadura", "con armas a distancia", "de un tipo de daño elegido por el jugador") Y exponerlo al frontend (mismo patrón que `/api/characters/{id}/resources` para recursos), Y cablear `tab_combat.dart`/`tab_skills.dart` para leerlo en vez de sus cálculos hardcodeados actuales. Es una pieza de trabajo del tamaño de las fases 1+2+4 de `RESOURCE_POOL` juntas, no algo para meter de pasada. Queda como el siguiente punto de trabajo real dentro de #8.2.

---

## 👨‍💼 Panel de administración

### 9. Creación manual de contenido por administradores
**Prioridad: Media** — Nueva funcionalidad. **Depende de generalizar #8.2 primero (ver nota de alcance ahí) — hoy no hay ningún esquema del que un formulario de admin pueda "leer" qué campos pedir.**

Permitir que los administradores creen contenido personalizado directamente desde la app (panel `admin_panel_screen.dart` / endpoints backend dedicados), sin depender de la sync con la API pública de D&D 5e ni de scripts SQL manuales en `scripts/`:
- Razas, subrazas.
- Clases, subclases.
- Backgrounds.
- Feats.
- Hechizos.
- Equipamiento.
- Otros elementos de reglas.

**Objetivo:** reducir la dependencia de importaciones externas o de scripts SQL manuales para contenido no cubierto por la API pública (como ya ocurre hoy con feats, subclases y subrazas, según se documenta en el README del backend).

**Requisito de diseño explícito (aclarado 2026-07-06, no anotado hasta ahora):** el formulario de crear/editar una feature de clase/subclase no debe ser un formulario de texto libre — según el "tipo de mecánica" que el admin elija para esa feature (Resource Pool / Numeric Bonus / Grant Spell / Grant Proficiency, ver #8.2), el formulario debe pedir **solo** los campos que ese tipo necesita: una fórmula de usos y tipo de descanso si es un recurso; a qué campo suma y bajo qué condición si es un bonificador; qué hechizo y a qué nivel si otorga un hechizo; etc. Esto es exactamente lo que #8.2 tiene que proveer como esquema común antes de que este panel se pueda construir — sin ese esquema, el panel de admin sería solo una forma más bonita de escribir SQL a mano, no una solución real.

**Segunda pieza, relacionada pero separada: una API propia con los datos ya separados.** Hoy, para consumir/sincronizar contenido de fuentes externas (API pública de D&D 5e, Aurora) hace falta interpretar cada una a su manera — la API pública ya da JSON estructurado (`damage_at_slot_level`, `dc_type`...), Aurora da texto libre que hay que parsear (#10, #21). La idea es que la propia API REST de la app (`/api/spells`, `/api/items`, `/api/classes`...) sea, para cualquier consumidor futuro, la fuente de verdad con los datos **ya** separados en campos estructurados — nombre, descripción, Hit/DC, tipo y dado de daño, escalado por nivel de lanzamiento, escuela, etc. como propiedades de primera clase, nunca texto a re-interpretar. Parcialmente cierto ya hoy para lo que sí está parseado (los DTOs de `/api/spells/available` ya devuelven estos campos separados cuando existen), pero no es un objetivo explícito documentado en ningún sitio hasta ahora, y depende de que #10/#21 terminen de rellenar esos campos para todo el catálogo (PHB + Aurora) y de que el contenido creado a mano desde este mismo panel de admin también los rellene desde el primer momento (no como texto libre que haya que parsear después).

---

### 10. Hechizos de Aurora sin datos de combate (Hit/DC, daño, escalado) — necesita parseador de descripción ✅HECHO.
**Prioridad: Media-Alta** — Para asignar a otro agente

Confirmado (2026-06-18): los hechizos sincronizados desde Aurora (no-PHB) llegan a la base de datos sin `attackType`, `dcType`, `damageType`, `damageBase` ni la tabla de escalado por nivel (`damageAtSlotLevel`, ver punto #4 ya resuelto para PHB). Está documentado como limitación conocida en `AuroraSpellMapper.java` ("Combat fields are left null — they require per-spell analysis").

**Causa de fondo:** la API pública de D&D 5e da estos datos en JSON estructurado y uniforme (`damage.damage_at_slot_level`, `dc.dc_type`, `attack_type`...). Aurora, en cambio, solo trae la descripción del hechizo como texto libre, sin esa estructura — cada sourcebook describe el daño/tirada de forma distinta.

**Lo que hace falta:** un parseador que extraiga de la descripción de cada hechizo de Aurora:
- Si es de ataque (ranged/melee) o de tirada de salvación (y de qué habilidad).
- Tipo y dados de daño base.
- Cómo escala el daño con el nivel de lanzamiento (cuando aplica — algunos hechizos escalan con más dados, otros con más "proyectiles/efectos" como Magic Missile/Scorching Ray, que ni siquiera la API pública resuelve bien, ver hallazgo de hoy).

**✅ HECHO (2026-06-29/2026-07-03).** Implementado `AuroraSpellCombatParser.java` (commit `36bbf10`), integrado en `AuroraSpellMapper.sync()`: parsea por regex sobre la descripción libre de cada hechizo —
- Ataque melee/ranged (`"melee spell attack"` / `"ranged spell attack"`) o tirada de salvación (`"<ability> saving throw"` → abreviatura STR-CHA).
- Daño base (`"XdY <tipo> damage"`, validando el tipo contra la lista oficial de tipos de daño).
- Escalado: tres patrones — lineal por nivel de slot ("damage increases by 1d6 ... for each slot level above 2nd"), cantrip a niveles 5/11/17, y umbrales explícitos ("...spell slot of 7th level or higher, the damage increases to 5d8").
- Deliberadamente best-effort: casos irregulares que ni la API pública resuelve bien (Magic Missile/Scorching Ray, escalado por proyectiles en vez de dados) se dejan sin parsear — mismo criterio de "gracioso degradado a null" que ya existía antes del parser.

Sincronizado y probado por el usuario contra los hechizos reales de Aurora en el VPS (`/api/sync/aurora/persist/spells`) — confirmado funcionando en producción.

**Por qué es más que un fix puntual:** el usuario quiere en el futuro un panel de admin para crear contenido nuevo (clases, razas, hechizos...) directamente desde la app (ver #9). Este parseador no debería ser un script suelto solo para Aurora, sino parte de una infraestructura común de extracción/normalización de datos de reglas, reutilizable tanto para el sync de Aurora como para lo que un admin meta a mano. Vale la pena diseñarlo pensando en ambos casos a la vez, no solo en tapar el agujero de Aurora.

---

### 21. Items de Aurora sin bonificadores mecánicos (mismo problema que #10, pero para items)
**Prioridad: Media-Alta** — Identificado 2026-07-06, mismo patrón que #10, sin empezar

Confirmado leyendo el código: `Item` (entidad) ya tiene campos estructurados y genéricos para bonificadores mecánicos — `bonusAc`, `bonusToHit`, `bonusSavingThrows`, `setStrTo`/`setDexTo`/`setConTo`/`setIntTo`/`setWisTo`/`setChaTo` (overrides de característica tipo Gauntlets of Ogre Power) — y `PlayerCharacterService` ya los aplica de forma completamente genérica a cualquier item equipado/sintonizado (`PlayerCharacterService.java:471-489`), sin ningún `if` por nombre de item. Es exactamente la misma clase de infraestructura que ya funciona bien para hechizos.

**El problema:** `AuroraItemMapper.java` deja estos campos explícitamente en 0/null para todo lo que sincroniza — dice en su propio comentario: *"Mechanical bonus fields (bonusAc, bonusToHit, set\*To) are left at their defaults (0 / null) — they require per-item analysis and are populated incrementally as bugs are found."* Así que cualquier anillo, capa, arma mágica o armadura mágica importada de Aurora que dé +1 AC, +1 a salvaciones, fuerce STR a 19, etc., hoy no hace nada en la app aunque el sistema para aplicarlo ya funcione — el mismo tipo de bug que Drakewarden/Thaumaturgy (#3), pero para items en vez de features de subclase.

**Lo que hace falta:** un parseador análogo a `AuroraSpellCombatParser` (#10) pero para items — extraer de la descripción libre del item patrones como "+1 bonus to AC", "you gain a +1 bonus to attack and damage rolls made with this weapon", "your Strength score is 19 while you wear these gauntlets", "+1 bonus to saving throws", y rellenar `bonusAc`/`bonusToHit`/`bonusSavingThrows`/`set*To` durante el sync, igual que ya se hace con los hechizos.

**Punto de partida ya preparado:** `backend/scripts/aurora_item_audit.sql` (consulta de solo lectura, no modifica nada) lista los items no-PHB con rareza/sintonización y confirma que sus campos de bonus siguen todos a 0/null, más sus descripciones completas para ver los patrones de frase reales. Cómo regenerar el volcado contra el VPS: ver memoria "Aurora content audit" (`reference_aurora_content_audit.md`). No auditado todavía en detalle (el volcado se generó pero no se ha leído a fondo esta sesión).

---

### 11. Pestaña Combat no se actualiza igual que Spells al añadir hechizos nuevos
**Prioridad: Media**

Confirmado (2026-06-18): al añadir hechizos nuevos a un personaje, la pestaña **Spells** los muestra correctamente, pero la pestaña **Combat** no — por ejemplo, Scorching Ray y Magic Missile no aparecen ahí tras añadirlos. Pendiente de investigar la causa (¿filtro distinto de qué hechizos se listan en Combat? ¿caché/estado no se refresca igual que en Spells?).

**(2026-06-19) No reproducible.** Probado de nuevo añadiendo un hechizo de ataque tanto desde el wizard de edición como desde el botón de la propia ficha — aparece correctamente en Combat en ambos casos. Pudo arreglarse de forma incidental con otros cambios de esta sesión, o ser un problema puntual. Dejar abierto por si reaparece con más detalle (clase/hechizo/vía exacta).

---

## 🧹 Deuda técnica

### 12. Revisar y reemplazar usos de `withOpacity`
**Prioridad: Baja**

`withOpacity` está deprecado en Flutter (genera warnings) y debe sustituirse por `.withValues(alpha: ...)` o el mecanismo recomendado actual.

**Alcance real detectado:** ~165 usos repartidos en **19 archivos** dentro de `frontend/lib/views/`, entre otros: `tab_spells.dart`, `tab_inventory.dart`, `tab_abilities.dart`, `tab_combat.dart`, `tab_features.dart`, `login_screen.dart`, `character_sheet_screen.dart`, `character_creator_screen.dart`, `admin_panel_screen.dart`, `pending_tasks_screen.dart`, `add_item_screen.dart`, `character_card.dart`, `class_detail_screen.dart`, `class_options_screen.dart`, y los steps `step_preferences.dart`, `step_equipment.dart`, `step_background.dart`, `step_class.dart`, `step_race.dart`, `step_spells.dart`.

**Objetivo:** eliminar los warnings y alinear con las recomendaciones actuales del framework.

---

## 🚀 Infraestructura y despliegue

### 13. Dominio y publicación de la aplicación
**Prioridad: Alta (cuando se acerque la release)**

Tareas pendientes para pasar a producción real:
- Contratar dominio.
- Configurar DNS.
- Generar build de producción (`flutter build web --release` + copiar a `backend/frontend-dist/`).
- Desplegar (`docker compose up -d`, contenedores `dnd-mysql` / `dnd-backend` / `dnd-nginx`).
- Configurar HTTPS.
- Verificar funcionamiento en entorno real.

---

## 📝 Limpieza de textos y contenido

### 14. Texto duplicado "2nd class feature" en las especializaciones de Artificiero ✅HECHO (según el usuario).
**Prioridad: Baja**

Las dos especializaciones del Artificiero muestran la frase "2nd class feature" u otras dependiendo del nivel de forma redundante en su descripción. Revisar el origen del texto (datos sync/manual del Artificiero) y el formateo de descripciones generadas para subclases.

**Nota (2026-06-19):** el usuario confirma que ya no se reproduce, aunque sigue habiendo descripciones de Artificiero con formato raro en algunos casos — pendiente de revisar caso a caso si vuelve a aparecer.

---

## ⚡ Rendimiento

### 19. "Manage Spells" ralentiza la app al abrirse (pestaña "Learn New") ✅HECHO.
**Prioridad: Media**

Al entrar en "Manage Spells" desde la pestaña Spells de la ficha, la app se ralentiza notablemente. Causa más probable: la pestaña "Learn New" (`ManageSpellsScreen` → `_LearnNewTab`, `frontend/lib/views/screens/sheet/tabs/tab_spells.dart:1007-1056`) carga **todos** los hechizos disponibles para la clase del personaje de golpe vía `CharacterSheetViewModel.loadAvailableSpells()` (`character_sheet_viewmodel.dart:392-407`, llama a `GET /api/spells/available?classId=&maxLevel=`). El filtro por `classId`/`maxLevel` ya es server-side, pero desde que se enlazaron los 160 hechizos de Aurora a sus clases (punto #18, "Hechizos de expansión que faltan"), una clase full-caster (Wizard, Sorcerer, Warlock...) puede traer fácilmente 100-200+ hechizos en una sola respuesta.

Una vez en memoria, el problema se agrava en el render:
- Cada nivel de hechizo se pinta con `ListView.builder` (virtualizado), pero **dentro de cada nivel** los hechizos se expanden con `...spells.map(...)` en vez de otro `ListView.builder` anidado — es decir, si el nivel 1 tiene 40 hechizos, los 40 widgets se construyen de golpe en vez de solo los visibles.
- El buscador (`_query`) filtra en memoria sobre la lista completa en cada pulsación de tecla (`.where(...)` en el `build()`), sin debounce ni filtrado en servidor.
- La lista se recarga desde la red cada vez que se entra en la pantalla si `availableSpells` está vacío al salir (no hay caché entre aperturas dentro de la misma sesión de la ficha).

**Sugerencia de mejora:**
- Virtualizar también los hechizos dentro de cada nivel (p. ej. un único `ListView.builder` plano con cabeceras de nivel como "sticky headers", o `SliverList` por secciones, en vez de `Column` + `.map()` anidado).
- Añadir debounce (~250-300ms) al buscador antes de re-filtrar, para no recalcular en cada tecla.
- Evaluar mover el filtrado de texto al backend (`/api/spells/available?search=...`) si la lista por clase sigue siendo grande, o cachear `availableSpells` en el ViewModel mientras la ficha esté abierta para no repetir la llamada de red en cada apertura de "Manage Spells".

**Dónde mirar probablemente:** `frontend/lib/views/screens/sheet/tabs/tab_spells.dart` (`_LearnNewTab`, líneas ~1007-1056 y el `build()` con el `.map()` por nivel), `frontend/lib/viewmodels/characters/character_sheet_viewmodel.dart` (`loadAvailableSpells()`), `frontend/lib/services/spells/spell_service.dart` (`getAvailableSpells()`), backend `SpellController`/`SpellService` para el endpoint `/api/spells/available`.

**✅ HECHO (2026-07-03).** En `_LearnNewTab._buildContent()` (`tab_spells.dart`): los niveles y hechizos ya no se anidan como `Column` + `...spells.map(...)` dentro de un `ListView.builder` por nivel — se aplanan en una sola lista (`flatItems`, mezclando marcador de nivel `int` y `SpellOption`) que alimenta un único `ListView.builder` plano, así que cada hechizo se construye solo cuando entra en viewport, sin importar cuántos tenga el nivel.

Añadido debounce de 280ms al buscador (`_ManageSpellsScreenState`, `Timer _searchDebounce`): el `TextField.onChanged` ya no llama `setState` en cada tecla, espera a que el usuario deje de teclear antes de recalcular el filtro sobre `_MySpellsTab`/`_LearnNewTab`.

**Caché entre aperturas:** revisado — `CharacterSheetViewModel._availableSpells` nunca se resetea a `[]` en ningún punto salvo su inicialización, y `ManageSpellsScreen` recibe el mismo `vm` (por referencia) que ya vive en la ficha, no uno nuevo. `_LearnNewTabState.initState()` ya comprobaba `if (vm.availableSpells.isEmpty) loadAvailableSpells()`, así que la caché entre aperturas dentro de la misma sesión de ficha ya funcionaba correctamente — no hacía falta ningún cambio ahí, la sospecha del punto original no aplicaba.

---

### 20. Cargas lentas (varios segundos) en Class Features de la ficha y en Raza/Spells/Items del wizard ✅HECHO.
**Prioridad: Alta** — Reportado 2026-07-06 por el usuario probando la app tras el sync de Aurora.

Al abrir una ficha, las **class features** (subclase) tardaban mucho en cargar; creando un personaje, los pasos de **Raza**, **Spells** e **Items** tardaban varios segundos cada uno — más de lo normal. Investigado el backend (`DndClassController`/`SubclassController`, `RaceService`, `SpellController`/`SpellService`, `ItemController`), causa raíz confirmada: **N+1 queries** que siempre existieron pero eran imperceptibles con las ~pocas docenas de filas PHB, y se volvieron muy visibles al multiplicarse las filas de `races`/`spells`/`items`/`class_spells` con el sync de Aurora (160 hechizos, cientos de items nuevos, 449 vínculos clase-hechizo nuevos según #18). Encontrados 3 problemas concretos, verificados leyendo entidades/repositorios/servicios (no solo sospecha):

1. **`GET /api/subclasses/{id}/features` — el más grave, explica "class features tarda mucho".** El controlador devolvía la entidad `SubclassFeature` cruda (sin DTO), y su cadena `SubclassFeature.subclass` (`@ManyToOne` eager) → `Subclass.dndClass` (`@ManyToOne` eager) → `DndClass.spells` (`@ManyToMany`, con getter público, sin `@JsonIgnore`) hacía que Jackson serializara **todos los hechizos de la clase entera** al pedir solo las features de una subclase — y cada `Spell` serializado disparaba a su vez su propia colección `damageAtSlotLevel` (`@ElementCollection`, eager por defecto en JPA), una query extra por cada hechizo. Arreglado: `SubclassFeatureService` ahora mapea a `ClassFeatureDto` (el mismo DTO que ya usaba `/api/classes/{id}/features`, que nunca tuvo este problema) en vez de devolver la entidad — el grafo de la clase/hechizos ya no se toca en absoluto.
2. **`GET /api/spells/available`** (wizard, paso Spells): devolvía `List<Spell>` cruda — mismo problema de `damageAtSlotLevel` por fila (N+1 directo, uno por hechizo devuelto). Además, `SpellService.getAvailableSpells()` ejecutaba la **misma query completa dos veces** en el caso común (una vez solo para comprobar `.isEmpty()`, otra para el resultado real). Arreglado: nuevo mapeo a `SpellDto` (ya existía pero no se usaba en ningún sitio; se le añadieron los campos que el wizard necesita — `castingTime`/`range`/`duration`/`components`, ya presentes en el modelo `SpellOption` del frontend) y sustituido el chequeo `.findByDndClassesId(...).isEmpty()` por `existsByDndClassesId(...)` (nuevo método en `SpellRepository`, no trae filas).
3. **`GET /api/items`** (wizard, paso Items) y **`GET /api/races`** (wizard, paso Raza): ya devolvían DTOs correctos, pero `Item.weaponProperties` y `Race.abilityBonuses` son `@ElementCollection` (eager por defecto en JPA) sin ningún `@BatchSize`/`default_batch_fetch_size` configurado — Hibernate hacía una query aparte por cada item/raza para traer esa colección. Arreglado con `spring.jpa.properties.hibernate.default_batch_fetch_size=50` en `application.properties` (mitigación global: agrupa esas queries en lotes de 50 en vez de una por fila, cubre estos dos casos y cualquier otra colección `@ElementCollection`/lazy del proyecto sin tocar código por entidad).

**Verificado:** `mvn -o compile`/`mvn -o test` (exit 0, sin tests rotos) y `flutter analyze` (sin warnings nuevos, solo los `withOpacity` preexistentes de #12) — no se pudo probar contra los datos reales del VPS (ver "Local environment" de `CLAUDE.md`), así que **pendiente de que el usuario despliegue (`docker compose up -d --build backend`) y confirme la mejora real de tiempos** en ficha (class features) y wizard (Raza/Spells/Items).

**Dónde mirar:** `backend/src/main/java/controllers/SubclassController.java`, `services/SubclassFeatureService.java`, `controllers/SpellController.java`, `services/SpellService.java`, `repositories/SpellRepository.java`, `dto/SpellDto.java`, `backend/src/main/resources/application.properties`.

**No hecho a propósito (fuera de alcance de esta pasada):** mover el filtrado de texto al backend — con la virtualización + debounce ya no hace falta para el volumen actual (100-200 hechizos); revisar si vuelve a ser necesario si el catálogo crece mucho más.

Confirmado por el usuario probándolo manualmente en su sesión habitual (2026-07-03).

---

## 👤 Gestión de cuenta

### 15. Permitir cambiar el nombre de usuario
**Prioridad: Media** — Nueva funcionalidad

Actualmente los usuarios pueden cambiar su contraseña pero no su nombre de usuario.

**Comportamiento esperado:**
- Añadir opción para modificar el username desde la configuración del perfil.
- Validar que el nuevo nombre no esté ya en uso.
- Mantener las mismas restricciones de formato que en el registro.
- Propagar el cambio en toda la app (estado de sesión, referencias en UI).

**Consideraciones adicionales a decidir antes de implementar:**
- ¿El username debe seguir siendo único globalmente?
- ¿Debe limitarse la frecuencia de cambio (p. ej. una vez cada X días)?
- ¿El username aparece en URLs públicas o identificadores visibles que se romperían al cambiarlo?


## Items mágicos

### 16. Revisar qué items requieren attunement y aplicarlo funcionalmente en la app ✅HECHO.
**Prioridad: Media**
- Tras el Aurora Sync, se introdujeron una cantidad nueva y grande de items, algunos de ellos requieren attunement, con lo que funcionalmente en la app deberían serlo también (de manera que en inventory sólo puedan ser equipados como attuned) — **Hecho (2026-06-19):** el frontend ya lo impedía vía drag-and-drop; añadida la misma validación en el backend (`CharacterInventoryService.toggleEquipped()`, 409 si el item requiere attunement y no está attuned) como defensa en profundidad. Confirmado que el sync de Aurora rellena `requiresAttunement` correctamente desde el campo `attunement` de la fuente.
- Revisar si hay items de armas de fuego introducidas de las canon en D&D, ya que es necesario. — **Hecho (2026-06-19):** confirmado que no existía ninguna en la BD de producción. Añadidas las 7 armas de fuego del archetype Gunslinger (Palm Pistol, Pistol, Musket, Pepperbox, Blunderbuss, Bad News, Hand Mortar) vía `backend/scripts/seed_gunslinger_firearms.sql`, usando los stats ya descritos en el texto de la feature "Firearm Proficiency" de esa subclase. Ejecutado en el VPS.

## Multiclase

### 17. Añadir funcionalidad de multiclase
**Prioridad: Baja** — Nueva funcionalidad grande, toca modelo de datos, level-up y front

Hoy el modelo es estrictamente mono-clase: `PlayerCharacter` tiene un único `int level` y un único `@ManyToOne DndClass dndClass` (+ `subclass`), y toda la lógica de nivel/hechizos/features asume ese único par (clase, nivel de personaje). Añadir multiclase no es solo "permitir elegir otra clase", son varios subsistemas que hay que tocar a la vez:

**1. Modelo de datos (lo que falta de raíz):**
- No existe ninguna entidad que relacione un personaje con varias clases y el nivel que tiene en cada una. Hay que crear una entidad puente (p. ej. `PlayerCharacterClass`: personaje, clase, subclase, nivel-en-esa-clase) y migrar `dndClass`/`subclass`/`level` actuales de `PlayerCharacter` a ser, en la práctica, una vista derivada (clase principal = la primera tomada, nivel total = suma de niveles en cada clase) para no romper todo lo que ya lee esos campos directamente.

**2. Level-up (`POST /api/characters/{id}/level-up`, `PlayerCharacterService.levelUp()`):**
- Actualmente busca `ClassLevelProgression` por `(dndClass, newLevel)` asumiendo una sola clase — con multiclase hay que: (a) dejar elegir a qué clase se sube ese nivel (nueva clase o una ya existente), (b) si es una clase nueva, aplicar los requisitos de multiclase de 5e (mínimos de habilidad, p. ej. STR 13 para Fighter, DEX 13 para Rogue, etc. — actualmente no se valida nada de esto ni siquiera en creación), (c) calcular el nivel de competencia (`proficiency bonus`) sobre el **nivel total del personaje** (esto ya está bien, no depende de clase), pero todo lo demás (rasgos de clase, recursos de clase, ASI) debe evaluarse por **nivel dentro de esa clase concreta**, no por nivel de personaje.
- Las limitaciones de uso multiclase a aplicar en el level-up, concretamente:
  - **Hechizos (la parte más compleja):** los slots de conjuro no se calculan por clase sino sumando un "nivel de lanzador" (caster level) ponderado por clase según la tabla de multiclase del PHB (full caster cuenta 1, half caster cuenta 0.5 redondeando hacia abajo el total, third caster cuenta 1/3, Warlock no entra en este cómputo y mantiene sus Pact Magic aparte). Ahora mismo `generateSpellSlots()` solo mira `SpellSlotProgressionRepository.findByDndClassAndCharacterLevel(dndClass, character.getLevel())`, que asume una sola clase — habría que sustituirlo por una función que recoja todas las clases lanzadoras del personaje, calcule el caster level combinado y consulte la tabla multiclase en vez de la tabla por clase.
  - **Cantidad de hechizos conocidos/preparados:** se calculan por clase individualmente (cada clase mantiene su propia lista de hechizos conocidos), pero los slots para lanzarlos son compartidos (ver punto anterior).
  - **Competencias de armadura/armas que limitan lanzar conjuros:** una regla real de multiclase es que si el personaje no tiene competencia con la armadura que lleva, no puede lanzar conjuros de ninguna clase — no hay ninguna validación de esto en el código actual.
  - **ASI/Feat:** los niveles de ASI (4, 8, 12, 16, 19) son por clase, no por nivel de personaje — un Bardo 4/Guerrero 4 debería tener dos ASIs (uno en cada clase), no uno. El sistema de `PendingTask` actual genera estas tareas mirando `(feature, character_level)` sin contexto de clase; hay que añadir ese contexto para no perder ni duplicar ASIs.
  - **Competencias nuevas al multiclasear:** las tablas de multiclase del PHB dan un subconjunto reducido de competencias (normalmente solo armas/armadura ligera, nunca salvación) respecto a las que se obtienen al elegir esa clase desde nivel 1 — `CharacterProficiency` no distingue origen por clase hoy (solo tiene `source` como string), así que aplicar esto bien requiere poder marcar "estas competencias vienen de tomar X como segunda clase" para no otorgar de más.
  - **Hit Dice:** cada clase aporta su propio dado de golpe (d6/d8/d10/d12 según la clase), y al subir nivel hay que tirar/calcular con el dado de la clase en la que se sube, no con un dado fijo del personaje.

**3. Frontend — mostrar multiclase en la ficha:**
- La ficha (`character_sheet_screen.dart` y tabs) hoy asume "una clase, un nivel" en cualquier sitio donde se muestre el nombre/icono de clase o el nivel (cabecera del personaje, `tab_features.dart` al agrupar features por clase, `step_class.dart`/wizard si se reutiliza para añadir una segunda clase). Hay que decidir cómo se representa visualmente (p. ej. "Bardo 4 / Guerrero 4" en la cabecera) y agrupar features/recursos por clase de origen en vez de mostrarlos todos mezclados.
- El wizard de creación (`CharacterCreatorViewModel`, pasos `step_class.dart`/`step_spells.dart`/`step_equipment.dart`) está diseñado para elegir una sola clase inicial; tomar una segunda clase probablemente debería ser un flujo distinto al de creación (algo más parecido a level-up con un selector de "clase nueva vs. clase existente"), no reutilizar el wizard completo.

**Por qué es de prioridad baja pero hay que documentarlo bien:** es la funcionalidad más compleja y transversal del backlog (toca entidades, el endpoint de level-up, el cálculo de hechizos y el front a la vez), y antes de implementarla conviene haber resuelto primero los bugs base de progresión por nivel/hechizos que ya están detectados en otros puntos de este documento (especialmente #1 HP por nivel, #4 escalado de hechizos, y el bug de Fighting Style del punto 18), porque multiclase los vuelve a tocar todos y sería más caro arreglarlos después de meter multiclase que antes.

**Dónde mirar probablemente:** `entities/PlayerCharacter.java` (clase/nivel actuales), `services/PlayerCharacterService.java` (`levelUp()`, `generateSpellSlots()`, `processClassLevelFeatures()`), `repositories/SpellSlotProgressionRepository.java` y `ClassLevelProgressionRepository.java`, `entities/CharacterProficiency.java`, y en frontend `character_sheet_screen.dart`, `tab_features.dart`, `CharacterCreatorViewModel`.

### 18. Fixes que me voy encontrando o dudas.
- Fighting Style suma donde tiene que sumar? Porque si escoges archery, se suma el bonificador de ataque a sólo armas a distancia? — ✅ Sí, confirmado y probado (Defense/Archery ya funcionaban; ver detalle abajo).
- Creo que las subrazas de tiefling están sumando mal los bonificadores. Tiefling aparece como +2 CHA +1 INT, pero luego cada subraza parece añadir muchos bonificadores más. Y según los manuales, Tiefling como tal te da un bonificador y la subclase un bonificador secundario. Temo que tal como está ahora sume demasiadas cosas. — **✅ HECHO (2026-06-29), dos bugs distintos encontrados:**
  - **Bug 1 (el reportado):** confirmado con datos reales del VPS — Tiefling (PHB) da +2 CHA +1 INT a nivel de raza, y los 9 linajes variantes de Aurora (Feral Tiefling de SCAG + 8 linajes de MToF: Zariel, Mephistopheles, Glasya, Mammon, Fierna, Baalzebub, Dispater, Levistus) traen cada uno su **propio paquete completo** (+2 CHA + 1 otra característica), que `PlayerCharacterService.create()` sumaba siempre al de la raza base, duplicando el CHA. Por reglas reales estos linajes **sustituyen** el bono de raza, no se suman. Arreglado con un nuevo campo `replacesRaceAbilityBonus` en `Subrace.java` (genérico, no específico de Tiefling, para cualquier linaje variante futuro) + lógica en `PlayerCharacterService` que omite el bono de raza cuando el flag está activo + `scripts/patch_tiefling_variant_lineages.sql` marcando las 9 subrazas ya sincronizadas. (Asmodeus es un caso aparte sin filas de bono propias en BD — en MToF su bono ES igual al de la raza base, así que no necesita el flag; el chip del wizard no muestra nada para él, lo cual es confuso pero el resultado final es correcto. Pendiente de mejora visual menor si reaparece.)
  - **Bug 2 (mucho más grave, encontrado al verificar el fix del Bug 1 en producción):** `CharacterService.createCharacter()` (frontend) **nunca tuvo un parámetro `subraceId`** — el wizard guardaba la subraza elegida en `selectedSubrace` pero nunca la enviaba al backend al crear el personaje, solo al editar (`updateProfile` sí lo enviaba). Esto significa que **ninguna subraza se ha aplicado nunca en creación**, para ninguna raza (Elfo Alto, Enano de Montaña, cualquier Tiefling...) desde siempre — ni bono de característica ni traits — solo el bono de la raza base. Arreglado añadiendo `subraceId` a `createCharacter()` y a la llamada de `CharacterCreatorViewModel.submit()`. Confirmado en producción con un Tiefling nuevo: ahora sí suma bien. **Los personajes creados antes de este fix con alguna subraza seleccionada se quedaron sin su bono/traits aplicados** (su `subrace_id` en BD es NULL aunque el jugador eligiera una) — pendiente decidir si se corrigen retroactivamente caso a caso.
- **Fighting Style: ✅ HECHO (2026-06-19).** Confirmado bug real y de todas las clases (no solo Aurora): solo había lógica numérica para Defense y Archery. Arreglado:
  - **Two-Weapon Fighting**: tenía un bug de detección (`hasTwoWeaponFighting` comprobaba una `ClassFeature` con `indexName=='two-weapon-fighting'` que nunca existe — el Fighting Style es una elección, no una feature de clase — así que nunca era `true`). Corregido para leer el campo real `character.fightingStyle` (nuevo, expuesto en `PlayerCharacterDto`).
  - **Dueling**: implementado de cero (+2 al daño cma con un arma a una mano y ninguna otra), en `tab_combat.dart`.
  - **Great Weapon Fighting / Protection**: no son representables como número (uno reroll de dados que la app no simula, el otro una reacción sobre aliados) — se muestran como badge descriptivo en Combat en vez de aplicar un efecto inexistente.
  - UX: para evitar que el jugador piense que tiene que sumar el bonus a mano, el badge descriptivo en Combat solo aparece para los estilos SIN efecto numérico automático (GWF, Protection, los de Tasha's); para los que sí tienen efecto (Archery/Defense/Dueling/Two-Weapon Fighting) se confirma la elección en `tab_features.dart` en su lugar, sin repetir el número.
- **`PendingTasksScreen` reactivada (2026-06-19).** Estaba deshabilitada (`character_sheet_screen.dart`, navegación comentada). Reactivada la carga (`_loadPendingTasks()` en `CharacterSheetViewModel.loadCharacter()`) y el botón de acceso. De paso se corrigió un bug igual al de ASI/Feat del wizard (#1): el resolver de ASI dentro de esta pantalla también enviaba el nombre completo de la habilidad ("Strength") en vez de la abreviatura ("STR") que espera el backend. Las elecciones de **seguimiento** generadas después de la creación (p. ej. las 3 skills de "Skilled", que solo se crean al resolver el ASI_OR_FEAT) ya deberían poder resolverse desde aquí — sin verificar todavía caso por caso.
- Creo que el botón de "Crear Personaje" en el step de inventory no debería poder ser pulsado hasta que haya cargado bien el inventory, porque me he dado cuenta que da error 500 si pulsas el botón de Crear Personaje antes de que cargue inventory. — **(2026-06-19) No se ha vuelto a reproducir** tras los cambios de esta sesión; pudo ser puntual. Dejar abierto por si reaparece.
- Las battle maneuver del battle master, cuando tienes que escoger varias, cuando escoges una, en las siguiente "battle maneuver" deberían deshabilitarse las ya escogidas. — **(2026-06-19) Confirmado, sigue siendo un bug.** Pendiente de arreglar.
- **Artificiero no activa el step de Spells: ✅ HECHO (2026-06-19).** Causa raíz: `spellcasting_ability = NULL` en la BD para ambas variantes (ERLW/TCE) — `isSpellcaster` depende de ese campo. Al investigar se encontraron dos huecos más detrás del mismo síntoma, los tres necesarios para que el Artificiero funcione de verdad en el wizard:
  - `spellcasting_ability` NULL en BD → `scripts/patch_artificer_spellcasting.sql` (UPDATE a `'int'`).
  - `spell_slot_progression` con 0 filas para Artificiero (class_id 13/14) → `scripts/seed_artificer_spell_slots.sql` (tabla oficial TCE/ERLW completa, 20 niveles, tope 4º nivel de hechizo).
  - `maxSpellsKnown`/`maxSpellLevel`/`maxCantrips` en `CharacterCreatorViewModel` no tenían rama para `'artificer'` (caían a 0) — añadidas las fórmulas oficiales (preparación: mod. INT + mitad de nivel; tope de nivel de hechizo en 1/7/13/18; cantrips por tabla propia).
  - **Cuarto hueco encontrado al probarlo:** `class_skill_choices` tampoco tenía ninguna fila para Artificiero (pedía elegir 2 skills sin ofrecer ninguna opción), así que el botón "Next" del step de Clase quedaba bloqueado para siempre. → `scripts/patch_artificer_skill_choices.sql` (Arcana, History, Investigation, Medicine, Nature, Perception, Sleight of Hand).
  - Scripts SQL ejecutados en el VPS por el usuario.
- **(2026-06-19) Background se pierde al editar: ✅ HECHO.** Causa: `selectedSources` nunca se restauraba al entrar en modo edición (siempre arrancaba en solo PHB), así que cualquier raza/clase/subclase/background de fuente no-PHB quedaba invisible en los catálogos filtrados. Corregido en `forEdit()`/`forLevelUp()`.
- **(2026-06-19) "Save Changes" daba error 500: ✅ HECHO.** No relacionado con el bug anterior — `POST /pending-tasks/{id}/resolve` fallaba porque `_autoResolveFeatureChoices()` intentaba volver a resolver tareas YA completadas (el backend lo rechaza). Pasó a ser un problema real con el fix de pre-relleno del punto #1 (que deja un valor no-nulo en `featureChoices` para tareas completadas, solo para mostrarlas — pero `_autoResolveFeatureChoices` las reenviaba igualmente). Corregido con un guard `if (task.completed) continue;`.
- **(2026-06-19) Sugerencia de UX: ✅ HECHA (2026-06-29).** En modo edición puro (no level-up), cada paso del wizard muestra "Save Changes" y guarda directamente desde cualquier paso, no solo el último (`character_creator_screen.dart`, `_NavButtons`). No se aplica a level-up porque ahí las elecciones de nivel nuevo deben resolverse en orden. La navegación libre entre pasos ya existía vía los puntos del indicador superior (`goToStep`, sin restricción de orden), así que no se pierde nada al quitar el "Next" intermedio en edición.
- **(2026-06-19) Step de Spells sin tick al editar: ✅ HECHO.** `spellsValid` dependía de `_spellsStepVisited` (pensado para forzar al menos una visita en creación), pero en edición los hechizos ya existen desde el principio — ahora `loadEditData()` marca el paso como visitado automáticamente si el personaje es lanzador. El step de Equipment sin tick es comportamiento esperado (paso opcional que nunca bloquea; los items reales se gestionan desde el tab Inventory, no desde este step).
- **Hechizos de expansión que faltan en las listas de clase: ✅ HECHO (2026-06-19).** Causa raíz, mucho más grave de lo que parecía: **ninguno de los 160 hechizos no-PHB sincronizados desde Aurora (XGtE, TCE, EGtW, FToD, SCAG, SCoC, IDRotF, GGtR, VGtM, AI) tenía ninguna clase vinculada en `class_spells`** — estaba documentado como limitación conocida en `AuroraSpellMapper.java` ("DndClass linking is skipped here... handled separately", pero nunca se llegó a hacer esa parte separada). Confirmado con Shadow Blade (XGtE): existe en `spells`, pero `class_spells` no tenía ninguna fila para él.
  - El campo `supports` de Aurora ya trae los nombres de clase en texto plano (ej. `"Sorcerer, Warlock, Wizard"`), mezclados con tags no-clase (`"Ranged"`, `"Spell Attack"`...) y casos de subclase (`"Rogue (Arcane Trickster)"`). Implementado el parseo en `AuroraSpellMapper.linkClasses()`: separa por comas, recorta el paréntesis de subclase, y enlaza por *prefix match* contra el nombre real de la clase (así "Artificer" enlaza con ambas variantes "Artificer (ERLW)"/"(TCE)"); los tokens que no coinciden con ninguna clase (los tags) se ignoran solos, sin lista de exclusión manual.
  - Nuevo método `DndClassRepository.linkSpell()` con `INSERT IGNORE` (la tabla `class_spells` tiene PK compuesta `class_id+spell_id`), así que re-ejecutar el sync es idempotente.
  - **No hace falta backfill aparte**: re-ejecutar `POST /api/sync/aurora/persist/spells` (tras desplegar el backend) reprocesa los 160 hechizos ya sincronizados y crea los enlaces que faltaban.
  - Primer intento real tras desplegar dio `classLinks: 0` — `DndClassRepository.linkSpell()` es una query `@Modifying`, que Spring Data JPA rechaza fuera de una transacción ("Executing an update/delete query"), capturado en silencio por el try/catch por-hechizo. Arreglado añadiendo `@Transactional` a `AuroraSpellMapper.sync()`. Confirmado en producción: **449 vínculos clase-hechizo creados** sobre los 160 hechizos; Shadow Blade ya aparece para Sorcerer/Warlock/Wizard.
  - **Efecto colateral encontrado al probar**: con más hechizos de expansión visibles en el wizard, salió un overflow de layout en `step_spells.dart` — la fila de tags (nivel/escuela/tiempo de lanzamiento) no manejaba `castingTime` largo (algunas reacciones de Aurora describen su condición en una frase completa, ej. "1 reaction, which you take when..."). Corregido: `Row` → `Wrap` (para que los tags salten de línea en vez de desbordar) + límite de ancho con elipsis en `_Tag`. `tab_spells.dart` (la ficha) ya truncaba esto correctamente (`_shortTime()`), solo el wizard tenía el bug.
  - **Otro bug encontrado al probar: `components` salía vacío para todos los hechizos de Aurora.** `AuroraSpellMapper.buildComponents()` buscaba las claves `"verbal"`/`"somatic"`/`"material"`/`"materials"` en los setters, pero Aurora las llama `"hasVerbalComponent"`/`"hasSomaticComponent"`/`"hasMaterialComponent"`/`"materialComponent"` — nunca coincidían. Corregido.
  - **Aclaración (no es un bug nuevo):** estos hechizos de expansión siguen sin Hit/DC/daño/escalado por nivel (`attack_type`/`dc_type`/`damage_type`/`damage_base` NULL) — es exactamente el hueco ya documentado en el punto #10 (parseador de descripción de Aurora), no algo que este fix debiera cubrir.
  - **Aclaración: "Green-Flame Blade" aparece dos veces — no es un bug.** Son dos versiones de sourcebook distintas (`source='SCAG'` y `source='TCE'`, id 455 y 394): el hechizo se publicó originalmente en *Sword Coast Adventurer's Guide* y se reimprimió en *Tasha's Cauldron of Everything* con texto actualizado. Mismo patrón que el Artificiero ERLW/TCE. Si aparecen más "duplicados" así, comprobar primero `source` antes de asumir que es un fallo del sync.

  - Revisar si visualmente se ven bien los hechizos ahora (se veían mal) y además si se adaptan a las necesidades de la app (mecánicamente hablando)
- **Battle Master: deshabilitar maniobras ya elegidas: ✅ HECHO (2026-06-29).** Causa: en `class_options_screen.dart` (selector de subclass feature choices), `alreadyTaken` solo se calculaba para `LORE_BONUS_PROF` — cualquier otro choice "ranurado" (varios slots compartiendo la misma lista de opciones: Battle Master Maneuvers, Four Elements Disciplines, Trick Shots del Gunslinger) recibía siempre `const {}`, así que nunca se deshabilitaba nada ya elegido en otro slot. Corregido calculando `alreadyTaken` genéricamente: para cada choice, se recogen los valores ya elegidos en otros `subclassFeatureChoices` que comparten la misma lista de opciones (comparación por identidad de la lista const), no solo el caso de Lore. Efecto colateral correcto: arregla el mismo bug latente en Four Elements Monk y Gunslinger Trick Shots, que no estaban reportados pero tenían exactamente el mismo problema. Probado y confirmado funcionando por el usuario.
  
