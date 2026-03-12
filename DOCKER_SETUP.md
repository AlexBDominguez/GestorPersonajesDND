# Docker Setup - Compartir MySQL entre dos ordenadores

## Resumen
Con Docker puedes crear un contenedor MySQL que funcione igual en cualquier ordenador. Esto elimina la necesidad de instalar MySQL localmente en el segundo ordenador.

---

## PASO 1: Instala Docker

### En este PC (ya tienes MySQL):
1. Descarga Docker Desktop desde: https://www.docker.com/products/docker-desktop
2. Instala y reinicia el ordenador
3. Verifica que Docker esté funcionando: `docker --version`

### En el otro PC (sin MySQL):
1. Descargar Docker Desktop desde: https://www.docker.com/products/docker-desktop
2. Instala y reinicia el ordenador
3. Verifica que Docker esté funcionando: `docker --version`

---

## PASO 2: Estructura del proyecto

Tu proyecto debe tener esta estructura:
```
GestorPersonajesDND/
├── docker-compose.yml          ← Archivo actualizado
├── init-db.sql                 ← Script SQL actualizado
├── src/
├── pom.xml
├── application.properties
└── ...
```

---

## PASO 3: Configurar application.properties

En ambos ordenadores, actualiza tu `application.properties`:

```properties
# URL de conexión (localhost si ejecutas locally)
spring.datasource.url=jdbc:mysql://localhost:3306/dnd_character_manager?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC

# Credenciales (igual que en docker-compose.yml)
spring.datasource.username=dnd_user
spring.datasource.password=dnd_password

# Hibernate
spring.jpa.hibernate.ddl-auto=update
spring.jpa.show-sql=true

# MySQL 8
spring.jpa.database-platform=org.hibernate.dialect.MySQL8Dialect
```

**AVANZADO - Opción alternativa**: Si ejecutas Spring Boot desde OTRO contenedor Docker:
```properties
# URL si spring corre en otro contenedor
spring.datasource.url=jdbc:mysql://mysql-db:3306/dnd_character_manager?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC
```

---

## PASO 4: Ejecutar en Este PC (con MySQL existente)

### Opción A: Migrar a Docker (recomendado)
```bash
# 1. Detén MySQL local (opcional)
# En Windows: net stop MySQL80
# O directamente no lo ejecutes

# 2. Ve a la carpeta del proyecto
cd "c:\Users\alexb\OneDrive\Documentos\Alex BD\GestorPersonajesDND"

# 3. Inicia Docker
docker-compose up -d

# Verifica que está corriendo:
docker ps

# Deberías ver:
# CONTAINER ID   IMAGE     COMMAND                   STATUS
# xxx            mysql:8.0 docker-entrypoint.sh...   Up X seconds
```

### Opción B: Mantener MySQL local
```bash
# Sigue usando tu MySQL local instalado
# Solo asegúrate de que el puerto 3306 está disponible
# No ejecutes docker-compose up
```

---

## PASO 5: Ejecutar en el Otro PC (sin MySQL)

```bash
# 1. Copia TODO el proyecto a este ordenador (o clónalo de Git)

# 2. Ve a la carpeta del proyecto
cd "C:\ruta\a\tu\GestorPersonajesDND"

# 3. Inicia Docker
docker-compose up -d

# 4. Verifica que está corriendo
docker ps
docker logs dnd-mysql

# 5. Si quieres ver los logs en tiempo real
docker compose logs -f mysql-db
```

---

## PASO 6: Ejecutar la Aplicación Java

### En Este PC:
```bash
cd "c:\Users\alexb\OneDrive\Documentos\Alex BD\GestorPersonajesDND"
mvn spring-boot:run
```

### En el Otro PC:
```bash
cd "C:\ruta\a\tu\GestorPersonajesDND"
mvn spring-boot:run
# Espera a que Spring Boot se conecte a MySQL en Docker
```

---

## PASO 7: Compartir datos entre ordenadores

### Opción 1: MySQL en la nube (mejor para colaboración)
Si ambos ordenadores necesitan acceder a los MISMOS datos:

1. Despliega Docker en un servidor/cloud:
   - AWS EC2
   - DigitalOcean
   - Heroku
   - Azure Container Instances

2. Actualiza la IP del servidor en `application.properties`:
```properties
spring.datasource.url=jdbc:mysql://tu-servidor.com:3306/dnd_character_manager
```

### Opción 2: Un ordenador es servidor (red local)
```bash
# En el PC que corre Docker:
# Obtén la IP local:
ipconfig

# Ejemplo: 192.168.1.100

# En el otro PC, actualiza application.properties:
spring.datasource.url=jdbc:mysql://192.168.1.100:3306/dnd_character_manager
# Asegúrate de que el puerto 3306 está abierto en el firewall
```

### Opción 3: Sincronizar con Git
- Cada ordenador ejecuta su propia BD locally en Docker
- Los cambios al código se sincronizan vía Git
- Las BDs están separadas (no compartidas)

---

## Comandos Docker útiles

```bash
# Ver contenedores en ejecución
docker ps

# Ver todos los contenedores (incluso detenidos)
docker ps -a

# Ver logs del contenedor
docker logs dnd-mysql

# Ver logs en tiempo real
docker logs -f dnd-mysql

# Detener el contenedor
docker stop dnd-mysql

# Iniciar el contenedor detenido
docker start dnd-mysql

# Eliminar el contenedor (CUIDADO: pierde datos si no tienes volumen)
docker rm dnd-mysql

# Conectarse a MySQL dentro del contenedor
docker exec -it dnd-mysql mysql -u root -p

# Dentro de MySQL, ver bases de datos:
# SHOW DATABASES;
# USE dnd_character_manager;
# SHOW TABLES;
```

---

## Solución de Problemas

### Puerto 3306 ya está en uso
```bash
# Ver qué está usando el puerto
netstat -ano | findstr :3306

# O en PowerShell:
Get-NetTCPConnection -LocalPort 3306 | Select-Object OwnerProcess
```

Solución:
1. Detén MySQL local o el contenedor anterior
2. Cambia el puerto en `docker-compose.yml`:
```yaml
ports:
  - "3307:3306"  # Usa 3307 en lugar de 3306
```

### No se conecta desde la aplicación Java
1. Verifica que Docker está corriendo: `docker ps`
2. Verifica que el contenedor está arriba: `docker logs dnd-mysql`
3. Prueba conectar manualmente:
```bash
docker exec -it dnd-mysql mysql -u dnd_user -p dnd_character_manager
```
4. Verifica la URL en `application.properties`

### Quiero actualizar init-db.sql después de crear el contenedor
```bash
# Los cambios a init-db.sql solo aplican en contenedores NUEVOS
# Para actualizar uno existente:

# Opción 1: Elimina y recrea el contenedor
docker-compose down  # ⚠️ Esto elimina los datos
docker-compose up -d

# Opción 2: Ejecuta los cambios SQL manualmente
docker exec -it dnd-mysql mysql -u dnd_user -p dnd_character_manager < cambios.sql
```

---

## Checklist Final

- [ ] Docker instalado en ambos ordenadores
- [ ] `docker-compose.yml` en la raíz del proyecto
- [ ] `init-db.sql` actualizado en la raíz del proyecto
- [ ] `application.properties` configurado correctamente
- [ ] `mvn spring-boot:run` conecta exitosamente
- [ ] Puedes hacer queries a MySQL desde tu aplicación

---

## Referencias

- Docker: https://docs.docker.com/
- Docker Compose: https://docs.docker.com/compose/
- MySQL Docker Image: https://hub.docker.com/_/mysql
