# Kuma Kubernetes Lab

Este repositorio contiene un entorno preconfigurado para realizar laboratorios con **Kuma**, una malla de servicios (Service Mesh) desarrollada por Kong. El entorno incluye scripts automatizados para instalar, configurar y gestionar Kuma en un clúster de Kubernetes utilizando **Helm**. Además, se proporciona un contenedor de desarrollo (`devcontainer`) con todas las herramientas necesarias preinstaladas.

---

## **Objetivo del Proyecto**

El objetivo principal es proporcionar un entorno práctico para aprender y experimentar con Kuma en Kubernetes. Los laboratorios permiten:
- Instalar y configurar Kuma en un clúster de Kubernetes.
- Gestionar versiones de Kuma (instalación, actualización).
- Configurar la inyección de sidecars para habilitar la malla de servicios.
- Configurar Ingress para acceder al plano de control de Kuma.
- Desplegar aplicaciones dockerizadas (frontend, backend, database y Redis) y gestionarlas con Kuma.

---

## **Arquitectura del Proyecto**

El laboratorio incluye un clúster de Kubernetes con las siguientes aplicaciones y componentes:

- **Frontend**: Una aplicación React servida con Nginx.
- **Backend**: Una API básica escrita en Python.
- **Database**: Un contenedor de PostgreSQL para almacenar datos.
- **Redis**: Un contenedor de Redis para almacenamiento en caché.
- **Kuma**: Malla de servicios para gestionar el tráfico entre los servicios.

### Diagrama de Arquitectura

```plaintext
+-------------------+       +-------------------+       +-------------------+
|                   |       |                   |       |                   |
|     Frontend      | <---> |      Backend      | <---> |     Database      |
|                   |       |                   |       |                   |
+-------------------+       +-------------------+       +-------------------+
                                ^
                                |
                                v
                          +-------------------+
                          |       Redis       |
                          +-------------------+

                          [Gestionado por Kuma]
```

---

## **Estructura del Proyecto**

### **1. Devcontainer**

El entorno de desarrollo está configurado mediante un contenedor de desarrollo (`devcontainer`). Este incluye las siguientes herramientas preinstaladas:
- **kubectl**: Para interactuar con el clúster de Kubernetes.
- **Helm**: Para gestionar aplicaciones en Kubernetes.
- **Minikube** (opcional): Para ejecutar un clúster de Kubernetes local.
- Dependencias necesarias para ejecutar los scripts.

El contenedor asegura que todos los desarrolladores trabajen en un entorno uniforme y preconfigurado.

---

### **2. Scripts**

#### **kuma.sh**
Este script es el núcleo del laboratorio de Kuma. Permite instalar, actualizar y configurar Kuma en un clúster de Kubernetes utilizando Helm.

##### **Opciones del Menú**
1. **Verificar dependencias**:
   - Verifica que las herramientas necesarias (`kubectl`, `helm`, `aws-cli`, `eksctl`) estén instaladas y disponibles en el sistema.
   - Valida que las credenciales de AWS estén configuradas correctamente.
   - Verifica que el clúster de EKS sea accesible y que `kubectl` esté configurado para conectarse al clúster.

2. **Listar versiones disponibles de Kuma**:
   - Consulta el repositorio oficial de Helm de Kuma para obtener una lista de versiones disponibles.

3. **Instalar Kuma con una versión específica usando Helm**:
   - Permite al usuario seleccionar una versión específica de Kuma para instalar.
   - Usa Helm para instalar Kuma en el namespace `kuma-system`.

4. **Actualizar Kuma con Helm**:
   - Detecta la versión actual de Kuma instalada.
   - Lista las versiones disponibles para la actualización.
   - Permite al usuario seleccionar una versión para actualizar.
   - Usa Helm para realizar la actualización.

5. **Habilitar inyección de sidecars**:
   - Habilita la inyección automática de sidecars de Kuma en el namespace `default`.

6. **Configurar Ingress para Kuma**:
   - Configura un recurso de Ingress para exponer el plano de control de Kuma (`kuma-control-plane`) en el host `kuma.local`.
   - Agrega la IP del nodo de Kubernetes al archivo `/etc/hosts`.

