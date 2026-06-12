# MECHANICS_REQUIREMENTS.md
# Requisitos de Implementación Mecánica — DungeonScroll

> Documento de trabajo que define qué mecánicas de D&D 5e deben ser funcionales en la app, en qué orden atacarlas y exactamente qué hay que tocar en el código.

---

## Estado de Partida (resumen del audit)

El sistema actual funciona para el contenido base del PHB con dos enfoques:
- **Automático (hardcodeado):** HP, proficiency bonus, spell slots, bonos de raza/subraza, proficiencias de clase y trasfondo, recursos de clase PHB, hechizos raciales.
- **Elección del usuario (PendingTask):** ASI/Feat, subclase, Fighting Style, Expertise, Invocaciones, Metamagic, Favored Enemy/Terrain, Draconic Ancestry, idiomas extra, cantrip de High Elf, Skill Versatility (Half-Elf), Tool Proficiency (Dwarf).

**Lo que NO está implementado y debe estarlo:**
1. Efectos de objetos mágicos sintonizados no se aplican a la ficha.
2. Los hechizos de subclase (Domain spells, Oath spells, Circle spells) no se añaden automáticamente.
3. Las proficiencias extra que dan ciertas subclases no se aplican.
4. Artificiero, Blood Hunter y Gunslinger no tienen recursos de clase.
5. Varias subclases requieren elecciones (Battle Master, Totem Warrior, Hunter Ranger, Monje 4 Elementos) que no tienen PendingTask.
6. Las dotes seleccionadas no aplican sus efectos mecánicos.
7. Defensa Sin Armadura (Bárbaro, Monje) no está calculada.
8. Los efectos mecánicos de features de subclase (bonificaciones, resistencias, ventajas) son solo texto.

---

## Índice de Fases

| Fase | Título | Impacto |
|------|--------|---------|
| 1 | Correcciones críticas — ficha incorrecta | Bloquea correctitud |
| 2 | Clases nuevas funcionales | Artificiero, Blood Hunter, Gunslinger inusables |
| 3 | PendingTasks incompletas de PHB | Subclases PHB con elecciones sin implementar |
| 4 | Hechizos de subclase automáticos | Domain/Oath/Circle spells faltantes |
| 5 | Proficiencias de subclase | Armaduras/armas extra por subclase |
| 6 | Efectos de dotes (Feats) | 42 dotes sin efecto mecánico |
| 7 | Features de subclase con efecto en stats | Bonificaciones, resistencias, ventajas pasivas |
| 8 | Traits raciales nuevos | Razas nuevas con choices sin PendingTask |

---

## FASE 1 — Correcciones Críticas

### 1.1 Efectos de objetos mágicos sintonizados

**Problema:** Los campos mecánicos de `Item` existen en BD (`bonus_ac`, `bonus_saving_throws`, `set_str_to`, `set_int_to`, etc.) y están migrados (`migrate_magic_item_effects.sql`), pero el backend nunca los lee al calcular el DTO del personaje.

**Objetos afectados actualmente:**
| Objeto | Efecto |
|--------|--------|
| Ring of Protection | +1 AC, +1 a todas las saving throws |
| Gauntlets of Ogre Power | STR = 19 (si la STR del personaje es menor) |
| Headband of Intellect | INT = 19 (si la INT del personaje es menor) |

**Qué hacer:**

*Backend — `PlayerCharacterService.java` en el método que construye el `CharacterDTO`:*
1. Recuperar todos los `CharacterInventory` del personaje donde `attuned = true`.
2. Para cada item sintonizado con `requiresAttunement = true`, acumular:
   - `bonusAc` → sumar al AC calculado.
   - `bonusSavingThrows` → sumar a todos los saving throw modifiers.
   - `bonusToHit` → sumar a las tiradas de ataque.
   - `setStrTo`, `setDexTo`, etc. → si el valor actual del personaje es inferior, reemplazarlo para los cálculos (no modificar la BD, solo el DTO).
3. El AC base con item debe calcularse DESPUÉS de todos los bonos de armadura pero ANTES de mostrar el DTO.

*Frontend — `character_sheet_viewmodel.dart`:*
- No debería requerir cambios; los bonos vienen ya calculados en el DTO.
- Mostrar en la tab de Inventario si el item está sintonizado (`attuned`) con un indicador visual.

**Reglas D&D a respetar:**
- Máximo 3 objetos sintonizados simultáneamente (ya implementado en `CharacterInventoryService`).
- `setStrTo = 19` significa que la STR es 19 mientras el item está sintonizado, pero si la STR natural del personaje ya es ≥ 19, no hace nada.
- Los bonos de AC de objetos distintos se suman (Ring of Protection + Shield = +1 AC + +2 AC).

---

### 1.2 Defensa Sin Armadura (Unarmored Defense)

**Problema:** Bárbaro y Monje tienen AC calculada incorrectamente si no llevan armadura.

**Reglas:**
- **Bárbaro:** AC = 10 + MOD_DEX + MOD_CON (sin armadura, sin escudo restado)
- **Monje:** AC = 10 + MOD_DEX + MOD_WIS (sin armadura, sin escudo restado)
- Solo aplica cuando NO se lleva armadura equipada.

**Qué hacer:**

*Backend — método de cálculo de AC en `PlayerCharacterService` o en el DTO builder:*
```
if (personaje no lleva armadura) {
    if (clase == BARBARIAN) AC = 10 + dexMod + conMod + (escudo ? 2 : 0)
    if (clase == MONK)      AC = 10 + dexMod + wisMod   // Monje no usa escudo
}
```
El campo `DndClass.indexName` identifica la clase (`"barbarian"`, `"monk"`).

*Nota:* El Monje con Unarmored Defense tampoco puede usar escudo. Si lleva escudo equipado en la ficha, el cálculo vuelve al base `10 + DEX`.

---

### 1.3 Escala de la Barbarian Rage

