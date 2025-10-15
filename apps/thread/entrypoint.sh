#!/bin/sh

# Script pour injecter les variables d'environnement dans le JS buildé
# Remplace __API_URL__ et __SENDER_URL__ par les vraies valeurs

API_URL=${API_URL:-http://localhost:3000}
SENDER_URL=${SENDER_URL:-http://localhost:8080}

echo "Injecting environment variables..."
echo "API_URL: $API_URL"
echo "SENDER_URL: $SENDER_URL"

# Trouver tous les fichiers JS dans /usr/share/nginx/html/assets
find /usr/share/nginx/html/assets -type f -name '*.js' -exec sed -i \
  -e "s|__API_URL__|$API_URL|g" \
  -e "s|__SENDER_URL__|$SENDER_URL|g" \
  {} \;

# Démarrer Nginx
exec nginx -g 'daemon off;'
