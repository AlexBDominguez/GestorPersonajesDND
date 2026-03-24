#!/bin/bash

# Script para verificar el estado de la sincronización de datos
# Ejecuta: bash backend/check-sync-status.sh

echo "🔍 Verificando estado de la base de datos..."
echo "=============================================="
echo ""

docker exec dnd-mysql mysql -u dnd_user -pdnd_password dnd_character_manager -e "
SELECT
    'Razas (Race)' as 'Tabla',
    COUNT(*) as 'Registros',
    CASE
        WHEN COUNT(*) >= 9 THEN '✅ Completo'
        ELSE '⏳ En progreso'
    END as 'Estado'
FROM race
UNION ALL
SELECT
    'Clases (Classes)',
    COUNT(*),
    CASE
        WHEN COUNT(*) >= 12 THEN '✅ Completo'
        ELSE '⏳ En progreso'
    END
FROM classes
UNION ALL
SELECT
    'Hechizos (Spells)',
    COUNT(*),
    CASE
        WHEN COUNT(*) >= 300 THEN '✅ Completo'
        ELSE '⏳ En progreso'
    END
FROM spells
UNION ALL
SELECT
    'Habilidades (Skills)',
    COUNT(*),
    CASE
        WHEN COUNT(*) >= 18 THEN '✅ Completo'
        ELSE '⏳ En progreso'
    END
FROM skills
UNION ALL
SELECT
    'Trasfondos (Backgrounds)',
    COUNT(*),
    CASE
        WHEN COUNT(*) >= 13 THEN '✅ Completo'
        ELSE '⏳ En progreso'
    END
FROM backgrounds
UNION ALL
SELECT
    'Subclases (Subclasses)',
    COUNT(*),
    CASE
        WHEN COUNT(*) >= 100 THEN '✅ Completo'
        ELSE '⏳ En progreso'
    END
FROM subclasses
UNION ALL
SELECT
    'Competencias (Proficiencies)',
    COUNT(*),
    CASE
        WHEN COUNT(*) >= 100 THEN '✅ Completo'
        ELSE '⏳ En progreso'
    END
FROM proficiencies
UNION ALL
SELECT
    'Idiomas (Languages)',
    COUNT(*),
    CASE
        WHEN COUNT(*) >= 14 THEN '✅ Completo'
        ELSE '⏳ En progreso'
    END
FROM languages
UNION ALL
SELECT
    'Usuarios (Users)',
    COUNT(*),
    '✅'
FROM users;
" 2>&1 | grep -v "Warning"

echo ""
echo "=============================================="
echo "📝 Nota: Si alguna tabla muestra '⏳ En progreso',"
echo "   la sincronización todavía está corriendo."
echo "   Espera unos minutos y vuelve a ejecutar este script."
echo ""
echo "Para ver el progreso en tiempo real, ejecuta:"
echo "  tail -f /tmp/backend.log | grep -E 'Syncing|synced'"
