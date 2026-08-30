#!/bin/bash
set -e

echo "🗑️  Desinstalando NitroSense CLI..."

# 1. Eliminar el ejecutable del sistema
if [ -f /usr/local/bin/nitro ]; then
    echo "Eliminando ejecutable /usr/local/bin/nitro..."
    sudo rm -f /usr/local/bin/nitro
fi

# 2. Eliminar la regla de sudoers
if [ -f /etc/sudoers.d/nitro-sense ]; then
    echo "Eliminando permisos sudoers /etc/sudoers.d/nitro-sense..."
    sudo rm -f /etc/sudoers.d/nitro-sense
fi

# 3. Eliminar el acceso directo de aplicaciones
if [ -f "$HOME/.local/share/applications/nitro.desktop" ]; then
    echo "Eliminando acceso directo de aplicaciones..."
    rm -f "$HOME/.local/share/applications/nitro.desktop"
    kbuildsycoca6 2>/dev/null || kbuildsycoca5 2>/dev/null || update-desktop-database "$HOME/.local/share/applications" 2>/dev/null
fi

echo "✨ ¡NitroSense CLI ha sido completamente desinstalado de tu sistema!"
