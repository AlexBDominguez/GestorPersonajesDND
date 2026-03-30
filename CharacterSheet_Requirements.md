# Character Sheet — Requisitos de Diseño

## Visión General

Ficha de personaje interactiva, navegable por swipe entre tabs, con un header fijo en la parte superior.

---

## Header (Fijo en toda la ficha)

| Zona | Contenido |
|------|-----------|
| Izquierda | **Armor Class** (valor numérico) + **Initiative** (valor con signo, ej: +2) |
| Centro | Imagen del personaje *(pendiente de implementar)* + Nombre + Subtítulo: `Raza Clase Nivel` (ej: *Dwarf Barbarian 3*) |
| Derecha | **Hit Points** (ej: 28/34) — **pulsable** para abrir "Manage HP" |

> **TODO:** Implementar modal/screen de "Manage HP" al pulsar los Hit Points (recibir daño, curar, añadir HP temporales).

---

## Navegación por Tabs (Swipe)

La ficha se divide en tabs navegables mediante swipe horizontal (izquierda/derecha):

1. Abilities, Saves & Senses
2. Skills
3. Combat
4. Inventory
5. Spells
6. *(Pendiente de definir: Speed & Defenses, Features & Traits, Proficiencies, Background)*

---

## Tab 1 — Abilities, Saves & Senses

### 1.1 Ability Scores
Grid de 6 celdas: **2 filas × 3 columnas**, imitando la ficha física de D&D 5e.

```
[ STR ] [ DEX ] [ CON ]
[ INT ] [ WIS ] [ CHA ]
```

Cada celda muestra:
- Nombre de la ability (STR, DEX, etc.)
- Valor en un **rectángulo** (ej: `16`)
- Modificador en una **elipse** debajo (ej: `+3`)

### 1.2 Saving Throws
Grid de 6 entradas: **3 filas × 2 columnas**, imitando la ficha física.

Cada entrada muestra:
- ● / ○ a la izquierda (relleno = proficient, vacío = no proficient)
- Nombre de la ability (ej: Strength)
- Bonificador a la derecha (calculado desde backend: mod + proficiency si aplica)

### 1.3 Senses
Lista de 3 filas horizontales:

| Valor | Descripción |
|-------|-------------|
| `13` | Passive Perception |
| `11` | Passive Investigation |
| `12` | Passive Insight |

- Si el personaje tiene **Darkvision** u otros sentidos especiales, se muestra una línea adicional debajo (ej: *"Darkvision 60 ft"*).

---

## Tab 2 — Skills

Tabla con separadores horizontales (sin bordes verticales visibles), imitando la ficha física de D&D 5e.

| PROF | MOD | SKILL | BONUS |
|------|-----|-------|-------|
| ●/○ | DEX | Acrobatics | +5 |
| ●/○ | WIS | Animal Handling | +2 |
| ●/○ | INT | Arcana | +1 |
| ... | ... | ... | ... |

**Skills completas (en orden alfabético):**
Acrobatics, Animal Handling, Arcana, Athletics, Deception, History, Insight, Intimidation, Investigation, Medicine, Nature, Perception, Performance, Persuasion, Religion, Sleight of Hand, Stealth, Survival.

**Columnas:**
- **PROF** — Círculo lleno (●) si es proficient, vacío (○) si no.
- **MOD** — Ability asociada a la skill (ej: DEX, WIS, STR...).
- **SKILL** — Nombre de la skill.
- **BONUS** — Bonificador total (calculado desde backend).

**Advantage / Disadvantage:**
- Si una skill tiene **Advantage**, mostrar badge `A` junto al nombre.
- Si tiene **Disadvantage**, mostrar badge `D`.
- Ejemplo: Stealth con desventaja por armadura pesada → badge `D` en la fila de Stealth.

> **TODO:** Confirmar con backend si se devuelven flags de advantage/disadvantage por skill.

---

## Tab 3 — Combat

### 3.1 Actions
Tabla de acciones de ataque/hechizo:

| RANGE | HIT / DC | DAMAGE |
|-------|----------|--------|
| Greatsword +1 — 5 ft | +7 | 2d6+4 slashing |
| Firebolt — 120 ft | +5 | 1d10 fire |
| Healing Hands — touch | — | 2d4 |
| Unarmed Strike — 5 ft | +5 | 1d4+3 bludgeoning |

- **Range**: nombre del arma/hechizo + alcance.
- **Hit/DC**: bonificador de ataque (ej: `+7`) o dificultad de salvación (ej: `DC 14`).
- **Damage**: dados + tipo. Si es curativo, sólo dados (sin tipo de daño).
- **Pulsable**: al pulsar el nombre (ej: *"Greatsword +1"* o *"Shield"*), se abre una pantalla de detalle con toda la información del arma o hechizo.

