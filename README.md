# DungeonScroll 

Sistema de gestión de personajes para Dungeons & Dragons 5e, desarrollado con Spring Boot, MySQL y Flutter.

> Estado del Proyecto: El backend está completo con todas las funcionalidades implementadas y operativas, incluyendo las mecánicas de subclases, hechizos de subclase y proficiencias de subclase, bonificadores mecánicos automáticos (recursos de clase/raza, bonificadores numéricos, hechizos y competencias otorgados), y un panel de administración para crear contenido homebrew (clases, subclases, razas, subrazas, items, backgrounds, feats y sus features/rasgos) que se integra con esas mismas mecánicas sin necesitar código nuevo. El contenido oficial se sincroniza tanto desde la D&D 5e API pública como desde Aurora (fuente adicional con contenido de expansiones no cubierto por la API pública). El frontend está completo para esta versión (lista para presentar), con el flujo de creación de personajes (7 pasos), modo de edición, subida de nivel, pantalla de tareas pendientes, panel de administración y la ficha de personaje interactiva. Hay funcionalidades implementadas en el backend (slots de equipamiento por parte del cuerpo, encumbrance, sistema XP) que están pendientes de integración visual en el frontend para una versión futura.

## Descripción

Sistema completo para gestionar personajes de D&D 5e:

- Backend REST API con Spring Boot que gestiona toda la lógica de negocio
- Aplicación Flutter multiplataforma (web, Android, iOS) para gestionar personajes
- Base de datos MySQL con todas las entidades del sistema D&D 5e

### Funcionalidades del Backend

- Gestión completa de personajes (atributos, puntos de vida, nivel, experiencia)
- Sistema de clases, subclases, razas y backgrounds
- Sistema de habilidades (skills) y salvaciones (saving throws)
- Gestión de hechizos y slots de hechizos por nivel
- Sistema de subida de nivel automatizado
- Progresión de características por nivel y clase
- Sistema de inventario, equipamiento y dinero
- Catálogo de items sincronizado desde la D&D 5e API y desde Aurora (armas, armaduras, herramientas, monturas, etc.)
- Gestión de idiomas y competencias (proficiencies)
- Sistema de feats (dotes) y recursos de clase
- Recursos de raza (paralelos a los de clase) para rasgos raciales con usos limitados
- Hechizos de subclase (Domain/Oath/Circle spells) aplicados automáticamente al asignar subclase
- Proficiencias de subclase aplicadas automáticamente al asignar subclase
- Capa de mecánicas reutilizable por tipo de efecto (Resource Pool, Numeric Bonus, Grant Spell, Grant Proficiency) para features de clase, subclase y rasgos raciales
- Bonificadores mecánicos automáticos de items (CA, bono de ataque, daño, salvaciones, override de característica) al equipar/sintonizar
- Gestión de condiciones y efectos activos
- Resistencias y vulnerabilidades a tipos de daño
- Sistema de descansos (cortos y largos)
- Sincronización de datos desde la D&D 5e API pública y desde Aurora (contenido de expansiones no cubierto por la API pública)
- Panel de administración para crear contenido homebrew (clases, subclases, razas, subrazas, items, backgrounds, feats y sus features/rasgos) con mecánica real, no solo texto
- Rate limiting para peticiones API
- Sistema de autenticación JWT con Spring Security
- Gestión de usuarios del sistema (incluye cambio de nombre de usuario y contraseña propios)

## Tecnologías

### Backend
- **Java 21**
- Spring Boot 3.2.5
- **Spring Data JPA** - Persistencia de datos
- **MySQL 8.0** - Base de datos relacional (ejecutándose en Docker)
- **Maven** - Gestión de dependencias
- **RestTemplate** - Cliente HTTP para integración con D&D 5e API
- **Hibernate** - ORM (Object-Relational Mapping)
- **Docker & Docker Compose** - Contenedorización de MySQL y la aplicación backend
- **Spring Security** - Autenticación y autorización
- **JWT (jjwt)** - Tokens de autenticación

### Frontend
- **Flutter 3.x** - Framework multiplataforma para Android/iOS
- **Dart** - Lenguaje de programación
- **Provider** - Gestión de estado
- **HTTP** - Cliente HTTP para consumir la API REST
- **google_fonts** - Tipografía LibreBaskerville y Lato
- **font_awesome_flutter** - Iconografía temática

