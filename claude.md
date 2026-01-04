# Documentación Interna - nginx-server

## Estado Actual

### auto-install.sh
Script de instalación automatizada de servidor Nginx en contenedor LXC de Proxmox.

**Última actualización**: 2026-01-04
**Commit**: `🔧 Mejorar auto-install.sh con soporte bilingüe y validaciones`

### Mejoras Implementadas

1. **Soporte Bilingüe (Inglés/Español)**
   - Selector de idioma al inicio
   - Variables TXT_* para todos los textos

2. **Silenciar Warnings de Locale**
   ```bash
   export LC_ALL=C
   export LANG=C
   ```

3. **Menú Interactivo con Pasos**
   - STEP 1/4: Container Configuration
   - STEP 2/4: Resources Configuration
   - STEP 3/4: Confirmation
   - STEP 4/4: Installation

4. **Función read_input() con Valores por Defecto**
   - Soporte para valores default
   - Validación de campos requeridos
   - Recursión si campo vacío y requerido

5. **Auto-detección de ID Disponible**
   - `get_next_available_id()` busca en LXC y VMs

6. **Listar Templates Disponibles**
   - Usa `pveam list local`

7. **Mostrar Recursos Disponibles**
   - Storage con `pvesm status`
   - Bridges con `ip link show type bridge`

8. **Validaciones**
   - Password mínimo 5 caracteres
   - Verificación de ID existente

9. **Confirmación con Formato Tree**
   ```
   Container
   ├─ ID: 100
   ├─ Name: nginx-server
   └─ Storage: local-lvm
   ```

10. **ASCII en lugar de Emojis**
    - [OK], [INFO], [ERROR], [WARN], [STEP]
    - Compatibilidad con todos los terminales

## Convenciones

### Commits
- Usar emoji al inicio: 📝 🔧 🚀 🐛 🌐
- Mensajes casuales, NO formales
- NO mencionar Claude/AI

### Archivos
- **README.md**: SI usar emojis
- **Scripts .sh**: NO emojis, usar [OK] [INFO] etc.

## Compatibilidad
- Proxmox VE 8.x y 9.x
- Ubuntu 22.04, 24.04
- Debian 12, 13

## Repositorio
- GitHub: https://github.com/MondoBoricua/nginx-server
- Usuario: MondoBoricua
