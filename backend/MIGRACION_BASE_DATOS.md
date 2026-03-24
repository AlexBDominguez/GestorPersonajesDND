# Guía de Migración de Base de Datos Entre PCs

Esta guía explica cómo mover tu proyecto DungeonScroll (incluyendo la base de datos completa) a otro ordenador sin perder ningún dato.

## 📦 Qué incluye la base de datos

La carpeta `mysql-data/` contiene:
- Usuario admin pre-configurado
- Todos los datos sincronizados de D&D 5e API:
  - Razas (Races)
  - Clases (Classes)
  - Hechizos (Spells)
  - Trasfondos (Backgrounds)
  - Habilidades (Skills)
  - Subclases (Subclasses)
  - Competencias (Proficiencies)
  - Idiomas (Languages)
  - Condiciones (Conditions)
  - Tipos de daño (Damage Types)
- Personajes de jugadores creados por los usuarios

## 📋 Configuración Actual

El proyecto está configurado con un volumen persistente **local** en `docker-compose.yml`:

```yaml
volumes:
  - ./mysql-data:/var/lib/mysql
```

Esto significa que todos los datos de MySQL se guardan en la carpeta:
```
backend/mysql-data/
```

## 🚚 Pasos para Migrar a Otro PC

⚠️ **IMPORTANTE**: Los archivos en `mysql-data/` pertenecen al usuario MySQL (UID 999) y **no se pueden copiar directamente**. Usa uno de estos métodos:

### Método 1: Backup SQL (RECOMENDADO - Más simple y portable)

#### En el PC Original:

```bash
cd backend

# 1. Asegúrate de que MySQL está corriendo
docker compose up -d

# 2. Crear backup SQL
docker exec dnd-mysql mysqldump -u dnd_user -pdnd_password dnd_character_manager > backup_dnd.sql

# 3. Verificar que el backup se creó (debería tener varios MB)
ls -lh backup_dnd.sql
```

#### Copiar el proyecto:
```bash
# Copia todo el proyecto al nuevo PC (incluyendo backup_dnd.sql)
# Puedes usar Git, USB, o cualquier método
```

#### En el PC Nuevo:

```bash
cd backend

# 1. Arrancar MySQL (creará una base de datos vacía)
docker compose up -d

# 2. Esperar 10 segundos para que MySQL inicialice
sleep 10

# 3. Restaurar el backup
docker exec -i dnd-mysql mysql -u dnd_user -pdnd_password dnd_character_manager < backup_dnd.sql

# 4. Verificar que los datos se importaron
docker exec dnd-mysql mysql -u dnd_user -pdnd_password dnd_character_manager -e "SELECT COUNT(*) FROM users;"

# 5. Arrancar el backend
mvn spring-boot:run
```

✅ **¡Listo!** Todos los datos están disponibles.

---

### Método 2: Copiar mysql-data/ con permisos (Más rápido, requiere sudo)

#### En el PC Original:

```bash
cd backend

# 1. Detener MySQL
docker compose down

# 2. Crear un archivo tar con todos los datos (conserva permisos)
sudo tar -czf mysql-data-backup.tar.gz mysql-data/

# 3. Cambiar el propietario del tar a tu usuario
sudo chown $USER:$USER mysql-data-backup.tar.gz

# 4. Verificar el tamaño (debería ser 50-200 MB)
ls -lh mysql-data-backup.tar.gz
```

#### Copiar el proyecto:
```bash
# Copia el proyecto Y el archivo mysql-data-backup.tar.gz
```

#### En el PC Nuevo:

```bash
cd backend

# 1. Extraer el backup (con sudo para mantener permisos)
sudo tar -xzf mysql-data-backup.tar.gz

# 2. Verificar que mysql-data/ existe
ls -lh mysql-data/

# 3. Arrancar MySQL (usará los datos existentes)
docker compose up -d

# 4. Verificar logs
docker logs dnd-mysql

# 5. Arrancar el backend
mvn spring-boot:run
```

---

### Método 3: Usar docker cp (Alternativa sin sudo)

#### En el PC Original:

```bash
cd backend

# 1. MySQL debe estar corriendo
docker compose up -d

# 2. Copiar datos desde el contenedor
docker cp dnd-mysql:/var/lib/mysql ./mysql-backup-export

# 3. Crear tar del backup
tar -czf mysql-backup.tar.gz mysql-backup-export/

# 4. Limpiar
rm -rf mysql-backup-export/
```

#### En el PC Nuevo:

```bash
cd backend

# 1. Extraer backup
tar -xzf mysql-backup.tar.gz

# 2. Arrancar MySQL (base de datos vacía temporal)
docker compose up -d
sleep 10

# 3. Detener MySQL
docker compose down

# 4. Reemplazar datos
sudo rm -rf mysql-data/*
sudo mv mysql-backup-export/* mysql-data/

# 5. Corregir permisos
sudo chown -R 999:999 mysql-data/

# 6. Arrancar MySQL de nuevo
docker compose up -d
```

### 2. En el PC Nuevo (Destino)

