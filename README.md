# Kuma Kubernetes Lab

Este repositorio contiene un entorno preconfigurado para realizar laboratorios con **Kuma**, una malla de servicios (Service Mesh) desarrollada por Kong. El entorno incluye scripts automatizados para instalar, configurar y gestionar Kuma en un clúster de Kubernetes utilizando **Helm**. Además, se proporciona un contenedor de desarrollo (`devcontainer`) con todas las herramientas necesarias preinstaladas.

---

## **Objetivo del Proyecto**

El objetivo principal es proporcionar un entorno práctico para aprender y experimentar con Kuma en Kubernetes. Los laboratorios permiten:
- Instalar y configurar Kuma en un clúster de Kubernetes.
- Gestionar versiones de Kuma (instalación, actualización).
- Configurar la inyección de sidecars para habilitar la malla de servicios.
- Configurar Ingress para acceder al plano de control de Kuma.

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

#### **setup.sh**
Este script se utiliza para configurar el entorno inicial. Incluye funciones para instalar herramientas adicionales, configurar SSH, y preparar el clúster de Kubernetes.

##### **Funciones Principales**
1. **Configuración de SSH**:
   - Genera claves SSH para interactuar con repositorios remotos.
   - Añade la clave pública al agente SSH.

2. **Instalación de ArgoCD**:
   - Instala y configura ArgoCD en el clúster de Kubernetes.
   - Descarga el cliente de ArgoCD (`argocd-cli`) si no está instalado.

3. **Configuración de Minikube**:
   - Inicia un clúster de Minikube con recursos predefinidos.
   - Habilita complementos como `ingress` y `metrics-server`.

4. **Configuración de Kuma**:
   - Llama al script `kuma.sh` para instalar y configurar Kuma.

2. Abrir en un Dev Container
Abre el proyecto en Visual Studio Code y selecciona la opción para abrir en un contenedor de desarrollo.

3. Ejecutar el Script de Configuración
Ejecuta el script setup.sh para configurar el entorno inicial.

```bash
chmod +x setup.sh
./setup.sh
```

4. Ejecutar el Script de Kuma
Ejecuta el script kuma.sh para instalar y gestionar Kuma.

```bash
chmod +x [kuma.sh](http://_vscodecontentref_/2)
[kuma.sh](http://_vscodecontentref_/3)
```
Detalles de las Opciones del Script kuma.sh
1. Verificar dependencias
Verifica que kubectl y helm estén instalados.
Si alguna herramienta falta, muestra un mensaje de error y detiene la ejecución.
2. Listar versiones disponibles de Kuma
Consulta el repositorio oficial de Helm de Kuma (https://kumahq.github.io/charts).
Muestra una lista de versiones disponibles en orden descendente.
3. Instalar Kuma con una versión específica usando Helm
Solicita al usuario que introduzca una versión de Kuma.
Usa Helm para instalar Kuma en el namespace kuma-system.
Espera a que los pods de Kuma estén en estado Ready.
4. Actualizar Kuma con Helm
Detecta la versión actual de Kuma instalada.
Lista las versiones disponibles para la actualización.
Solicita al usuario que seleccione una versión para actualizar.
Realiza la actualización utilizando Helm.
Espera a que los pods de Kuma estén en estado Ready.
5. Habilitar inyección de sidecars
Habilita la inyección automática de sidecars de Kuma en el namespace default.
Esto permite que Kuma gestione automáticamente el tráfico de red de los servicios en este namespace.
6. Configurar Ingress para Kuma
Configura un recurso de Ingress para exponer el plano de control de Kuma.
Agrega la IP del nodo de Kubernetes al archivo /etc/hosts para que kuma.local apunte a esa IP.

---

#### **kuma.sh**
Este script es el núcleo del laboratorio de Kuma. Permite instalar, actualizar y configurar Kuma en un clúster de Kubernetes utilizando Helm.

##### **Opciones del Menú**
1. **Verificar dependencias**:
   - Verifica que las herramientas necesarias (`kubectl`, `helm`) estén instaladas y disponibles en el sistema.

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

Notas Adicionales
Requisitos del Clúster
Recursos:
Al menos 4 CPUs y 8 GB de RAM para Minikube.
Complementos de Minikube:
Habilitar los complementos necesarios:

```bash
minikube addons enable ingress
minikube addons enable metrics-server
```

Acceso al Plano de Control
Una vez configurado el Ingress, puedes acceder al plano de control de Kuma en:

```bash
http://kuma.local
```

Verificar el Estado de los Pods
Después de instalar o actualizar Kuma, verifica que los pods estén en estado Running:

```bash
kubectl get pods -n kuma-system
```