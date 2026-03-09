# Gestor de Personajes DND

Sistema de gestión de personajes para Dungeons & Dragons 5e, desarrollado con Spring Boot y PostgreSQL.

## 📋 Descripción

Aplicación backend que permite crear y gestionar personajes de D&D 5e, incluyendo:

- Gestión completa de personajes (atributos, puntos de vida, nivel)
- Sistema de clases, razas y backgrounds
- Sistema de habilidades (skills) y salvaciones (saving throws)
- Gestión de hechizos y slots de hechizos por nivel
- Sistema de subida de nivel automatizado
- Progresión de características por nivel y clase
- Sistema de inventario y objetos
- Sincronización de datos desde la D&D 5e API
- Rate limiting para peticiones API

## 🛠️ Tecnologías

- **Java 24**
- **Spring Boot 3.2.0**
- **Spring Data JPA** - Persistencia de datos
- **PostgreSQL** - Base de datos relacional
- **Maven** - Gestión de dependencias
- **RestTemplate** - Cliente HTTP para integración con D&D 5e API
- **Hibernate** - ORM (Object-Relational Mapping)

## ✨ Características Técnicas

### Modelo de Datos
- 19 entidades JPA con relaciones complejas (OneToMany, ManyToOne, ElementCollection)
- Mapeo de atributos como Map y List
- Métodos transient para cálculos en tiempo de ejecución
- Cascadas y eliminación en cascada (orphanRemoval)