## Características Técnicas

### Backend

#### Modelo de Datos
- 51 entidades JPA con relaciones complejas (OneToMany, ManyToOne, OneToOne, ElementCollection)
- Mapeo de atributos como Map y List
- Métodos transient para cálculos en tiempo de ejecución
- Cascadas y eliminación en cascada (orphanRemoval)
- Relaciones bidireccionales con gestión automática

#### Integración Externa
Dos fuentes de contenido oficial, ambas vía sincronización (no solo scripts manuales):

- **D&D 5e API** (https://www.dnd5eapi.co) — cobertura base del PHB:
  - Rate Limiting inteligente con pausas entre peticiones
  - 12 clases oficiales con progresión completa y subclases
  - 9 razas base con bonificadores y sus subrazas (subraces)
  - 13 backgrounds con características únicas
  - 18 habilidades del sistema D&D
  - 300+ hechizos con información completa
  - Slots de hechizos por clase y nivel
  - 237 items de equipo (armas, armaduras, herramientas, monturas y vehículos)
  - Competencias (proficiencies) de todo tipo, idiomas, condiciones y tipos de daño
- **Aurora** — segunda fuente con contenido de expansiones (XGtE, TCE, MToF, ERLW, SCAG, VRGtR, FToD, AI y más) no cubierto por la API pública: clases/subclases, razas/subrazas, items (con bonificadores mecánicos ya estructurados), hechizos y feats. Se sincroniza en su propio flujo (`/api/sync/aurora/*`, ver más abajo) y se mapea a las mismas entidades que el resto del contenido.

> **Nota sobre datos hardcodeados:** Parte del contenido no estaba disponible en ninguna de las dos fuentes anteriores y fue generado/insertado manualmente mediante scripts SQL en `backend/scripts/` (patch/seed scripts, distintos de los dumps de `backend/backups/`):
> - 42 feats del Player's Handbook (con descripciones completas y prerrequisitos)
> - 28+ subclases PHB con sus características por nivel (subclass features)
> - Subraces con sus bonificadores raciales
> - Hechizos de subclase (Domain/Oath/Circle spells) con su relación a cada subclase
> - Infraestructura de recursos de clase/raza para features con usos limitados que no llegan estructuradas desde ninguna fuente (Rage, Ki, Channel Divinity, runas de Rune Knight, etc.)

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
- Tipografía temática con LibreBaskerville (títulos) y Lato (texto)
- Navegación automática basada en estado de autenticación
- Manejo de estados de carga y errores
- Feedback visual con SnackBars y loaders
- Manejo de errores de red y autenticación con mensajes descriptivos al usuario
- Ficha de personaje interactiva con tabs navegables por swipe
- Header fijo con AC, Initiative y HP interactivo (modal Manage HP)
- Tab Abilities con grid de atributos, saving throws y senses
- Tab Skills con tabla completa de las 18 habilidades
- Tab Combat con secciones de acciones, acciones de bonus y reacciones siempre visibles
- Tab Spells con filtro por nivel, modificadores, slots interactivos (usar/restaurar) y detalle de hechizo con botón de lanzamiento
- Tab Features con características de clase, subclase y rasgos raciales agrupados, recursos con contador de usos (clase y raza) y badges de relevancia en combate
- Tab Inventory con gestión de ítems, peso total, cantidades, attunement (normalmente 3 objetos, ampliable por feats/clase) y bonificadores mecánicos aplicados automáticamente al equipar
- Tab Info con información narrativa del personaje (rasgos físicos, personalidad, ideales, vínculos y defectos)
- Paso "Content Sources" en el wizard de creación/edición: elegir qué sourcebooks están disponibles al elegir raza, clase, background, etc.
- Panel de administración con gestión de usuarios, creación de contenido homebrew (clase/subclase/raza/subraza/item/background/feat) y creación de features/rasgos adaptada al tipo de mecánica elegido

## Estructura del Proyecto

### Backend
```
backend/
├── src/main/java/
│   ├── com/                 # Punto de entrada (Main)
│   ├── config/              # Configuración de beans e inicialización
│   ├── controllers/         # Endpoints REST
│   │   ├── AuthController
│   │   ├── PlayerCharacterController
│   │   ├── PendingTaskController
│   │   ├── SubraceController
│   │   ├── UserController
│   │   ├── CharacterRaceResourceController
│   │   └── ... (32 controllers en total)
│   ├── dto/                 # Data Transfer Objects
│   ├── entities/            # Entidades JPA
│   ├── enumeration/         # Enumeraciones del dominio
│   ├── repositories/        # Repositorios Spring Data
│   ├── security/            # JWT, filtros y seguridad HTTP
│   ├── services/            # Lógica de negocio
│   └── sync/                # Sincronización con la D&D 5e API pública
│       └── aurora/          # Mappers de sincronización desde Aurora (clases, subclases, razas, items, hechizos, feats)
├── src/main/resources/
│   └── application.properties
├── docker-compose.yml
├── Dockerfile
├── init-db.sql
├── .env.example
└── mysql-data/
```

### Frontend (Flutter)
```
frontend/lib/
├── config/                 # api_config, tema, iconos, opciones D&D
├── models/                 # Modelos de auth, personaje, inventario y wizard
├── services/               # Cliente HTTP, auth, personajes, inventario, hechizos, feats, wizard
├── viewmodels/             # MVVM con Provider
├── views/
│   ├── screens/
│   │   ├── login_screen.dart
│   │   ├── dashboard_screen.dart
│   │   ├── admin/
│   │   │   ├── admin_panel_screen.dart       # Gestión de usuarios + accesos a los dos siguientes
│   │   │   ├── create_content_screen.dart    # Crear clase/subclase/raza/subraza/item/background/feat
│   │   │   └── create_feature_screen.dart    # Crear feature/rasgo adaptado al tipo de mecánica
│   │   ├── sheet/
│   │   │   ├── character_sheet_screen.dart
│   │   │   ├── pending_tasks_screen.dart
│   │   │   └── tabs/
│   │   │       ├── tab_abilities.dart
│   │   │       ├── tab_skills.dart
│   │   │       ├── tab_combat.dart
│   │   │       ├── tab_spells.dart
│   │   │       ├── tab_features.dart
│   │   │       ├── tab_inventory.dart
│   │   │       └── tab_info.dart
│   │   └── wizard/
│   │       ├── character_creator_screen.dart
│   │       ├── edit_character_screen.dart
│   │       ├── level_up_screen.dart
│   │       ├── class_detail_screen.dart
│   │       ├── class_options_screen.dart
│   │       └── steps/
│   │           ├── step_preferences.dart
│   │           ├── step_class.dart
│   │           ├── step_background.dart
│   │           ├── step_race.dart
│   │           ├── step_ability_scores.dart
│   │           ├── step_spells.dart
│   │           └── step_equipment.dart
│   └── widgets/
└── main.dart
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
  - Invocaciones (Eldritch Invocations)
  - Metamagia
  - Características de clase generales
  - Elecciones de Battle Master (maneuvers)
  - Elecciones de Rune Knight (runes)
  - Elecciones de Totem Warrior (totems)
  - Elecciones de Hunter Ranger
  - Elecciones de Monk 4 Elements (disciplines)
  - Infusiones de Artificer (Infuse Item)
- Las tareas de "elige N" que se repiten en varios hitos de nivel (maniobras, runas, disciplinas elementales, infusiones, invocaciones, metamagia) comparten un mismo pool de opciones — las ya elegidas en un hito anterior aparecen deshabilitadas para no poder repetirlas

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
- Límite de objetos con attunement (normalmente 3, ampliable por feats o rasgos de clase como Artificer)
- Bonificadores mecánicos de items (CA, bono de ataque, daño, salvaciones, override de característica) aplicados automáticamente al equipar/sintonizar
- Para items genéricos sin arma base propia (plantillas mágicas), selector para elegir el arma real de la que hereda daño/alcance/propiedades

### Sistema de Equipamiento
- Slots dedicados para cada parte del cuerpo implementados en el **backend**: mano principal, mano secundaria, armadura, casco, guantes, botas, capa, amuleto, dos anillos y cinturón
- API REST completa para equipar/desequipar items por slot
- Relación OneToOne con el personaje
- **Nota:** La interfaz de gestión de slots por parte del cuerpo no está implementada en el frontend en esta versión (pendiente para versión futura)

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
- Catálogo de feats disponibles, sincronizado desde la D&D 5e API y desde Aurora
- Requisitos y prerrequisitos
- Efectos mecánicos aplicados automáticamente al asignar el feat (bono numérico a característica, hechizos otorgados, elección de N competencias)

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

### Sistema de Recursos de Clase y Raza
- Gestión de recursos específicos de clase (Ki, Rage, Sorcery Points, runas de Rune Knight, etc.) y de raza (rasgos raciales con usos limitados, misma infraestructura)
- Cantidad actual y máxima por recurso
- Recuperación en descansos cortos o largos
- Vinculación con nivel y clase del personaje, o con raza/subraza en el caso de recursos raciales

### Sistema de Subclases
- Catálogo de subclases por clase, sincronizado desde la D&D 5e API y desde Aurora
- Asignación de subclase al personaje
- Características específicas de subclase por nivel
- Hechizos de subclase (Domain/Oath/Circle spells) añadidos automáticamente al personaje al escoger subclase
- Proficiencias extra de subclase (armaduras, armas) aplicadas automáticamente al escoger subclase

### Sistema de Creación de Contenido (Admin)
- Panel de administración para crear contenido homebrew sin depender de la sync ni de scripts SQL manuales: clases, subclases, razas, subrazas, items, backgrounds y feats
- Creación de features de clase, subclase y rasgos raciales adaptada al tipo de mecánica elegido (Resource Pool, Numeric Bonus, Grant Spell, Grant Proficiency) — el formulario solo pide los campos que ese tipo necesita, y la app aplica el efecto igual que con contenido oficial
- Creación de items con bonificadores mecánicos reales (no solo texto), incluyendo copiar los datos de un arma existente del catálogo como base
- Endpoints de creación protegidos por rol ADMIN

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
```

3. **Ejecutar la aplicación**
```bash
# Opción A: Con Maven directamente
mvn spring-boot:run

# Opción B: Desde tu IDE
# Ejecuta la clase Main.java
```

La aplicación estará disponible en `http://localhost:8081`

4. **Variables de entorno requeridas**

Antes de arrancar con Docker Compose, crea `backend/.env` a partir de `backend/.env.example` y completa:

- `MYSQL_ROOT_PASSWORD`
- `MYSQL_USER`
- `MYSQL_PASSWORD`
- `SPRING_DATASOURCE_USERNAME`
- `SPRING_DATASOURCE_PASSWORD`
- `JWT_SECRET`
- `ADMIN_INITIAL_PASSWORD`

Nota: en este proyecto, `SPRING_DATASOURCE_USERNAME` y `SPRING_DATASOURCE_PASSWORD` normalmente coinciden con `MYSQL_USER` y `MYSQL_PASSWORD`.

### Opción 2: Configuración Manual

1. **Instalar y configurar MySQL manualmente**

Crear una base de datos MySQL:
```sql
CREATE DATABASE dnd_character_manager CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'dnd_user'@'localhost' IDENTIFIED BY 'dnd_password';
GRANT ALL PRIVILEGES ON dnd_character_manager.* TO 'dnd_user'@'localhost';
FLUSH PRIVILEGES;
```

2. **Configurar variables de entorno para Spring Boot**

```properties
spring.datasource.url=jdbc:mysql://localhost:3306/dnd_character_manager?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC
spring.datasource.username=${SPRING_DATASOURCE_USERNAME}
spring.datasource.password=${SPRING_DATASOURCE_PASSWORD}
jwt.secret=${JWT_SECRET}
admin.initial.password=${ADMIN_INITIAL_PASSWORD}
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

El proyecto incluye configuración de Docker para facilitar el desarrollo y despliegue:

### Archivos Docker
- `docker-compose.yml` - Configuración de MySQL y el backend de la aplicación
- `Dockerfile` - Imagen de la aplicación Spring Boot
- `init-db.sql` - Script de inicialización de base de datos

### Servicios Docker
El `docker-compose.yml` levanta tres contenedores:
- `dnd-mysql` — MySQL 8.0 accesible en el puerto `3306`
- `dnd-backend` — Aplicación Spring Boot accesible en el puerto `8081`
- `dnd-nginx` — Nginx en el puerto `80`, sirve el build web de Flutter desde `./frontend-dist/` y hace proxy de `/api/` al backend

### Comandos Docker útiles
```bash
# Iniciar todos los servicios
docker compose up -d

# Iniciar solo MySQL
docker compose up -d mysql-db

# Ver logs del backend
docker compose logs -f backend

# Ver logs de MySQL
docker compose logs -f mysql-db

# Reconstruir la imagen del backend
docker compose build --no-cache backend

# Detener todos los servicios
docker compose down

# Ejecutar script SQL en el contenedor
docker exec -i dnd-mysql mysql -u <MYSQL_USER> -p<MYSQL_PASSWORD> dnd_character_manager < mi_script.sql
```

### Conectar con DBeaver o MySQL Workbench
- **Host:** `localhost`
- **Port:** `3306`
- **Database:** `dnd_character_manager`
- **Username:** `<tu_usuario>`
- **Password:** `<tu_contraseña>`

Nota: En DBeaver, añade en "Driver properties":
- `allowPublicKeyRetrieval` = `true`
- `useSSL` = `false`

## Documentación Adicional

- [backend/DOCKER.md](backend/DOCKER.md) - Guía completa de uso con Docker
- [backend/init-db.sql](backend/init-db.sql) - Script de base de datos con todas las tablas

## API Endpoints de Autenticación y Usuarios

### Autenticación
- `POST /api/auth/login` - Iniciar sesión y obtener token JWT
- `POST /api/auth/refresh` - Rotar refresh token y emitir nuevo access token
- `POST /api/auth/logout` - Revocar refresh token

### Administración de Usuarios
- `GET /api/admin/users` - Listar todos los usuarios
- `GET /api/admin/users/{id}` - Obtener usuario por ID
- `POST /api/admin/users` - Crear nuevo usuario
- `PATCH /api/admin/users/{id}/activate` - Activar usuario
- `PATCH /api/admin/users/{id}/deactivate` - Desactivar usuario
- `PATCH /api/admin/users/{id}/role` - Cambiar rol de usuario
- `PATCH /api/admin/users/{id}/reset-password` - Resetear contraseña de un usuario
- `DELETE /api/admin/users/{id}` - Eliminar usuario

### Cuenta Propia
- `GET /api/users/me` - Obtener el usuario autenticado
- `PATCH /api/users/me/password` - Cambiar la contraseña propia
- `PATCH /api/users/me/username` - Cambiar el nombre de usuario propio (revoca los refresh tokens existentes y devuelve un par de tokens nuevo)

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
curl -X POST http://localhost:8081/api/sync/items
```

**Nota:** El endpoint `/sync/all` incluye rate limiting automático para evitar sobrecargar la API externa.

### Sincronizar contenido de expansiones desde Aurora

Flujo en dos pasos: primero traer los datos crudos, luego persistir cada tipo de contenido por separado (`/api/sync/aurora/*`):

```bash
curl -X POST http://localhost:8081/api/sync/aurora/fetch
curl http://localhost:8081/api/sync/aurora/status

curl -X POST http://localhost:8081/api/sync/aurora/persist/classes
curl -X POST http://localhost:8081/api/sync/aurora/persist/class-features
curl -X POST http://localhost:8081/api/sync/aurora/persist/subclasses
curl -X POST http://localhost:8081/api/sync/aurora/persist/races
curl -X POST http://localhost:8081/api/sync/aurora/persist/items
curl -X POST http://localhost:8081/api/sync/aurora/persist/spells
curl -X POST http://localhost:8081/api/sync/aurora/persist/feats
curl -X POST http://localhost:8081/api/sync/aurora/persist/backgrounds
```

`GET /api/sync/aurora/elements` expone los elementos crudos ya traídos (admite `?name=` como filtro), útil para depurar cómo Aurora estructura una regla concreta antes de escribir su mapper.

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

### Recursos de Raza
- `GET /api/characters/{characterId}/race-resources` - Obtener recursos de raza del personaje
- `POST /api/characters/{characterId}/race-resources/initialize` - Inicializar recursos según raza/subraza
- `POST /api/characters/{characterId}/race-resources/spend` - Gastar recurso de raza
- `POST /api/characters/{characterId}/race-resources/recover` - Restaurar recurso de raza
- `POST /api/characters/{characterId}/race-resources/update-maximums` - Recalcular máximos (p. ej. tras subir de nivel)

### Clases
- `GET /api/classes` - Listar todas las clases
- `GET /api/classes/{id}` - Obtener una clase con detalles
- `GET /api/classes/index/{indexName}` - Obtener clase por nombre índice
- `GET /api/classes/{id}/subclasses` - Obtener subclases de una clase
- `POST /api/classes` - Crear una clase (admin)
- `POST /api/classes/{id}/features` - Crear una característica de clase adaptada al tipo de mecánica (admin)

### Subclases
- `GET /api/subclasses` - Listar todas las subclases
- `GET /api/subclasses/{id}` - Obtener una subclase con detalles
- `GET /api/subclasses/class/{classId}` - Obtener subclases de una clase
- `GET /api/subclasses/{id}/features` - Obtener características de una subclase
- `GET /api/subclasses/{id}/features/level/{level}` - Características de subclase por nivel
- `POST /api/subclasses` - Crear una subclase (admin)
- `POST /api/subclasses/{id}/features` - Crear una característica de subclase adaptada al tipo de mecánica (admin)

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
- `GET /api/races/{id}/traits` - Obtener rasgos de una raza
- `GET /api/races/subraces/{subraceId}/traits` - Obtener rasgos de una subraza
- `POST /api/races` - Crear una raza (admin)
- `POST /api/races/traits` - Crear un rasgo racial (de raza o subraza) adaptado al tipo de mecánica, vía `targetType`/`targetId` en el body (admin)

### Subrazas
- `GET /api/subraces/race/{raceId}` - Obtener subrazas de una raza
- `GET /api/subraces/{id}` - Obtener una subraza con detalles
- `POST /api/subraces` - Crear una subraza (admin)

### Backgrounds
- `GET /api/backgrounds` - Listar todos los backgrounds
- `GET /api/backgrounds/{id}` - Obtener un background con detalles
- `POST /api/backgrounds` - Crear un background (admin)

### Items (Catálogo)
- `GET /api/items` - Listar todos los items (soporta `?type=` y `?name=` como parámetros opcionales)
- `GET /api/items/{id}` - Obtener item por ID
- `POST /api/items` - Crear un item, incluyendo bonificadores mecánicos (admin)

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
- `GET /api/feats/search` - Buscar feats por nombre
- `POST /api/feats` - Crear un feat, incluyendo efecto mecánico y hechizos otorgados (admin)

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
- `POST /api/sync/items` - Sincronizar items de equipo desde D&D 5e API
- `POST /api/sync/all` - Sincronización completa de todos los datos

## Ejemplos de Uso

### Crear un nuevo personaje

```bash
curl -X POST http://localhost:8081/api/characters \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Cloud Strife",
    "level": 1,
    "raceId": 1,
    "dndClassId": 1,
    "backgroundId": 3,
    "abilityScores": {
      "str": 18,
      "dex": 14,
      "con": 17,
      "int": 15,
      "wis": 11,
      "cha": 10
    },
    "maxHp": 13,
    "currentHp": 13,
    "useEncumbrance": false,
    "personalityTrait1": "Actúo frío y distante, pero me importa más de lo que aparento",
    "ideal": "Identidad. Quiero descubrir quién soy realmente",
    "bond": "Mis compañeros son mi verdadera fuerza",
    "flaw": "Dudo de mí mismo y de mis recuerdos"
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
- Sincronización completa con la D&D 5e API pública y con Aurora (contenido de expansiones)
- Rate limiting en peticiones API
- Subida de nivel con características automáticas
- Cálculo automático de bonificadores y estadísticas
- Sistema de inventario completo con peso y gestión
- Sistema de equipamiento con slots específicos
- Sistema de dinero con las 5 monedas
- Gestión de idiomas del personaje
- Gestión de competencias (proficiencies)
- Sistema de feats (dotes), con efectos mecánicos (bono numérico, hechizos, elección de competencias) aplicados automáticamente al asignarlo
- Sistema de condiciones y efectos activos
- Resistencias y vulnerabilidades a tipos de daño
- Unarmored Defense de Bárbaro y Monje aplicado al cálculo de CA
- Recursos de clase y de raza (Ki, Rage, Sorcery Points, runas de Rune Knight, rasgos raciales con usos limitados, etc.) con escala de Barbarian Rage corregida
- Capa de mecánicas reutilizable por tipo de efecto (Resource Pool, Numeric Bonus, Grant Spell, Grant Proficiency) para features de clase, subclase y rasgos raciales
- Bonificadores mecánicos automáticos de items (CA, ataque, daño, salvaciones, override de característica) al equipar/sintonizar
- Panel de administración con creación de contenido homebrew (clase, subclase, raza, subraza, item, background, feat) integrada con la capa de mecánicas anterior
- Sistema de descansos cortos y largos
- Sistema de death saves y HP temporal
- Cálculos automáticos de CA, velocidad, iniciativa
- Percepción pasiva, investigación e intuición
- Autenticación JWT con Spring Security
- Gestión de usuarios del sistema (admin), incluyendo cambio de nombre de usuario y contraseña propios
- Hechizos de subclase (Domain/Oath/Circle spells) aplicados automáticamente
- Proficiencias de subclase aplicadas automáticamente
- PendingTasks para subclases PHB y de expansión: Battle Master, Rune Knight, Totem Warrior, Hunter Ranger, Monk 4 Elements, Artificer Infusions

### Frontend Mobile - Completo para esta versión
- Sistema de autenticación con login y gestión de tokens JWT
- Manejo de errores de red con mensajes descriptivos (sin conexión, credenciales incorrectas, errores de servidor)
- Pantalla de dashboard con lista de personajes y acciones rápidas
- Cliente HTTP centralizado para consumo de la API REST
- Arquitectura MVVM con Provider para gestión de estado reactivo
- Modelos de datos (personajes, autenticación, inventario, wizard)
- Servicios para personajes, autenticación, inventario, hechizos y feats
- Almacenamiento persistente de tokens
- Tema visual personalizado con paleta D&D (dark theme, LibreBaskerville + Lato)
- Panel de administración: gestión de usuarios (incluye cambiar el propio nombre de usuario/contraseña), creación de contenido homebrew (clase/subclase/raza/subraza/item/background/feat) y creación de features/rasgos adaptada al tipo de mecánica elegido
- Paso "Content Sources" en el wizard para elegir qué sourcebooks están disponibles al elegir raza, clase, background, etc.
- Wizard de creación de personajes en 7 pasos: preferencias, clase, background, raza, puntuaciones, hechizos y equipamiento
- Wizard en modo edición (EditCharacterScreen) y modo subida de nivel (LevelUpScreen)
- Selección de habilidades de clase, feats/ASI, elecciones de subclase integradas en el wizard
- Pasos de equipamiento y hechizos opcionales con banner informativo
- Ficha de personaje interactiva con 7 tabs: Abilities, Skills, Combat, Spells, Features, Inventory, Info
- Tab Features con características de clase, subclase y rasgos raciales, recursos con contador de usos (clase y raza) y badges de relevancia en combate
- Tab Spells con slot tracker interactivo y detalle de hechizo con botón de lanzamiento
- Tab Combat con acciones, acciones de bonus y reacciones siempre visibles
- Tab Inventory con bonificadores mecánicos de items aplicados automáticamente al equipar y selector de "arma base" para plantillas de arma mágica genéricas
- Gestión de descansos cortos y largos desde la ficha
- Pantalla de tareas pendientes (PendingTasksScreen) para resolución de elecciones de subida de nivel: ASI/Feat, subclase, hechizos, Fighting Style, Expertise, Invocaciones, Metamagic, Battle Master maneuvers, Rune Knight runes, Totem Warrior, Hunter Ranger, Monk 4 Elements, Artificer Infusions — las tareas de "elige N" que se repiten en varios hitos de nivel excluyen las opciones ya elegidas en un hito anterior

> **Funcionalidades pendientes para versiones futuras:** gestión visual de slots de equipamiento por parte del cuerpo, sistema XP (el backend ya lo soporta, la UI siempre usa Milestone), toggle de Encumbrance, soporte multi-idioma, multiclase.



## 👤 Autor

Alexandre Barbeito
