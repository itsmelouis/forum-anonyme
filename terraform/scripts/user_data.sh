#!/bin/bash
set -e

# Log all output
exec > >(tee /var/log/user-data.log) 2>&1
echo "=== Starting Forum Anonyme deployment at $(date) ==="

# Update system
echo "Updating system packages..."
yum update -y

# Install Docker
echo "Installing Docker..."
yum install -y docker git

# Start and enable Docker
systemctl start docker
systemctl enable docker
usermod -a -G docker ec2-user

# Install Docker Compose
echo "Installing Docker Compose..."
curl -L "https://github.com/docker/compose/releases/download/v2.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
ln -sf /usr/local/bin/docker-compose /usr/bin/docker-compose

# Verify installations
docker --version
docker-compose --version

# Create application directory
APP_DIR="/opt/${project_name}"
mkdir -p $APP_DIR
cd $APP_DIR

echo "Creating docker-compose.yml..."

# Create docker-compose.yml for production deployment
cat > docker-compose.yml << 'EOFCOMPOSE'
version: "3.8"

services:
  db:
    image: postgres:16
    environment:
      POSTGRES_USER: forum
      POSTGRES_PASSWORD: ${db_password}
      POSTGRES_DB: forumdb
    volumes:
      - db-data:/var/lib/postgresql/data
    networks:
      - backend
    restart: unless-stopped
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U forum"]
      interval: 10s
      timeout: 5s
      retries: 5

  api:
    image: ghcr.io/${github_repository}/api:${docker_image_tag}
    ports:
      - "3000:3000"
    depends_on:
      db:
        condition: service_healthy
    environment:
      - DATABASE_URL=postgresql://forum:${db_password}@db:5432/forumdb
      - NODE_ENV=production
    networks:
      - backend
    restart: unless-stopped

  thread:
    image: ghcr.io/${github_repository}/thread:${docker_image_tag}
    ports:
      - "80:3000"
    environment:
      - API_URL=http://api:3000/threads
    networks:
      - backend
    restart: unless-stopped
    depends_on:
      - api

  sender:
    image: ghcr.io/${github_repository}/sender:${docker_image_tag}
    ports:
      - "8080:3000"
    environment:
      - API_URL=http://api:3000/threads
    networks:
      - backend
    restart: unless-stopped
    depends_on:
      - api

volumes:
  db-data:

networks:
  backend:
EOFCOMPOSE

echo "Substituting variables in docker-compose.yml..."
sed -i "s/\${db_password}/${db_password}/g" docker-compose.yml
sed -i "s|\${github_repository}|${github_repository}|g" docker-compose.yml
sed -i "s/\${docker_image_tag}/${docker_image_tag}/g" docker-compose.yml

echo "Docker Compose file created:"
cat docker-compose.yml

# Create systemd service
echo "Creating systemd service..."
cat > /etc/systemd/system/${project_name}.service << EOFSERVICE
[Unit]
Description=Forum Anonyme Application
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=$APP_DIR
ExecStart=/usr/local/bin/docker-compose up -d
ExecStop=/usr/local/bin/docker-compose down
ExecReload=/usr/local/bin/docker-compose pull && /usr/local/bin/docker-compose up -d
TimeoutStartSec=600
User=root

[Install]
WantedBy=multi-user.target
EOFSERVICE

# Reload systemd and enable service
systemctl daemon-reload
systemctl enable ${project_name}.service

# Wait for Docker to be fully ready
echo "Waiting for Docker to be ready..."
sleep 10

# Pull images (this may take a while)
echo "Pulling Docker images..."
docker-compose pull || echo "Warning: Could not pull all images, will try to start anyway"

# Start the application
echo "Starting ${project_name} services..."
systemctl start ${project_name}.service

# Wait for services to start
echo "Waiting for services to start..."
sleep 30

# Check status
echo "=== Service Status ==="
systemctl status ${project_name}.service --no-pager || true

echo "=== Docker Containers ==="
docker-compose ps

echo "=== Docker Logs ==="
docker-compose logs --tail=50

# Get public IP
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)

echo ""
echo "=== Deployment completed at $(date) ==="
echo "Services should be available at:"
echo "  - Thread (view messages): http://$PUBLIC_IP"
echo "  - Sender (post messages): http://$PUBLIC_IP:8080"
echo "  - API (backend): http://$PUBLIC_IP:3000"
echo ""
echo "To check logs: docker-compose -f $APP_DIR/docker-compose.yml logs -f"
echo "To restart: systemctl restart ${project_name}.service"
