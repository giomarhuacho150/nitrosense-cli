#!/bin/bash
# ==============================================================================
# NitroSense CLI Minimalist
# Hecho por Giomar Huacho y Clementine
# ==============================================================================
export LC_ALL=C

FAN_FILE="/sys/devices/platform/acer-wmi/nitro_sense/fan_speed"
TURBO_FILE="/sys/devices/system/cpu/intel_pstate/no_turbo"

# Colores ANSI
C_ORANGE='\033[38;5;208m'
C_CYAN='\033[1;36m'
C_GREEN='\033[1;32m'
C_RED='\033[1;31m'
C_YELLOW='\033[1;33m'
C_PURPLE='\033[1;35m'
C_BLUE='\033[1;34m'
C_GRAY='\033[0;90m'
C_WHITE='\033[1;37m'
C_RESET='\033[0m'

cleanup() {
    echo -ne "\033[?25h\033[0m\n"
    exit 0
}
trap cleanup INT TERM EXIT

clear
echo -ne "\033[?25l"
STATUS="Listo para la acción."

while true; do
    HORA=$(date +"%H:%M:%S")

    # 1. Estado de ventilación
    FAN_VAL="0,0"
    [ -f "$FAN_FILE" ] && FAN_VAL=$(cat "$FAN_FILE" 2>/dev/null)
    [ -z "$FAN_VAL" ] && FAN_VAL="0,0"

    # 2. RPMs en tiempo real
    CPU_RPM=0; GPU_RPM=0
    for h in /sys/devices/platform/acer-wmi/hwmon/hwmon* /sys/class/hwmon/hwmon*; do
        if [ -f "$h/fan1_input" ]; then
            CPU_RPM=$(cat "$h/fan1_input" 2>/dev/null || echo 0)
            GPU_RPM=$(cat "$h/fan2_input" 2>/dev/null || echo 0)
            break
        fi
    done
    [[ ! "$CPU_RPM" =~ ^[0-9]+$ ]] && CPU_RPM=0
    [[ ! "$GPU_RPM" =~ ^[0-9]+$ ]] && GPU_RPM=0

    # 3. CPU Temp
    CPU_T=45
    for f in /sys/class/thermal/thermal_zone*/temp /sys/class/hwmon/hwmon*/temp1_input; do
        if [ -f "$f" ]; then
            t=$(cat "$f" 2>/dev/null)
            if [[ "$t" =~ ^[0-9]+$ ]] && [ "$t" -gt 10000 ]; then
                CPU_T=$((t / 1000))
                break
            fi
        fi
    done
    
    # 4. Estado de Intel Turbo Boost
    TURBO_STAT="${C_GREEN}ON${C_RESET}"
    if [ -f "$TURBO_FILE" ]; then
        [ "$(cat "$TURBO_FILE" 2>/dev/null)" = "1" ] && TURBO_STAT="${C_RED}OFF${C_RESET}"
    fi

    # 5. GPU Metrics (NVIDIA)
    GPU_T="--"; GPU_U="0%"; GPU_P=""
    if command -v nvidia-smi &>/dev/null; then
        RAW=$(nvidia-smi --query-gpu=temperature.gpu,utilization.gpu,power.draw --format=csv,noheader,nounits 2>/dev/null | head -n1)
        if [ -n "$RAW" ]; then
            IFS=',' read -r gt gu gp <<< "$RAW"
            gt=$(echo "$gt" | tr -d ' '); gu=$(echo "$gu" | tr -d ' '); gp=$(echo "$gp" | tr -d ' ' | cut -d'.' -f1)
            [ -n "$gt" ] && GPU_T="${gt}°C"
            [ -n "$gu" ] && GPU_U="${gu}%"
            [ -n "$gp" ] && [ "$gp" -gt 0 ] 2>/dev/null && GPU_P=" ${gp}W"
        fi
    fi

    # 6. Memoria RAM
    mem_tot=$(awk '/MemTotal:/ {print $2}' /proc/meminfo)
    mem_avail=$(awk '/MemAvailable:/ {print $2}' /proc/meminfo)
    mem_used=$(( (mem_tot - mem_avail) / 1048576 ))
    mem_max=$(( mem_tot / 1048576 ))

    # Color de CPU Temp
    COL_CPU="$C_GREEN"; [ "$CPU_T" -ge 65 ] && COL_CPU="$C_YELLOW"; [ "$CPU_T" -ge 80 ] && COL_CPU="$C_RED"

    # Render Minimalista
    echo -ne "\033[H"
    echo -e "${C_ORANGE}┌─[ ${C_CYAN}NITRO CLI${C_ORANGE} ]─────────────────────────────────────────[ ${C_YELLOW}${HORA}${C_ORANGE} ]─┐${C_RESET}\033[K"
    echo -e "${C_ORANGE}│${C_RESET}  💻 CPU: ${COL_CPU}${CPU_T}°C${C_RESET} │ 🎮 GPU: ${C_CYAN}${GPU_T}${C_RESET} (${GPU_U}${GPU_P}) │ 🧠 RAM: ${C_PURPLE}${mem_used}/${mem_max}G${C_RESET} │ ⚡ Turbo: ${TURBO_STAT}  ${C_ORANGE}│${C_RESET}\033[K"
    echo -e "${C_ORANGE}│${C_RESET}  🌪️  FAN: ${C_WHITE}${FAN_VAL}%${C_RESET} │ CPU: ${C_CYAN}${CPU_RPM} RPM${C_RESET} │ GPU: ${C_CYAN}${GPU_RPM} RPM${C_RESET}                      ${C_ORANGE}│${C_RESET}\033[K"
    echo -e "${C_ORANGE}├──────────────────────────────────────────────────────────────────┤${C_RESET}\033[K"
    echo -e "${C_ORANGE}│${C_RESET}  ${C_YELLOW}[1]${C_RESET} Auto  ${C_YELLOW}[2]${C_RESET} Eco(40%)  ${C_YELLOW}[3]${C_RESET} Mid(65%)  ${C_YELLOW}[4]${C_RESET} Max(100%)  ${C_YELLOW}[5]${C_RESET} Manual       ${C_ORANGE}│${C_RESET}\033[K"
    echo -e "${C_ORANGE}│${C_RESET}  ${C_YELLOW}[t]${C_RESET} Turbo ON/OFF   ${C_YELLOW}[k]${C_RESET} Kill Games/Zombies   ${C_YELLOW}[q]${C_RESET} Salir              ${C_ORANGE}│${C_RESET}\033[K"
    echo -e "${C_ORANGE}├──────────────────────────────────────────────────────────────────┤${C_RESET}\033[K"
    echo -e "${C_ORANGE}│${C_RESET}  💜 ${C_PURPLE}Hecho por Giomar Huacho y Clementine${C_RESET}                         ${C_ORANGE}│${C_RESET}\033[K"
    echo -e "${C_ORANGE}└──────────────────────────────────────────────────────────────────┘${C_RESET}\033[K"
    echo -e "  Estado: ${C_GRAY}${STATUS}${C_RESET}\033[K"
    echo -ne "  > \033[K"

    # Lectura de 1 tecla
    read -t 1 -n 1 -s key
    case "$key" in
        1)
            echo "0,0" | sudo tee "$FAN_FILE" >/dev/null 2>&1
            STATUS="${C_GREEN}Modo Automático EC activo.${C_RESET}"
            ;;
        2)
            echo "40,40" | sudo tee "$FAN_FILE" >/dev/null 2>&1
            STATUS="${C_CYAN}Modo Eco (40%) activo.${C_RESET}"
            ;;
        3)
            echo "65,65" | sudo tee "$FAN_FILE" >/dev/null 2>&1
            STATUS="${C_BLUE}Modo Equilibrado (65%) activo.${C_RESET}"
            ;;
        4)
            echo "100,100" | sudo tee "$FAN_FILE" >/dev/null 2>&1
            STATUS="${C_RED}Modo Turbo Máximo (100%) activo.${C_RESET}"
            ;;
        5)
            echo -ne "\033[?25h\n"
            read -p "  Introduce velocidad de ventiladores (10-100): " custom_pct
            echo -ne "\033[?25l"
            if [[ "$custom_pct" =~ ^[0-9]+$ ]] && [ "$custom_pct" -ge 10 ] && [ "$custom_pct" -le 100 ]; then
                echo "${custom_pct},${custom_pct}" | sudo tee "$FAN_FILE" >/dev/null 2>&1
                STATUS="${C_YELLOW}Ventiladores fijados al ${custom_pct}%.${C_RESET}"
            else
                STATUS="${C_RED}Porcentaje no válido (10-100).${C_RESET}"
            fi
            clear
            ;;
        t|T)
            if [ -f "$TURBO_FILE" ]; then
                curr=$(cat "$TURBO_FILE" 2>/dev/null)
                if [ "$curr" = "0" ]; then
                    echo 1 | sudo tee "$TURBO_FILE" >/dev/null 2>&1
                    STATUS="${C_RED}Intel Turbo Boost DESACTIVADO.${C_RESET}"
                else
                    echo 0 | sudo tee "$TURBO_FILE" >/dev/null 2>&1
                    STATUS="${C_GREEN}Intel Turbo Boost ACTIVADO.${C_RESET}"
                fi
            else
                STATUS="${C_RED}Control de Turbo no disponible.${C_RESET}"
            fi
            ;;
        k|K)
            killall -9 dota2 dota2.sh cs2 2>/dev/null
            pkill -9 -f "steam_app|dota" 2>/dev/null
            STATUS="${C_GREEN}Procesos de juegos cerrados.${C_RESET}"
            ;;
        0|q|Q)
            cleanup
            ;;
    esac
done