**Problema:** El número de usos de Furia del Bárbaro escala con nivel, no con proficiency bonus. La tabla correcta es:

| Niveles | Usos | Daño bonus |
|---------|------|-----------|
| 1–2 | 2 | +2 |
| 3–5 | 3 | +2 |
| 6–11 | 4 | +2 |
| 12–16 | 5 | +3 |
| 17–19 | 6 | +4 |
| 20 | Ilimitado | +4 |

**Qué hacer:**

*Backend — `CharacterClassResourceService.java`:*
- El recurso `rage` actualmente usa `-4` como fórmula especial (tabla de proficiency).
- Añadir una tabla de consulta por nivel para Bárbaro que devuelva los usos correctos.
- El campo de "daño de Furia" también debería existir como resource separado o como metadato visible en la ficha (actualmente no está).

---

## FASE 2 — Clases Nuevas Funcionales

### 2.1 Artificiero (Artificer)

**Fuentes:** ERLW (original) y TCE (revisado). La clase ya tiene features en BD vía Aurora. Falta toda la infraestructura mecánica.

#### 2.1.1 Spell Slots — Half-Caster

El Artificiero es half-caster **redondeando hacia arriba** (diferente a Paladín/Ranger que redondean hacia abajo).

| Nivel Artificiero | 1st | 2nd | 3rd | 4th | 5th |
|------------------|-----|-----|-----|-----|-----|
| 1 | 2 | — | — | — | — |
| 2 | 2 | — | — | — | — |
| 3 | 3 | — | — | — | — |
| 4 | 3 | — | — | — | — |
| 5 | 4 | 2 | — | — | — |
| 6 | 4 | 2 | — | — | — |
| 7 | 4 | 3 | — | — | — |
| 8 | 4 | 3 | — | — | — |
| 9 | 4 | 3 | 2 | — | — |
| 10 | 4 | 3 | 2 | — | — |
| 11 | 4 | 3 | 3 | — | — |
| 12 | 4 | 3 | 3 | — | — |
| 13 | 4 | 3 | 3 | 1 | — |
| 14 | 4 | 3 | 3 | 1 | — |
| 15 | 4 | 3 | 3 | 2 | — |
| 16 | 4 | 3 | 3 | 2 | — |
| 17 | 4 | 3 | 3 | 3 | 1 |
| 18 | 4 | 3 | 3 | 3 | 1 |
| 19 | 4 | 3 | 3 | 3 | 2 |
| 20 | 4 | 3 | 3 | 3 | 2 |

*Implementar como filas en `spell_slot_progression` con `class_index = 'artificer'`.*

**Ability de spellcasting:** INT. Los campos de `DndClass.spellcastingAbility` ya deben decir `"intelligence"`.

#### 2.1.2 Infusiones (Infuse Item)

**Mecánica:** El Artificiero aprende un número de infusiones y puede preparar la mitad de ellas (activas simultáneamente). Los ítems infusionados cuentan como objetos mágicos sintonizados pero no gastan slots de attunement normales.

| Nivel | Infusiones conocidas | Infusiones activas (ítems infusionados) |
|-------|---------------------|----------------------------------------|
| 2 | 4 | 2 |
| 6 | 6 | 3 |
| 10 | 8 | 4 |
| 14 | 10 | 5 |
| 18 | 12 | 6 |

**Qué hacer:**

*Backend:*
- Nuevo tipo de recurso en `ClassResource`: `artificer_infusions` con `maxFormula` basado en tabla de nivel.
- Nuevo `FeatureType.INFUSION_CHOICE` para crear PendingTask cuando el Artificiero sube al nivel 2, 6, 10, 14 y 18.
- La PendingTask de infusiones debe permitir elegir de `kArtificerInfusions` (nueva lista en el frontend).
- Las infusiones elegidas se almacenan como `CharacterFeature` con `source = "INFUSION"` o en una tabla dedicada.

*Frontend:*
- Nueva lista `kArtificerInfusions` en `dnd_choice_options.dart` con las infusiones disponibles.
- Handler en `PendingTasksScreen` para el tipo `INFUSION_CHOICE`.
- Mostrar infusiones activas en la tab de Features, separadas de las features de clase.

**Lista de infusiones a implementar (TCE, las más comunes):**
Arcane Propulsion Armor, Armor of Magical Strength, Boots of the Winding Path, Enhanced Arcane Focus (+1/+2), Enhanced Defense (+1/+2 armor/shield), Enhanced Weapon (+1/+2), Homunculus Servant, Mind Sharpener, Radiant Weapon, Repulsion Shield, Resistant Armor, Returning Weapon, Spell-Refueling Ring.

#### 2.1.3 Tool Expertise

A nivel 6 el Artificiero duplica su proficiency bonus con herramientas en las que ya es competente.

*Backend:* Cuando se calcula el bonus de una herramienta de artesano y el personaje es Artificiero de nivel ≥ 6, multiplicar el proficiency bonus por 2 para esa herramienta.

#### 2.1.4 Flash of Genius (nivel 7)

**Mecánica:** Reacción. Al ver a criatura a 30 pies tirar un check o saving throw, añadir MOD_INT al resultado.

*Implementación:* Descriptiva + aparece como reacción en la tab de combate. No requiere cálculo automático (es situacional).

*Frontend — `combat_features.dart`:* Añadir `'flash-of-genius'` a `kCombatReactionFeatures`.

#### 2.1.5 Magic Item Adept / Savant / Master (niveles 10, 14, 18)

Amplían los slots de attunement más allá de 3 (hasta 4, 5, 6 según la versión ERLW/TCE).

*Backend — `CharacterInventoryService`:* El límite de attunement actual está hardcodeado a 3. Hacer que consulte el nivel y la clase del personaje para ajustar el límite.

| Nivel Artificiero | Attunement slots |
|------------------|-----------------|
| < 10 | 3 (estándar) |
| 10–13 | 4 |
| 14–17 | 5 |
| 18+ | 6 |

