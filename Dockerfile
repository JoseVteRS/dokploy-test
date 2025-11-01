# Usamos una imagen oficial de Node.js como base.
FROM node:20-alpine AS builder

# Creamos un directorio de trabajo
WORKDIR /app

# Copiamos los archivos de dependencias
COPY package.json package-lock.json* pnpm-lock.yaml* yarn.lock* ./

# Instalamos dependencias
RUN npm install

# Copiamos el resto del código de la aplicación
COPY . .

# Construimos la aplicación Next.js
RUN npm run build

# ---- Imagen de producción ----
FROM node:20-alpine AS runner

WORKDIR /app

# Copiamos las dependencias necesarias de node_modules de la build
COPY --from=builder /app/node_modules ./node_modules

# Copiamos la build de .next y los archivos necesarios
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/package.json ./package.json

# Especificamos la variable de entorno de producción
ENV NODE_ENV=production

# Exponemos el puerto 3000 (puerto por defecto de Next.js)
EXPOSE 3000

# Comando por defecto para iniciar la app
CMD ["npm", "run", "start"]
