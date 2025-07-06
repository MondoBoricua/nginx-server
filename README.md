# 🌐 Nginx Web Server para Proxmox LXC

Un script automatizado para crear y configurar servidores web Nginx en contenedores LXC de Proxmox, perfecto para hospedar sitios web, aplicaciones y servicios web sin complicaciones.

## 📋 Requisitos

* **Proxmox VE** (cualquier versión reciente)
* **Template LXC** (Ubuntu 22.04 o Debian 12 - se detecta automáticamente)
* **Acceso de red** para el contenedor
* **Dominio o IP** para acceder al servidor web

## 🚀 Instalación Rápida

### Método 1: Instalación Automática (Recomendado)

```bash
# Ejecutar desde el HOST Proxmox (no desde un contenedor)
wget -O - https://raw.githubusercontent.com/MondoBoricua/nginx-server/master/auto-install.sh | bash
```

### Método 2: Instalación Manual

```bash
# Clonar el repositorio
git clone https://github.com/MondoBoricua/nginx-server.git
cd nginx-server

# Hacer ejecutable el instalador
chmod +x auto-install.sh

# Ejecutar instalación
./auto-install.sh
```

## ✨ Características

* 🔧 **Instalación completamente automatizada**
* 🌐 **Nginx optimizado para producción**
* 📂 **Gestión fácil de sitios web**
* 🔒 **Soporte SSL/TLS con Let's Encrypt**
* 📊 **Panel de información del servidor**
* 🛠️ **Herramientas de gestión integradas**
* 📋 **Logs centralizados y monitoreo**
* 🔄 **Backup automático de configuraciones**
* 🎨 **Sitio web de ejemplo incluido**
* 🔐 **Configuración de seguridad avanzada**

## 🎯 Lo que Instala

* **Nginx** - Servidor web principal
* **PHP-FPM** - Procesamiento de PHP (opcional)
* **Certbot** - Certificados SSL gratuitos
* **UFW** - Firewall configurado
* **Fail2ban** - Protección contra ataques
* **Logrotate** - Gestión de logs
* **Herramientas de gestión** - Scripts personalizados

## 🏗️ Estructura del Proyecto

```
nginx-server/
├── auto-install.sh         # Instalador automático principal
├── install.sh             # Script de instalación en contenedor
├── nginx-manager.sh        # Herramienta de gestión de sitios
├── ssl-manager.sh          # Gestor de certificados SSL
├── welcome.sh              # Pantalla de bienvenida
├── backup-config.sh        # Script de respaldo
├── configs/
│   ├── nginx.conf          # Configuración principal de nginx
│   ├── default-site.conf   # Configuración de sitio por defecto
│   └── ssl-template.conf   # Template para sitios SSL
├── sites/
│   └── default/            # Sitio web de ejemplo
│       ├── index.html
│       ├── css/
│       └── js/
└── utils/
    ├── security.sh         # Configuraciones de seguridad
    └── monitoring.sh       # Herramientas de monitoreo
```

## 🔧 Configuración Automática

El script configura automáticamente:

* **Nginx** con configuración optimizada
* **Virtual hosts** para múltiples sitios
* **SSL/TLS** con certificados gratuitos
* **Firewall** con reglas de seguridad
* **Logs** centralizados y rotación
* **Backup** automático de configuraciones
* **Monitoreo** de servicios

## 🌐 Gestión de Sitios Web

### Crear Nuevo Sitio

```bash
# Usar el gestor integrado
nginx-manager create-site ejemplo.com

# Con SSL automático
nginx-manager create-site ejemplo.com --ssl
```

### Gestionar Sitios Existentes

```bash
# Listar sitios
nginx-manager list-sites

# Habilitar sitio
nginx-manager enable-site ejemplo.com

# Deshabilitar sitio
nginx-manager disable-site ejemplo.com

# Eliminar sitio
nginx-manager remove-site ejemplo.com
```

## 🔒 Certificados SSL

### Obtener Certificado SSL

```bash
# SSL para un dominio
ssl-manager get-cert ejemplo.com

# SSL para múltiples dominios
ssl-manager get-cert ejemplo.com www.ejemplo.com
```

### Renovar Certificados

```bash
# Renovación automática (configurada en cron)
ssl-manager renew-all

# Renovar certificado específico
ssl-manager renew ejemplo.com
```

## 🖥️ Acceso al Contenedor

### Consola Proxmox (Recomendado)

```bash
# Acceso directo sin contraseña
pct enter [ID_CONTENEDOR]
```