7. **Salir**:
   - Finaliza el script.

---

## **Cómo Usar el Proyecto**

### **1. Clonar el Repositorio**
Clona este repositorio en tu máquina local o en un entorno de desarrollo compatible con Dev Containers.

```bash
git clone <URL_DEL_REPOSITORIO>
cd <NOMBRE_DEL_REPOSITORIO>
```
---

### **2. Construir las Imágenes Docker**
Construye las imágenes para cada componente y súbelas a Docker Hub:

```bash
# Frontend
docker build -t <dockerhub-username>/frontend:latest -f frontend/Docker/Dockerfile frontend/
docker push <dockerhub-username>/frontend:latest

# Backend
docker build -t <dockerhub-username>/backend:latest backend/
docker push <dockerhub-username>/backend:latest

# Database
docker build -t <dockerhub-username>/database:latest database/
docker push <dockerhub-username>/database:latest

# Redis
docker build -t <dockerhub-username>/redis:latest redis/
docker push <dockerhub-username>/redis:latest
```

### **3. Desplegar las Aplicaciones**
Aplica los manifiestos de Kubernetes para cada componente:

```bash
kubectl apply -f backend/deployment.yaml
kubectl apply -f backend/service.yaml

kubectl apply -f database/deployment.yaml
kubectl apply -f database/service.yaml

kubectl apply -f frontend/deployment.yaml
kubectl apply -f frontend/service.yaml

kubectl apply -f redis/deployment.yaml
kubectl apply -f redis/service.yaml
```

### **4. Configurar Ingress**
Configura un recurso Ingress para exponer el servicio del frontend y otros servicios según sea necesario. Asegúrate de agregar el IP del nodo de Minikube al archivo /etc/hosts.

Nota Importante sobre Ingress
Por defecto, Kubernetes se vincula a la IP de una interfaz específica en lugar de localhost o todas las interfaces. Por esta razón, debes usar la IP del nodo de Kubernetes (por ejemplo, la IP de Minikube) para conectarte, incluso si solo tienes un nodo.

---

## **Flujo de Trabajo**

1. Construcción de Imágenes Docker
2. Subida de Imágenes a Docker Hub
3. Despliegue en Kubernetes
4. Configuración de Kuma y Ingress
5. Pruebas de Conectividad y Observabilidad

---

## **Estructura del Repositorio**

```plaintext
/workspaces/kuma/
├── backend/
│   ├── argocd-application.yaml
│   ├── deployment.yaml
│   ├── service.yaml
│   └── Docker/
│       └── Dockerfile
├── database/
│   ├── argocd-application.yaml
│   ├── deployment.yaml
│   ├── service.yaml
│   └── Docker/
│       └── Dockerfile
├── frontend/
│   ├── argocd-application.yaml
│   ├── deployment.yaml
│   ├── ingress.yaml
│   ├── package.json
│   ├── service.yaml
│   └── Docker/
│       └── Dockerfile
├── redis/
│   ├── argocd-application.yaml
│   ├── deployment.yaml
│   ├── service.yaml
│   └── Docker/
│       └── Dockerfile
├── kuma/
│   ├── argocd-application.yaml
│   ├── httpbin.yaml
│   ├── kuma-ingress.yaml
│   ├── kuma-mtls.yaml
│   └── ...
├── repos/
│   ├── app-1/
│   │   ├── .gitignore
│   │   ├── README.md
│   │   ├── .github/
│   │   ├── Docker/
│   │   └── Kubernetes/
│   ├── app-2/
│   └── KubeOps/
│       ├── README.md
│       ├── Docker/
│       ├── Kubernetes/
│       └── .github/
├── setup.sh
└── README.md
```

---

## **Notas**

- Kuma: Gestiona el tráfico entre servicios y proporciona observabilidad.
- Minikube: Asegúrate de usar el IP del nodo de Minikube para acceder a los servicios.
- Docker Hub: Reemplaza <dockerhub-username> con tu nombre de usuario en Docker Hub.

---

