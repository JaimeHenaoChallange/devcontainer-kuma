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