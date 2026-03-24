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

### 1. En el PC Original (Origen)

#### a) Detener los servicios
```bash
cd backend
docker compose down
```

#### b) Verificar que los datos existen
```bash
ls -lh mysql-data/
# Deberías ver archivos como: ibdata1, ib_logfile*, carpetas de bases de datos, etc.
```

#### c) Copiar el proyecto completo
Tienes dos opciones:

**Opción 1: Usando Git (Recomendado)**
```bash
# Asegúrate de que mysql-data/ está excluido del .gitignore
cd ..
git add .
git commit -m "Preparando migración"
git push
```

**Opción 2: Copia directa (USB/Red)**
```bash
# Copia todo el proyecto a un USB o disco externo
cp -r GestorPersonajesDND /ruta/al/usb/
```

⚠️ **IMPORTANTE**: La carpeta `mysql-data/` debe tener permisos correctos:
```bash
# Cambiar propietario a tu usuario antes de copiar (opcional)
sudo chown -R $USER:$USER mysql-data/
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

1. **La carpeta `mysql-data/` NO está en Git** por razones de seguridad y tamaño. Debes copiarla manualmente o crear un backup.

2. **Los datos son portátiles entre arquitecturas similares** (Linux→Linux, Mac→Mac), pero pueden tener problemas entre sistemas muy diferentes (Linux→Windows).

3. **Alternativa: Backup SQL**
   Si prefieres un método más universal:
   ```bash
   # Crear backup
   docker exec dnd-mysql mysqldump -u root -proot_password dnd_character_manager > backup.sql

   # Restaurar en nuevo PC
   docker exec -i dnd-mysql mysql -u root -proot_password dnd_character_manager < backup.sql
   ```

4. **Tamaño aproximado de mysql-data/**: 200-500 MB dependiendo de cuántos personajes tengas creados.

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
