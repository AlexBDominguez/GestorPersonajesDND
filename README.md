# DungeonScroll (nombre temporal)

Sistema de gestión de personajes para Dungeons & Dragons 5e, desarrollado con Spring Boot, MySQL y Flutter.

> **Estado del Proyecto**: El backend está **100% completo** con todas las funcionalidades implementadas y operativas. El frontend móvil está **en desarrollo activo**.

## Descripción

Sistema completo para gestionar personajes de D&D 5e:

- Backend REST API con Spring Boot que gestiona toda la lógica de negocio
- Aplicación móvil Flutter para Android/iOS (en desarrollo)
- Base de datos MySQL con todas las entidades del sistema D&D 5e

### Funcionalidades del Backend

- Gestión completa de personajes (atributos, puntos de vida, nivel, experiencia)
- Sistema de clases, subclases, razas y backgrounds
- Sistema de habilidades (skills) y salvaciones (saving throws)
- Gestión de hechizos y slots de hechizos por nivel
- Sistema de subida de nivel automatizado
- Progresión de características por nivel y clase
- Sistema de inventario, equipamiento y dinero
- Gestión de idiomas y competencias (proficiencies)
- Sistema de feats (dotes) y recursos de clase
- Gestión de condiciones y efectos activos
- Resistencias y vulnerabilidades a tipos de daño
- Sistema de descansos (cortos y largos)
- Sincronización de datos desde la D&D 5e API
- Rate limiting para peticiones API
- Sistema de autenticación JWT con Spring Security
- Gestión de usuarios del sistema

## Tecnologías

### Backend
- **Java 21**
- **Spring Boot 3.2.0**
- **Spring Data JPA** - Persistencia de datos
- **MySQL 8.0** - Base de datos relacional (ejecutándose en Docker)
- **Maven** - Gestión de dependencias
- **RestTemplate** - Cliente HTTP para integración con D&D 5e API
- **Hibernate** - ORM (Object-Relational Mapping)
- **Docker & Docker Compose** - Contenedorización de MySQL
- **Spring Security** - Autenticación y autorización
- **JWT (jjwt)** - Tokens de autenticación

### Frontend
- **Flutter 3.x** - Framework multiplataforma para Android/iOS
- **Dart** - Lenguaje de programación
- **Provider** - Gestión de estado
- **HTTP** - Cliente HTTP para consumir la API REST
- **google_fonts** - Tipografía Cinzel y Lato

## Características Técnicas

### Backend

#### Modelo de Datos
- 38 entidades JPA con relaciones complejas (OneToMany, ManyToOne, OneToOne, ElementCollection)
- Mapeo de atributos como Map y List
- Métodos transient para cálculos en tiempo de ejecución
- Cascadas y eliminación en cascada (orphanRemoval)
- Relaciones bidireccionales con gestión automática

