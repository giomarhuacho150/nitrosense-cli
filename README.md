# 🚀 NitroSense CLI Dashboard

Un panel TUI ultraligero y minimalista para controlar los ventiladores y el rendimiento de portátiles **Acer Nitro / Predator** en Linux.

Hecho por **Giomar Huacho** y **Clementine**.

---

## ✨ Características

- 🌪️ **Control de ventiladores:** Modos Auto (EC), Eco (40%), Equilibrado (65%), Máximo (100%) y Manual independiente.
- ⚡ **Toggle de Intel Turbo Boost:** Activa o desactiva el Turbo de la CPU en caliente con una sola tecla para evitar sobrecalentamientos.
- 🎮 **Asesino de procesos colgados:** Cierra procesos fantasma de juegos (Dota 2, CS2, shaders de Steam) con una tecla.
- 📊 **Métricas en tiempo real:** Temperaturas (CPU/GPU), uso de hardware, VRAM, consumo en Watts y RPM reales.
- ⚡ **Carga instantánea:** Consulta nativa de kernel (`/sys/` y `/proc/`) con 0% de consumo en reposo.

---

## 📋 Requisitos

1. Driver `acer-wmi` compatible con el sysfs de NitroSense (módulo de **DAMX** / `linuwu-sense` o `acer-wmi-dkms`).
2. `nvidia-smi` (para tarjetas NVIDIA).
3. Linux x86_64 con Bash.

---

## 📥 Instalación

```bash
git clone https://github.com/giomarhuacho150/nitrosense-cli.git
cd nitrosense-cli
chmod +x install.sh
./install.sh
