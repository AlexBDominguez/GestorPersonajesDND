# Aurora Fixes — Backlog de incidencias y mejoras (DungeonScroll)

Lista de bugs y mejoras pendientes, organizados por área. Cada entrada incluye contexto del proyecto (módulos/archivos probablemente implicados) para facilitar el triage y la implementación. Las prioridades son las indicadas por el usuario.

---

## 📋 Estado para retomar (sesión 2026-06-19)

**Resuelto y confirmado por el usuario en producción:** #1, #2, #4, #5, #6, #7, #14, #16, y dentro de #18: Fighting Style, reactivación de `PendingTasksScreen`, Artificiero no activaba Spells, background se perdía al editar, error 500 al guardar cambios, step de Spells sin tick al editar, hechizos de expansión sin clase vinculada (+ components vacíos de Aurora), Battle Master maneuvers ya elegidas sin deshabilitar en el selector, bonificadores de subraza de Tiefling duplicados, `subraceId` nunca enviado en creación (bug mucho más grave encontrado de paso — ninguna subraza se aplicaba nunca al crear personaje), "Save Changes" en cada paso del wizard en modo edición. Todos con commits ya hechos en `dev` (sin pushear a remoto salvo que el usuario lo haya hecho aparte — confirmar con `git log`/`git status` antes de seguir).

