# Aurora Fixes — Backlog de incidencias y mejoras (DungeonScroll)

Lista de bugs y mejoras pendientes, organizados por área. Cada entrada incluye contexto del proyecto (módulos/archivos probablemente implicados) para facilitar el triage y la implementación. Las prioridades son las indicadas por el usuario.

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
- Reactivada `PendingTasksScreen` (estaba deshabilitada, ver #15) — los feats elegidos por ASI/Feat ya aparecen en `tab_features`.

**Gaps conocidos sin arreglar (necesitan trabajo de backend nuevo, no solo de envío):** `LORE_BONUS_PROF` (College of Lore Bard) y `MUTAGEN_CHOICE` (Blood Hunter Mutante) no tienen ninguna `PendingTask` creada en el backend.

**Limitación conocida de HP por nivel:** personajes creados/subidos de nivel *antes* de este fix no tienen tiradas guardadas (la columna no existía), así que "Manage HP" seguirá vacío para esos niveles ya existentes; solo los niveles nuevos a partir de ahora se guardan.

---

### 2. Cambiar las Sources (paso de Preferencias) rompe la configuración del personaje
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

---

### 3. Algunas features de clase/subclase no se aplican correctamente en la ficha
**Prioridad: Alta**

Casos detectados (no exhaustivo, ver punto 8 para auditoría completa):
- **Ranger → Drakewarden**: otorga *Thaumaturgy*. El hechizo aparece en la descripción de la subclase pero nunca se añade realmente a la ficha del personaje.
- **Artificer → Magic Item Adept**: debería aumentar el máximo de *attunement* de 3 a 4. Revisar `CharacterInventoryService.java` / `Item.java` (campo attunement) y el punto donde se calcula el máximo de attunement del personaje — probablemente no contempla este feature de subclase.
- **Blood Hunter → Mutagen Formula**: la cantidad de fórmulas conocidas depende del modificador de INT y debe gestionarse como un recurso escalable, no fijo.

**Comportamiento esperado:**
- Todos los beneficios automáticos otorgados por clases y subclases (hechizos gratuitos, bonificadores, cambios de límites como el de attunement, recursos escalables por modificador) deben aplicarse y reflejarse correctamente en la ficha, no solo aparecer como texto descriptivo.

**Dónde mirar probablemente:** lógica de aplicación de features de clase/subclase en el backend (servicios de creación/nivel) — posiblemente en `PlayerCharacterService` o un servicio dedicado a aplicar `ClassFeature`/`SubclassFeature` al personaje.

---

### 4. Escalado incorrecto de hechizos al subir el nivel de lanzamiento
**Prioridad: Media**

Revisar si, al seleccionar un nivel de lanzamiento superior para un hechizo, los dados de daño se actualizan conforme a la escala definida por el hechizo.

**Comportamiento esperado:** el daño mostrado en la ficha debe reflejar el nivel de lanzamiento seleccionado, no quedarse fijo en el nivel base.

**Dónde mirar probablemente:** `tab_spells.dart` (frontend) y la lógica de cálculo de daño de hechizos en el ViewModel del character sheet.

---

## 🎨 UX / Interfaz

### 5. Comportamiento de los desplegables en el paso de Razas
**Prioridad: Media**

Problemas en `step_race.dart`:
- Un desplegable abierto no se cierra al volver a pulsarlo (falta el toggle).
- Al abrir una raza, el scroll salta automáticamente al final de la lista de subrazas en vez de mantenerse sobre el elemento seleccionado.
- El icono del Artificiero no se muestra correctamente (en ninguno de los dos casos en que debería aparecer — revisar asset/mapeo de iconos por clase).

**Comportamiento esperado:**
- Un segundo clic sobre el desplegable abierto debe contraerlo.
- El foco visual debe mantenerse sobre la raza seleccionada, sin auto-scroll al final.
- El icono de Artificiero debe renderizarse correctamente.

---

### 6. Ordenación de Backgrounds
**Prioridad: Baja**

En `step_background.dart`, los backgrounds se muestran ordenados según el orden de las sources cargadas en vez de alfabéticamente.

**Comportamiento esperado:** mostrar siempre los backgrounds en orden alfabético, independientemente de su source de origen.

---

## ⚙️ Reglas de D&D / mecánicas

### 7. Sneak Attack se clasifica como Action
**Prioridad: Media**

Sneak Attack aparece en la ficha como una acción independiente (pestaña Combat / Features), cuando es una característica pasiva/condicional que se aplica como parte de un ataque, no una acción en sí misma.

**Comportamiento esperado:** debe mostrarse como característica pasiva/condicional y excluirse de la categoría "Action" en `config/combat_features.dart` y donde se clasifique el tipo de feature.

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

## 👨‍💼 Panel de administración

### 9. Creación manual de contenido por administradores
**Prioridad: Media** — Nueva funcionalidad

Permitir que los administradores creen contenido personalizado directamente desde la app (panel `admin_panel_screen.dart` / endpoints backend dedicados), sin depender de la sync con la API pública de D&D 5e ni de scripts SQL manuales en `backups/`:
- Razas, subrazas.
- Clases, subclases.
- Backgrounds.
- Feats.
- Hechizos.
- Equipamiento.
- Otros elementos de reglas.

**Objetivo:** reducir la dependencia de importaciones externas o de scripts SQL manuales para contenido no cubierto por la API pública (como ya ocurre hoy con feats, subclases y subrazas, según se documenta en el README del backend).

---

### 16. Hechizos de Aurora sin datos de combate (Hit/DC, daño, escalado) — necesita parseador de descripción
**Prioridad: Media-Alta** — Para asignar a otro agente

Confirmado (2026-06-18): los hechizos sincronizados desde Aurora (no-PHB) llegan a la base de datos sin `attackType`, `dcType`, `damageType`, `damageBase` ni la tabla de escalado por nivel (`damageAtSlotLevel`, ver punto #4 ya resuelto para PHB). Está documentado como limitación conocida en `AuroraSpellMapper.java` ("Combat fields are left null — they require per-spell analysis").

**Causa de fondo:** la API pública de D&D 5e da estos datos en JSON estructurado y uniforme (`damage.damage_at_slot_level`, `dc.dc_type`, `attack_type`...). Aurora, en cambio, solo trae la descripción del hechizo como texto libre, sin esa estructura — cada sourcebook describe el daño/tirada de forma distinta.

**Lo que hace falta:** un parseador que extraiga de la descripción de cada hechizo de Aurora:
- Si es de ataque (ranged/melee) o de tirada de salvación (y de qué habilidad).
- Tipo y dados de daño base.
- Cómo escala el daño con el nivel de lanzamiento (cuando aplica — algunos hechizos escalan con más dados, otros con más "proyectiles/efectos" como Magic Missile/Scorching Ray, que ni siquiera la API pública resuelve bien, ver hallazgo de hoy).

**Por qué es más que un fix puntual:** el usuario quiere en el futuro un panel de admin para crear contenido nuevo (clases, razas, hechizos...) directamente desde la app (ver #9). Este parseador no debería ser un script suelto solo para Aurora, sino parte de una infraestructura común de extracción/normalización de datos de reglas, reutilizable tanto para el sync de Aurora como para lo que un admin meta a mano. Vale la pena diseñarlo pensando en ambos casos a la vez, no solo en tapar el agujero de Aurora.

---

### 17. Pestaña Combat no se actualiza igual que Spells al añadir hechizos nuevos
**Prioridad: Media**

Confirmado (2026-06-18): al añadir hechizos nuevos a un personaje, la pestaña **Spells** los muestra correctamente, pero la pestaña **Combat** no — por ejemplo, Scorching Ray y Magic Missile no aparecen ahí tras añadirlos. Pendiente de investigar la causa (¿filtro distinto de qué hechizos se listan en Combat? ¿caché/estado no se refresca igual que en Spells?).

---

## 🧹 Deuda técnica

### 10. Revisar y reemplazar usos de `withOpacity`
**Prioridad: Baja**

`withOpacity` está deprecado en Flutter (genera warnings) y debe sustituirse por `.withValues(alpha: ...)` o el mecanismo recomendado actual.

**Alcance real detectado:** ~165 usos repartidos en **19 archivos** dentro de `frontend/lib/views/`, entre otros: `tab_spells.dart`, `tab_inventory.dart`, `tab_abilities.dart`, `tab_combat.dart`, `tab_features.dart`, `login_screen.dart`, `character_sheet_screen.dart`, `character_creator_screen.dart`, `admin_panel_screen.dart`, `pending_tasks_screen.dart`, `add_item_screen.dart`, `character_card.dart`, `class_detail_screen.dart`, `class_options_screen.dart`, y los steps `step_preferences.dart`, `step_equipment.dart`, `step_background.dart`, `step_class.dart`, `step_race.dart`, `step_spells.dart`.

**Objetivo:** eliminar los warnings y alinear con las recomendaciones actuales del framework.

---

## 🚀 Infraestructura y despliegue

### 11. Dominio y publicación de la aplicación
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

### 12. Texto duplicado "2nd class feature" en las especializaciones de Artificiero
**Prioridad: Baja**

Las dos especializaciones del Artificiero muestran la frase "2nd class feature" u otras dependiendo del nivel de forma redundante en su descripción. Revisar el origen del texto (datos sync/manual del Artificiero) y el formateo de descripciones generadas para subclases.

---

## 👤 Gestión de cuenta

### 13. Permitir cambiar el nombre de usuario
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

### 14. Revisar qué items requieren attunement y aplicarlo funcionalmente en la app
**Prioridad: Media**
- Tras el Aurora Sync, se introdujeron una cantidad nueva y grande de items, algunos de ellos requieren attunement, con lo que funcionalmente en la app deberían serlo también (de manera que en inventory sólo puedan ser equipados como attuned)
- Revisar si hay items de armas de fuego introducidas de las canon en D&D, ya que es necesario.

### 15. Fixes que me voy encontrando o dudas.
- Fighting Style suma donde tiene que sumar? Porque si escoges archery, se suma el bonificador de ataque a sólo armas a distancia?
- Creo que las subrazas de tiefling están sumando mal los bonificadores. Tiefling aparece como +2 CHA +1 INT, pero luego cada subraza parece añadir muchos bonificadores más. Y según los manuales, Tiefling como tal te da un bonificador y la subclase un bonificador secundario. Temo que tal como está ahora sume demasiadas cosas.
- **Fighting Style: confirmado, bug real y de todas las clases (no solo Aurora).** En `PlayerCharacterService.java` solo hay lógica numérica para 2 de los 5 estilos: Defense (+1 AC si llevas armadura) y Archery (+2 a ataques a distancia). Dueling, Great Weapon Fighting, Protection y Two-Weapon Fighting no tienen ningún efecto mecánico implementado, nunca lo tuvieron. Además, incluso Defense/Archery dependen de que exista una `PendingTask` tipo `FIGHTING_STYLE` completada con la elección — si esa tarea no se resuelve correctamente, el bono nunca se aplica aunque el jugador haya "elegido" el estilo en el wizard.
- **`PendingTasksScreen` reactivada (2026-06-19).** Estaba deshabilitada (`character_sheet_screen.dart`, navegación comentada). Reactivada la carga (`_loadPendingTasks()` en `CharacterSheetViewModel.loadCharacter()`) y el botón de acceso. De paso se corrigió un bug igual al de ASI/Feat del wizard (#1): el resolver de ASI dentro de esta pantalla también enviaba el nombre completo de la habilidad ("Strength") en vez de la abreviatura ("STR") que espera el backend. Las elecciones de **seguimiento** generadas después de la creación (p. ej. las 3 skills de "Skilled", que solo se crean al resolver el ASI_OR_FEAT) ya deberían poder resolverse desde aquí — sin verificar todavía caso por caso.
- Creo que el botón de "Crear Personaje" en el step de inventory no debería poder ser pulsado hasta que haya cargado bien el inventory, porque me he dado cuenta que da error 500 si pulsas el botón de Crear Personaje antes de que cargue inventory.
- Las battle maneuver del battle master, cuando tienes que escoger varias, cuando escoges una, en las siguiente "battle maneuver" deberían deshabilitarse las ya escogidas.