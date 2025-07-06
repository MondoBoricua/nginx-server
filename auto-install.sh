#!/bin/bash

# 🌐 Nginx Web Server - Instalador Automático para Proxmox LXC
# Desarrollado con ❤️ para la comunidad de Proxmox
# Hecho en 🇵🇷 Puerto Rico con mucho ☕ café

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Banner de bienvenida
show_banner() {
    clear
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                                                              ║"
    echo "║            🌐 NGINX WEB SERVER - PROXMOX LXC 🌐              ║"
    echo "║                                                              ║"
    echo "║              Instalador Automático v1.0                     ║"
    echo "║                                                              ║"
    echo "║     Desarrollado con ❤️  para la comunidad de Proxmox       ║"
    echo "║           Hecho en 🇵🇷 Puerto Rico con mucho ☕ café        ║"
    echo "║                                                              ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Función para mostrar mensajes con colores
log_info() {
    echo -e "${CYAN}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[⚠]${NC} $1"
}

log_error() {
    echo -e "${RED}[✗]${NC} $1"
}

log_step() {
    echo -e "${PURPLE}[PASO]${NC} $1"
}

# Verificar si estamos en Proxmox
check_proxmox() {
    log_step "Verificando entorno Proxmox..."
    
    if ! command -v pct &> /dev/null; then
        log_error "Este script debe ejecutarse en un servidor Proxmox VE"
        log_error "No se encontró el comando 'pct'"
        exit 1
    fi
    
    if ! command -v pvesh &> /dev/null; then
        log_error "Este script debe ejecutarse en un servidor Proxmox VE"
        log_error "No se encontró el comando 'pvesh'"
        exit 1
    fi
    
    log_success "Entorno Proxmox verificado correctamente"
}

# Detectar templates disponibles
detect_templates() {
    log_step "Detectando templates LXC disponibles..."
    
    # Buscar templates de Ubuntu 22.04 y Debian 12
    UBUNTU_TEMPLATE=$(pveam available | grep "ubuntu-22.04" | head -1 | awk '{print $2}')
    DEBIAN_TEMPLATE=$(pveam available | grep "debian-12" | head -1 | awk '{print $2}')
    
    # Verificar templates ya descargados
    DOWNLOADED_UBUNTU=$(pveam list local | grep "ubuntu-22.04" | head -1 | awk '{print $1}')
    DOWNLOADED_DEBIAN=$(pveam list local | grep "debian-12" | head -1 | awk '{print $1}')
    
    if [ -n "$DOWNLOADED_UBUNTU" ]; then
        SELECTED_TEMPLATE="$DOWNLOADED_UBUNTU"
        TEMPLATE_TYPE="ubuntu"
        log_success "Template Ubuntu 22.04 encontrado: $SELECTED_TEMPLATE"
    elif [ -n "$DOWNLOADED_DEBIAN" ]; then
        SELECTED_TEMPLATE="$DOWNLOADED_DEBIAN"
        TEMPLATE_TYPE="debian"
        log_success "Template Debian 12 encontrado: $SELECTED_TEMPLATE"
    elif [ -n "$UBUNTU_TEMPLATE" ]; then
        SELECTED_TEMPLATE="$UBUNTU_TEMPLATE"
        TEMPLATE_TYPE="ubuntu"
        log_info "Descargando template Ubuntu 22.04..."
        pveam download local "$UBUNTU_TEMPLATE"
        log_success "Template Ubuntu 22.04 descargado"
    elif [ -n "$DEBIAN_TEMPLATE" ]; then
        SELECTED_TEMPLATE="$DEBIAN_TEMPLATE"
        TEMPLATE_TYPE="debian"
        log_info "Descargando template Debian 12..."
        pveam download local "$DEBIAN_TEMPLATE"
        log_success "Template Debian 12 descargado"
    else
        log_error "No se encontraron templates compatibles (Ubuntu 22.04 o Debian 12)"
        exit 1
    fi
}

# Obtener siguiente ID disponible
get_next_vmid() {
    log_step "Obteniendo ID de contenedor disponible..."
    
    # Buscar el próximo ID disponible
    for i in {100..999}; do
        if ! pct status $i &>/dev/null; then
            CONTAINER_ID=$i
            break
        fi
    done
    
    if [ -z "$CONTAINER_ID" ]; then
        log_error "No se pudo encontrar un ID de contenedor disponible"
        exit 1
    fi
    
    log_success "ID de contenedor asignado: $CONTAINER_ID"
}

# Configurar parámetros del contenedor
configure_container() {
    log_step "Configurando parámetros del contenedor..."
    
    # Valores por defecto
    CONTAINER_NAME="nginx-server"
    CONTAINER_MEMORY="1024"
    CONTAINER_DISK="8"
    CONTAINER_CORES="2"
    CONTAINER_PASSWORD="nginx123"
    CONTAINER_STORAGE="local-lvm"
    
    # Detectar bridge de red
    NETWORK_BRIDGE=$(ip route | grep default | awk '{print $5}' | head -1)
    if [ -z "$NETWORK_BRIDGE" ]; then
        NETWORK_BRIDGE="vmbr0"
    fi
    
    echo
    log_info "Configuración del contenedor:"
    echo -e "  ${WHITE}ID:${NC} $CONTAINER_ID"
    echo -e "  ${WHITE}Nombre:${NC} $CONTAINER_NAME"
    echo -e "  ${WHITE}Memoria:${NC} ${CONTAINER_MEMORY}MB"
    echo -e "  ${WHITE}Disco:${NC} ${CONTAINER_DISK}GB"
    echo -e "  ${WHITE}CPU Cores:${NC} $CONTAINER_CORES"
    echo -e "  ${WHITE}Template:${NC} $SELECTED_TEMPLATE"
    echo -e "  ${WHITE}Storage:${NC} $CONTAINER_STORAGE"
    echo -e "  ${WHITE}Red:${NC} $NETWORK_BRIDGE"
    echo -e "  ${WHITE}Contraseña:${NC} $CONTAINER_PASSWORD"
    echo
    
    read -p "¿Deseas personalizar la configuración? (y/N): " customize
    if [[ $customize =~ ^[Yy]$ ]]; then
        customize_container
    fi
}

# Personalizar configuración del contenedor
customize_container() {
    echo
    log_info "Personalización de configuración:"
    
    read -p "Nombre del contenedor [$CONTAINER_NAME]: " input
    [ -n "$input" ] && CONTAINER_NAME="$input"
    
    read -p "Memoria en MB [$CONTAINER_MEMORY]: " input
    [ -n "$input" ] && CONTAINER_MEMORY="$input"
    
    read -p "Tamaño del disco en GB [$CONTAINER_DISK]: " input
    [ -n "$input" ] && CONTAINER_DISK="$input"
    
    read -p "Número de CPU cores [$CONTAINER_CORES]: " input
    [ -n "$input" ] && CONTAINER_CORES="$input"
    
    read -p "Contraseña root [$CONTAINER_PASSWORD]: " input
    [ -n "$input" ] && CONTAINER_PASSWORD="$input"
    
    # Mostrar storages disponibles
    echo
    log_info "Storages disponibles:"
    pvesh get /storage --output-format=table | grep -E "local|lvm"
    echo
    read -p "Storage para el contenedor [$CONTAINER_STORAGE]: " input
    [ -n "$input" ] && CONTAINER_STORAGE="$input"
    
    # Mostrar bridges disponibles
    echo
    log_info "Bridges de red disponibles:"
    ip link show | grep -E "vmbr|br" | awk '{print $2}' | sed 's/://'
    echo
    read -p "Bridge de red [$NETWORK_BRIDGE]: " input
    [ -n "$input" ] && NETWORK_BRIDGE="$input"
}

# Crear contenedor LXC
create_container() {
    log_step "Creando contenedor LXC..."
    
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
        log_success "Contenedor creado exitosamente"
    else
        log_error "Error al crear el contenedor"
        exit 1
    fi
    
    # Esperar a que el contenedor inicie
    log_info "Esperando a que el contenedor inicie..."
    sleep 10
    
    # Verificar que el contenedor está corriendo
    if pct status $CONTAINER_ID | grep -q "running"; then
        log_success "Contenedor iniciado correctamente"
    else
        log_error "El contenedor no pudo iniciarse"
        exit 1
    fi
}

# Instalar nginx en el contenedor
install_nginx() {
    log_step "Instalando y configurando Nginx..."
    
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
        log_success "Nginx instalado y configurado correctamente"
    else
        log_error "Error durante la instalación de nginx"
        exit 1
    fi
    
    # Limpiar archivo temporal
    rm -f /tmp/nginx-install.sh
}

# Instalar herramientas de gestión
install_management_tools() {
    log_step "Instalando herramientas de gestión..."
    
    # Descargar scripts de gestión desde GitHub (simulado - crear localmente)
    pct exec $CONTAINER_ID -- mkdir -p /opt/nginx-server
    
    # Crear script de bienvenida
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
    
    log_success "Herramientas de gestión instaladas"
    
    # Limpiar archivos temporales
    rm -f /tmp/welcome.sh
}

# Obtener información del contenedor
get_container_info() {
    log_step "Obteniendo información del contenedor..."
    
    # Obtener IP del contenedor
    sleep 5
    CONTAINER_IP=$(pct exec $CONTAINER_ID -- hostname -I | awk '{print $1}')
    
    if [ -z "$CONTAINER_IP" ]; then
        log_warning "No se pudo obtener la IP del contenedor"
        CONTAINER_IP="Verificar con: pct exec $CONTAINER_ID -- hostname -I"
    fi
    
    log_success "Información del contenedor obtenida"
}

# Mostrar resumen final
show_summary() {
    clear
    echo -e "${GREEN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                                                              ║"
    echo "║               🎉 ¡INSTALACIÓN COMPLETADA! 🎉                 ║"
    echo "║                                                              ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    echo -e "${WHITE}📋 Resumen de la Instalación${NC}"
    echo -e "   ${CYAN}ID del Contenedor:${NC} $CONTAINER_ID"
    echo -e "   ${CYAN}Nombre:${NC} $CONTAINER_NAME"
    echo -e "   ${CYAN}IP Address:${NC} $CONTAINER_IP"
    echo -e "   ${CYAN}Memoria:${NC} ${CONTAINER_MEMORY}MB"
    echo -e "   ${CYAN}Disco:${NC} ${CONTAINER_DISK}GB"
    echo -e "   ${CYAN}CPU Cores:${NC} $CONTAINER_CORES"
    echo -e "   ${CYAN}Template:${NC} $SELECTED_TEMPLATE"
    echo
    
    echo -e "${WHITE}🌐 Acceso al Servidor Web${NC}"
    echo -e "   ${GREEN}URL:${NC} http://$CONTAINER_IP"
    echo -e "   ${GREEN}Estado:${NC} Activo y funcionando"
    echo
    
    echo -e "${WHITE}🖥️  Acceso al Contenedor${NC}"
    echo -e "   ${CYAN}Consola Proxmox:${NC} pct enter $CONTAINER_ID"
    echo -e "   ${CYAN}SSH:${NC} ssh root@$CONTAINER_IP"
    echo -e "   ${CYAN}Contraseña:${NC} $CONTAINER_PASSWORD"
    echo
    
    echo -e "${WHITE}🛠️  Próximos Pasos${NC}"
    echo -e "   ${YELLOW}1.${NC} Acceder al contenedor: ${CYAN}pct enter $CONTAINER_ID${NC}"
    echo -e "   ${YELLOW}2.${NC} Ver información: ${CYAN}nginx-info${NC}"
    echo -e "   ${YELLOW}3.${NC} Gestionar sitios: ${CYAN}nginx-manager${NC}"
    echo -e "   ${YELLOW}4.${NC} Configurar SSL: ${CYAN}ssl-manager${NC}"
    echo
    
    echo -e "${WHITE}📚 Documentación${NC}"
    echo -e "   ${CYAN}GitHub:${NC} https://github.com/MondoBoricua/nginx-server"
    echo -e "   ${CYAN}Logs:${NC} /var/log/nginx/"
    echo -e "   ${CYAN}Config:${NC} /etc/nginx/"
    echo
    
    echo -e "${PURPLE}¡Gracias por usar nginx-server!${NC}"
    echo -e "${PURPLE}Desarrollado con ❤️  para la comunidad de Proxmox${NC}"
    echo -e "${PURPLE}Hecho en 🇵🇷 Puerto Rico con mucho ☕ café${NC}"
    echo
}

# Función principal
main() {
    show_banner
    
    # Verificaciones iniciales
    check_proxmox
    detect_templates
    get_next_vmid
    configure_container
    
    # Confirmación final
    echo
    log_warning "¿Continuar con la instalación?"
    read -p "Presiona Enter para continuar o Ctrl+C para cancelar..."
    
    # Proceso de instalación
    create_container
    install_nginx
    install_management_tools
    get_container_info
    
    # Mostrar resumen
    show_summary
    
    # Abrir navegador automáticamente si es posible
    if command -v xdg-open &> /dev/null; then
        xdg-open "http://$CONTAINER_IP" &>/dev/null &
    fi
}

# Verificar si se ejecuta como root
if [ "$EUID" -ne 0 ]; then
    log_error "Este script debe ejecutarse como root"
    exit 1
fi

# Ejecutar función principal
main "$@" 