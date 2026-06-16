FROM node:20-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

# Usaremos ts-node-dev o compilaremos el TypeScript.
# Como es para desarrollo/prueba fácil, usaremos ts-node.
# Instalamos ts-node globalmente para asegurar que esté disponible.
RUN npm install -g tsx typescript

EXPOSE 3000

CMD ["npx", "tsx", "server.ts"]
