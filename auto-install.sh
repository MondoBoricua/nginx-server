#!/bin/bash

# Nginx Web Server - Instalador Automatico para Proxmox LXC
# Desarrollado para la comunidad de Proxmox
# Hecho en Puerto Rico

# Silenciar warnings de locale
export LC_ALL=C
export LANG=C

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# =============================================================================
# FUNCIONES DE UTILIDAD
# =============================================================================

show_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
show_success() { echo -e "${GREEN}[OK]${NC} $1"; }
show_error() { echo -e "${RED}[ERROR]${NC} $1"; }
show_warning() { echo -e "${YELLOW}[WARN]${NC} $1"; }
show_step_msg() { echo -e "${PURPLE}[STEP]${NC} $1"; }

show_step() {
    echo ""
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${WHITE}  $1${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

read_input() {
    local prompt="$1"
    local default="$2"
    local var_name="$3"
    local required="$4"

    if [ -n "$default" ]; then
        echo -ne "${GREEN}>${NC} $prompt ${CYAN}[$default]${NC}: "
    else
        echo -ne "${GREEN}>${NC} $prompt: "
    fi

    read user_input

    if [ -z "$user_input" ] && [ -n "$default" ]; then
        eval "$var_name='$default'"
    elif [ -z "$user_input" ] && [ "$required" = "true" ]; then
        show_error "$TXT_REQUIRED"
        read_input "$prompt" "$default" "$var_name" "$required"
    else
        eval "$var_name='$user_input'"
    fi
}

# =============================================================================
# SELECCION DE IDIOMA
# =============================================================================

select_language() {
    clear
    echo -e "${CYAN}"
    echo "=============================================================="
    echo "           NGINX WEB SERVER - PROXMOX LXC INSTALLER           "
    echo "=============================================================="
    echo -e "${NC}"
    echo ""
    echo "Select language / Selecciona idioma:"
    echo ""
    echo "   1) English"
    echo "   2) Espanol"
    echo ""
    echo -ne "${GREEN}>${NC} Option/Opcion [1]: "
    read LANG_CHOICE
    LANG_CHOICE=${LANG_CHOICE:-1}

    if [[ "$LANG_CHOICE" == "2" ]]; then
        set_spanish
    else
        set_english
    fi
}

set_english() {
    TXT_STEP1="STEP 1/4: Verifying Environment"
    TXT_STEP2="STEP 2/4: Container Configuration"
    TXT_STEP3="STEP 3/4: Resources and Network"
    TXT_STEP4="STEP 4/4: Confirmation"
    TXT_VERIFYING_PROXMOX="Verifying Proxmox environment..."
    TXT_PROXMOX_OK="Proxmox environment verified"
    TXT_NOT_PROXMOX="This script must be run on a Proxmox VE server"
    TXT_CMD_NOT_FOUND="Command not found"
    TXT_DETECTING_TEMPLATES="Detecting available LXC templates..."
    TXT_TEMPLATE_FOUND="Template found"
    TXT_DOWNLOADING_TEMPLATE="Downloading template..."
    TXT_TEMPLATE_DOWNLOADED="Template downloaded"
    TXT_NO_TEMPLATES="No compatible templates found (Ubuntu 22.04 or Debian 12)"
    TXT_GETTING_ID="Getting available container ID..."
    TXT_EXISTING_IDS="Existing IDs found"
    TXT_ID_ASSIGNED="Container ID assigned"
    TXT_NO_ID_AVAILABLE="No available container ID found (100-999)"
    TXT_CONTAINER_CONFIG="Container Configuration"
    TXT_CONTAINER_ID="Container ID"
    TXT_CONTAINER_NAME="Container Name"
    TXT_ROOT_PASSWORD="Root Password"
    TXT_MEMORY="Memory (MB)"
    TXT_DISK="Disk (GB)"
    TXT_CPU_CORES="CPU Cores"
    TXT_STORAGE="Storage"
    TXT_NETWORK_BRIDGE="Network Bridge"
    TXT_REQUIRED="This field is required"
    TXT_PASSWORD_SHORT="Password must be at least 5 characters (Proxmox requirement)"
    TXT_AVAILABLE_STORAGES="Available storages:"
    TXT_AVAILABLE_BRIDGES="Available network bridges:"
    TXT_CONFIRM_TITLE="Configuration Summary"
    TXT_CONFIRM_CONTINUE="Continue with installation?"
    TXT_CONFIRM_YES="Y/n"
    TXT_CANCELLED="Installation cancelled"
    TXT_CREATING_CONTAINER="Creating LXC container..."
    TXT_CONTAINER_CREATED="Container created successfully"
    TXT_CONTAINER_ERROR="Error creating container"
    TXT_WAITING_START="Waiting for container to start..."
    TXT_CONTAINER_STARTED="Container started successfully"
    TXT_CONTAINER_NOT_STARTED="Container could not start"
    TXT_INSTALLING_NGINX="Installing and configuring Nginx..."
    TXT_NGINX_INSTALLED="Nginx installed and configured"
    TXT_NGINX_ERROR="Error during Nginx installation"
    TXT_INSTALLING_TOOLS="Installing management tools..."
    TXT_TOOLS_INSTALLED="Management tools installed"
    TXT_TOOLS_ERROR="Error installing tools, installing basic version..."
    TXT_GETTING_INFO="Getting container information..."
    TXT_INFO_OBTAINED="Container information obtained"
    TXT_IP_NOT_FOUND="Could not get container IP"
    TXT_INSTALL_COMPLETE="INSTALLATION COMPLETED!"
    TXT_SUMMARY="Installation Summary"
    TXT_WEB_ACCESS="Web Server Access"
    TXT_CONTAINER_ACCESS="Container Access"
    TXT_PROXMOX_CONSOLE="Proxmox Console"
    TXT_NEXT_STEPS="Next Steps"
    TXT_DOCUMENTATION="Documentation"
    TXT_THANKS="Thank you for using nginx-server!"
    TXT_DEVELOPED="Developed for the Proxmox community"
    TXT_MADE_IN="Made in Puerto Rico"
    TXT_FEATURES="Features"
    TXT_AUTOBOOT="Autoboot enabled"
    TXT_AUTOLOGIN="Autologin configured"
    TXT_SERVICE_RUNNING="Service running"
}

set_spanish() {
    TXT_STEP1="PASO 1/4: Verificando Entorno"
    TXT_STEP2="PASO 2/4: Configuracion del Contenedor"
    TXT_STEP3="PASO 3/4: Recursos y Red"
    TXT_STEP4="PASO 4/4: Confirmacion"
    TXT_VERIFYING_PROXMOX="Verificando entorno Proxmox..."
    TXT_PROXMOX_OK="Entorno Proxmox verificado"
    TXT_NOT_PROXMOX="Este script debe ejecutarse en un servidor Proxmox VE"
    TXT_CMD_NOT_FOUND="Comando no encontrado"
    TXT_DETECTING_TEMPLATES="Detectando templates LXC disponibles..."
    TXT_TEMPLATE_FOUND="Template encontrado"
    TXT_DOWNLOADING_TEMPLATE="Descargando template..."
    TXT_TEMPLATE_DOWNLOADED="Template descargado"
    TXT_NO_TEMPLATES="No se encontraron templates compatibles (Ubuntu 22.04 o Debian 12)"
    TXT_GETTING_ID="Obteniendo ID de contenedor disponible..."
    TXT_EXISTING_IDS="IDs existentes encontrados"
    TXT_ID_ASSIGNED="ID de contenedor asignado"
    TXT_NO_ID_AVAILABLE="No se encontro ID de contenedor disponible (100-999)"
    TXT_CONTAINER_CONFIG="Configuracion del Contenedor"
    TXT_CONTAINER_ID="ID del Contenedor"
    TXT_CONTAINER_NAME="Nombre del Contenedor"
    TXT_ROOT_PASSWORD="Contrasena Root"
    TXT_MEMORY="Memoria (MB)"
    TXT_DISK="Disco (GB)"
    TXT_CPU_CORES="Nucleos CPU"
    TXT_STORAGE="Almacenamiento"
    TXT_NETWORK_BRIDGE="Bridge de Red"
    TXT_REQUIRED="Este campo es obligatorio"
    TXT_PASSWORD_SHORT="La contrasena debe tener al menos 5 caracteres (requisito de Proxmox)"
    TXT_AVAILABLE_STORAGES="Almacenamientos disponibles:"
    TXT_AVAILABLE_BRIDGES="Bridges de red disponibles:"
    TXT_CONFIRM_TITLE="Resumen de Configuracion"
    TXT_CONFIRM_CONTINUE="Continuar con la instalacion?"
    TXT_CONFIRM_YES="S/n"
    TXT_CANCELLED="Instalacion cancelada"
    TXT_CREATING_CONTAINER="Creando contenedor LXC..."
    TXT_CONTAINER_CREATED="Contenedor creado exitosamente"
    TXT_CONTAINER_ERROR="Error al crear el contenedor"
    TXT_WAITING_START="Esperando a que el contenedor inicie..."
    TXT_CONTAINER_STARTED="Contenedor iniciado correctamente"
    TXT_CONTAINER_NOT_STARTED="El contenedor no pudo iniciarse"
    TXT_INSTALLING_NGINX="Instalando y configurando Nginx..."
    TXT_NGINX_INSTALLED="Nginx instalado y configurado"
    TXT_NGINX_ERROR="Error durante la instalacion de Nginx"
    TXT_INSTALLING_TOOLS="Instalando herramientas de gestion..."
    TXT_TOOLS_INSTALLED="Herramientas de gestion instaladas"
    TXT_TOOLS_ERROR="Error instalando herramientas, instalando version basica..."
    TXT_GETTING_INFO="Obteniendo informacion del contenedor..."
    TXT_INFO_OBTAINED="Informacion del contenedor obtenida"
    TXT_IP_NOT_FOUND="No se pudo obtener la IP del contenedor"
    TXT_INSTALL_COMPLETE="INSTALACION COMPLETADA!"
    TXT_SUMMARY="Resumen de la Instalacion"
    TXT_WEB_ACCESS="Acceso al Servidor Web"
    TXT_CONTAINER_ACCESS="Acceso al Contenedor"
    TXT_PROXMOX_CONSOLE="Consola Proxmox"
    TXT_NEXT_STEPS="Proximos Pasos"
    TXT_DOCUMENTATION="Documentacion"
    TXT_THANKS="Gracias por usar nginx-server!"
    TXT_DEVELOPED="Desarrollado para la comunidad de Proxmox"
    TXT_MADE_IN="Hecho en Puerto Rico"
    TXT_FEATURES="Caracteristicas"
    TXT_AUTOBOOT="Autoarranque habilitado"
    TXT_AUTOLOGIN="Autologin configurado"
    TXT_SERVICE_RUNNING="Servicio funcionando"
}

# =============================================================================
# BANNER DE BIENVENIDA
# =============================================================================

show_banner() {
    clear
    echo -e "${CYAN}"
    echo "=================================================================="
    echo "||                                                              ||"
    echo "||            NGINX WEB SERVER - PROXMOX LXC                    ||"
    echo "||                                                              ||"
    echo "||                  Automatic Installer v2.0                    ||"
    echo "||                                                              ||"
    echo "||              $TXT_DEVELOPED              ||"
    echo "||                   $TXT_MADE_IN                    ||"
    echo "||                                                              ||"
    echo "=================================================================="
    echo -e "${NC}"
}

# =============================================================================
# VERIFICACIONES
# =============================================================================

check_proxmox() {
    show_step_msg "$TXT_VERIFYING_PROXMOX"

    if ! command -v pct &> /dev/null; then
        show_error "$TXT_NOT_PROXMOX"
        show_error "'pct' - $TXT_CMD_NOT_FOUND"
        exit 1
    fi

    if ! command -v pvesh &> /dev/null; then
        show_error "$TXT_NOT_PROXMOX"
        show_error "'pvesh' - $TXT_CMD_NOT_FOUND"
        exit 1
    fi

    show_success "$TXT_PROXMOX_OK"
}

detect_templates() {
    show_step_msg "$TXT_DETECTING_TEMPLATES"

    UBUNTU_TEMPLATE=$(pveam available | grep "ubuntu-22.04" | head -1 | awk '{print $2}')
    DEBIAN_TEMPLATE=$(pveam available | grep "debian-12" | head -1 | awk '{print $2}')

    DOWNLOADED_UBUNTU=$(pveam list local | grep "ubuntu-22.04" | head -1 | awk '{print $1}')
    DOWNLOADED_DEBIAN=$(pveam list local | grep "debian-12" | head -1 | awk '{print $1}')

    if [ -n "$DOWNLOADED_UBUNTU" ]; then
        SELECTED_TEMPLATE="$DOWNLOADED_UBUNTU"
        TEMPLATE_TYPE="ubuntu"
        show_success "$TXT_TEMPLATE_FOUND: Ubuntu 22.04"
    elif [ -n "$DOWNLOADED_DEBIAN" ]; then
        SELECTED_TEMPLATE="$DOWNLOADED_DEBIAN"
        TEMPLATE_TYPE="debian"
        show_success "$TXT_TEMPLATE_FOUND: Debian 12"
    elif [ -n "$UBUNTU_TEMPLATE" ]; then
        SELECTED_TEMPLATE="$UBUNTU_TEMPLATE"
        TEMPLATE_TYPE="ubuntu"
        show_info "$TXT_DOWNLOADING_TEMPLATE Ubuntu 22.04..."
        pveam download local "$UBUNTU_TEMPLATE"
        show_success "$TXT_TEMPLATE_DOWNLOADED: Ubuntu 22.04"
    elif [ -n "$DEBIAN_TEMPLATE" ]; then
        SELECTED_TEMPLATE="$DEBIAN_TEMPLATE"
        TEMPLATE_TYPE="debian"
        show_info "$TXT_DOWNLOADING_TEMPLATE Debian 12..."
        pveam download local "$DEBIAN_TEMPLATE"
        show_success "$TXT_TEMPLATE_DOWNLOADED: Debian 12"
    else
        show_error "$TXT_NO_TEMPLATES"
        exit 1
    fi
}

# Obtener siguiente ID disponible
get_next_vmid() {
    show_step_msg "$TXT_GETTING_ID"
    
    # Obtener lista de IDs existentes usando múltiples métodos
    EXISTING_IDS=""
    
    # Método 1: pct list (contenedores)
    if command -v pct &> /dev/null; then
        PCT_IDS=$(pct list 2>/dev/null | awk 'NR>1 {print $1}' | grep -E '^[0-9]+$' || true)
        EXISTING_IDS="$EXISTING_IDS $PCT_IDS"
    fi
    
    # Método 2: qm list (VMs)
    if command -v qm &> /dev/null; then
        QM_IDS=$(qm list 2>/dev/null | awk 'NR>1 {print $1}' | grep -E '^[0-9]+$' || true)
        EXISTING_IDS="$EXISTING_IDS $QM_IDS"
    fi
    
    # Método 3: pvesh (si está disponible)
    if command -v pvesh &> /dev/null; then
        PVESH_IDS=$(pvesh get /cluster/resources --type vm 2>/dev/null | awk 'NR>1 {print $2}' | grep -E '^[0-9]+$' || true)
        EXISTING_IDS="$EXISTING_IDS $PVESH_IDS"
    fi
    
    # Limpiar y ordenar IDs
    EXISTING_IDS=$(echo $EXISTING_IDS | tr ' ' '\n' | sort -nu | tr '\n' ' ')
    
    show_info "$TXT_EXISTING_IDS: $EXISTING_IDS"
    
    # Buscar el próximo ID disponible
    CONTAINER_ID=""
    for i in {100..999}; do
        if ! echo " $EXISTING_IDS " | grep -q " $i "; then
            CONTAINER_ID=$i
            break
        fi
    done
    
    if [ -z "$CONTAINER_ID" ]; then
        show_error "$TXT_NO_ID_AVAILABLE"
        show_error "IDs existentes: $EXISTING_IDS"
        exit 1
    fi
    
    show_success "$TXT_ID_ASSIGNED: $CONTAINER_ID"
}

# =============================================================================
# CONFIGURACION DEL CONTENEDOR
# =============================================================================

configure_container() {
    show_step "$TXT_STEP2"

    # Valores por defecto
    DEFAULT_NAME="nginx-server"
    DEFAULT_PASSWORD="nginx123"
    DEFAULT_MEMORY="1024"
    DEFAULT_DISK="8"
    DEFAULT_CORES="2"
    DEFAULT_STORAGE="local-lvm"

    # Detectar bridge de red
    DEFAULT_BRIDGE=$(ip route | grep default | awk '{print $5}' | head -1)
    if [ -z "$DEFAULT_BRIDGE" ]; then
        DEFAULT_BRIDGE="vmbr0"
    fi

    echo -e "${WHITE}$TXT_CONTAINER_CONFIG${NC}"
    echo ""

    read_input "$TXT_CONTAINER_ID" "$CONTAINER_ID" "CONTAINER_ID" "true"
    read_input "$TXT_CONTAINER_NAME" "$DEFAULT_NAME" "CONTAINER_NAME" "true"
    read_input "$TXT_ROOT_PASSWORD" "$DEFAULT_PASSWORD" "CONTAINER_PASSWORD" "true"

    # Validar password minimo 5 caracteres
    while [ ${#CONTAINER_PASSWORD} -lt 5 ]; do
        show_error "$TXT_PASSWORD_SHORT"
        read_input "$TXT_ROOT_PASSWORD" "$DEFAULT_PASSWORD" "CONTAINER_PASSWORD" "true"
    done

    # Verificar que ID no existe
    if pct status $CONTAINER_ID &> /dev/null; then
        show_error "Container ID $CONTAINER_ID already exists / El ID $CONTAINER_ID ya existe"
        exit 1
    fi
}

configure_resources() {
    show_step "$TXT_STEP3"

    echo -e "${WHITE}$TXT_AVAILABLE_STORAGES${NC}"
    pvesm status 2>/dev/null | grep -E "active" | awk '{print "   - " $1}'
    echo ""

    read_input "$TXT_STORAGE" "$DEFAULT_STORAGE" "CONTAINER_STORAGE" "true"

    echo ""
    read_input "$TXT_MEMORY" "$DEFAULT_MEMORY" "CONTAINER_MEMORY" "true"
    read_input "$TXT_DISK" "$DEFAULT_DISK" "CONTAINER_DISK" "true"
    read_input "$TXT_CPU_CORES" "$DEFAULT_CORES" "CONTAINER_CORES" "true"

    echo ""
    echo -e "${WHITE}$TXT_AVAILABLE_BRIDGES${NC}"
    ip link show type bridge 2>/dev/null | grep -E "^[0-9]" | awk -F: '{print "   - " $2}' | tr -d ' '
    echo ""

    read_input "$TXT_NETWORK_BRIDGE" "$DEFAULT_BRIDGE" "NETWORK_BRIDGE" "true"
}

# =============================================================================
# CONFIRMACION
# =============================================================================

show_confirmation() {
    show_step "$TXT_STEP4"

    echo -e "${WHITE}$TXT_CONFIRM_TITLE${NC}"
    echo ""
    echo "   Container"
    echo "   ├─ ID: $CONTAINER_ID"
    echo "   ├─ Name: $CONTAINER_NAME"
    echo "   ├─ Password: $CONTAINER_PASSWORD"
    echo "   ├─ Template: $SELECTED_TEMPLATE"
    echo "   └─ Storage: $CONTAINER_STORAGE"
    echo ""
    echo "   Resources"
    echo "   ├─ Memory: ${CONTAINER_MEMORY}MB"
    echo "   ├─ Disk: ${CONTAINER_DISK}GB"
    echo "   └─ CPU: $CONTAINER_CORES cores"
    echo ""
    echo "   Network"
    echo "   └─ Bridge: $NETWORK_BRIDGE (DHCP)"
    echo ""

    echo -ne "${GREEN}>${NC} $TXT_CONFIRM_CONTINUE [$TXT_CONFIRM_YES]: "
    read confirm
    confirm=${confirm:-Y}

    if [[ ! "$confirm" =~ ^[SsYy]$ ]]; then
        show_warning "$TXT_CANCELLED"
        exit 0
    fi
}

# =============================================================================
# CREACION E INSTALACION
# =============================================================================

# Crear contenedor LXC
create_container() {
    show_step_msg "$TXT_CREATING_CONTAINER"
    
    # Crear el contenedor
    pct create $CONTAINER_ID \
        $SELECTED_TEMPLATE \
        --hostname $CONTAINER_NAME \
        --memory $CONTAINER_MEMORY \
        --rootfs $CONTAINER_STORAGE:$CONTAINER_DISK \
        --cores $CONTAINER_CORES \
        --net0 name=eth0,bridge=$NETWORK_BRIDGE,ip=dhcp \
        --password $CONTAINER_PASSWORD \
        --unprivileged 1 \
        --onboot 1 \
        --start 1 \
        --features nesting=1 \
        --description "Servidor web Nginx automatizado - Creado por nginx-server installer"
    
    if [ $? -eq 0 ]; then
        show_success "$TXT_CONTAINER_CREATED"
    else
        show_error "$TXT_CONTAINER_ERROR"
        exit 1
    fi
    
    # Esperar a que el contenedor inicie
    show_info "$TXT_WAITING_START"
    sleep 10
    
    # Verificar que el contenedor está corriendo
    if pct status $CONTAINER_ID | grep -q "running"; then
        show_success "$TXT_CONTAINER_STARTED"
    else
        show_error "$TXT_CONTAINER_NOT_STARTED"
        exit 1
    fi
}

# Instalar nginx en el contenedor
install_nginx() {
    show_step_msg "$TXT_INSTALLING_NGINX"
    
    # Crear script de instalación temporal
    cat > /tmp/nginx-install.sh << 'EOF'
#!/bin/bash

# Actualizar sistema
apt update && apt upgrade -y

# Instalar paquetes necesarios
apt install -y \
    nginx \
    certbot \
    python3-certbot-nginx \
    ufw \
    fail2ban \
    curl \
    wget \
    git \
    nano \
    htop \
    tree \
    unzip \
    logrotate

# Habilitar y iniciar servicios
systemctl enable nginx
systemctl start nginx
systemctl enable fail2ban
systemctl start fail2ban

# Configurar firewall
ufw --force enable
ufw allow 22/tcp
ufw allow 80/tcp
ufw allow 443/tcp

# Crear directorios necesarios
mkdir -p /var/www/html
mkdir -p /etc/nginx/sites-available
mkdir -p /etc/nginx/sites-enabled
mkdir -p /var/log/nginx
mkdir -p /opt/nginx-server

# Configurar permisos
chown -R www-data:www-data /var/www/
chmod -R 755 /var/www/

# Crear página de bienvenida
cat > /var/www/html/index.html << 'HTML'
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>🌐 Nginx Server - ¡Funcionando!</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            text-align: center;
        }
        
        .container {
            max-width: 800px;
            padding: 2rem;
            background: rgba(255, 255, 255, 0.1);
            border-radius: 20px;
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.2);
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3);
        }
        
        .logo {
            font-size: 4rem;
            margin-bottom: 1rem;
        }
        
        h1 {
            font-size: 2.5rem;
            margin-bottom: 1rem;
            text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.3);
        }
        
        .subtitle {
            font-size: 1.2rem;
            margin-bottom: 2rem;
            opacity: 0.9;
        }
        
        .info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 1rem;
            margin: 2rem 0;
        }
        
        .info-card {
            background: rgba(255, 255, 255, 0.1);
            padding: 1.5rem;
            border-radius: 15px;
            border: 1px solid rgba(255, 255, 255, 0.2);
        }
        
        .info-card h3 {
            margin-bottom: 0.5rem;
            color: #ffd700;
        }
        
        .status {
            display: inline-block;
            padding: 0.5rem 1rem;
            background: #28a745;
            color: white;
            border-radius: 25px;
            font-weight: bold;
            margin: 1rem 0;
        }
        
        .commands {
            background: rgba(0, 0, 0, 0.3);
            padding: 1.5rem;
            border-radius: 15px;
            margin: 2rem 0;
            text-align: left;
        }
        
        .commands h3 {
            color: #ffd700;
            margin-bottom: 1rem;
            text-align: center;
        }
        
        .commands code {
            display: block;
            background: rgba(0, 0, 0, 0.5);
            padding: 0.5rem;
            border-radius: 5px;
            margin: 0.5rem 0;
            font-family: 'Courier New', monospace;
        }
        
        .footer {
            margin-top: 2rem;
            padding-top: 2rem;
            border-top: 1px solid rgba(255, 255, 255, 0.2);
            opacity: 0.8;
        }
        
        .flag {
            font-size: 1.5rem;
            margin: 0 0.5rem;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="logo">🌐</div>
        <h1>¡Nginx Server Funcionando!</h1>
        <p class="subtitle">Tu servidor web está listo para servir contenido</p>
        
        <div class="status">✅ ACTIVO</div>
        
        <div class="info-grid">
            <div class="info-card">
                <h3>🚀 Servidor</h3>
                <p>Nginx Web Server</p>
                <p>Optimizado para producción</p>
            </div>
            
            <div class="info-card">
                <h3>🔒 Seguridad</h3>
                <p>Firewall configurado</p>
                <p>Fail2ban activo</p>
            </div>
            
            <div class="info-card">
                <h3>📂 Ubicación</h3>
                <p>/var/www/html</p>
                <p>Directorio web principal</p>
            </div>
            
            <div class="info-card">
                <h3>🛠️ Gestión</h3>
                <p>nginx-manager</p>
                <p>Herramientas incluidas</p>
            </div>
        </div>
        
        <div class="commands">
            <h3>🖥️ Comandos Útiles</h3>
            <code># Ver información del servidor</code>
            <code>nginx-info</code>
            <code># Gestionar sitios web</code>
            <code>nginx-manager</code>
            <code># Configurar SSL</code>
            <code>ssl-manager</code>
        </div>
        
        <div class="footer">
            <p>Desarrollado con ❤️ para la comunidad de Proxmox</p>
            <p>Hecho en <span class="flag">🇵🇷</span> Puerto Rico con mucho <span class="flag">☕</span> café</p>
        </div>
    </div>
</body>
</html>
HTML

# Configurar autologin para la consola
echo "root:x:0:0:root:/root:/bin/bash" > /etc/passwd.tmp
grep -v "^root:" /etc/passwd >> /etc/passwd.tmp
mv /etc/passwd.tmp /etc/passwd

# Configurar autologin en getty
mkdir -p /etc/systemd/system/getty@tty1.service.d/
cat > /etc/systemd/system/getty@tty1.service.d/autologin.conf << 'GETTY'
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin root --noclear %I $TERM
GETTY

# Configurar bienvenida automática en .bashrc
cat >> /root/.bashrc << 'BASHRC'

# Mostrar información del servidor nginx al hacer login
if [ -f /opt/nginx-server/welcome.sh ]; then
    /opt/nginx-server/welcome.sh
fi

# Alias útiles para nginx
alias nginx-info='/opt/nginx-server/welcome.sh'
alias nginx-manager='/opt/nginx-server/nginx-manager.sh'
alias ssl-manager='/opt/nginx-server/ssl-manager.sh'
alias nginx-logs='tail -f /var/log/nginx/access.log'
alias nginx-errors='tail -f /var/log/nginx/error.log'
alias nginx-test='nginx -t'
alias nginx-reload='systemctl reload nginx'
alias nginx-restart='systemctl restart nginx'
alias nginx-status='systemctl status nginx'
BASHRC

systemctl daemon-reload
systemctl enable getty@tty1.service

echo "Instalación de nginx completada"
EOF

    # Copiar script al contenedor y ejecutarlo
    pct push $CONTAINER_ID /tmp/nginx-install.sh /tmp/nginx-install.sh
    pct exec $CONTAINER_ID -- chmod +x /tmp/nginx-install.sh
    pct exec $CONTAINER_ID -- /tmp/nginx-install.sh
    
    if [ $? -eq 0 ]; then
        show_success "$TXT_NGINX_INSTALLED"
    else
        show_error "$TXT_NGINX_ERROR"
        exit 1
    fi
    
    # Limpiar archivo temporal
    rm -f /tmp/nginx-install.sh
}