### SSH

```bash
# Acceso por SSH
ssh root@IP_DEL_CONTENEDOR
# Contraseña por defecto: nginx123
```

## 📊 Monitoreo y Logs

### Ver Estado del Servidor

```bash
# Información completa del servidor
nginx-info

# Estado de nginx
systemctl status nginx

# Procesos activos
nginx-manager status
```

### Logs del Sistema

```bash
# Logs de acceso
tail -f /var/log/nginx/access.log

# Logs de errores
tail -f /var/log/nginx/error.log

# Logs del sistema
journalctl -u nginx -f
```

## 🛠️ Solución de Problemas

### Problemas Comunes

#### Nginx no inicia

```bash
# Verificar configuración
nginx -t

# Ver logs de error
journalctl -u nginx --no-pager

# Reiniciar servicio
systemctl restart nginx
```

#### Problemas de permisos

```bash
# Corregir permisos de sitios web
chown -R www-data:www-data /var/www/
chmod -R 755 /var/www/
```

#### Problemas de SSL

```bash
# Verificar certificados
ssl-manager check-cert ejemplo.com

# Renovar certificado
ssl-manager renew ejemplo.com
```

## 🔧 Personalización

### Agregar Módulos de Nginx

```bash
# Instalar módulos adicionales
apt install nginx-module-geoip nginx-module-image-filter

# Habilitar en configuración
echo "load_module modules/ngx_http_geoip_module.so;" >> /etc/nginx/nginx.conf
```

### Configurar PHP

```bash
# Instalar PHP-FPM
apt install php-fpm php-mysql php-curl php-gd php-mbstring

# Configurar en nginx
nginx-manager enable-php ejemplo.com
```

## 🔄 Backup y Restauración

### Crear Backup

```bash
# Backup completo
backup-config.sh full

# Solo configuraciones
backup-config.sh config

# Solo sitios web
backup-config.sh sites
```

### Restaurar Backup

```bash
# Restaurar desde backup
backup-config.sh restore backup-YYYYMMDD.tar.gz
```

## 📝 Configuraciones de Ejemplo

### Sitio Web Estático

```nginx
server {
    listen 80;
    server_name ejemplo.com www.ejemplo.com;
    root /var/www/ejemplo.com;
    index index.html index.htm;

    location / {
        try_files $uri $uri/ =404;
    }
}
```

### Aplicación PHP

```nginx
server {
    listen 80;
    server_name app.ejemplo.com;
    root /var/www/app.ejemplo.com;
    index index.php index.html;

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
        fastcgi_index index.php;
        include fastcgi_params;
    }
}
```

## 🔐 Seguridad

El script configura automáticamente:

* **Fail2ban** - Protección contra ataques de fuerza bruta
* **UFW Firewall** - Solo puertos necesarios abiertos
* **SSL/TLS** - Cifrado en tránsito
* **Headers de seguridad** - Protección contra XSS, clickjacking
* **Rate limiting** - Protección contra DDoS básico

## 📈 Optimización

### Para Alto Tráfico

```bash
# Optimizar configuración
nginx-manager optimize-performance

# Habilitar caché
nginx-manager enable-cache ejemplo.com
```

### Para Desarrollo

```bash
# Modo desarrollo
nginx-manager dev-mode ejemplo.com

# Deshabilitar caché
nginx-manager disable-cache ejemplo.com
```

## 🤝 Contribuir

¿Encontraste un bug o tienes una mejora?

1. Haz fork del repositorio
2. Crea tu rama de feature (`git checkout -b feature/mejora-increible`)
3. Commit tus cambios (`git commit -am 'Añade mejora increíble'`)
4. Push a la rama (`git push origin feature/mejora-increible`)
5. Crea un Pull Request

## 📜 Licencia

Este proyecto está bajo la Licencia MIT - ve el archivo LICENSE para más detalles.

## ⭐ ¿Te Sirvió?

Si este script te ayudó, ¡dale una estrella al repo! ⭐

---

**Desarrollado en 🇵🇷 Puerto Rico con mucho ☕ café para la comunidad de Proxmox**

## 🔗 Recursos Adicionales

* [Documentación oficial de Nginx](https://nginx.org/en/docs/)
* [Guía de Proxmox LXC](https://pve.proxmox.com/wiki/Linux_Container)
* [Let's Encrypt](https://letsencrypt.org/)

---

*Basado en el exitoso proyecto [proxmox-samba](https://github.com/MondoBoricua/proxmox-samba)* 