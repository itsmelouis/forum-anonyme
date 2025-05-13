FROM node:18-alpine

RUN corepack enable && corepack prepare pnpm@latest --activate

WORKDIR /app

# Copier le package.json de l'application
COPY package.json ./

# Copier le reste des fichiers de l'application
COPY . .

# Installation des dépendances et build
# Utiliser --no-frozen-lockfile car le fichier pnpm-lock.yaml n'est pas disponible
RUN pnpm install && pnpm build

EXPOSE 3000

CMD ["pnpm", "preview", "--host", "--port", "3000"]
