# Aurora Fixes — Backlog de incidencias y mejoras (DungeonScroll)

Lista de bugs y mejoras pendientes, organizados por área. Cada entrada incluye contexto del proyecto (módulos/archivos probablemente implicados) para facilitar el triage y la implementación. Las prioridades son las indicadas por el usuario.

---

## 🐛 Creación y edición de personajes

### 1. La edición de un personaje reinicia datos ya configurados
**Prioridad: Alta**

Al entrar en modo edición del wizard (`frontend/lib/views/screens/wizard/`), algunos datos se pierden o se recalculan desde cero (skills, expertise, puntos de vida y otros valores derivados), en vez de partir del estado real del personaje.

**Comportamiento esperado:**
- Al editar, todas las selecciones previas deben conservarse.
- La pantalla de edición debe inicializarse con el estado completo y actual del personaje (no con valores por defecto del wizard de creación).
- Solo deben cambiar los campos que el usuario modifique explícitamente.

**Dónde mirar probablemente:** `CharacterCreatorViewModel` (carga inicial en modo edición) y cómo se hidrata desde `PlayerCharacter` / DTOs al entrar al wizard en modo "editar" en vez de "crear".

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