### 3.2 Actions in Combat
Lista de acciones estándar disponibles:

> Attack, Dash, Disengage, Dodge, Grapple, Help, Hide, Improvise, Influence, Magic, Ready, Search, Shove, Study, Utilize

Más cualquier acción especial de clase/feat (ej: *Cleave (Greataxe)*, *Graze (Greatsword)*, *Slow (Javelin)*).

### 3.3 Bonus Actions
Misma estructura que Actions, pero mostrando sólo lo que puede hacerse como Bonus Action (ej: *Second Wind*, spells de bonus action, feats).

### 3.4 Reactions
Lista de reacciones disponibles (ej: *Opportunity Attack*, *Spell: Shield*).
- También pulsables para ver el detalle.

---

## Tab 4 — Inventory

### 4.1 Equipment (Equipado)
Tabla con los objetos actualmente en posesión del personaje.

- Checkbox/cuadrado a la izquierda de cada ítem, **pulsable** para marcar si está **equipado**.
- Equipar/desequipar **afecta a la ficha**:
  - Equipar armadura → recalcula Armor Class.
  - Equipar arma → aparece en la sección *Actions* de Combat.

### 4.2 Backpack
Lista de objetos que el personaje carga pero no tiene equipados (consumibles, materiales, misc).

### 4.3 Attuned Items
3 filas (estilo visual similar a Senses), que se rellenan cuando el personaje hace *attunement* con un ítem que lo requiera. Máximo 3 ítems en attunement.

### 4.4 Dinero
Visible en algún lugar de esta tab. Campos: CP, SP, EP, GP, PP.

---

## Tab 5 — Spells

### 5.1 Sub-tabs de Nivel
Fila de botones en la parte superior (no swipe, sino botones/chips):

> **All** | **0** | **1** | **2** | **3** | ...

- Sólo se muestran los niveles que el personaje **puede usar** (no mostrar un botón de nivel 5 si el personaje sólo llega a nivel 3 de hechizos).
- **All** muestra todos ordenados de Cantrips → mayor nivel.

### 5.2 Modificadores de hechizos
Justo debajo de los botones, una fila con:

| Modifier | Spell Attack | Save DC |
|----------|-------------|---------|
| +4 (WIS) | +6 | 14 |

### 5.3 Botón "Manage Spells"
- Lleva a otra Screen donde el jugador gestiona los hechizos aprendidos/preparados.
> **TODO:** Diseñar e implementar la screen de "Manage Spells" (lógica propia y compleja).

### 5.4 Tabla de Hechizos
Tabla filtrada según la sub-tab activa.

**Header de cada nivel** (ej: `Level 2`):
- A la derecha del header, lista de **Spell Slots** del nivel (rellenos/vacíos según los usados).
  - Ej: `● ● ○` → 2 slots usados de 3.

**Columnas de la tabla:**

| CAST | TIME | RANGE | HIT/DC | EFFECT |
|------|------|-------|--------|--------|
| — *(at will)* | 1A | 120 ft | +5 | 1d10 fire |
| [CAST] | 1A | Touch | DC 14 | 1d8+4 radiant |
| [CAST] | 1BA | Self | — | +1d8 healing |

- **CAST**: `at will` si es cantrip. Si es nivel ≥1, botón **CAST** pulsable → abre modal de confirmación → al confirmar, consume un spell slot (se rellena uno de los círculos del header).
- **TIME**: duración/tipo de acción resumida (1A, 1BA, 1R).
- **RANGE**: alcance del hechizo (Touch, Self, 60 ft, etc.).
- **HIT/DC**: bonificador de ataque mágico o DC de salvación.
- **EFFECT**: descripción resumida del efecto (tipo de daño, curación, efecto).

---

## Tab 6 — Pendiente de Definir

Las siguientes secciones están previstas pero sin diseño definido aún:

- **Speed & Defenses** — Velocidades (walk, swim, fly, climb) y resistencias/inmunidades.
- **Features & Traits** — Rasgos de raza, clase y trasfondo.
- **Proficiencies & Training** — Armaduras, armas, herramientas, idiomas.
- **Background** — Trasfondo, personalidad, ideales, vínculos, defectos.

---

## Resumen de TODOs

| # | Funcionalidad | Complejidad estimada |
|---|---------------|---------------------|
| 1 | Modal "Manage HP" (daño, curación, HP temporales) | Media |
| 2 | Pantalla de detalle al pulsar arma/hechizo | Baja-Media |
| 3 | Recalcular AC/Actions al equipar/desequipar ítem | Media-Alta |
| 4 | Screen "Manage Spells" (aprender/preparar hechizos) | Alta |
| 5 | Confirmar con backend flags de advantage/disadvantage por skill | Baja |
| 6 | Diseñar Tab 6 (Speed, Features, Proficiencies, Background) | Por definir |