#### a) Copiar el proyecto
```bash
# Si usaste Git:
git clone <tu-repositorio>
cd GestorPersonajesDND

# Si usaste USB:
cp -r /ruta/del/usb/GestorPersonajesDND ~/
cd ~/GestorPersonajesDND
```

#### b) Verificar que mysql-data/ existe
```bash
cd backend
ls -lh mysql-data/
# Debes ver los mismos archivos que en el PC original
```

#### c) Arrancar MySQL con los datos existentes
```bash
cd backend
docker compose up -d
```

Docker detectará automáticamente que la carpeta `mysql-data/` ya tiene datos y **NO** inicializará una base de datos nueva. Usará los datos existentes.

#### d) Verificar la conexión
Espera unos segundos y verifica:
```bash
docker logs dnd-mysql
# Deberías ver: "ready for connections. Version: '8.0.45'"
```

#### e) Arrancar el backend
```bash
mvn spring-boot:run
```

#### f) Verificar que los datos están presentes
```bash
# Test de login con el usuario admin
curl -X POST http://localhost:8081/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'

# Si responde con un token JWT, ¡todo funciona! ✅
```

## 🔄 Sincronización Inicial (Solo si mysql-data/ está vacío)

Si por alguna razón la carpeta `mysql-data/` está vacía o quieres repoblar la base de datos desde cero:

```bash
# 1. Asegúrate de que MySQL está corriendo
docker compose up -d

# 2. Espera 10 segundos para que MySQL inicialice

# 3. Arranca el backend
mvn spring-boot:run

# 4. Popula la base de datos (tarda ~5-10 minutos)
curl -X POST http://localhost:8081/api/sync/all
```

El endpoint `/api/sync/all` llamará a la API de D&D 5e y descargará todos los datos.

## 🔧 Solución de Problemas

### Problema: MySQL no arranca en el nuevo PC

**Solución 1: Permisos incorrectos**
```bash
cd backend
sudo chown -R 999:999 mysql-data/
docker compose restart
```

**Solución 2: Archivos corruptos**
```bash
# Hacer backup de los datos actuales
mv mysql-data mysql-data.backup

# Iniciar con base de datos limpia
docker compose up -d

# Esperar inicialización y poblar desde API
mvn spring-boot:run
curl -X POST http://localhost:8081/api/sync/all
```

### Problema: Puerto 3306 ya en uso

```bash
# Cambiar puerto en docker-compose.yml
ports:
  - "3307:3306"  # Usar puerto 3307 en el host

# Actualizar application.properties
spring.datasource.url=jdbc:mysql://localhost:3307/dnd_character_manager?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC
```

### Problema: No puedo hacer login con admin

El usuario admin se crea automáticamente al iniciar el backend por primera vez. Credenciales:
- **Username:** `admin`
- **Password:** `admin123`

Si no funciona:
```bash
# Verificar que el usuario existe conectándote a MySQL
docker exec -it dnd-mysql mysql -u root -proot_password

USE dnd_character_manager;
SELECT username, email, role, active FROM users;
```

## 📝 Notas Importantes

1. **Método Recomendado**: Usa el **Método 1 (Backup SQL)**. Es el más simple, portable y sin problemas de permisos.

2. **La carpeta `mysql-data/` tiene permisos especiales** (UID 999) y no se puede copiar directamente. Por eso usamos backups SQL o tar con sudo.

3. **Tamaño del backup**:
   - Backup SQL: 10-50 MB (comprimido con texto)
   - mysql-data tar: 50-200 MB (datos binarios)

4. **Los backups SQL son portátiles entre arquitecturas** (Linux→Mac→Windows), mientras que mysql-data/ puede tener problemas entre sistemas diferentes.

5. **Automatización**: Puedes crear un script para hacer backups automáticos:
   ```bash
   #!/bin/bash
   # backup.sh
   DATE=$(date +%Y%m%d_%H%M%S)
   docker exec dnd-mysql mysqldump -u dnd_user -pdnd_password dnd_character_manager > "backup_${DATE}.sql"
   echo "Backup creado: backup_${DATE}.sql"
   ```

## 🎯 Checklist de Migración

- [ ] Detener servicios en PC origen: `docker compose down`
- [ ] Verificar que `mysql-data/` existe y tiene contenido
- [ ] Copiar proyecto completo al nuevo PC
- [ ] Verificar que `mysql-data/` se copió correctamente
- [ ] Arrancar MySQL: `docker compose up -d`
- [ ] Esperar 10 segundos para inicialización
- [ ] Arrancar backend: `mvn spring-boot:run`
- [ ] Probar login: `curl -X POST http://localhost:8081/api/auth/login`
- [ ] Verificar que el frontend conecta correctamente

## 🆘 Soporte

Si tienes problemas durante la migración:
1. Revisa los logs de Docker: `docker logs dnd-mysql`
2. Revisa los logs del backend en la terminal donde ejecutaste `mvn spring-boot:run`
3. Verifica permisos de `mysql-data/`: debe ser `drwxr-xr-x` o similar
