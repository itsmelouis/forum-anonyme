FROM node:18-alpine

# Activation PNPM via Corepack
RUN corepack enable && corepack prepare pnpm@latest --activate

WORKDIR /app

# Copie uniquement ce service
COPY . .

# Installation et build
RUN pnpm install --frozen-lockfile

EXPOSE 3000

CMD ["node", "src/index.js"]
