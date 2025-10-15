#!/bin/sh

# Script pour injecter les variables d'environnement dans le JS buildé
# Remplace __API_URL__ par la vraie valeur

API_URL=${API_URL:-http://localhost:3000}

echo "Injecting environment variables..."
echo "API_URL: $API_URL"

# Trouver tous les fichiers JS dans /usr/share/nginx/html/assets
find /usr/share/nginx/html/assets -type f -name '*.js' -exec sed -i \
  -e "s|__API_URL__|$API_URL|g" \
  {} \;

# Démarrer Nginx
exec nginx -g 'daemon off;'
