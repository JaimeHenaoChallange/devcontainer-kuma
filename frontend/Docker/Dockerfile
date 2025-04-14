FROM node:18 AS build

# Establecer el directorio de trabajo en el contenedor
WORKDIR /app

# Copiar los archivos necesarios para la construcción
COPY ../package.json ../package-lock.json ./
RUN npm install

COPY ../ ./
RUN npm run build

# Fase de producción
FROM nginx:latest
COPY --from=build /app/build /usr/share/nginx/html

# Exponer el puerto
EXPOSE 80

# Comando por defecto
CMD ["nginx", "-g", "daemon off;"]