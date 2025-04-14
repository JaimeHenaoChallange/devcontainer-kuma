# Dockerfile
FROM python:3.9-slim

# Instalar curl y dependencias necesarias
RUN apt-get update && apt-get install -y curl && apt-get clean

# Configurar el directorio de trabajo
WORKDIR /app

# Copiar el código fuente (si tienes un backend real)
COPY . /app

# Exponer el puerto
EXPOSE 8080

# Comando por defecto
CMD ["python", "-m", "http.server", "8080"]