#### 2.1.6 Subclases del Artificiero

**Subclase a nivel 3.** Cada subclase del Artificiero concede:

**Alchemist:**
- Proficiency: Alchemist's Supplies (herramienta).
- Hechizos de subclase automáticos: Healing Word, Ray of Sickness (3), Flaming Sphere, Melf's Acid Arrow (5), Gaseous Form, Mass Healing Word (9), Blight, Death Ward (13), Cloudkill, Raise Dead (17).
- Feature: Experimental Elixir — crea d6 pociones de efecto aleatorio o elegido (choice PendingTask si se permite elegir a nivel alto).

**Armorer:**
- Proficiency automática: Armadura pesada.
- Hechizos de subclase automáticos: Magic Missile, Thunderwave (3), Mirror Image, Shatter (5), Hypnotic Pattern, Lightning Bolt (9), Fire Shield, Greater Invisibility (13), Passwall, Wall of Force (17).
- Feature: Arcane Armor — cualquier armadura puede ser tu foco mágico + customizable.
- Feature choice a nivel 3: Guardian (Thunder Gauntlets + helmet mode) vs. Infiltrator (Lightning Launcher + stealth mode) → PendingTask `ARMORER_MODE`.

**Artillerist:**
- Proficiency: Woodcarver's Tools.
- Hechizos de subclase automáticos: Shield, Thunderwave (3), Scorching Ray, Shatter (5), Fireball, Wind Wall (9), Ice Storm, Wall of Fire (13), Cone of Cold, Wall of Force (17).
- Feature: Eldritch Cannon — choice a nivel 3 entre Flamethrower, Force Ballista, Protector → PendingTask `CANNON_TYPE`.
- Feature: Fortified Position (nivel 15) — segunda ametralladora.

**Battle Smith:**
- Proficiency automática: Armas marciales, Smith's Tools.
- Hechizos de subclase automáticos: Heroism, Shield (3), Branding Smite, Warding Bond (5), Aura of Vitality, Conjure Barrage (9), Aura of Purity, Fire Shield (13), Banishing Smite, Mass Cure Wounds (17).
- Feature: Steel Defender — compañero autónomo de combate. Tiene sus propias estadísticas. Sus AC, HP, ataque escalan con el nivel del Artificiero. *Mecánica compleja: requiere un objeto separado en la ficha (como un familiar).*

---

### 2.2 Blood Hunter

**La clase ya tiene sus features en `class_features` y sus subclases/features en `subclass_features`. Falta toda la mecánica.**

#### 2.2.1 Recursos de clase — Blood Maledict

**Mecánica:** El Blood Hunter puede lanzar Blood Curses (maldiciones). El número de usos iguala su proficiency bonus. Recupera todos los usos con Long Rest. A nivel 20 los usos son ilimitados.

*Backend — `CharacterClassResourceService`:*
```
Nuevo recurso: BLOOD_MALEDICT
maxFormula: "proficiency_bonus"
recoveryType: LONG_REST
Excepción a nivel 20: ilimitado (maxFormula = "999" o un flag especial)
```

#### 2.2.2 Recursos de clase — Crimson Rite

**Mecánica:** Acción bonus para activar el Rite. Al activarlo, el personaje sufre `1d4` de daño (no puede reducirse). El rite añade daño de un tipo elemental a los ataques con armas. Dura hasta short/long rest o hasta que el personaje quede inconsciente.

**Tipos de Rite desbloqueados:**
- Rite of the Flame (fuego) — nivel 2 todos.
- Rite of the Frozen (frío) — nivel 2 todos.
- Rite of the Storm (relámpago) — nivel 2 todos.
- Rite of the Dawn (radiante) — Order of the Ghostslayer únicamente.
- Rite of the Oracle (psíquico) — Order of the Mutant únicamente.
- Rite of the Roar (trueno) — Order of the Lycan únicamente.

*Backend:*
- Nuevo recurso de tipo "activo/toggle": `CRIMSON_RITE`. No tiene usos contables; es un estado activo/inactivo.
- PendingTask `CRIMSON_RITE_TYPE` para elegir qué tipo de rite activar (entre los disponibles para el personaje).
- Al activar: registrar el coste de HP en el estado del personaje (el backend puede simplemente indicar que debe reducir el HP; el frontend muestra la advertencia).
- El daño adicional del rite en sí es descriptivo (el jugador lo aplica en su herramienta de combate).

#### 2.2.3 Blood Curses

Las Blood Curses son las "hechizos" del Blood Hunter, activadas con Blood Maledict. El Blood Hunter las aprende al subir de nivel.

| Nivel | Maldiciones aprendidas |
|-------|----------------------|
| 1 | 1 |
| 6 | 2 |
| 14 | 3 |

Cada subclase también concede blood curses específicas de forma automática.

**Lista de Blood Curses disponibles:**
Blood Curse of the Anxious, Blood Curse of Binding, Blood Curse of Bloated Agony, Blood Curse of Corrosion, Blood Curse of Despair, Blood Curse of the Eyeless, Blood Curse of Exposure, Blood Curse of the Fallen Puppet, Blood Curse of the Howl, Blood Curse of the Marked, Blood Curse of the Muddled Mind, Blood Curse of Purgation, Blood Curse of the Souleater (nivel 18 solo), Blood Curse of the Spiteful Web, Blood Curse of the Stranded.

*Backend:*
- Nuevo `FeatureType.BLOOD_CURSE_CHOICE`.
- PendingTask creada a niveles 1, 6, 14 con metadata que indica cuántas curses elegir.
- Las curses elegidas se almacenan como `CharacterFeature` con `source = "BLOOD_CURSE"`.

*Frontend:*
- Nueva lista `kBloodCurses` en `dnd_choice_options.dart`.
- Handler en `PendingTasksScreen` para `BLOOD_CURSE_CHOICE`.
- En la tab de Features, Blood Curses aparecen como abilities usables (acción bonus) que consumen Blood Maledict.

