# Gestor de Personajes DND

Sistema de gestión de personajes para Dungeons & Dragons 5e, desarrollado con Spring Boot y PostgreSQL.

## 📋 Descripción

Aplicación backend que permite crear y gestionar personajes de D&D 5e, incluyendo:

- Gestión completa de personajes (atributos, puntos de vida, nivel)
- Sistema de clases y razas
- Gestión de hechizos y slots de hechizos
- Sistema de subida de nivel automatizado
- Progresión de características por nivel
- Sincronización de datos desde fuentes externas

## 🛠️ Tecnologías

- **Java 24**
- **Spring Boot 3.2.0**
- **Spring Data JPA** - Persistencia de datos
- **PostgreSQL** - Base de datos
- **Maven** - Gestión de dependencias

## 📦 Estructura del Proyecto

```
src/main/java/
├── controllers/        # Controladores REST API
│   ├── DndClassController
│   ├── PlayerCharacterController
│   ├── RaceController
│   └── SpellController
├── dto/               # Data Transfer Objects
├── entities/          # Entidades JPA
│   ├── PlayerCharacter
│   ├── DndClass
│   ├── Race
│   ├── Spell
│   ├── CharacterSpell
│   └── ClassLevelProgression
├── enumeration/       # Enumeraciones
│   └── FeatureType
├── repositories/      # Repositorios JPA
├── services/          # Lógica de negocio
└── sync/             # Servicios de sincronización
```

## 🚀 Características Principales

### Gestión de Personajes
- Crear, leer, actualizar y eliminar personajes
- Asignación de clase y raza
- Gestión de puntos de vida (actuales y máximos)
- Cálculo automático de bono de competencia

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
  - Características de clase

### Sistema de Hechizos
- Gestión de hechizos disponibles
- Slots de hechizos por nivel
- Asignación de hechizos a personajes
- Progresión automática de slots según clase y nivel

### Sincronización
- Importación de datos de clases desde API externa
- Importación de razas
- Sincronización de hechizos
- Configuración de progresión de slots

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
```

3. **Compilar el proyecto**
```bash
mvn clean install
```

4. **Ejecutar la aplicación**
```bash
mvn spring-boot:run
```

## 🔌 API Endpoints

### Personajes
- `GET /api/characters` - Listar todos los personajes
- `GET /api/characters/{id}` - Obtener un personaje
- `POST /api/characters` - Crear nuevo personaje
- `PUT /api/characters/{id}` - Actualizar personaje
- `DELETE /api/characters/{id}` - Eliminar personaje
- `POST /api/characters/{id}/level-up` - Subir de nivel

### Clases
- `GET /api/classes` - Listar todas las clases
- `GET /api/classes/{id}` - Obtener una clase

### Razas
- `GET /api/races` - Listar todas las razas
- `GET /api/races/{id}` - Obtener una raza

### Hechizos
- `GET /api/spells` - Listar todos los hechizos
- `GET /api/spells/{id}` - Obtener un hechizo

### Sincronización
- `POST /api/sync/classes` - Sincronizar clases
- `POST /api/sync/races` - Sincronizar razas
- `POST /api/sync/spells` - Sincronizar hechizos

## 📄 Licencia

Este proyecto es de código abierto y está disponible bajo la licencia MIT.

## 👤 Autor

Alexandre Barbeito

## 🤝 Contribuciones

Las contribuciones son bienvenidas. Por favor:

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/NuevaCaracteristica`)
3. Commit tus cambios (`git commit -m 'Añadir nueva característica'`)
4. Push a la rama (`git push origin feature/NuevaCaracteristica`)
5. Abre un Pull Request

## 📞 Soporte

Para reportar bugs o solicitar nuevas características, por favor abre un issue en el repositorio.