# Instalar herramientas de gestión
install_management_tools() {
    show_step_msg "$TXT_INSTALLING_TOOLS"
    
    # Ejecutar el instalador de herramientas dentro del contenedor
    show_info "Descargando e instalando herramientas desde GitHub..."
    
    pct exec $CONTAINER_ID -- wget -O /tmp/install-tools.sh https://raw.githubusercontent.com/MondoBoricua/nginx-server/master/install-tools.sh
    pct exec $CONTAINER_ID -- chmod +x /tmp/install-tools.sh
    pct exec $CONTAINER_ID -- /tmp/install-tools.sh
    
    # Ejecutar corrección automática de nginx
    show_info "Ejecutando corrección automática de nginx..."
    pct exec $CONTAINER_ID -- wget -O /tmp/nginx-fix.sh https://raw.githubusercontent.com/MondoBoricua/nginx-server/master/utils/nginx-fix.sh
    pct exec $CONTAINER_ID -- chmod +x /tmp/nginx-fix.sh
    pct exec $CONTAINER_ID -- /tmp/nginx-fix.sh
    
    if [ $? -eq 0 ]; then
        show_success "$TXT_TOOLS_INSTALLED"
    else
        show_warning "$TXT_TOOLS_ERROR"
        
        # Fallback: instalar versión básica
        pct exec $CONTAINER_ID -- mkdir -p /opt/nginx-server
        
        # Crear script de bienvenida básico
        cat > /tmp/welcome.sh << 'EOF'
#!/bin/bash
# Script de bienvenida para nginx-server

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

# Obtener información del sistema
HOSTNAME=$(hostname)
IP_ADDRESS=$(hostname -I | awk '{print $1}')
NGINX_STATUS=$(systemctl is-active nginx)
NGINX_VERSION=$(nginx -v 2>&1 | cut -d' ' -f3)
UPTIME=$(uptime -p)
MEMORY=$(free -h | grep Mem | awk '{print $3 "/" $2}')
DISK=$(df -h / | tail -1 | awk '{print $3 "/" $2}')

clear
echo -e "${CYAN}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                                                              ║"
echo "║            🌐 NGINX WEB SERVER - INFORMACIÓN 🌐              ║"
echo "║                                                              ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

echo -e "${WHITE}🖥️  Información del Servidor${NC}"
echo -e "   ${CYAN}Hostname:${NC} $HOSTNAME"
echo -e "   ${CYAN}IP Address:${NC} $IP_ADDRESS"
echo -e "   ${CYAN}Uptime:${NC} $UPTIME"
echo -e "   ${CYAN}Memoria:${NC} $MEMORY"
echo -e "   ${CYAN}Disco:${NC} $DISK"
echo

echo -e "${WHITE}🌐 Estado de Nginx${NC}"
if [ "$NGINX_STATUS" = "active" ]; then
    echo -e "   ${GREEN}✅ Nginx está ACTIVO${NC}"
else
    echo -e "   ${RED}❌ Nginx está INACTIVO${NC}"
fi
echo -e "   ${CYAN}Versión:${NC} $NGINX_VERSION"
echo -e "   ${CYAN}Acceso web:${NC} http://$IP_ADDRESS"
echo

echo -e "${WHITE}📂 Directorios Importantes${NC}"
echo -e "   ${CYAN}Sitios web:${NC} /var/www/"
echo -e "   ${CYAN}Configuración:${NC} /etc/nginx/"
echo -e "   ${CYAN}Logs:${NC} /var/log/nginx/"
echo

echo -e "${WHITE}🛠️  Comandos Útiles${NC}"
echo -e "   ${YELLOW}nginx-info${NC}      - Mostrar esta información"
echo -e "   ${YELLOW}nginx-manager${NC}   - Gestionar sitios web"
echo -e "   ${YELLOW}ssl-manager${NC}     - Gestionar certificados SSL"
echo -e "   ${YELLOW}nginx-status${NC}    - Ver estado del servicio"
echo -e "   ${YELLOW}nginx-test${NC}      - Probar configuración"
echo -e "   ${YELLOW}nginx-reload${NC}    - Recargar configuración"
echo -e "   ${YELLOW}nginx-logs${NC}      - Ver logs de acceso"
echo -e "   ${YELLOW}nginx-errors${NC}    - Ver logs de errores"
echo

echo -e "${WHITE}🔗 Acceso Rápido${NC}"
echo -e "   ${CYAN}Sitio web:${NC} http://$IP_ADDRESS"
echo -e "   ${CYAN}Consola:${NC} pct enter $(cat /etc/hostname | cut -d'-' -f3 2>/dev/null || echo 'ID')"
echo

echo -e "${PURPLE}Desarrollado con ❤️  para la comunidad de Proxmox${NC}"
echo -e "${PURPLE}Hecho en 🇵🇷 Puerto Rico con mucho ☕ café${NC}"
echo
EOF

        # Copiar script de bienvenida
        pct push $CONTAINER_ID /tmp/welcome.sh /opt/nginx-server/welcome.sh
        pct exec $CONTAINER_ID -- chmod +x /opt/nginx-server/welcome.sh
        
        # Limpiar archivos temporales
        rm -f /tmp/welcome.sh
    fi
    
    show_success "$TXT_TOOLS_INSTALLED"
}

