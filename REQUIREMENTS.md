# 🧙‍♂️ D&D Character Management API

## Functional & Technical Requirements Document

---

# 1. Project Overview

This application is a **Spring Boot backend API** designed to manage player characters for a Dungeons & Dragons 5e-style system.

The goal is **not** to create a simple CRUD application, but to build a scalable and extensible **rules engine** capable of:

* Managing characters
* Handling class progression
* Supporting structured level-up logic
* Supporting player choices during progression
* Preparing for future features like multiclassing and homebrew content

The architecture is being designed with long-term scalability and rule modularity in mind.

---

# 2. Current Technical Stack

* Java
* Spring Boot
* Spring Data JPA
* Hibernate
* MySQL
* REST API architecture

---

# 3. Current Domain Model (Implemented So Far)

## 3.1 PlayerCharacter

Represents a player character.

### Key Fields:

* id
* name
* level
* maxHp
* proficiencyBonus
* abilityScores (Map<String, Integer>)
* dndClass (ManyToOne relationship)

### Responsibilities:

* Stores character state
* Tracks ability scores
* Tracks hit points
* Tracks class association

---

## 3.2 DndClass

Represents a character class.

### Key Fields:

* id
* indexName
* name
* hitDie
* proficiencies (ElementCollection)
* description

### Purpose:

* Defines core class data
* Provides hit die for HP calculations
* Links to class progression system

---

# 4. Level Progression System (Core Architecture)

The system is being designed to avoid hardcoded logic such as:

```java
if(className.equals("Wizard"))
```

Instead, progression rules are data-driven.

---

## 4.1 ClassLevelProgression

Represents a specific class at a specific level.

### Fields:

* id
* dndClass (ManyToOne)
* level
* features (OneToMany → ClassLevelFeature)

### Purpose:

Defines what a class gains at a specific level.

---

## 4.2 ClassLevelFeature

Represents an individual feature gained at a specific class level.

### Fields:

* id
* progression (ManyToOne)
* type (FeatureType enum)
* requiresChoice (boolean)
* metadata (TEXT)

### Purpose:

Defines:

* What kind of feature is gained
* Whether player input is required
* Optional additional configuration data

---

## 4.3 FeatureType (Enum)

Represents types of features a class can gain.

Examples:

* HP_INCREASE
* SPELL_LEARN
* SPELL_PREPARE
* SUBCLASS_CHOICE
* ASI_OR_FEAT
* FIGHTING_STYLE
* INVOCATION
* METAMAGIC
* CLASS_FEATURE

This ensures:

* No string-based logic
* Type safety
* Extensibility

---

# 5. Level-Up System Architecture

## 5.1 startLevelUp()

When a character levels up:

1. Increase level
2. Recalculate proficiency bonus
3. Retrieve ClassLevelProgression for that class and level
4. For each feature:

   * If requiresChoice → create LevelUpTask
   * If automatic → apply immediately

---

## 5.2 LevelUpTask System

Instead of resolving everything instantly, the system generates tasks.

### Purpose:

* Allow user-controlled decisions
* Track incomplete progression steps
* Prevent forced automation of player choices

### Example Tasks:

* HP increase choice (average vs rolled)
* Spell selection
* Subclass selection
* ASI or Feat selection

This allows:

* Partial completion
* UI-driven resolution
* Deferred decisions

---

# 6. Design Philosophy

The system must:

* Avoid hardcoding class names
* Avoid hardcoding level checks
* Be data-driven via database
* Allow adding new classes without changing Java logic
* Support future multiclassing
* Support homebrew extensions

---

# 7. Current Functional Scope

Currently implemented or in progress:

✔ Character entity
✔ Class entity
✔ Ability scores stored as Map
✔ Proficiency recalculation
✔ HP calculation logic
✔ Data-driven class progression model
✔ Feature type system via enum
✔ Task-based level-up workflow

---

# 8. Future Functional Goals

## 8.1 Immediate Goals

* Populate progression data in database
* Implement full HP choice resolution
* Implement ASI vs Feat resolution
* Implement Spell selection resolution
* Implement task completion endpoints

---

## 8.2 Medium-Term Goals

* Subclass system
* Feature tracking system (not just tasks)
* Spellbook system
* Prepared spells logic
* Resource tracking (spell slots, abilities)

---

## 8.3 Long-Term Goals

* Multiclass support
* Homebrew class support
* REST DTO layer separation
* Validation layer
* Character sheet export
* Optional frontend

---

# 9. Architectural Constraints

* Must remain REST-based
* Must use JPA relational modeling
* Must avoid business logic in controllers
* All rule logic belongs in services
* Domain must be extensible without structural rewrites

---

# 10. Non-Goals (For Now)

* No frontend yet
* No authentication layer yet
* No campaign management
* No combat engine

---

# 11. Core Objective

This is not a CRUD practice project.

It is intended to become:

> A modular, scalable D&D 5e character progression engine implemented in Java using clean architecture principles.

---

# 12. Summary

The system currently:

* Models characters
* Models classes
* Models class progression per level
* Separates automatic vs choice-based features
* Uses a task system to manage player decisions
* Is structured to support future growth

The next major step is completing task resolution logic and populating official progression data.

---