**Sin empezar / pendiente, por tamaño/prioridad:**
- **#3 / #8 / #8.1** — la auditoría grande de features de clase/subclase sin efecto mecánico (Channel Divinity, Ki points, Infusions del Artificiero, etc.). El trabajo más grueso que queda; #8.1 ya tiene un inventario clase-por-clase detallado para empezar a picar.
- **#8.2** — idea de capa de "mecánicas" reutilizable, solo diseño, no implementado.
- **#9** — panel de admin (nueva funcionalidad), mejor después de #8.2 si se puede.
- **#10** — parser de descripción de hechizos de Aurora para Hit/DC/daño (pensado para otro agente).
- **#11** — Combat tab vs Spells al añadir hechizos: no reproducible la última vez, dejar abierto por si reaparece con un repro más preciso.
- **#12** — limpieza de `withOpacity` (deprecado, no urgente, no rompe nada hoy).
- **#13** — dominio/despliegue, no es código, para cuando se acerque release.
- **#15** — permitir cambiar username (nueva funcionalidad, no compleja).
- **#17** — multiclase (grande, dejar para el final a propósito).
- **#18, último ítem ✅ HECHO (2026-06-29):** Battle Master: deshabilitar maniobras ya elegidas en el selector del wizard.
- **Sugerencia de UX ✅ HECHA (2026-06-29):** en modo edición (no level-up), cada paso muestra "Save Changes" y guarda directamente, no solo el último.
- **Duda de Tiefling (#18) ✅ RESUELTA (2026-06-29):** ver detalle más abajo, en #18 — dos bugs encontrados y corregidos (uno de datos/lógica de bonificadores, otro mucho más grave de `subraceId` nunca enviado en creación).

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

**Gaps conocidos sin arreglar (necesitan trabajo de backend nuevo, no solo de envío):** `LORE_BONUS_PROF` (College of Lore Bard) y `MUTAGEN_CHOICE` (Blood Hunter Mutante) no tienen ninguna `PendingTask` creada en el backend.

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

### 3. Algunas features de clase/subclase no se aplican correctamente en la ficha
**Prioridad: Alta**

Casos detectados (no exhaustivo, ver puntos 8 y 8.1 para la auditoría completa):
- **Ranger → Drakewarden**: otorga *Thaumaturgy*. El hechizo aparece en la descripción de la subclase pero nunca se añade realmente a la ficha del personaje.
- **Artificer → Magic Item Adept**: debería aumentar el máximo de *attunement* de 3 a 4. Revisar `CharacterInventoryService.java` / `Item.java` (campo attunement) y el punto donde se calcula el máximo de attunement del personaje — probablemente no contempla este feature de subclase.
- **Blood Hunter → Mutagen Formula**: la cantidad de fórmulas conocidas depende del modificador de INT y debe gestionarse como un recurso escalable, no fijo.

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
- **Bardo** — *Bardic Inspiration*: ⚠️ usos solo en frontend (`bardic-inspiration-*`). *College of Lore* (Cutting Words) y *College of Valor* (Combat Inspiration) reutilizan ese mismo dado para efectos reactivos — no hay lógica de "gastar un dado de Inspiration para X efecto distinto a inspirar", es responsabilidad manual del jugador hoy. *Additional Magical Secrets* (Lore, nivel 6): otorga 2 hechizos de cualquier clase — ¿existe alguna `PendingTask` para esta elección o se pierde?
- **Clérigo** — **Channel Divinity es un gap entero, no solo de una subclase**: el recurso base (2 usos a partir de nivel 6, normalmente 1 antes) no aparece en la lista de `ClassResource` confirmados, y cada Dominio añade una opción propia de Channel Divinity (Preserve Life en Life, Knowledge of the Ages en Knowledge, Warding Flare en Light, Destructive Wrath en Tempest, Invoke Duplicity en Trickery, Guided Strike/War Domain). Si el recurso base no está, ninguna de las 7 variantes de dominio puede estarlo tampoco.
- **Druida** — *Wild Shape*: ⚠️ usos solo en frontend (`wild-shape-*`), sin enforcement de CR/restricciones de forma por nivel. *Circle of the Moon* (Combat Wild Shape: gasto de slot de hechizo para recuperar usos de Wild Shape en combate, curación al cambiar de forma, acceso a CR superior) — no hay evidencia de que estas reglas extra estén implementadas más allá del Wild Shape base. *Circle of the Land*: ya es data-driven (`subclass_spells` + switch de terreno) — único caso de subclase con grant de hechizos correctamente resuelto.
- **Guerrero** — *Action Surge*/*Second Wind*: ⚠️ solo frontend, sin `ClassResource`. *Fighting Style*: solo Defense+Archery con efecto real (punto 18). *Battle Master* (Superiority Dice): el recurso sí tiene constante dedicada (-6) en el frontend, y las maniobras ya se resolvieron a nivel de selección (punto #1), pero falta deshabilitar maniobras ya elegidas al elegir la siguiente (punto 18, último ítem) y verificar que cada maniobra aplique su efecto real, no solo consuma el dado. *Champion* (Improved/Superior Critical: ampliar rango de crítico; Remarkable Athlete: bonificador a pruebas de habilidad) — sin evidencia de implementación, son cambios de regla numérica que normalmente se calculan en frontend al tirar dados. *Eldritch Knight*: spellcasting de subclase + War Magic (nivel 7, atacar con bonus action tras lanzar conjuro de acción) — la parte de economía de acciones no está modelada. **Psi-Warrior** (Psionic Power): ❌ sin ningún tracker de usos, ni siquiera frontend-only — el hallazgo que originó este punto.
- **Mago** — School features (7 escuelas seedeadas): revisar caso por caso, pero al menos *Evocation* (Sculpt Spells: excluir aliados del área; Empowered Evocation: +mod. INT al daño una vez por turno; Overchannel: daño extra con coste de daño necrótico acumulativo y usos limitados por día) son bonificadores/recursos que no aparecen en ningún sitio confirmado del backend.
- **Mediano (Monje)** — *Ki points*: no hay evidencia de que exista como recurso (ni siquiera frontend-only, a diferencia de Rage/Bardic Inspiration) — esto bloquearía mecánicamente todas las features que gastan Ki: Flurry of Blows, Patient Defense, Step of the Wind, y las específicas de subclase como *Way of Shadow* (Darkness, Pass without Trace, Silence, Shadow Step) que son básicamente "hechizos" pagados con Ki, no con slots.
- **Paladín** — Comparte el gap de Channel Divinity del Clérigo (Sacred Weapon + Turn the Unholy en Devotion, y la segunda jura seedeada). *Auras* (Devotion, Protection... según nivel) son pasivas de rango que no implican recurso pero sí lógica de "aplica a aliados a X pies", a confirmar si existe.
- **Pícaro** — *Sneak Attack* ya señalado como mal clasificado (punto 7), pero además revisar que el cálculo de dados escale con nivel correctamente. *Thief* (Fast Hands, Second-Story Work) y *Arcane Trickster* (Mage Hand Legerdemain) son en su mayoría utilidad pasiva, impacto mecánico bajo pero a confirmar que Fast Hands realmente permita una acción de objeto adicional.
- **Brujo (Warlock)** — *Pact Magic* (slots de hechizo independientes, se recuperan en descanso corto, no largo) — confirmar que el sistema de slots no los mezcle con los de un multiclase de lanzador (relevante también para el punto #17). *Eldritch Invocations* ya resueltas a nivel de elección (punto #1) pero cada invocation puede tener efecto mecánico propio (p. ej. Agonizing Blast: +mod. CHA al daño de Eldritch Blast) — confirmar que estos efectos se aplican y no solo se registra la elección. *Fiend* (Dark One's Blessing: PG temporales al matar) — trigger basado en evento de combate, normalmente no implementado en apps de ficha.
- **Hechicero (Sorcerer)** — *Sorcery Points*: confirmar si existen como recurso (mismo patrón de duda que Ki). *Draconic Bloodline* (Draconic Resilience: +1 PG por nivel + CA base alternativa; Elemental Affinity: +mod. CHA al daño de hechizos de un tipo elegido) — bonificadores numéricos que necesitan lógica dedicada, no solo texto.
- **Artificiero** (2 variantes, TCE/ERLW) — *Infusions*: sistema completo de "número de infusiones conocidas según nivel" + "vincular un efecto mágico a un objeto" — no hay evidencia de que exista nada parecido a un sistema de infusiones; probablemente el gap más grande de todo este inventario porque es una mecánica entera, no una feature suelta. *Magic Item Adept* (+1 a attunement máximo) ya señalado en el punto #3.
- **Blood Hunter** (homebrew, Critical Role) — *Blood Maledict*: ✅ es el único recurso de clase con `ClassResource` real en BD. *Crimson Rite* (convierte daño del arma + daño extra, coste de PG por uso) — mezcla de bonificador y recurso, confirmar si el coste de PG y el daño extra se aplican. *Order of the Lycan* (Hybrid Transformation, usos limitados) y *Order of the Mutant* (Mutagen Formula, ya señalado en el punto #3 como gap conocido de backend) — sin implementar. *Order of the Gunslinger*: ✅ `grit` sí tiene `ClassResource` real.

**Nota sobre alcance:** esta lista cubre las subclases confirmadas en `seed_subclasses.sql` (28, todas PHB) más los casos ya detectados fuera de ese fichero (Psi-Warrior vía Aurora). Las subclases que llegan dinámicamente desde Aurora (`AuroraSyncService.java`) no están en el repo como datos estáticos, así que cualquier subclase de esa fuente (probablemente la mayoría del contenido "expandido" tipo Tasha's) necesita pasar por esta misma auditoría una vez se pueda inspeccionar en una base de datos real — no se puede confirmar desde el código solo.

### 8.2 Construir capa de mecánicas como infraestructura reutilizable
**Idea para cuando se aborde esto (a futuro, no parte de este punto):** en vez de seguir resolviendo cada gap a mano feature por feature, tendría sentido construir una capa de "mecánicas" como infraestructura reutilizable: un esquema/API interna donde cada feature se describe de forma declarativa según el tipo de efecto que produce — por ejemplo `RESOURCE_POOL` (fórmula de usos + tipo de descanso para reponerlos), `NUMERIC_BONUS` (campo al que suma, condición de aplicación), `GRANT_SPELL` / `GRANT_PROFICIENCY` (nivel al que se desbloquea) — y que tanto backend como frontend lean esa descripción para activar el comportamiento automáticamente, sin necesitar una rama de código nueva por feature. Esto conectaría directamente con la creación manual de contenido para administradores (punto #9): al definir una clase, subclase o feat nueva desde el panel, el admin podría marcar qué "tipo de mecánica" tiene cada feature y la app la aplicaría sola. Y de cara a mantenerse sincronizado con fuentes externas, si una fuente expone sus datos con suficiente estructura (como ya hace la API pública de D&D 5e con `damage_at_slot_level`, `dc_type`, etc.), esta misma capa permitiría mapear esos campos directamente a una mecánica conocida sin escribir un caso especial por fuente. Para Aurora esto no sustituye al parseador de descripción que hace falta de todos modos (punto #10) — su contenido es texto libre, así que primero habría que extraer la estructura y después sí podría alimentar esta capa de mecánicas como cualquier otra fuente.

**Dónde mirar probablemente:** `entities/ClassResource.java`, `entities/CharacterClassResource.java`, `frontend/lib/viewmodels/characters/character_sheet_viewmodel.dart` (`_kConsumableFeatures`), `services/PlayerCharacterService.java` (bonificadores y grants ad-hoc), `services/RacialTraitService.java`, `services/SubclassSpellService.java`, `scripts/seed_subclasses.sql` / `seed_subclass_spells.sql`, `sync/AuroraSyncService.java`.

---

## 👨‍💼 Panel de administración

### 9. Creación manual de contenido por administradores
**Prioridad: Media** — Nueva funcionalidad

Permitir que los administradores creen contenido personalizado directamente desde la app (panel `admin_panel_screen.dart` / endpoints backend dedicados), sin depender de la sync con la API pública de D&D 5e ni de scripts SQL manuales en `scripts/`:
- Razas, subrazas.
- Clases, subclases.
- Backgrounds.
- Feats.
- Hechizos.
- Equipamiento.
- Otros elementos de reglas.

**Objetivo:** reducir la dependencia de importaciones externas o de scripts SQL manuales para contenido no cubierto por la API pública (como ya ocurre hoy con feats, subclases y subrazas, según se documenta en el README del backend).

---

### 10. Hechizos de Aurora sin datos de combate (Hit/DC, daño, escalado) — necesita parseador de descripción
**Prioridad: Media-Alta** — Para asignar a otro agente

Confirmado (2026-06-18): los hechizos sincronizados desde Aurora (no-PHB) llegan a la base de datos sin `attackType`, `dcType`, `damageType`, `damageBase` ni la tabla de escalado por nivel (`damageAtSlotLevel`, ver punto #4 ya resuelto para PHB). Está documentado como limitación conocida en `AuroraSpellMapper.java` ("Combat fields are left null — they require per-spell analysis").

**Causa de fondo:** la API pública de D&D 5e da estos datos en JSON estructurado y uniforme (`damage.damage_at_slot_level`, `dc.dc_type`, `attack_type`...). Aurora, en cambio, solo trae la descripción del hechizo como texto libre, sin esa estructura — cada sourcebook describe el daño/tirada de forma distinta.

**Lo que hace falta:** un parseador que extraiga de la descripción de cada hechizo de Aurora:
- Si es de ataque (ranged/melee) o de tirada de salvación (y de qué habilidad).
- Tipo y dados de daño base.
- Cómo escala el daño con el nivel de lanzamiento (cuando aplica — algunos hechizos escalan con más dados, otros con más "proyectiles/efectos" como Magic Missile/Scorching Ray, que ni siquiera la API pública resuelve bien, ver hallazgo de hoy).

**Por qué es más que un fix puntual:** el usuario quiere en el futuro un panel de admin para crear contenido nuevo (clases, razas, hechizos...) directamente desde la app (ver #9). Este parseador no debería ser un script suelto solo para Aurora, sino parte de una infraestructura común de extracción/normalización de datos de reglas, reutilizable tanto para el sync de Aurora como para lo que un admin meta a mano. Vale la pena diseñarlo pensando en ambos casos a la vez, no solo en tapar el agujero de Aurora.

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
  
