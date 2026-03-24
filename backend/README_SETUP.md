# ✅ Configuración Completada - Base de Datos Persistente

## 🎯 Resumen de Cambios

Se ha configurado exitosamente el proyecto con:

1. ✅ **Volumen persistente local** en `backend/mysql-data/`
2. ✅ **Base de datos poblada** con datos de D&D 5e API
3. ✅ **Usuario admin** pre-configurado
4. ✅ **Documentación de migración** completa

## 🚀 Estado Actual

### Backend
- ✅ Spring Boot corriendo en `http://localhost:8081`
- ✅ MySQL corriendo en puerto `3306`
- ✅ Usuario admin creado: `admin` / `admin123`

### Base de Datos
La sincronización con la API de D&D 5e está **en progreso**. Datos cargados:
- ✅ 9 Razas
- ✅ 12 Clases
- ⏳ ~130+ Hechizos (continúa cargando)
- ✅ 18 Habilidades
- ⏳ Trasfondos, Subclases, etc. (en progreso)

Para verificar el progreso:
```bash
cd backend
bash check-sync-status.sh
```

## 📁 Estructura de Datos

```
backend/
├── mysql-data/              ← DATOS PERSISTENTES (no en Git)
│   ├── dnd_character_manager/
│   ├── ibdata1
│   └── ...
├── docker-compose.yml       ← Configurado con volumen local
├── MIGRACION_BASE_DATOS.md ← Guía completa de migración
└── check-sync-status.sh     ← Script para verificar progreso
```

## 🔄 Migración a Otro PC

### Pasos Rápidos:

1. **En el PC actual:**
   ```bash
   cd backend
   docker compose down
   ```

2. **Copiar el proyecto completo** (incluyendo `mysql-data/`)

3. **En el nuevo PC:**
   ```bash
   cd backend
   docker compose up -d
   mvn spring-boot:run
   ```

**📖 Guía completa:** Lee `MIGRACION_BASE_DATOS.md` para instrucciones detalladas.

## 🛠️ Comandos Útiles

### Verificar estado de sincronización
```bash
bash backend/check-sync-status.sh
```

### Ver logs del backend en tiempo real
```bash
tail -f /tmp/backend.log
```

### Reiniciar MySQL
```bash
cd backend
docker compose restart
```

### Hacer backup manual de la base de datos
```bash
docker exec dnd-mysql mysqldump -u dnd_user -pdnd_password dnd_character_manager > backup.sql
```

### Restaurar desde backup
```bash
docker exec -i dnd-mysql mysql -u dnd_user -pdnd_password dnd_character_manager < backup.sql
```

## 🔐 Credenciales

### Usuario Admin (Backend)
- **Username:** `admin`
- **Password:** `admin123`

### MySQL
- **Host:** `localhost:3306`
- **Database:** `dnd_character_manager`
- **User:** `dnd_user`
- **Password:** `dnd_password`
- **Root Password:** `root_password`

## ⚙️ Configuración

### Docker Compose (`docker-compose.yml`)
```yaml
volumes:
  - ./mysql-data:/var/lib/mysql  # Volumen local persistente
```

### Application Properties
```properties
spring.datasource.url=jdbc:mysql://localhost:3306/dnd_character_manager
server.port=8081
```

## 📊 Datos Disponibles

Una vez completada la sincronización, la base de datos contendrá:

- **Razas:** Humano, Elfo, Enano, Mediano, Dracónido, Gnomo, Semielfo, Semiorco, Tiefling
- **Clases:** Bárbaro, Bardo, Clérigo, Druida, Guerrero, Monje, Paladín, Explorador, Pícaro, Hechicero, Brujo, Mago
- **Hechizos:** ~300+ hechizos de D&D 5e
- **Trasfondos:** Acólito, Criminal, Héroe del pueblo, Noble, etc.
- **Y mucho más...**

## 🎮 Probar el Sistema

### Test de Login (Backend)
```bash
curl -X POST http://localhost:8081/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin123"}'
```

Respuesta esperada:
```json
{
  "token": "eyJhbGc...",
  "username": "admin",
  "email": "admin@dungeonscroll.com"
}
```

### Test desde Flutter
1. Arranca la app: `cd frontend && flutter run`
2. Selecciona Chrome
3. Usa las credenciales: `admin` / `admin123`

## ❓ Solución de Problemas

### MySQL no arranca
```bash
cd backend
docker compose down
sudo chown -R 999:999 mysql-data/
docker compose up -d
```

### Backend no conecta a MySQL
```bash
# Verificar que MySQL está corriendo
docker ps | grep dnd-mysql

# Verificar logs
docker logs dnd-mysql
```

### Sincronización muy lenta
Es normal. La API de D&D 5e tiene rate limiting. La sincronización completa puede tardar 10-15 minutos.

## 📚 Documentación Adicional

- `MIGRACION_BASE_DATOS.md` - Guía detallada de migración entre PCs
- `DB_TABLES_INFO.md` - Información sobre las tablas de la base de datos
- `DOCKER.md` / `DOCKER_SETUP.md` - Configuración Docker original

## ✨ Próximos Pasos

1. ✅ Backend y base de datos funcionando
2. ✅ Datos de D&D 5e sincronizados (en progreso)
3. 🔜 Crear personajes desde Flutter
4. 🔜 Agregar más funcionalidades

---

**🎲 DungeonScroll - D&D 5e Character Manager**
