#!/bin/bash

# Colores para el output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Función para mostrar mensajes
show_success() { echo -e "\n${GREEN}✅ $1${NC}"; }
show_error() { echo -e "\n${RED}❌ $1${NC}"; }
show_process() { echo -e "\n${YELLOW}⏳ $1${NC}"; }
show_info() { echo -e "\n${YELLOW}ℹ️  $1${NC}"; }
pause() { read -p "Presiona Enter para continuar..."; }

# Función para manejar errores
handle_error() {
    local exit_code=$1
    local message="$2"
    if [ $exit_code -ne 0 ]; then
        show_error "$message"
        exit $exit_code
    fi
}

# Función para verificar si un comando está disponible
check_command() {
    local cmd=$1
    if ! command -v "$cmd" &>/dev/null; then
        show_error "El comando '$cmd' no está disponible. Por favor, instálalo antes de continuar."
        case "$cmd" in
            kubectl)
                echo -e "${YELLOW}Sugerencia:${NC} Puedes instalar kubectl siguiendo las instrucciones oficiales: https://kubernetes.io/docs/tasks/tools/install-kubectl/"
                ;;
            helm)
                echo -e "${YELLOW}Sugerencia:${NC} Puedes instalar Helm siguiendo las instrucciones oficiales: https://helm.sh/docs/intro/install/"
                ;;
            aws)
                echo -e "${YELLOW}Sugerencia:${NC} Puedes instalar AWS CLI siguiendo las instrucciones oficiales: https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html"
                ;;
            eksctl)
                echo -e "${YELLOW}Sugerencia:${NC} Puedes instalar eksctl siguiendo las instrucciones oficiales: https://eksctl.io/introduction/#installation"
                ;;
        esac
        exit 1
    fi
}

# Verificar que los comandos necesarios estén disponibles
check_dependencies() {
    show_process "Verificando dependencias necesarias para trabajar con Kubernetes y EKS..."

    # Verificar herramientas básicas
    check_command "kubectl"
    check_command "helm"

    # Verificar herramientas específicas de AWS y EKS
    check_command "aws"
    check_command "eksctl"

    # Verificar configuración de AWS CLI
    show_process "Verificando configuración de AWS CLI..."
    if ! aws sts get-caller-identity &>/dev/null; then
        show_error "No se pudo verificar la identidad de AWS. Asegúrate de que las credenciales de AWS estén configuradas correctamente."
        echo -e "${YELLOW}Sugerencia:${NC} Configura tus credenciales de AWS usando el comando: aws configure"
        exit 1
    fi
    show_success "AWS CLI está configurado correctamente."

    # Verificar acceso al clúster de EKS
    show_process "Verificando acceso al clúster de EKS..."
    local cluster_name
    cluster_name=$(eksctl get cluster -o json | jq -r '.[0].metadata.name' 2>/dev/null)
    if [[ -z "$cluster_name" ]]; then
        show_error "No se encontró ningún clúster de EKS accesible. Asegúrate de que el clúster esté creado y configurado."
        echo -e "${YELLOW}Sugerencia:${NC} Puedes crear un clúster de EKS usando eksctl: eksctl create cluster --name <nombre-del-cluster>"
        exit 1
    fi
    show_success "Clúster de EKS detectado: ${GREEN}$cluster_name${NC}"

    # Verificar conectividad con el clúster
    show_process "Verificando conectividad con el clúster de EKS..."
    if ! kubectl get nodes &>/dev/null; then
        show_error "No se pudo conectar al clúster de EKS. Asegúrate de que el contexto de kubectl esté configurado correctamente."
        echo -e "${YELLOW}Sugerencia:${NC} Configura el contexto de kubectl para el clúster de EKS usando: aws eks update-kubeconfig --name $cluster_name"
        exit 1
    fi
    show_success "Conectividad con el clúster de EKS verificada."

    show_success "Todas las dependencias están disponibles y configuradas correctamente. El entorno está listo para trabajar con EKS."
}