#### 2.2.4 Subclases del Blood Hunter

**Order of the Ghostslayer (nivel 3):**
- Rite of the Dawn desbloqueado automáticamente.
- Hechizos de orden automáticos: Detect Evil and Good, Etherealness, Remove Curse, Silence, Banishment, Speak with Dead, Destroy Undead, Divine Word, True Resurrection.
- Features adicionales: Esoteric Rite (Channel a rite of the dawn onto weapon as free action), Ghosts Among the Dead (Darkvision 60ft si no se tiene), Purge the Wicked (Sacred Flame).

**Order of the Lycan (nivel 3):**
- Rite of the Roar desbloqueado.
- Features: Heightened Senses, Hybrid Transformation (transformación en forma híbrida con ataques de garra/mordida, impone una PendingTask a nivel 3 para elegir el tipo de licántropo — Wolf, Bear, Tiger, Snake, Boar).
- Nivel 7: Stalker's Prowess (velocidad +10 pies, Pounce mechanic).
- Nivel 11: Advanced Transformation (mayor potencia del Hybrid).
- Nivel 15: Brand of the Voracious (ventaja en saves vs. transform).
- Nivel 18: Hybrid Transformation Mastery (full control, mejora de claws).

**Order of the Mutant (nivel 3):**
- Rite of the Oracle desbloqueado.
- Mecánica especial: Formulas. Al subir a nivel 3, 7, 11, 15 elige Mutagen Formulas (efectos temporales que puede aplicarse). Cada formula tiene efecto positivo + "mutagenic toxin" negativo.
- Nuevos `FeatureType.MUTAGEN_FORMULA_CHOICE` con lista de fórmulas disponibles.
- Formulas: Celerity, Conversant, Cruelty, Deftness, Embers, Gelid, Impermeable, Mobility, Percipient, Potency, Rapidity, Reconstruction, Siege, Unbreakable, Vigilant.

**Order of the Profane Soul (nivel 3):**
- Gana un Warlock Pact (como la clase Warlock a nivel 1): elige patron entre Archfey, Fiend, Great Old One, Undying, Celestial, Hexblade, etc.
- Recibe Eldritch Blast + un Eldritch Invocation a nivel 3 y más a niveles 7, 15.
- Pact Spells automáticos según el patron elegido.
- Uso de Pact Magic slots (cortos, recuperan con short rest): 1 slot a nivel 3, 2 slots a nivel 7+.
- *Esta subclase es especialmente compleja porque fusiona dos sistemas de clase.*
- PendingTask `PROFANE_SOUL_PATRON` para elegir el patron.

---

### 2.3 Gunslinger (Subclase de Guerrero — Martial Archetype)

**La subclase ya está en BD con sus features. Falta la mecánica de Grit y Trick Shots.**

#### 2.3.1 Recurso — Grit

**Mecánica:**
- Máximo = modificador de WIS (mínimo 1).
- Se recupera cuando el personaje consigue un critical hit con un arma de fuego O reduce a 0 HP a una criatura con un arma de fuego.
- Se recupera completamente con Short o Long Rest.
- Se gasta para usar Trick Shots (1 punto por trick).

*Backend:*
```
Nuevo recurso: GRIT
maxFormula: "wisdom_modifier_min1"  (nueva fórmula: max(1, wis_mod))
recoveryType: SHORT_REST
```
Añadir la fórmula `wisdom_modifier_min1` al sistema de fórmulas de `CharacterClassResourceService`.

#### 2.3.2 Trick Shots

**Mecánica:** El Gunslinger aprende Trick Shots que puede ejecutar gastando 1 Grit. Se aprenden a niveles 3 (2 shots), 7 (+1), 10 (+1), 15 (+1), 18 (+1).

**Lista de Trick Shots:**
- Bullseye Shot — objetivo a larga distancia sin desventaja.
- Dazing Shot — objetivo supera CON save o queda incapacitado hasta inicio del siguiente turno del Gunslinger.
- Deadeye Shot — ventaja en el próximo ataque de arma de fuego.
- Disarming Shot — objetivo supera STR save o suelta lo que tenga.
- Forceful Shot — objetivo supera STR save o es empujado 15 pies.
- Piercing Shot — DEX save o todos en línea recta toman el daño.
- Violent Shot — el ataque hace daño extra pero la pistola tiene desventaja en fallo de misfire.
- Winging Shot — objetivo supera DEX save o cae Prone.

*Backend:* Nuevo `FeatureType.TRICK_SHOT_CHOICE`. PendingTask a niveles 3, 7, 10, 15, 18.

*Frontend:*
- Nueva lista `kTrickShots` en `dnd_choice_options.dart`.
- Handler en `PendingTasksScreen`.
- Trick Shots elegidos aparecen en tab de Features/Combate como abilities que cuestan 1 Grit.

#### 2.3.3 Firearm Proficiency

Automático al tomar la subclase. El personaje debe ganar proficiency con "Firearms" (categoría especial de armas).

*Backend:* Al resolver la subclase `"gunslinger"`, añadir `CharacterProficiency` con `proficiencyType = "WEAPON"`, `name = "Firearms"`.

---

## FASE 3 — PendingTasks Incompletas del PHB

Estas subclases PHB tienen elecciones definidas en `dnd_choice_options.dart` pero **no tienen `FeatureType` ni PendingTask asociada**. El usuario actualmente no puede hacer estas elecciones en la app.

### 3.1 Battle Master (Fighter) — Maniobras

**Mecánica:** Elige 3 maniobras a nivel 3. A nivel 7 aprende 2 más. A nivel 10 puede reemplazar una. A nivel 15 aprende 2 más.

