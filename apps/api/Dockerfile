FROM node:18-alpine

# Activation PNPM via Corepack
RUN corepack enable && corepack prepare pnpm@latest --activate

WORKDIR /app

# Copier le package.json de l'application
COPY package.json ./

# Copier le reste des fichiers de l'application
COPY . .

# Installation et build
# Utiliser pnpm install sans --frozen-lockfile car le fichier pnpm-lock.yaml n'est pas disponible
RUN pnpm install

EXPOSE 3000

CMD ["node", "src/index.js"]