# Función para listar versiones disponibles de Kuma con Helm
list_kuma_versions() {
    show_process "Obteniendo versiones disponibles de Kuma desde el repositorio de Helm..."
    
    # Asegurarse de que el repositorio de Kuma esté agregado
    helm repo add kuma https://kumahq.github.io/charts &>/dev/null
    handle_error $? "Error al agregar el repositorio de Helm de Kuma."

    helm repo update &>/dev/null
    handle_error $? "Error al actualizar los repositorios de Helm."

    # Listar las versiones disponibles
    local versions
    versions=$(helm search repo kuma/kuma --versions | awk '{print $2}' | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' | sort -Vr)

    if [[ -z "$versions" ]]; then
        show_error "No se encontraron versiones disponibles de Kuma. Verifica tu conexión a internet."
        exit 1
    fi

    echo -e "${GREEN}Versiones disponibles de Kuma:${NC}"
    echo "$versions"
    pause
    echo "$versions"
}

# Función para instalar Kuma con una versión específica usando Helm
install_kuma_with_helm_version() {
    local versions
    versions=$(list_kuma_versions)

    echo -e "${YELLOW}Introduce la versión de Kuma que deseas instalar (por ejemplo, 2.10.0):${NC}"
    read -r kuma_version

    if [[ -z "$kuma_version" ]]; then
        show_error "No se proporcionó una versión válida."
        return 1
    fi

    show_process "Instalando Kuma versión $kuma_version con Helm..."

    # Instalar Kuma con la versión seleccionada
    helm install kuma kuma/kuma --namespace kuma-system --create-namespace --version "$kuma_version"
    handle_error $? "Error al instalar Kuma versión $kuma_version con Helm."

    show_process "Esperando que los pods de Kuma estén listos..."
    kubectl wait --for=condition=Ready pods --all -n kuma-system --timeout=300s
    handle_error $? "Error al esperar que los pods de Kuma estén listos."

    show_success "Kuma versión $kuma_version instalado correctamente con Helm."
    pause
}

# Función para actualizar Kuma con Helm
upgrade_kuma_with_helm() {
    # Obtener la versión actual de Kuma instalada
    show_process "Obteniendo la versión actual de Kuma instalada..."
    local current_version
    current_version=$(helm list -n kuma-system -o json | jq -r '.[0].chart' | awk -F'-' '{print $2}')
    
    if [[ -z "$current_version" ]]; then
        show_error "No se pudo determinar la versión actual de Kuma. Asegúrate de que Kuma esté instalado."
        return 1
    fi

    show_info "La versión actual de Kuma instalada es: ${GREEN}$current_version${NC}"

    # Listar las versiones disponibles para la actualización
    local versions
    versions=$(list_kuma_versions)

    echo -e "${YELLOW}Versiones disponibles para actualizar:${NC}"
    echo "$versions"

    # Solicitar al usuario la versión a la que desea actualizar
    echo -e "${YELLOW}Introduce la versión de Kuma a la que deseas actualizar (o presiona Enter para la última versión):${NC}"
    read -r kuma_version

    if [[ -z "$kuma_version" ]]; then
        kuma_version=$(echo "$versions" | head -n 1)
        show_info "No se proporcionó una versión. Se usará la última versión disponible: ${GREEN}$kuma_version${NC}"
    fi

    # Validar que la versión seleccionada esté en la lista de versiones disponibles
    if ! echo "$versions" | grep -q "^$kuma_version$"; then
        show_error "La versión seleccionada ($kuma_version) no está disponible. Por favor, selecciona una versión válida."
        return 1
    fi

    # Confirmar la actualización
    echo -e "${YELLOW}¿Estás seguro de que deseas actualizar Kuma de la versión ${GREEN}$current_version${YELLOW} a la versión ${GREEN}$kuma_version${YELLOW}? (s/n):${NC}"
    read -r confirm
    if [[ "$confirm" != "s" && "$confirm" != "S" ]]; then
        show_info "Actualización cancelada por el usuario."
        return 0
    fi

    # Realizar la actualización
    show_process "Actualizando Kuma a la versión $kuma_version con Helm..."
    helm upgrade kuma kuma/kuma --namespace kuma-system --version "$kuma_version"
    handle_error $? "Error al actualizar Kuma a la versión $kuma_version con Helm."

    # Esperar a que los pods estén listos
    show_process "Esperando que los pods de Kuma estén listos..."
    kubectl wait --for=condition=Ready pods --all -n kuma-system --timeout=300s
    handle_error $? "Error al esperar que los pods de Kuma estén listos."

    show_success "Kuma actualizado correctamente de la versión $current_version a la versión $kuma_version con Helm."
    pause
}

# Función para habilitar la inyección de sidecars en el namespace default
enable_kuma_sidecar_injection() {
    show_process "Habilitando la inyección de sidecars de Kuma en el namespace 'default'..."
    kubectl annotate namespace default kuma.io/sidecar-injection=enabled --overwrite
    handle_error $? "Error al habilitar la inyección de sidecars de Kuma."
    show_success "Inyección de sidecars habilitada en el namespace 'default'."
    pause
}

# Función para configurar Ingress para Kuma
configure_kuma_ingress() {
    show_process "Configurando Ingress para Kuma..."
    local node_ip
    node_ip=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')

    if [[ -z "$node_ip" ]]; then
        show_error "No se pudo obtener la IP del nodo de Kubernetes."
        exit 1
    fi

    # Crear un manifiesto de Ingress para Kuma
    cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: kuma-ingress
  namespace: kuma-system
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: kuma.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: kuma-control-plane
            port:
              number: 5681
EOF
    handle_error $? "Error al configurar Ingress para Kuma."

    # Agregar la IP del nodo al archivo /etc/hosts
    echo "$node_ip kuma.local" | sudo tee -a /etc/hosts
    handle_error $? "Error al agregar la IP al archivo /etc/hosts."

    show_success "Ingress configurado correctamente. Accede a Kuma en http://kuma.local"
    pause
}

# Submenú para Kuma
show_kuma_menu() {
    clear
    echo -e "${GREEN}=== Menú Kuma ===${NC}"
    echo "1. Verificar dependencias"
    echo "2. Listar versiones disponibles de Kuma"
    echo "3. Instalar Kuma con una versión específica usando Helm"
    echo "4. Actualizar Kuma con Helm"
    echo "5. Habilitar inyección de sidecars"
    echo "6. Configurar Ingress para Kuma"
    echo "7. Salir"
    echo -e "${YELLOW}Selecciona una opción:${NC}"
}

# Loop del submenú de Kuma
while true; do
    show_kuma_menu
    read -r kuma_opt
    case $kuma_opt in
        1) check_dependencies ;;
        2) list_kuma_versions ;;
        3) install_kuma_with_helm_version ;;
        4) upgrade_kuma_with_helm ;;
        5) enable_kuma_sidecar_injection ;;
        6) configure_kuma_ingress ;;
        7) break ;;
        *) show_error "Opción inválida." ;;
    esac
done