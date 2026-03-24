#!/bin/bash

# Script para restaurar un backup de la base de datos DungeonScroll
# Uso: bash backend/restore-backup.sh <archivo_backup.sql>

set -e  # Salir si hay algún error

if [ $# -eq 0 ]; then
    echo "❌ Error: Debes proporcionar el archivo de backup"
    echo ""
    echo "Uso: bash restore-backup.sh <archivo_backup.sql>"
    echo ""
    echo "Ejemplo:"
    echo "  bash restore-backup.sh backups/dnd_backup_20260324_120000.sql"
    echo "  bash restore-backup.sh backups/dnd_backup_20260324_120000.sql.gz"
    echo ""
    exit 1
fi

BACKUP_FILE="$1"

echo "🔄 Restaurando backup de la base de datos..."
echo "=============================================="

# Verificar que el archivo existe
if [ ! -f "$BACKUP_FILE" ]; then
    echo "❌ Error: El archivo $BACKUP_FILE no existe"
    exit 1
fi

# Verificar que MySQL está corriendo
if ! docker ps | grep -q dnd-mysql; then
    echo "❌ Error: El contenedor MySQL no está corriendo"
    echo "   Ejecuta: docker compose up -d"
    exit 1
fi

# Si el archivo está comprimido, descomprimirlo temporalmente
TEMP_FILE=""
if [[ "$BACKUP_FILE" == *.gz ]]; then
    echo "📦 Descomprimiendo archivo..."
    TEMP_FILE="${BACKUP_FILE%.gz}"
    gunzip -c "$BACKUP_FILE" > "$TEMP_FILE"
    BACKUP_FILE="$TEMP_FILE"
fi

# Verificar tamaño del archivo
FILE_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
echo "📄 Archivo: $BACKUP_FILE"
echo "📏 Tamaño: $FILE_SIZE"
echo ""

# Advertencia
echo "⚠️  ADVERTENCIA: Esta operación REEMPLAZARÁ todos los datos actuales"
echo "   en la base de datos con los datos del backup."
echo ""
read -p "¿Continuar? (s/N): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[SsYy]$ ]]; then
    echo "❌ Operación cancelada"
    [ -n "$TEMP_FILE" ] && rm -f "$TEMP_FILE"
    exit 0
fi

# Restaurar backup
echo ""
echo "🔄 Importando datos..."
docker exec -i dnd-mysql mysql -u dnd_user -pdnd_password dnd_character_manager < "$BACKUP_FILE" 2>/dev/null

# Limpiar archivo temporal si existe
[ -n "$TEMP_FILE" ] && rm -f "$TEMP_FILE"

# Verificar la restauración
echo ""
echo "🔍 Verificando restauración..."
USER_COUNT=$(docker exec dnd-mysql mysql -u dnd_user -pdnd_password dnd_character_manager -se "SELECT COUNT(*) FROM users;" 2>/dev/null)
RACE_COUNT=$(docker exec dnd-mysql mysql -u dnd_user -pdnd_password dnd_character_manager -se "SELECT COUNT(*) FROM race;" 2>/dev/null)
CLASS_COUNT=$(docker exec dnd-mysql mysql -u dnd_user -pdnd_password dnd_character_manager -se "SELECT COUNT(*) FROM classes;" 2>/dev/null)

echo ""
echo "✅ Backup restaurado exitosamente!"
echo ""
echo "📊 Datos importados:"
echo "   - Usuarios: $USER_COUNT"
echo "   - Razas: $RACE_COUNT"
echo "   - Clases: $CLASS_COUNT"
echo ""
echo "=============================================="
echo "🚀 Ahora puedes arrancar el backend:"
echo "   mvn spring-boot:run"
