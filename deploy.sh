#!/bin/bash

# Script de déploiement pour serveur distant
# Usage: ./deploy.sh <username> <server_ip>

USERNAME=$1
SERVER_IP=$2

if [ -z "$USERNAME" ] || [ -z "$SERVER_IP" ]; then
  echo "Usage: ./deploy.sh <username> <server_ip>"
  exit 1
fi

# Créer le docker-compose.prod.yml pour le déploiement
cat > docker-compose.prod.yml << EOL
version: "3.8"

services:
  db:
    image: postgres:16
    environment:
      POSTGRES_USER: forum
      POSTGRES_PASSWORD: secret
      POSTGRES_DB: forumdb
    volumes:
      - db-data:/var/lib/postgresql/data
      - ./db/init.sql:/docker-entrypoint-initdb.d/init.sql
    networks:
      - backend
    restart: unless-stopped

  api:
    image: ghcr.io/itsmelouis/forum-anonyme/api:latest
    environment:
      - DATABASE_URL=postgresql://forum:secret@db:5432/forumdb
      - THREAD_SERVICE_URL=http://thread:3000/threads
    networks:
      - backend
    restart: unless-stopped

  thread:
    image: ghcr.io/itsmelouis/forum-anonyme/thread:latest
    ports:
      - "80:3000"
    environment:
      - API_URL=http://api:3000/threads
    networks:
      - backend
      - frontend
    restart: unless-stopped

  sender:
    image: ghcr.io/itsmelouis/forum-anonyme/sender:latest
    ports:
      - "8080:3000"
    environment:
      - API_URL=http://api:3000/threads
    networks:
      - backend
      - frontend
    restart: unless-stopped

networks:
  backend:
    internal: true  # Réseau interne non accessible depuis l'extérieur
  frontend:
    # Réseau pour les services exposés au public

volumes:
  db-data:
    # Volume persistant pour les données de la base de données
EOL

# Créer le script d'installation sur le serveur distant
cat > server-setup.sh << EOL
#!/bin/bash

# Installation de Docker et Docker Compose si nécessaire
if ! command -v docker &> /dev/null; then
  echo "Installation de Docker..."
  curl -fsSL https://get.docker.com -o get-docker.sh
  sudo sh get-docker.sh
  sudo usermod -aG docker $USER
fi

if ! command -v docker-compose &> /dev/null; then
  echo "Installation de Docker Compose..."
  sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.3/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
fi

# Création des dossiers nécessaires
mkdir -p db

# Configuration de GitHub Container Registry
echo "Veuillez saisir votre token GitHub avec les droits 'read:packages':"
read -s GITHUB_TOKEN
echo "$GITHUB_TOKEN" | docker login ghcr.io -u itsmelouis --password-stdin

# Démarrage des services
docker-compose -f docker-compose.prod.yml up -d

echo "Déploiement terminé! L'application est accessible sur:"
echo "- Thread: http://$(hostname -I | awk '{print $1}'):80"
echo "- Sender: http://$(hostname -I | awk '{print $1}'):8080"
EOL

# Copier les fichiers nécessaires sur le serveur distant
echo "Copie des fichiers sur le serveur distant..."
scp docker-compose.prod.yml server-setup.sh db/init.sql "$USERNAME@$SERVER_IP:~/forum-anonyme/"

# Exécuter le script d'installation sur le serveur distant
echo "Exécution du script d'installation sur le serveur distant..."
ssh "$USERNAME@$SERVER_IP" "cd ~/forum-anonyme && chmod +x server-setup.sh && ./server-setup.sh"

# Nettoyage des fichiers temporaires
rm docker-compose.prod.yml server-setup.sh

echo "Déploiement terminé avec succès!"