*Backend:*
- Nuevo `FeatureType.MANEUVER_CHOICE`.
- PendingTask a niveles 3, 7, 15 con metadata `"count": 3/2/2`.
- Las maniobras elegidas se almacenan como `CharacterFeature`.

*Frontend:*
- `kBattleMasterManeuvers` ya existe en `dnd_choice_options.dart` (16 opciones).
- Handler en `PendingTasksScreen` para `MANEUVER_CHOICE` (multi-select con límite).
- Las maniobras elegidas aparecen en tab de Features/Combate.

### 3.2 Path of the Totem Warrior (Barbarian) — Espíritus Tótem

**Mecánica:** Tres elecciones separadas en niveles 3, 6 y 14. Cada una es independiente (pueden ser animales diferentes).
- Nivel 3: Spirit Seeker cantrip + **Totem Spirit** (Bear/Eagle/Wolf).
- Nivel 6: **Aspect of the Beast** (Bear/Eagle/Wolf).
- Nivel 14: **Totemic Attunement** (Bear/Eagle/Wolf).

*Backend:*
- Nuevo `FeatureType.TOTEM_SPIRIT`, `TOTEM_ASPECT`, `TOTEM_ATTUNEMENT` (o un único `TOTEM_CHOICE` con metadata de qué tipo).
- Tres PendingTasks a niveles 3, 6, 14.

*Frontend:*
- `kTotemSpirit`, `kTotemAspect`, `kTotemicAttunement` ya existen en `dnd_choice_options.dart`.
- Handlers en `PendingTasksScreen` para los tres tipos.
- Las elecciones son descriptivas en Features.

### 3.3 Hunter Ranger — Elecciones de Subclase

**Mecánica:** Cuatro elecciones a lo largo de los niveles:
- Nivel 3: **Hunter's Prey** (Colossus Slayer / Giant Killer / Horde Breaker).
- Nivel 7: **Defensive Tactics** (Escape the Horde / Multiattack Defense / Steel Will).
- Nivel 11: **Multiattack** (Volley / Whirlwind Attack).
- Nivel 15: **Superior Hunter's Defense** (Evasion / Stand Against the Tide / Uncanny Dodge).

*Backend:*
- Nuevos FeatureTypes: `HUNTERS_PREY`, `DEFENSIVE_TACTICS`, `HUNTER_MULTIATTACK`, `SUPERIOR_DEFENSE`.
- PendingTask a cada nivel.

*Frontend:*
- Todos los `k*` ya existen en `dnd_choice_options.dart`.
- Handlers correspondientes.

### 3.4 Way of the Four Elements (Monk) — Disciplinas

**Mecánica:** A nivel 3 elige 2 disciplinas elementales (Elemental Attunement es gratis/automática). A niveles 6, 11, 17 gana una disciplina más.

*Backend:*
- Nuevo `FeatureType.ELEMENTAL_DISCIPLINE`.
- PendingTask a niveles 3 (elige 2), 6, 11, 17 (elige 1 cada vez).

*Frontend:*
- `kFourElementsDisciplines` ya existe (17 opciones).
- Handler en `PendingTasksScreen` para `ELEMENTAL_DISCIPLINE`.

### 3.5 Eldritch Knight (Fighter) y Arcane Trickster (Rogue) — Hechizos

**Mecánica:**
- **Eldritch Knight:** Aprende hechizos de las escuelas de Abjuración y Evocación (puede elegir 1 de cualquier escuela en los niveles 3 y 20 adicionales). Usa INT.
- **Arcane Trickster:** Aprende hechizos de las escuelas de Ilusión y Encantamiento (puede elegir 1 de cualquier escuela en los niveles 3 y 20 adicionales). Usa INT.

*Backend:*
- El sistema de `SPELL_LEARN` existe, pero no filtra por escuela de magia.
- Añadir un campo `schoolFilter` al metadata de la PendingTask de SPELL_LEARN para que el frontend solo muestre hechizos de las escuelas permitidas.

*Frontend:*
- El selector de hechizos en PendingTasks debe poder filtrar por escuela cuando el metadata lo indique.

### 3.6 Invocaciones Adicionales (Warlock)

**Mecánica:** El Warlock gana invocaciones adicionales a niveles 2, 5, 7, 9, 12, 15, 18. Puede reemplazar una conocida a cada nivel par.

*Backend:*
- Verificar que se crean PendingTasks de `INVOCATION` a **todos** esos niveles, no solo al 2.
- El tipo `INVOCATION` ya existe en `FeatureType`.

### 3.7 Metamagia Adicional (Sorcerer)

**Mecánica:** El Sorcerer elige 2 metamagias a nivel 3 y gana 1 más a niveles 10 y 17.

*Backend:*
- Verificar que se crean PendingTasks de `METAMAGIC` a niveles 3 (×2), 10, y 17.
- El tipo `METAMAGIC` ya existe en `FeatureType`.

---

## FASE 4 — Hechizos de Subclase Automáticos

Muchas subclases proporcionan hechizos que se **siempre se preparan** (no ocupan espacio de preparación) o se **conocen** automáticamente al alcanzar ciertos niveles.

**Regla D&D:** Los hechizos de dominio/juramento/círculo se marcan como "siempre preparados" y no cuentan para el límite de hechizos preparados del personaje.

*Implementación backend:*
- Al resolver una PendingTask de `CHOOSE_SUBCLASS`, o al crear un personaje con subclase ya elegida, ejecutar `applySubclassSpells(character, subclass)`.
- Este método busca una tabla `subclass_spells` (a crear) que mapea `subclass_index → [(level_required, spell_index)]`.
- Añadir los hechizos al personaje con `source = "SUBCLASS"`. Los hechizos con source `"SUBCLASS"` no se pueden eliminar y no cuentan para el límite.
- Al subir de nivel, si el nuevo nivel desbloquea hechizos de subclase adicionales, añadirlos automáticamente.

