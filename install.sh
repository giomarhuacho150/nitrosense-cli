#!/bin/bash
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "📦 Instalando NitroSense CLI..."

if [ ! -f "$DIR/nitro.sh" ]; then
    echo "❌ Error: No se encontró nitro.sh en la carpeta actual."
    exit 1
fi

sudo cp "$DIR/nitro.sh" /usr/local/bin/nitro
sudo chmod +x /usr/local/bin/nitro

sudo mkdir -p /etc/sudoers.d
echo "$USER ALL=(ALL) NOPASSWD: /usr/bin/tee /sys/devices/platform/acer-wmi/nitro_sense/*, /usr/bin/tee /sys/devices/system/cpu/intel_pstate/no_turbo" | sudo tee /etc/sudoers.d/nitro-sense >/dev/null

mkdir -p "$HOME/.local/share/applications"
cat << 'DESKTOP_EOF' > "$HOME/.local/share/applications/nitro.desktop"
[Desktop Entry]
Name=NitroSense CLI
Comment=Control de ventiladores y hardware para Acer Nitro
Exec=/usr/local/bin/nitro
Icon=speedometer
Terminal=true
Type=Application
Categories=System;HardwareSettings;
Keywords=nitro;fans;ventiladores;acer;turbo;
DESKTOP_EOF

kbuildsycoca6 2>/dev/null || kbuildsycoca5 2>/dev/null || update-desktop-database "$HOME/.local/share/applications" 2>/dev/null

echo "✅ ¡Instalación completada con éxito!"
echo "Ejecuta 'nitro' en tu terminal o búscalo en tus aplicaciones."
