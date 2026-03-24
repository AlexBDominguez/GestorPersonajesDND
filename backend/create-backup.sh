#!/bin/bash

# Script para crear backup de la base de datos DungeonScroll
# Uso: bash backend/create-backup.sh

set -e  # Salir si hay algún error

BACKUP_DIR="./backups"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/dnd_backup_${DATE}.sql"

echo "🗄️  Creando backup de la base de datos..."
echo "=============================================="

# Crear directorio de backups si no existe
mkdir -p "$BACKUP_DIR"

# Verificar que MySQL está corriendo
if ! docker ps | grep -q dnd-mysql; then
    echo "❌ Error: El contenedor MySQL no está corriendo"
    echo "   Ejecuta: docker compose up -d"
    exit 1
fi

# Crear backup
echo "📦 Exportando datos..."
docker exec dnd-mysql mysqldump -u dnd_user -pdnd_password \
    --single-transaction \
    --quick \
    --lock-tables=false \
    dnd_character_manager > "$BACKUP_FILE" 2>/dev/null

# Verificar que el backup se creó correctamente
if [ ! -f "$BACKUP_FILE" ]; then
    echo "❌ Error: No se pudo crear el backup"
    exit 1
fi

# Mostrar información del backup
FILE_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
echo ""
echo "✅ Backup creado exitosamente!"
echo "   Archivo: $BACKUP_FILE"
echo "   Tamaño: $FILE_SIZE"
echo ""

# Comprimir el backup
echo "🗜️  Comprimiendo backup..."
gzip "$BACKUP_FILE"
COMPRESSED_FILE="${BACKUP_FILE}.gz"
COMPRESSED_SIZE=$(du -h "$COMPRESSED_FILE" | cut -f1)

echo ""
echo "✅ Backup comprimido!"
echo "   Archivo: $COMPRESSED_FILE"
echo "   Tamaño: $COMPRESSED_SIZE"
echo ""
echo "=============================================="
echo "📝 Para restaurar este backup en otro PC:"
echo "   1. Copia $COMPRESSED_FILE al nuevo PC"
echo "   2. Descomprime: gunzip $(basename $COMPRESSED_FILE)"
echo "   3. Restaura: docker exec -i dnd-mysql mysql -u dnd_user -pdnd_password dnd_character_manager < $(basename $BACKUP_FILE)"
echo ""
echo "💡 Tip: Guarda este backup en un lugar seguro (USB, nube, etc.)"
