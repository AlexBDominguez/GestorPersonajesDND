# Guía de Uso con Docker

## Requisitos previos
- Docker instalado
- Docker Compose instalado

## Configuración inicial

1. **Crear archivo de variables de entorno** (opcional):
   ```bash
   cp .env.example .env
   # Edita .env con tus credenciales preferidas
   ```

2. **Levantar los servicios**:
   ```bash
   docker-compose up -d
   ```

   Esto iniciará:
   - MySQL en el puerto `3306`
   - Spring Boot en el puerto `8080`
   - La base de datos se inicializará automáticamente con `init-db.sql`

3. **Ver logs**:
   ```bash
   docker-compose logs -f
   # O solo de un servicio
   docker-compose logs -f spring-app
   docker-compose logs -f mysql-db
   ```

## Conectar DBeaver a MySQL en Docker

**Datos de conexión:**
- **Host:** `localhost`
- **Port:** `3306`
- **Database:** `dnd_character_manager`
- **Username:** `dnd_user` (o el que configuraste en `.env`)
- **Password:** `dnd_password` (o el que configuraste en `.env`)

**Usuario root (si lo necesitas):**
- **Username:** `root`
- **Password:** `dnd_root_password` (o el que configuraste en `.env`)

## Comandos útiles

### Iniciar servicios
```bash
docker-compose up -d
```

### Detener servicios
```bash
docker-compose down
```

### Detener y eliminar datos (CUIDADO: borra la base de datos)
```bash
docker-compose down -v
```

### Reiniciar un servicio específico
```bash
docker-compose restart spring-app
docker-compose restart mysql-db
```

### Ver estado de los contenedores
```bash
docker-compose ps
```

### Acceder a MySQL desde línea de comandos
```bash
docker exec -it dnd-mysql mysql -u dnd_user -p dnd_character_manager
# Contraseña: dnd_password (o la tuya)
```

### Reconstruir la aplicación después de cambios en el código
```bash
docker-compose up -d --build spring-app
```

### Ejecutar solo MySQL (sin la aplicación)
```bash
docker-compose up -d mysql-db
```

## Desarrollo local

Si quieres ejecutar la aplicación Spring Boot localmente (no en Docker) pero usar MySQL de Docker:

1. Levantar solo MySQL:
   ```bash
   docker-compose up -d mysql-db
   ```

2. Ejecutar Spring Boot desde tu IDE o con Maven:
   ```bash
   mvn spring-boot:run
   ```

   La aplicación se conectará a MySQL en `localhost:3306`

## Acceder a la aplicación

Una vez levantados los servicios:
- **API REST:** http://localhost:8080
- **Base de datos MySQL:** localhost:3306

## Solución de problemas

### El contenedor de MySQL no inicia
```bash
# Ver logs detallados
docker-compose logs mysql-db

# Verificar que el puerto 3306 no esté ocupado
sudo netstat -tuln | grep 3306
```

### La aplicación no se conecta a MySQL
```bash
# Verificar que MySQL esté saludable
docker-compose ps

# Debe mostrar "healthy" para mysql-db
# Si no, espera unos segundos más o revisa los logs
```

### Reiniciar desde cero
```bash
# Detener todo y eliminar datos
docker-compose down -v

# Volver a levantar
docker-compose up -d
```

## Datos de ejemplo

Si quieres cargar datos de prueba, puedes:

1. Conectarte a MySQL:
   ```bash
   docker exec -it dnd-mysql mysql -u dnd_user -p dnd_character_manager
   ```

2. Ejecutar tus queries SQL de prueba

O ejecutar un archivo SQL:
```bash
docker exec -i dnd-mysql mysql -u dnd_user -pdnd_password dnd_character_manager < datos-prueba.sql
```