### Integración Externa
- Consumo de la **D&D 5e API** (https://www.dnd5eapi.co)
- Rate Limiting inteligente con pausas entre peticiones
- Sincronización automática de:
  - 12 clases oficiales con progresión completa
  - 9 razas base con bonificadores
  - 13 backgrounds con características únicas
  - 18 habilidades del sistema D&D
  - 300+ hechizos con información completa
  - Slots de hechizos por clase y nivel

### Lógica de Negocio
- Inicialización automática de habilidades y salvaciones al crear personaje
- Aplicación automática de competencias de background
- Cálculo dinámico de bonificadores (competencia + modificador de atributo)
- Sistema de tareas pendientes para decisiones durante subida de nivel
- Validaciones y gestión de errores

## 📦 Estructura del Proyecto

```
src/main/java/
├── controllers/        # Controladores REST API
│   ├── BackgroundController
│   ├── CharacterSkillController
│   ├── ClassFeatureController
│   ├── DndClassController
│   ├── PlayerCharacterController
│   ├── RaceController
│   └── SpellController
├── dto/               # Data Transfer Objects
│   ├── BackgroundDto
│   ├── CharacterSavingThrowDto
│   ├── CharacterSkillDto
│   ├── DndClassDto
│   ├── LevelUpRequest
│   ├── PlayerCharacterDto
│   ├── RaceDto
│   └── SpellDto
├── entities/          # Entidades JPA
│   ├── Background
│   ├── CharacterFeature
│   ├── CharacterInventory
│   ├── CharacterSavingThrow
│   ├── CharacterSkill
│   ├── CharacterSpell
│   ├── CharacterSpellSlot
│   ├── ClassFeature
│   ├── ClassLevelFeature
│   ├── ClassLevelProgression
│   ├── DndClass
│   ├── Item
│   ├── LevelUpTask
│   ├── PendingTask
│   ├── PlayerCharacter
│   ├── Race
│   ├── Skill
│   ├── Spell
│   └── SpellSlotProgression
├── enumeration/       # Enumeraciones
│   └── FeatureType
├── repositories/      # Repositorios JPA
│   ├── BackgroundRepository
│   ├── CharacterSkillRepository
│   ├── CharacterSavingThrowRepository
│   ├── DndClassRepository
│   ├── PlayerCharacterRepository
│   ├── SkillRepository
│   ├── SpellRepository
│   └── ...
├── services/          # Lógica de negocio
│   ├── BackgroundService
│   ├── CharacterSkillService
│   ├── DndClassService
│   ├── PlayerCharacterService
│   ├── RaceService
│   └── ...
└── sync/             # Servicios de sincronización
    ├── ApiRateLimiter
    ├── BackgroundSyncService
    ├── DndClassSyncService
    ├── RaceSyncService
    ├── SkillSyncService
    ├── SpellSyncService
    ├── SpellSlotSyncService
    └── SyncController
```

## 🚀 Características Principales

### Gestión de Personajes
- Crear, leer, actualizar y eliminar personajes
- Asignación de clase, raza y background
- Gestión de atributos (STR, DEX, CON, INT, WIS, CHA)
- Gestión de puntos de vida (actuales y máximos)
- Cálculo automático de bono de competencia
- Rasgos de personalidad, ideales, vínculos y defectos
- Percepción, investigación e intuición pasivas

### Sistema de Habilidades y Salvaciones
- 18 habilidades de D&D 5e (Acrobacia, Atletismo, Sigilo, etc.)
- Inicialización automática al crear personaje
- Gestión de competencias y expertise
- Cálculo automático de bonus (modificador + competencia)
- 6 salvaciones vinculadas a atributos
- Aplicación automática de competencias de clase

### Sistema de Backgrounds
- Catálogo de backgrounds de D&D 5e
- Competencias en habilidades por background
- Competencias en herramientas
- Idiomas y opciones de idiomas
- Características especiales con descripciones
- Rasgos de personalidad, ideales, vínculos y defectos sugeridos

### Sistema de Niveles
- Subida de nivel automatizada
- Progresión de características por clase
- Tipos de características:
  - Aumento de HP
  - Aprender hechizos
  - Preparar hechizos
  - Elección de subclase
  - ASI (Ability Score Improvement) o Feat
  - Estilo de combate
  - Invocaciones
  - Metamagia
  - Características de clase generales

### Sistema de Hechizos
- Gestión de hechizos disponibles por clase
- Slots de hechizos por nivel de personaje
- Asignación de hechizos conocidos/preparados
- Progresión automática de slots según clase y nivel
- Hechizos con toda la información: nivel, escuela, componentes, descripción
- Sistema de lanzamiento y recuperación de slots

### Sistema de Inventario (En desarrollo)
- Gestión de objetos del personaje
- Cantidades y descripciones
- Vinculación con catálogo de items

## 📝 Requisitos Previos

- Java 24 o superior
- Maven 3.6+
- PostgreSQL 12+
- IDE compatible con Java (IntelliJ IDEA, Eclipse, VS Code)

## ⚙️ Configuración

1. **Clonar el repositorio**
```bash
git clone <url-repositorio>
cd GestorPersonajesDND
```

2. **Configurar la base de datos**

Crear una base de datos PostgreSQL y configurar las credenciales en `application.properties`:

```properties
spring.datasource.url=jdbc:postgresql://localhost:5432/dnd_db
spring.datasource.username=tu_usuario
spring.datasource.password=tu_contraseña
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true
```

3. **Compilar el proyecto**
```bash
mvn clean install
```

4. **Ejecutar la aplicación**
```bash
mvn spring-boot:run
```

5. **Sincronizar datos iniciales** (Opcional pero recomendado)

Una vez la aplicación esté corriendo, sincronizar todos los datos desde la D&D 5e API:

```bash
curl -X POST http://localhost:8080/api/sync/all
```

O sincronizar elementos individuales:
```bash
curl -X POST http://localhost:8080/api/sync/skills
curl -X POST http://localhost:8080/api/sync/backgrounds
curl -X POST http://localhost:8080/api/sync/races
curl -X POST http://localhost:8080/api/sync/classes
curl -X POST http://localhost:8080/api/sync/spells
```

**Nota:** El endpoint `/sync/all` incluye rate limiting automático para evitar sobrecargar la API externa.

## 🔌 API Endpoints

### Personajes
- `GET /api/characters` - Listar todos los personajes
- `GET /api/characters/{id}` - Obtener un personaje con todos sus detalles
- `POST /api/characters` - Crear nuevo personaje
- `PUT /api/characters/{id}` - Actualizar personaje
- `DELETE /api/characters/{id}` - Eliminar personaje
- `POST /api/characters/{id}/level-up` - Subir de nivel
- `POST /api/characters/{id}/spells/{spellId}` - Asignar hechizo a personaje
- `DELETE /api/characters/{id}/spells/{spellId}` - Eliminar hechizo de personaje
- `POST /api/characters/{id}/spell-slots/restore` - Restaurar slots de hechizos
- `POST /api/characters/{id}/spell-slots/use` - Usar slot de hechizo

### Habilidades y Salvaciones
- `GET /api/characters/{characterId}/skills` - Obtener habilidades del personaje
- `GET /api/characters/{characterId}/saving-throws` - Obtener salvaciones del personaje
- `PUT /api/characters/{characterId}/skills/{skillId}/proficiency` - Establecer competencia en habilidad
- `PUT /api/characters/{characterId}/skills/{skillId}/expertise` - Establecer expertise en habilidad

### Clases
- `GET /api/classes` - Listar todas las clases
- `GET /api/classes/{id}` - Obtener una clase con detalles
- `GET /api/classes/{id}/features` - Obtener características de clase por nivel

### Razas
- `GET /api/races` - Listar todas las razas
- `GET /api/races/{id}` - Obtener una raza con detalles

### Backgrounds
- `GET /api/backgrounds` - Listar todos los backgrounds
- `GET /api/backgrounds/{id}` - Obtener un background con detalles

### Hechizos
- `GET /api/spells` - Listar todos los hechizos
- `GET /api/spells/{id}` - Obtener un hechizo con detalles

### Características de Clase
- `GET /api/class-features` - Listar todas las características de clase
- `GET /api/class-features/class/{classId}` - Características por clase
- `GET /api/class-features/class/{classId}/level/{level}` - Características por clase y nivel

### Sincronización (Admin)
- `POST /api/sync/skills` - Sincronizar habilidades desde D&D 5e API
- `POST /api/sync/backgrounds` - Sincronizar backgrounds
- `POST /api/sync/races` - Sincronizar razas
- `POST /api/sync/classes` - Sincronizar clases
- `POST /api/sync/spells` - Sincronizar hechizos
- `POST /api/sync/spell-slots/{classIndex}` - Sincronizar slots de una clase
- `POST /api/sync/all` - **Sincronización completa de todos los datos**

## 📘 Ejemplos de Uso

### Crear un nuevo personaje

```bash
curl -X POST http://localhost:8080/api/characters \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Thorin Escudo de Roble",
    "level": 1,
    "raceId": 3,
    "dndClassId": 2,
    "backgroundId": 5,
    "abilityScores": {
      "str": 16,
      "dex": 12,
      "con": 15,
      "int": 8,
      "wis": 13,
      "cha": 10
    },
    "maxHp": 12,
    "currentHp": 12,
    "personalityTrait1": "Siempre busco la manera más directa de hacer las cosas",
    "ideal": "Honor. Si deshonro a mí mismo, deshonro a todo mi clan",
    "bond": "Debo limpiar el nombre de mi familia",
    "flaw": "Tengo problemas para confiar en los miembros de otras razas"
  }'
```

### Obtener habilidades de un personaje

```bash
curl http://localhost:8080/api/characters/1/skills
```

**Respuesta:**
```json
[
  {
    "id": 1,
    "skillName": "Acrobatics",
    "abilityScore": "dex",
    "proficient": false,
    "expertise": false,
    "bonus": 1
  },
  {
    "id": 2,
    "skillName": "Athletics",
    "abilityScore": "str",
    "proficient": true,
    "expertise": false,
    "bonus": 5
  }
  ...
]
```

### Subir de nivel

```bash
curl -X POST http://localhost:8080/api/characters/1/level-up \
  -H "Content-Type: application/json" \
  -d '{
    "hpIncrement": 8,
    "spellsLearned": [23, 45],
    "abilityScoreIncrements": {
      "str": 1,
      "con": 1
    }
  }'
```

## 🔄 Estado del Proyecto

### ✅ Implementado
- ✅ Sistema completo de personajes
- ✅ Gestión de clases, razas y backgrounds
- ✅ Sistema de habilidades y salvaciones
- ✅ Sistema de hechizos y slots
- ✅ Sincronización con D&D 5e API
- ✅ Rate limiting en peticiones API
- ✅ Subida de nivel con características
- ✅ Cálculo automático de bonificadores

### 🚧 En Desarrollo
- 🚧 Sistema de inventario completo
- 🚧 Sistema de combate
- 🚧 Gestión de subclases
- 🚧 Frontend web

### 📋 Planificado
- Frontend React o Angular
- Sistema de autenticación y usuarios
- Gestión de campañas
- Sistema de dados virtuales
- Compartir personajes entre jugadores

## 👤 Autor

Alexandre Barbeito