*Nueva tabla `subclass_spells`:*
```sql
CREATE TABLE subclass_spells (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    subclass_id BIGINT NOT NULL,
    spell_id BIGINT NOT NULL,
    required_level INT NOT NULL DEFAULT 3,
    FOREIGN KEY (subclass_id) REFERENCES subclasses(id),
    FOREIGN KEY (spell_id) REFERENCES spells(id)
);
```

### Hechizos por subclase a seed:

**Cleric Domains:**
| Subclase | Nivel 3 | Nivel 5 | Nivel 9 | Nivel 13 | Nivel 17 |
|----------|---------|---------|---------|----------|----------|
| Knowledge | Command, Identify | Augury, Suggestion | Nondetection, Speak with Dead | Arcane Eye, Confusion | Legend Lore, Scrying |
| Light | Burning Hands, Faerie Fire | Flaming Sphere, Scorching Ray | Daylight, Fireball | Guardian of Faith, Wall of Fire | Flame Strike, Scrying |
| Nature | Animal Friendship, Speak with Animals | Barkskin, Spike Growth | Plant Growth, Wind Wall | Dominate Beast, Grasping Vine | Insect Plague, Wall of Stone |
| Tempest | Fog Cloud, Thunderwave | Gust of Wind, Shatter | Call Lightning, Sleet Storm | Control Water, Ice Storm | Destructive Wave, Insect Plague |
| Trickery | Charm Person, Disguise Self | Mirror Image, Pass Without Trace | Blink, Dispel Magic | Dimension Door, Polymorph | Dominate Person, Modify Memory |
| War | Divine Favor, Shield of Faith | Magic Weapon, Spiritual Weapon | Crusader's Mantle, Spirit Guardians | Freedom of Movement, Stoneskin | Flame Strike, Hold Monster |

**Paladin Oaths:**
| Subclase | Nivel 3 | Nivel 5 | Nivel 9 | Nivel 13 | Nivel 17 |
|----------|---------|---------|---------|----------|----------|
| Devotion | Protection from Evil and Good, Sanctuary | Lesser Restoration, Zone of Truth | Beacon of Hope, Dispel Magic | Freedom of Movement, Guardian of Faith | Commune, Flame Strike |
| Ancients | Ensnaring Strike, Speak with Animals | Misty Step, Moonbeam | Plant Growth, Protection from Energy | Ice Storm, Stoneskin | Commune with Nature, Tree Stride |
| Vengeance | Bane, Hunter's Mark | Hold Person, Misty Step | Haste, Protection from Energy | Banishment, Dimension Door | Hold Monster, Scrying |

**Druid Circles:**
| Subclase | Nivel 3 | Nivel 5 | Nivel 7 | Nivel 9 |
|----------|---------|---------|---------|---------|
| Land (Arctic) | Hold Person, Spike Growth | Sleet Storm, Slow | Freedom of Movement, Ice Storm | Commune with Nature, Cone of Cold |
| Land (Coast) | Mirror Image, Misty Step | Water Breathing, Water Walk | Control Water, Freedom of Movement | Conjure Elemental, Scrying |
| Land (Desert) | Blur, Silence | Create Food and Water, Protection from Energy | Blight, Hallucinatory Terrain | Insect Plague, Wall of Stone |
| Land (Forest) | Barkskin, Spider Climb | Call Lightning, Plant Growth | Divination, Freedom of Movement | Commune with Nature, Tree Stride |
| Land (Grassland) | Invisibility, Pass Without Trace | Daylight, Haste | Divination, Freedom of Movement | Dream, Insect Plague |
| Land (Mountain) | Spider Climb, Spike Growth | Lightning Bolt, Meld into Stone | Stone Shape, Stoneskin | Passwall, Wall of Stone |
| Land (Swamp) | Darkness, Melf's Acid Arrow | Water Walk, Stinking Cloud | Freedom of Movement, Locate Creature | Insect Plague, Scrying |
| Land (Underdark) | Spider Climb, Web | Gaseous Form, Stinking Cloud | Greater Invisibility, Stone Shape | Cloudkill, Insect Plague |

*Nota: La selección de tipo de Land (subdominio) necesita su propio PendingTask.*

---

## FASE 5 — Proficiencias Extra por Subclase

Algunas subclases conceden proficiencias adicionales que deben aplicarse al personaje al elegir la subclase.

*Implementación backend:*
- En `PendingTaskService.applyChoice()` para `CHOOSE_SUBCLASS`, después de asignar la subclase, llamar a `applySubclassProficiencies(character, subclass)`.
- Este método consulta una tabla `subclass_proficiencies` (a crear) o un switch hardcodeado por `subclass.indexName`.

### Proficiencias por subclase a implementar:

| Subclase | Proficiencias que concede |
|----------|--------------------------|
| Knowledge Cleric | 2 skills a elegir de cualquier lista (con Expertise, no solo proficiency) → PendingTask `KNOWLEDGE_DOMAIN_SKILLS` |
| Knowledge Cleric | 2 idiomas a elegir → 2 PendingTask `EXTRA_LANGUAGE` |
| Nature Cleric | Heavy Armor, 1 cantrip (Animal Friendship/Poison Spray/Shillelagh/Thorn Whip) → PendingTask `NATURE_DOMAIN_CANTRIP` |
| Tempest Cleric | Heavy Armor, Martial Weapons (automático) |
| War Cleric | Heavy Armor, Martial Weapons (automático) |
| Battle Master | Herramientas artesanas: elige 1 de (Forgery Kit, Herbalism Kit, navigator's tools, thieves' tools) o 1 idioma → PendingTask |
| Eldritch Knight | No extra proficiencias |
| Arcane Trickster | No extra proficiencias |
| College of Lore | 3 skills a elegir de cualquier lista → PendingTask `LORE_BARD_SKILLS` |
| College of Valor | Armadura media, escudo, armas marciales (automático) |
| Circle of the Moon | No extra proficiencias |
| Gunslinger | Tinker's Tools, Firearms (automático al elegir subclase) |
| Armorer Artificer | Heavy Armor (automático) |
| Battle Smith Artificer | Martial Weapons, Smith's Tools (automático) |
| Alchemist Artificer | Alchemist's Supplies (automático) |
| Artillerist Artificer | Woodcarver's Tools (automático) |
| Order of the Lycan | Elección de tipo de licántropo → PendingTask `LYCAN_TYPE` |
| Order of the Profane Soul | Elección de Warlock patron → PendingTask `PROFANE_SOUL_PATRON` |

