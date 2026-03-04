#!/bin/bash

# Script para ejecutar la aplicación con MySQL en Docker

echo "🚀 Iniciando Gestor de Personajes D&D..."
echo ""

# Verificar si MySQL está corriendo
if ! docker compose ps mysql-db | grep -q "Up"; then
    echo "📦 Iniciando MySQL en Docker..."
    docker compose up -d mysql-db
    echo "⏳ Esperando a que MySQL esté listo..."
    sleep 10
else
    echo "✅ MySQL ya está corriendo"
fi

echo ""
echo "🔧 Compilando y ejecutando la aplicación Spring Boot..."
echo "📍 La aplicación estará disponible en: http://localhost:8080"
echo "📊 MySQL disponible en: localhost:3306"
echo ""

# Ejecutar la aplicación con Maven
mvn spring-boot:run