#### Integración Externa
- Consumo de la **D&D 5e API** (https://www.dnd5eapi.co)
- Rate Limiting inteligente con pausas entre peticiones
- Sincronización automática de:
  - 12 clases oficiales con progresión completa y subclases
  - 9 razas base con bonificadores
  - 13 backgrounds con características únicas
  - 18 habilidades del sistema D&D
  - 300+ hechizos con información completa
  - Slots de hechizos por clase y nivel
  - Competencias (proficiencies) de todo tipo
  - Idiomas disponibles
  - Condiciones del juego
  - Tipos de daño
  - Feats (dotes) del sistema

#### Lógica de Negocio
- Inicialización automática de habilidades y salvaciones al crear personaje
- Aplicación automática de competencias de background
- Cálculo dinámico de bonificadores (competencia + modificador de atributo)
- Sistema de tareas pendientes para decisiones durante subida de nivel
- Validaciones y gestión de errores

### Frontend

#### Arquitectura
- Patrón MVVM (Model-View-ViewModel) con Provider
- Separación clara entre lógica de presentación y lógica de negocio
- Gestión reactiva de estado con ChangeNotifier
- Inyección de dependencias con Provider

#### Servicios
- Cliente HTTP centralizado (ApiClient) para comunicación con el backend
- Servicio de autenticación con gestión de tokens JWT
- Servicio de personajes para operaciones CRUD
- Almacenamiento seguro de tokens en el dispositivo

#### Interfaz de Usuario
- Material Design 3
- Tema visual personalizado con paleta D&D (dark theme, dorado, carmesí)
- Tipografía temática con Cinzel (títulos) y Lato (texto)
- Navegación automática basada en estado de autenticación
- Manejo de estados de carga y errores
- Feedback visual con SnackBars y loaders

## Estructura del Proyecto

### Backend
```
src/main/java/
├── controllers/        # Controladores REST API (27 controladores)
│   ├── ActiveEffectController
│   ├── AuthController
│   ├── BackgroundController
│   ├── CharacterActiveEffectController
│   ├── CharacterClassResourceController
│   ├── CharacterConditionController
│   ├── CharacterDamageRelationController
│   ├── CharacterEquipmentController
│   ├── CharacterFeatController
│   ├── CharacterInventoryController
│   ├── CharacterLanguageController
│   ├── CharacterMoneyController
│   ├── CharacterProficiencyController
│   ├── CharacterSkillController
│   ├── ClassFeatureController
│   ├── ClassResourceController
│   ├── ConditionController
│   ├── DamageTypeController
│   ├── DndClassController
│   ├── FeatController
│   ├── LanguageController
│   ├── PlayerCharacterController
│   ├── ProficiencyController
│   ├── RaceController
│   ├── SpellController
│   ├── SubclassController
│   └── UserController
├── dto/               # Data Transfer Objects (30 DTOs)
│   ├── ActiveEffectDto
│   ├── AuthResponse
│   ├── BackgroundDto
│   ├── CharacterActiveEffectDto
│   ├── CharacterClassResourceDto
│   ├── CharacterConditionDto
│   ├── CharacterDamageRelationDto
│   ├── CharacterEquipmentDto
│   ├── CharacterFeatDto
│   ├── CharacterInventoryDto
│   ├── CharacterLanguageDto
│   ├── CharacterMoneyDto
│   ├── CharacterProficiencyDto
│   ├── CharacterSavingThrowDto
│   ├── CharacterSkillDto
│   ├── ClassResourceDto
│   ├── CreateUserRequest
│   ├── ConditionDto
│   ├── DamageTypeDto
│   ├── DndClassDto
│   ├── FeatDto
│   ├── LanguageDto
│   ├── LevelUpRequest
│   ├── LoginRequest
│   ├── PlayerCharacterDto
│   ├── ProficiencyDto
│   ├── RaceDto
│   ├── SpellDto
│   ├── SubclassDto
│   └── UserDto
├── entities/          # Entidades JPA (38 entidades)
│   ├── ActiveEffect
│   ├── Background
│   ├── CharacterActiveEffect
│   ├── CharacterClassResource
│   ├── CharacterCondition
│   ├── CharacterDamageRelation
│   ├── CharacterEquipment
│   ├── CharacterFeat
│   ├── CharacterFeature
│   ├── CharacterInventory
│   ├── CharacterLanguage
│   ├── CharacterMoney
│   ├── CharacterProficiency
│   ├── CharacterSavingThrow
│   ├── CharacterSkill
│   ├── CharacterSpell
│   ├── CharacterSpellSlot
│   ├── ClassFeature
│   ├── ClassLevelFeature
│   ├── ClassLevelProgression
│   ├── ClassResource
│   ├── Condition
│   ├── DamageType
│   ├── DndClass
│   ├── Feat
│   ├── Item
│   ├── Language
│   ├── LevelUpTask
│   ├── PendingTask
│   ├── PlayerCharacter
│   ├── Proficiency
│   ├── Race
│   ├── Skill
│   ├── Spell
│   ├── SpellSlotProgression
│   ├── Subclass
│   ├── SubclassFeature
│   └── User
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
├── services/          # Lógica de negocio (26 servicios)
│   ├── ActiveEffectService
│   ├── BackgroundService
│   ├── CharacterActiveEffectService
│   ├── CharacterClassResourceService
│   ├── CharacterConditionService
│   ├── CharacterDamageRelationService
│   ├── CharacterEquipmentService
│   ├── CharacterFeatService
│   ├── CharacterInventoryService
│   ├── CharacterLanguageService
│   ├── CharacterMoneyService
│   ├── CharacterProficiencyService
│   ├── CharacterSkillService
│   ├── ClassFeatureService
│   ├── ClassResourceService
│   ├── ConditionService
│   ├── DamageTypeService
│   ├── DndClassService
│   ├── FeatService
│   ├── LanguageService
│   ├── PlayerCharacterService
│   ├── ProficiencyService
│   ├── RaceService
│   ├── SpellService
│   ├── SubclassFeatureService
│   └── SubclassService
├── security/          # Autenticación y autorización JWT
│   ├── CustomUserDetailsService
│   ├── JwtAuthenticationFilter
│   ├── JwtUtil
│   └── SecurityConfig
└── sync/             # Servicios de sincronización (14 servicios)
    ├── ApiRateLimiter
    ├── BackgroundSyncService
    ├── BaseSyncService
    ├── ConditionSyncService
    ├── DamageTypeSyncService
    ├── DndClassSyncService
    ├── FeatSyncService
    ├── LanguageSyncService
    ├── ProficiencySyncService
    ├── RaceSyncService
    ├── SkillSyncService
    ├── SpellSlotSyncService
    ├── SpellSyncService
    ├── SubclassSyncService
    └── SyncController
```

### Frontend (Flutter)
```
frontend/lib/
├── config/            # Configuración global
│   ├── api_config.dart
│   └── app_theme.dart
├── models/            # Modelos de datos
│   ├── auth/
│   │   ├── auth_response.dart
│   │   └── login_request.dart
│   ├── character/
│   │   ├── player_character_summary.dart
│   │   └── player_character.dart
│   └── wizard/
│       ├── background_option.dart
│       ├── class_option.dart
│       └── race_option.dart
├── services/          # Servicios de API y almacenamiento
│   ├── auth/
│   │   └── auth_service.dart
│   ├── characters/
│   │   └── character_service.dart
│   ├── http/
│   │   └── api_client.dart
│   ├── storage/
│   │   └── token_storage.dart
│   └── wizard/
│       └── wizard_reference_service.dart
├── viewmodels/        # Lógica de presentación (MVVM)
│   ├── auth/
│   │   └── auth_viewmodel.dart
│   ├── characters/
│   │   ├── character_list_viewmodel.dart
│   │   └── character_sheet_viewmodel.dart
│   └── wizard/
│       └── character_creator_viewmodel.dart
├── views/             # Pantallas y widgets
│   ├── screens/
│   │   ├── dashboard_screen.dart
│   │   ├── login_screen.dart
│   │   ├── sheet/
│   │   │   ├── character_sheet_screen.dart
│   │   │   └── tabs/
│   │   │       
│   │   └── wizard/
│   │       ├── character_creator_screen.dart
│   │       └── steps/
│   │           ├── step_race.dart
│   │           ├── step_class.dart
│   │           ├── step_ability_scores.dart
│   │           └── step_background.dart
│   └── widgets/
│       └── character_card.dart
└── main.dart          # Punto de entrada de la aplicación
```

## Características Principales

### Gestión de Personajes
- Crear, leer, actualizar y eliminar personajes
- Asignación de clase, subclase, raza y background
- Gestión de atributos (STR, DEX, CON, INT, WIS, CHA)
- Gestión de puntos de vida (actuales, máximos y temporales)
- Cálculo automático de bono de competencia según nivel
- Sistema de death saves (salvaciones contra muerte)
- Inspiración del DM
- Sistema de experiencia (XP) y nivel
- Rasgos físicos (edad, altura, peso, ojos, piel, pelo, apariencia)
- Rasgos de personalidad, ideales, vínculos y defectos
- Historia del personaje, aliados y tesoro
- Percepción, investigación e intuición pasivas
- Cálculo automático de CA (Armor Class)
- Cálculo automático de velocidad
- Bonos de iniciativa y armadura natural
- Modificadores de velocidad

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

### Sistema de Inventario
- Gestión completa de objetos del personaje
- Cantidades y control de peso
- Vinculación con catálogo de items
- Sistema de equipamiento (attuned y equipped)
- Notas personalizadas por objeto
- Cálculo automático de peso total
- Límite de 3 objetos con attunement

### Sistema de Equipamiento
- Slots dedicados para cada parte del cuerpo
- Mano principal y mano secundaria
- Armadura, casco, guantes, botas
- Capa, amuleto, dos anillos, cinturón
- Relación OneToOne con el personaje

### Sistema de Dinero
- Gestión de las 5 monedas de D&D (platino, oro, electrum, plata, cobre)
- Conversión automática a piezas de oro
- Cálculo de peso del dinero (50 monedas = 1 libra)
- Métodos para añadir y gastar dinero

### Sistema de Idiomas
- Asignación de idiomas al personaje
- Gestión de competencias en idiomas
- Sincronización desde D&D 5e API

### Sistema de Competencias (Proficiencies)
- Gestión de competencias en armas, armaduras y herramientas
- Vinculación con personajes
- Catálogo completo de proficiencies desde la API

### Sistema de Feats (Dotes)
- Gestión de feats del personaje
- Catálogo de feats disponibles
- Sincronización desde D&D 5e API
- Requisitos y prerrequisitos

### Sistema de Condiciones
- Gestión de condiciones activas en el personaje
- Duración de condiciones (temporal o permanente)
- Catálogo de condiciones de D&D 5e
- Descripción y efectos de cada condición

### Sistema de Efectos Activos
- Gestión de efectos mágicos activos
- Duración en turnos o rounds
- Modificadores a atributos y estadísticas
- Asociación con hechizos o habilidades

### Sistema de Resistencias y Vulnerabilidades
- Gestión de resistencias a tipos de daño
- Gestión de vulnerabilidades a tipos de daño
- Gestión de inmunidades
- Catálogo de tipos de daño de D&D 5e

### Sistema de Recursos de Clase
- Gestión de recursos específicos de clase (Ki, Rage, Sorcery Points, etc.)
- Cantidad actual y máxima por recurso
- Recuperación en descansos cortos o largos
- Vinculación con nivel y clase del personaje

### Sistema de Subclases
- Catálogo de subclases por clase
- Asignación de subclase al personaje
- Características específicas de subclase por nivel
- Sincronización desde D&D 5e API

### Sistema de Descansos
- Descanso corto (Short Rest):
  - Uso de Hit Dice para recuperar HP
  - Recuperación de recursos de clase específicos
  - Recuperación de spell slots para Warlocks
- Descanso largo (Long Rest):
  - Restauración completa de HP
  - Restauración de todos los spell slots
  - Recuperación de Hit Dice (mínimo la mitad)
  - Reset de death saves
  - Eliminación de HP temporal

## Requisitos Previos

### Backend
- **Java 21** o superior
- **Maven 3.6+**
- **Docker y Docker Compose** (para MySQL)
- IDE compatible con Java (IntelliJ IDEA, Eclipse, VS Code)

### Frontend (Opcional)
- **Flutter 3.x** o superior
- **Dart SDK 3.x**
- **Android SDK** (para desarrollo Android)
- **Xcode** (para desarrollo iOS, solo macOS)
- IDE compatible con Flutter (VS Code, Android Studio, IntelliJ IDEA)

## Configuración

### Opción 1: Configuración Rápida con Docker (Recomendado)

1. **Clonar el repositorio**
```bash
git clone <url-repositorio>
cd GestorPersonajesDND
```

2. **Iniciar MySQL con Docker**
```bash
# Iniciar solo MySQL
docker compose up -d mysql-db

# O usar el script de ejecución que inicia todo automáticamente
./run.sh
```

3. **Ejecutar la aplicación**
```bash
# Opción A: Usar el script
./run.sh

# Opción B: Con Maven directamente
mvn spring-boot:run

# Opción C: Desde tu IDE
# Ejecuta la clase Main.java
```

La aplicación estará disponible en `http://localhost:8081`

### Opción 2: Configuración Manual

1. **Instalar y configurar MySQL manualmente**

Crear una base de datos MySQL:
```sql
CREATE DATABASE dnd_character_manager CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'dnd_user'@'localhost' IDENTIFIED BY 'dnd_password';
GRANT ALL PRIVILEGES ON dnd_character_manager.* TO 'dnd_user'@'localhost';
FLUSH PRIVILEGES;
```

2. **Configurar credenciales en `application.properties`**

```properties
spring.datasource.url=jdbc:mysql://localhost:3306/dnd_character_manager?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC
spring.datasource.username=dnd_user
spring.datasource.password=dnd_password
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true
```

3. **Inicializar la base de datos** (Opcional - Hibernate lo hace automáticamente)

Si prefieres usar el script SQL incluido:
```bash
mysql -u dnd_user -p dnd_character_manager < init-db.sql
```

4. **Compilar y ejecutar**
```bash
mvn clean install
mvn spring-boot:run
```

### Ejecutar el Frontend (Flutter)

1. **Navegar al directorio del frontend**
```bash
cd frontend
```

2. **Instalar dependencias**
```bash
flutter pub get
```

3. **Configurar la URL del backend**

Editar el archivo de configuración del API client para apuntar al backend (por defecto: `http://localhost:8081`).

4. **Ejecutar la aplicación**
```bash
# En un emulador o dispositivo conectado
flutter run

# Especificar dispositivo
flutter devices  # Ver dispositivos disponibles
flutter run -d <device_id>
```

5. **Construir APK para Android (Opcional)**
```bash
flutter build apk --release
```

## Docker

El proyecto incluye configuración de Docker para facilitar el desarrollo:

### Archivos Docker
- `docker-compose.yml` - Configuración de MySQL
- `Dockerfile` - Imagen de la aplicación (opcional)
- `init-db.sql` - Script de inicialización de base de datos
- `run.sh` - Script para iniciar MySQL y la aplicación

### Comandos Docker útiles
```bash
# Iniciar solo MySQL
docker compose up -d mysql-db

# Ver logs de MySQL
docker compose logs -f mysql-db

# Detener MySQL
docker compose stop mysql-db

# Ejecutar script SQL en el contenedor
docker exec -i dnd-mysql mysql -u dnd_user -pdnd_password dnd_character_manager < mi_script.sql
```

### Conectar con DBeaver o MySQL Workbench
- **Host:** `localhost`
- **Port:** `3306`
- **Database:** `dnd_character_manager`
- **Username:** `dnd_user`
- **Password:** `dnd_password`

Nota: En DBeaver, añade en "Driver properties":
- `allowPublicKeyRetrieval` = `true`
- `useSSL` = `false`

## Documentación Adicional

- [DOCKER.md](DOCKER.md) - Guía completa de uso con Docker
- [init-db.sql](init-db.sql) - Script de base de datos con todas las tablas

## API Endpoints de Autenticación y Usuarios

### Autenticación
- `POST /api/auth/login` - Iniciar sesión y obtener token JWT

### Administración de Usuarios
- `GET /api/admin/users` - Listar todos los usuarios
- `GET /api/admin/users/{id}` - Obtener usuario por ID
- `POST /api/admin/users` - Crear nuevo usuario
- `DELETE /api/admin/users/{id}` - Eliminar usuario

## 🔧 Sincronización de Datos

### Sincronizar datos iniciales (Opcional pero recomendado)

Una vez la aplicación esté corriendo, sincronizar todos los datos desde la D&D 5e API:

```bash
curl -X POST http://localhost:8081/api/sync/all
```

O sincronizar elementos individuales:
```bash
curl -X POST http://localhost:8081/api/sync/skills
curl -X POST http://localhost:8081/api/sync/backgrounds
curl -X POST http://localhost:8081/api/sync/races
curl -X POST http://localhost:8081/api/sync/classes
curl -X POST http://localhost:8081/api/sync/spells
```

**Nota:** El endpoint `/sync/all` incluye rate limiting automático para evitar sobrecargar la API externa.

## API Endpoints

### Personajes
- `GET /api/characters` - Listar todos los personajes
- `GET /api/characters/{id}` - Obtener un personaje con todos sus detalles
- `POST /api/characters` - Crear nuevo personaje
- `PUT /api/characters/{id}` - Actualizar personaje
- `DELETE /api/characters/{id}` - Eliminar personaje
- `POST /api/characters/{id}/level-up` - Subir de nivel
- `POST /api/characters/{id}/long-rest` - Realizar descanso largo
- `POST /api/characters/{id}/short-rest` - Realizar descanso corto
- `POST /api/characters/{id}/damage` - Aplicar daño al personaje
- `POST /api/characters/{id}/heal` - Curar al personaje
- `POST /api/characters/{id}/temp-hp` - Añadir HP temporal
- `POST /api/characters/{id}/death-save` - Realizar tirada de salvación contra muerte
- `POST /api/characters/{id}/subclass/{subclassId}` - Asignar subclase

### Hechizos del Personaje
- `GET /api/characters/{id}/spells` - Obtener hechizos del personaje
- `POST /api/characters/{id}/spells/{spellId}` - Asignar hechizo a personaje
- `DELETE /api/characters/{id}/spells/{spellId}` - Eliminar hechizo de personaje
- `POST /api/characters/{id}/spell-slots/restore` - Restaurar slots de hechizos
- `POST /api/characters/{id}/spell-slots/use` - Usar slot de hechizo
- `POST /api/characters/{id}/cast-spell` - Lanzar hechizo

### Habilidades y Salvaciones
- `GET /api/character-skills/character/{characterId}` - Obtener habilidades del personaje
- `PUT /api/character-skills/{skillId}/proficiency` - Establecer competencia en habilidad
- `PUT /api/character-skills/{skillId}/expertise` - Establecer expertise en habilidad
- `GET /api/characters/{characterId}/saving-throws` - Obtener salvaciones del personaje

### Inventario
- `GET /api/character-inventory/character/{characterId}` - Obtener inventario del personaje
- `GET /api/character-inventory/character/{characterId}/weight` - Obtener peso total del inventario
- `POST /api/character-inventory/add` - Añadir objeto al inventario
- `PUT /api/character-inventory/{inventoryId}/quantity` - Actualizar cantidad de objeto
- `DELETE /api/character-inventory/character/{characterId}/item/{itemId}` - Eliminar objeto del inventario
- `PUT /api/character-inventory/{inventoryId}/toggle-attuned` - Activar/desactivar attunement

### Equipamiento
- `GET /api/character-equipment/character/{characterId}` - Obtener equipamiento del personaje
- `PUT /api/character-equipment/character/{characterId}/equip` - Equipar objeto en slot específico
- `DELETE /api/character-equipment/character/{characterId}/unequip/{slot}` - Desequipar objeto de slot

### Dinero
- `GET /api/character-money/character/{characterId}` - Obtener dinero del personaje
- `POST /api/character-money/character/{characterId}/add` - Añadir dinero
- `POST /api/character-money/character/{characterId}/spend` - Gastar dinero
- `GET /api/character-money/character/{characterId}/total-gold` - Obtener total en piezas de oro

### Idiomas
- `GET /api/character-languages/character/{characterId}` - Obtener idiomas del personaje
- `POST /api/character-languages` - Añadir idioma al personaje
- `DELETE /api/character-languages/{id}` - Eliminar idioma del personaje

### Competencias (Proficiencies)
- `GET /api/character-proficiencies/character/{characterId}` - Obtener competencias del personaje
- `POST /api/character-proficiencies` - Añadir competencia al personaje
- `DELETE /api/character-proficiencies/{id}` - Eliminar competencia del personaje

### Feats (Dotes)
- `GET /api/character-feats/character/{characterId}` - Obtener feats del personaje
- `POST /api/character-feats` - Asignar feat al personaje
- `DELETE /api/character-feats/{id}` - Eliminar feat del personaje

### Condiciones
- `GET /api/character-conditions/character/{characterId}` - Obtener condiciones activas del personaje
- `POST /api/character-conditions` - Aplicar condición al personaje
- `DELETE /api/character-conditions/{id}` - Eliminar condición del personaje

### Efectos Activos
- `GET /api/character-active-effects/character/{characterId}` - Obtener efectos activos del personaje
- `POST /api/character-active-effects` - Añadir efecto activo al personaje
- `DELETE /api/character-active-effects/{id}` - Eliminar efecto activo
- `PUT /api/character-active-effects/{id}/decrement-duration` - Decrementar duración de efecto

### Resistencias y Vulnerabilidades
- `GET /api/character-damage-relations/character/{characterId}` - Obtener relaciones con tipos de daño
- `POST /api/character-damage-relations` - Añadir resistencia/vulnerabilidad
- `DELETE /api/character-damage-relations/{id}` - Eliminar resistencia/vulnerabilidad

### Recursos de Clase
- `GET /api/character-class-resources/character/{characterId}` - Obtener recursos de clase del personaje
- `POST /api/character-class-resources/spend` - Gastar recurso de clase
- `POST /api/character-class-resources/restore` - Restaurar recurso de clase
- `POST /api/character-class-resources/character/{characterId}/short-rest` - Restaurar recursos en descanso corto
- `POST /api/character-class-resources/character/{characterId}/long-rest` - Restaurar recursos en descanso largo

### Clases
- `GET /api/classes` - Listar todas las clases
- `GET /api/classes/{id}` - Obtener una clase con detalles
- `GET /api/classes/index/{indexName}` - Obtener clase por nombre índice

### Subclases
- `GET /api/subclasses` - Listar todas las subclases
- `GET /api/subclasses/{id}` - Obtener una subclase con detalles
- `GET /api/subclasses/class/{classId}` - Obtener subclases de una clase

### Características de Clase
- `GET /api/class-features` - Listar todas las características de clase
- `GET /api/class-features/{id}` - Obtener característica por ID
- `GET /api/class-features/class/{classId}` - Características por clase
- `GET /api/class-features/class/{classId}/level/{level}` - Características por clase y nivel

### Recursos de Clase (Catálogo)
- `GET /api/class-resources` - Listar todos los recursos de clase
- `GET /api/class-resources/{id}` - Obtener recurso por ID
- `GET /api/class-resources/class/{classId}` - Recursos por clase

### Razas
- `GET /api/races` - Listar todas las razas
- `GET /api/races/{id}` - Obtener una raza con detalles

### Backgrounds
- `GET /api/backgrounds` - Listar todos los backgrounds
- `GET /api/backgrounds/{id}` - Obtener un background con detalles

### Hechizos (Catálogo)
- `GET /api/spells` - Listar todos los hechizos
- `GET /api/spells/{id}` - Obtener un hechizo con detalles
- `GET /api/spells/class/{classIndex}` - Hechizos disponibles para una clase
- `GET /api/spells/level/{level}` - Hechizos por nivel

### Idiomas (Catálogo)
- `GET /api/languages` - Listar todos los idiomas
- `GET /api/languages/{id}` - Obtener idioma por ID

### Competencias (Catálogo)
- `GET /api/proficiencies` - Listar todas las competencias
- `GET /api/proficiencies/{id}` - Obtener competencia por ID
- `GET /api/proficiencies/type/{type}` - Competencias por tipo

### Feats (Catálogo)
- `GET /api/feats` - Listar todos los feats
- `GET /api/feats/{id}` - Obtener feat por ID

### Condiciones (Catálogo)
- `GET /api/conditions` - Listar todas las condiciones
- `GET /api/conditions/{id}` - Obtener condición por ID

### Efectos Activos (Catálogo)
- `GET /api/active-effects` - Listar todos los efectos
- `GET /api/active-effects/{id}` - Obtener efecto por ID

### Tipos de Daño
- `GET /api/damage-types` - Listar todos los tipos de daño
- `GET /api/damage-types/{id}` - Obtener tipo de daño por ID

### Sincronización (Admin)
- `POST /api/sync/skills` - Sincronizar habilidades desde D&D 5e API
- `POST /api/sync/backgrounds` - Sincronizar backgrounds
- `POST /api/sync/races` - Sincronizar razas
- `POST /api/sync/classes` - Sincronizar clases
- `POST /api/sync/subclasses` - Sincronizar subclases
- `POST /api/sync/spells` - Sincronizar hechizos
- `POST /api/sync/spell-slots/{classIndex}` - Sincronizar slots de una clase
- `POST /api/sync/languages` - Sincronizar idiomas
- `POST /api/sync/proficiencies` - Sincronizar competencias
- `POST /api/sync/feats` - Sincronizar feats
- `POST /api/sync/conditions` - Sincronizar condiciones
- `POST /api/sync/damage-types` - Sincronizar tipos de daño
- `POST /api/sync/all` - Sincronización completa de todos los datos

## Ejemplos de Uso

### Crear un nuevo personaje

```bash
curl -X POST http://localhost:8081/api/characters \
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
curl http://localhost:8081/api/characters/1/skills
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
curl -X POST http://localhost:8081/api/characters/1/level-up \
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

## Estado del Proyecto

### Backend - Implementado y Operativo
- Sistema completo de personajes con todos los atributos
- Gestión de clases, subclases, razas y backgrounds
- Sistema de habilidades y salvaciones
- Sistema de hechizos y slots con gestión de casting
- Sincronización completa con D&D 5e API
- Rate limiting en peticiones API
- Subida de nivel con características automáticas
- Cálculo automático de bonificadores y estadísticas
- Sistema de inventario completo con peso y gestión
- Sistema de equipamiento con slots específicos
- Sistema de dinero con las 5 monedas
- Gestión de idiomas del personaje
- Gestión de competencias (proficiencies)
- Sistema de feats (dotes)
- Sistema de condiciones y efectos activos
- Resistencias y vulnerabilidades a tipos de daño
- Recursos de clase (Ki, Rage, Sorcery Points, etc.)
- Sistema de descansos cortos y largos
- Sistema de death saves y HP temporal
- Cálculos automáticos de CA, velocidad, iniciativa
- Percepción pasiva, investigación e intuición
- Autenticación JWT con Spring Security
- Gestión de usuarios del sistema (admin)

### Frontend Mobile - En Desarrollo
- Sistema de autenticación con login y gestión de tokens
- Pantalla de dashboard con lista de personajes
- Cliente HTTP para consumo de API REST
- Arquitectura MVVM con Provider para gestión de estado
- Modelos de datos (personajes, autenticación)
- Servicios para personajes y autenticación
- Almacenamiento persistente de tokens
- Tema visual personalizado con paleta D&D (dark theme, Cinzel + Lato)
- Configuración centralizada de API (ApiConfig)
- Widget de tarjeta de personaje con barra de HP y estadísticas
- Wizard de creación de personajes en 4 pasos (raza, clase, puntuaciones de habilidad, background)
- Modelo completo de personaje (PlayerCharacter) para la ficha

### Planificado
- Gestión de hechizos e inventario desde la app
- Vinculación de personajes a usuarios (privacidad por cuenta)


## 👤 Autor

Alexandre Barbeito