---

## FASE 6 — Efectos de Dotes (Feats)

Las 42 dotes del PHB están en BD y el usuario puede elegirlas en el ASI_OR_FEAT, pero **ninguna aplica sus efectos** a la ficha. Esto significa que Tough no da HP extra, Alert no añade al initiative, etc.

*Implementación backend:*
- En `PendingTaskService`, en el case `ASI_OR_FEAT` cuando se elige `FEAT:NombreDote`, llamar a `applyFeatEffects(character, featName)`.
- `applyFeatEffects` es un método con un switch por `feat.indexName`.

### Dotes con efectos mecánicos a implementar:

**Efectos en stats/habilidades:**
| Dote | Efecto mecánico |
|------|----------------|
| Tough | +2 HP por nivel (retroactivo a todos los niveles actuales: +2 × nivel_actual a maxHP) |
| Alert | +5 a Initiative (añadir campo `initiativeBonus` al personaje o al DTO) |
| Observant | +5 Passive Perception, +5 Passive Investigation; +1 WIS o INT |
| Resilient | +1 al ability score elegido; proficiency en saving throw de ese ability → PendingTask `RESILIENT_ABILITY` |
| Skilled | Proficiency en 3 skills o herramientas a elegir → PendingTask `SKILLED_CHOICES` (3 picks) |
| Weapon Master | Proficiency en 4 armas a elegir → PendingTask `WEAPON_MASTER_CHOICES` |
| Linguist | Aprende 3 idiomas → 3× PendingTask `EXTRA_LANGUAGE` |
| Actor | +1 CHA |
| Athlete | +1 STR o DEX |
| Charger | (sin efecto automático en ficha, es situacional) |
| Dual Wielder | +1 AC si se empuñan dos armas cuerpo a cuerpo |
| Durable | +1 CON; mínimo de recuperación de hit dice = 2× modificador de CON |
| Heavily Armored | Proficiency en Heavy Armor; +1 STR |
| Heavy Armor Master | +1 STR; reduce daño de armas no mágicas en 3 si se lleva Heavy Armor |
| Keen Mind | +1 INT |
| Lightly Armored | Proficiency en Light Armor y Shields; +1 STR o DEX |
| Magic Initiate | Aprende 2 cantrips + 1 hechizo de nivel 1 de clase a elegir → PendingTask `MAGIC_INITIATE` |
| Martial Adept | Aprende 1 maniobra de Battle Master + 1 Superiority Die (d6) → PendingTask `MARTIAL_ADEPT_MANEUVER` |
| Medium Armor Master | Sin penalización a Stealth con armadura media; máximo DEX para AC con armadura media sube a +3 |
| Moderately Armored | Proficiency en Medium Armor y Shields; +1 STR o DEX |
| Ritual Caster | Aprende hechizos rituales de una clase a elegir → PendingTask `RITUAL_CASTER_CLASS` |
| Savage Attacker | (situacional, sin efecto en ficha) |
| Spell Sniper | Aprende 1 cantrip de ataque de clase a elegir → PendingTask `SPELL_SNIPER_CANTRIP` |
| Tavern Brawler | +1 STR o CON; proficiency con herramientas improvisadas |
| War Caster | (sin efecto automático en ficha, ventajas situacionales) |
| Elemental Adept | Elige un elemento → PendingTask `ELEMENTAL_ADEPT_TYPE` (descriptiva) |
| Magic Initiate | Requiere PendingTask para elegir clase y hechizos |

**Dotes puramente descriptivas** (sin modificación de stats, solo texto en Features):
Charger, Crossbow Expert, Defensive Duelist, Dungeon Delver, Grappler, Great Weapon Master, Healer, Inspiring Leader, Lucky, Mage Slayer, Mobile, Mounted Combatant, Polearm Master, Sentinel, Sharpshooter, Shield Master, Skulker, Tough (tiene efecto — ver arriba), War Caster.

---

## FASE 7 — Features de Subclase con Efectos en Stats

Algunas features de subclase modifican las estadísticas directamente. Actualmente son solo texto. Las más importantes:

### 7.1 Bonificaciones de velocidad
| Feature | Efecto |
|---------|--------|
| Champion (Fighter) lv.18 Survivor | Regain HP at start of turn if below half max (descriptiva/situacional) |
| Way of Shadow Monk — Shadow Step | Teleport, no mecánica automática |
| Monk — Unarmored Movement | Ya implementado |

### 7.2 Ventajas/resistencias pasivas
Estas son **descriptivas en la tab de Features**; no requieren implementación en el cálculo de stats ya que D&D 5e no tiene un campo "resistance" global — se aplican en combate por el jugador.

Sin embargo, el sistema podría mostrar un **badge** visual en la tab de Combate indicando resistencias activas. Esto es UI, no cálculo.

### 7.3 Draconic Bloodline Sorcerer — Natural Armor
- **Efecto:** AC = 13 + MOD_DEX si no se lleva armadura y se es Draconic Bloodline.
- *Backend:* Al calcular AC, si la subclase del personaje es `"draconic-bloodline"` y no lleva armadura, usar esta fórmula.

### 7.4 Circle of the Moon Druid — Wild Shape Mejorada
- El Druid base tiene Wild Shape con CR máximo según nivel.
- Circle of the Moon eleva el CR máximo para usar formas de combate.
- *Actualmente es descriptivo.* La implementación completa requeriría un sistema de formas de Wild Shape (fuera de alcance por ahora).