# Obtener información del contenedor
get_container_info() {
    show_step_msg "$TXT_GETTING_INFO"
    
    # Obtener IP del contenedor
    sleep 5
    CONTAINER_IP=$(pct exec $CONTAINER_ID -- hostname -I | awk '{print $1}')
    
    if [ -z "$CONTAINER_IP" ]; then
        show_warning "$TXT_IP_NOT_FOUND"
        CONTAINER_IP="Verificar con: pct exec $CONTAINER_ID -- hostname -I"
    fi
    
    show_success "$TXT_INFO_OBTAINED"
}
# =============================================================================
# RESUMEN FINAL
# =============================================================================

show_summary() {
    clear
    echo -e "${GREEN}"
    echo "=================================================================="
    echo "||                                                              ||"
    echo "||              [OK] $TXT_INSTALL_COMPLETE              ||"
    echo "||                                                              ||"
    echo "=================================================================="
    echo -e "${NC}"

    echo ""
    echo -e "${WHITE}$TXT_SUMMARY${NC}"
    echo ""
    echo "   Container"
    echo "   ├─ ID: $CONTAINER_ID"
    echo "   ├─ Hostname: $CONTAINER_NAME"
    echo "   ├─ IP: $CONTAINER_IP"
    echo "   ├─ Password: $CONTAINER_PASSWORD"
    echo "   └─ Template: $SELECTED_TEMPLATE"
    echo ""
    echo "   Resources"
    echo "   ├─ Memory: ${CONTAINER_MEMORY}MB"
    echo "   ├─ Disk: ${CONTAINER_DISK}GB"
    echo "   └─ CPU: $CONTAINER_CORES cores"
    echo ""
    echo "   $TXT_FEATURES"
    echo "   ├─ [OK] $TXT_AUTOBOOT"
    echo "   ├─ [OK] $TXT_AUTOLOGIN"
    echo "   └─ [OK] $TXT_SERVICE_RUNNING"
    echo ""

    echo -e "${WHITE}$TXT_WEB_ACCESS${NC}"
    echo "   └─ http://$CONTAINER_IP"
    echo ""

    echo -e "${WHITE}$TXT_CONTAINER_ACCESS${NC}"
    echo "   ├─ $TXT_PROXMOX_CONSOLE: pct enter $CONTAINER_ID"
    echo "   └─ SSH: ssh root@$CONTAINER_IP"
    echo ""

    echo -e "${WHITE}$TXT_NEXT_STEPS${NC}"
    echo "   1. pct enter $CONTAINER_ID"
    echo "   2. nginx-info"
    echo "   3. nginx-manager"
    echo "   4. ssl-manager"
    echo ""

    echo -e "${WHITE}$TXT_DOCUMENTATION${NC}"
    echo "   └─ https://github.com/MondoBoricua/nginx-server"
    echo ""

    echo -e "${CYAN}$TXT_THANKS${NC}"
    echo -e "${CYAN}$TXT_DEVELOPED${NC}"
    echo -e "${CYAN}$TXT_MADE_IN${NC}"
    echo ""
}

# =============================================================================
# FUNCION PRINCIPAL
# =============================================================================

main() {
    # Seleccionar idioma primero
    select_language

    # Mostrar banner
    show_banner

    # PASO 1: Verificaciones
    show_step "$TXT_STEP1"
    check_proxmox
    detect_templates
    get_next_vmid

    # PASO 2: Configuracion del contenedor
    configure_container

    # PASO 3: Recursos y red
    configure_resources

    # PASO 4: Confirmacion
    show_confirmation

    # Proceso de instalacion
    echo ""
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${WHITE}  INSTALLING / INSTALANDO...${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    create_container
    install_nginx
    install_management_tools
    get_container_info

    # Mostrar resumen
    show_summary
}

# =============================================================================
# VERIFICAR ROOT Y EJECUTAR
# =============================================================================

if [ "$EUID" -ne 0 ]; then
    echo -e "\033[0;31m[ERROR]\033[0m This script must be run as root / Este script debe ejecutarse como root"
    exit 1
fi

main "$@"
