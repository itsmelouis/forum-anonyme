FROM node:18-alpine

RUN corepack enable && corepack prepare pnpm@latest --activate

WORKDIR /app

COPY . .

RUN pnpm install --frozen-lockfile && pnpm build

EXPOSE 3000

CMD ["pnpm", "preview", "--host", "--port", "3000"]