### 7.5 College of Lore Bard — Cutting Words
- Reacción que usa un Bardic Inspiration para reducir tirada de atacante.
- *Descriptivo en combat features.* Frontend — `combat_features.dart`: `'cutting-words'` ya está en `kCombatReactionFeatures`. ✓

### 7.6 Aura de Paladin (nivel 6)
- **Devotion:** Aura of Protection (MOD_CHA a saving throws aliados en 10 pies).
- **Ancients:** Aura of Warding (resistencia a daño de hechizos).
- **Vengeance:** Aura of Hate (MOD_CHA a daño de armas vs. demonios/muertos vivientes).
- *Efecto automático:* El +CHA a saving throws del propio Paladín sí debe calcularse y añadirse al DTO de saving throws cuando el Paladín alcanza nivel 6 y tiene la subclase correspondiente.

---

## FASE 8 — Traits Raciales Nuevos sin PendingTask

Con las subraces y razas añadidas, puede haber traits de tipo `CHOICE_REQUIRED` cuyos `indexName` no están en el switch del backend.

### Traits conocidos sin handler:

| Trait (indexName) | Raza | Elección requerida |
|-------------------|------|--------------------|
| `natural-illusionist` | Forest Gnome | Aprende cantrip Minor Illusion → automático, no elección |
| `speak-with-small-beasts` | Forest Gnome | Descriptivo, no elección |
| `dwarven-armor-training` | Mountain Dwarf | Proficiency en Heavy Armor → automático |
| `fleet-of-foot` | Wood Elf | Velocidad 35 → modificar `race.speed` |
| `mask-of-the-wild` | Wood Elf | Descriptivo |
| `superior-darkvision` | Drow | Darkvision 120 ft → descriptivo/visual |
| `sunlight-sensitivity` | Drow | Desventaja en ataques y Perception bajo luz solar → descriptivo/visual |
| `drow-magic` | Drow | Cantrips: Dancing Lights (libre), Faerie Fire (lv.3), Darkness (lv.5) → automático por nivel |
| `drow-weapon-training` | Drow | Proficiency en rapier, shortsword, hand crossbow → automático |
| `stout-resilience` | Stout Halfling | Ventaja en saves vs. veneno, resistencia a daño de veneno → descriptivo |

### Implementación:

*Backend — switch en `PlayerCharacterService`:*
- `"natural-illusionist"` → añadir Minor Illusion como `CharacterSpell` con source=`"RACE"`. No crea PendingTask.
- `"dwarven-armor-training"` → añadir Heavy Armor proficiency como `CharacterProficiency`. No crea PendingTask.
- `"drow-weapon-training"` → añadir proficiencias: rapier, shortsword, hand crossbow.
- `"drow-magic"` → añadir Dancing Lights como `CharacterSpell` source=`"RACE"`. Faerie Fire y Darkness se añaden al subir a niveles 3 y 5.
- `"fleet-of-foot"` → la velocidad ya está en `Race.speed = 35` para Wood Elf. ✓

---

## Convenciones de Implementación

### Orden de ataque sugerido:

1. **Fase 1.2** (Unarmored Defense) — cambio pequeño, alto impacto en Bárbaro y Monje.
2. **Fase 1.1** (Magic item effects) — hay una migración de BD ya hecha, solo falta leerla en el DTO.
3. **Fase 4** (Hechizos de subclase) — requiere nueva tabla `subclass_spells` y seed; el mecanismo de aplicación es simple.
4. **Fase 3** (PendingTasks PHB faltantes) — sigue el patrón existente, riesgo bajo.
5. **Fase 5** (Proficiencias de subclase) — parte se puede hacer automático, parte requiere nuevas PendingTasks.
6. **Fase 2.3** (Gunslinger) — el más simple de los nuevos recursos.
7. **Fase 2.2** (Blood Hunter) — recursos nuevos de complejidad media.
8. **Fase 2.1** (Artificiero) — el más complejo, múltiples sistemas.
9. **Fase 6** (Feats) — muchas dotes, pero el patrón es repetitivo.
10. **Fase 7** (Stats de subclase) — mayormente cambios pequeños dispersos.
11. **Fase 8** (Racial traits nuevos) — añadir casos al switch existente.

### Patrones de código a seguir:

- **Nuevo recurso de clase:** Añadir case en `CharacterClassResourceService.initializeClassResourcesForCharacter()` y en `updateResourceMaximums()`.
- **Nueva PendingTask:** (1) Añadir valor a `FeatureType` enum. (2) Crear la tarea en el método `generateChoiceTasksForCreation()` o en `levelUp()`. (3) Añadir case en `PendingTaskService.applyChoice()`. (4) Añadir lista de opciones en `dnd_choice_options.dart`. (5) Añadir handler en `pending_tasks_screen.dart`.
- **Nuevo hechizo automático:** Llamar a `addSpellToCharacter(character, spellIndex, "RACE" | "SUBCLASS" | "CLASS")`.
- **Nueva proficiencia automática:** Crear `CharacterProficiency` y guardarlo en `characterProficiencyRepository`.

### Regla sobre qué es descriptivo vs. funcional:

- **Funcional (debe calcularse):** Todo lo que modifica un número que aparece en la ficha: AC, HP, tiradas de ataque, saving throws, velocidad, ability scores, número de usos de recursos.
- **Descriptivo (solo texto en Features):** Efectos situacionales, mecánicas de combate narrativas, resistencias/ventajas que el jugador aplica manualmente, habilidades de roleplay.
- **Combat feature (aparece en tab Combate):** Cualquier feature usada como acción, acción bonus o reacción en combate, aunque sea descriptiva. Se gestiona en `combat_features.dart`.

---

*Última actualización: 2026-06-12*
*Próximo paso: Fase 1.2 — Unarmored Defense.*
