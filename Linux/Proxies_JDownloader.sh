#!/bin/bash

# Paleta de colores
reset="\033[0m"       # Restablecer todos los estilos y colores
bold="\033[1m"        # Texto en negrita
italic="\033[3m"      # Texto en cursiva
underline="\033[4m"   # Texto subrayado
blink="\033[5m"       # Texto parpadeante
reverse="\033[7m"     # Invertir colores de fondo y texto
hidden="\033[8m"      # Texto oculto (generalmente invisible)

# Colores de texto
black="\033[0;30m"     # Negro
red="\033[0;31m"       # Rojo
green="\033[0;32m"     # Verde
yellow="\033[0;33m"    # Amarillo
blue="\033[0;34m"      # Azul
magenta="\033[0;35m"   # Magenta
cyan="\033[0;36m"      # Cian
white="\033[0;37m"     # Blanco

# Colores de fondo
bg_black="\033[0;40m"     # Fondo Negro
bg_red="\033[0;41m"       # Fondo Rojo
bg_green="\033[0;42m"     # Fondo Verde
bg_yellow="\033[0;43m"    # Fondo Amarillo
bg_blue="\033[0;44m"      # Fondo Azul
bg_magenta="\033[0;45m"   # Fondo Magenta
bg_cyan="\033[0;46m"      # Fondo Cian
bg_white="\033[0;47m"     # Fondo Blanco

# Iconos
checkmark="${white}[${green}+${white}]${green}"
error="${white}[${red}-${white}]${red}"
info="${white}[${yellow}*${white}]${yellow}"
unknown="${white}[${blue}!${white}]${blue}"
process="${white}[${magenta}>>${white}]${magenta}"
indicator="${red}==>${cyan}"

# Barra de separación
barra="${blue}|--------------------------------------------|${reset}"
bar="${yellow}----------------------------------------------${reset}"

# Comprobación de permisos de root
[[ "$(whoami)" != "root" ]] && {
    echo -e "\n${error} Necesitas ejecutar este script como administrador (${red}root${reset})."
    echo -e "\n${info} Intenta: sudo $0"
    exit 0
}

# Ruta de la carpeta y archivos
carpetaDestino="Proxies"
archivoRecolector="$carpetaDestino/recolector.txt"
archivoProxies="$carpetaDestino/proxies.txt"
archivoJDownloader="$carpetaDestino/proxies_jdownloader.txt"

# Mostrar banner
function MostrarBanner {
    echo -e "\n${blue}========================================="
    echo -e "${yellow} Extractor de Proxies para JDownloader 2"
    echo -e "${blue}=========================================${reset}\n"
    echo -e " ${green}    ____________________________"
    echo -e "    |\_________________________/|\\"
    echo -e "    ||                         || \\"
    echo -e "    ||                         ||  \\"
    echo -e "    ||                         ||  |"
    echo -e "    ||                         ||  |"
    echo -e "    ||                         ||  |"
    echo -e "    ||                         ||  |"
    echo -e "    ||                         ||  |"
    echo -e "    ||                         ||  /"
    echo -e "    ||_________________________|| /"
    echo -e "    |/_________________________\|/"
    echo -e "       __\_________________/__/|_"
    echo -e "      |_______________________|/"
    echo -e "    ________________________"
    echo -e "   /oooo  oooo  oooo  oooo /|"
    echo -e "  /ooooooooooooooooooooooo/ /"
    echo -e " /ooooooooooooooooooooooo/ /"
    echo -e "/C=_____________________/_/ \n"
}

# Crear la carpeta si no existe
function CrearCarpeta {
    if [[ ! -d "$carpetaDestino" ]]; then
        mkdir -p "$carpetaDestino"
        echo -e "${checkmark} Carpeta '${cyan}$carpetaDestino${reset}' creada."
    else
        echo -e "${info} Carpeta '${cyan}$carpetaDestino${reset}' ya existe."
    fi
}

# Limpiar archivos antiguos si existen
function LimpiarArchivos {
    for archivo in "$archivoProxies" "$archivoJDownloader"; do
        if [[ -f "$archivo" ]]; then
            rm "$archivo"
            echo -e "${checkmark} Archivo '${cyan}$archivo${reset}' eliminado."
        fi
    done
}

# Expresión regular para detectar proxies en el formato IP y puerto
patronProxies='^([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)[[:space:]]+([0-9]{2,5})'

# Leer proxies desde recolector.txt y guardar en proxies.txt
function ProcesarProxies {
    if [[ ! -f "$archivoRecolector" ]]; then
        echo -e "${error} El archivo '${cyan}$archivoRecolector${reset}' no existe."
        exit 1
    fi

    echo -e "${info} Procesando el archivo '${cyan}$archivoRecolector${reset}'..."

    proxies=()

    while IFS= read -r linea; do
        if [[ "$linea" =~ $patronProxies ]]; then
            ip="${BASH_REMATCH[1]}"
            puerto="${BASH_REMATCH[2]}"
            if (( puerto >= 1 && puerto <= 65535 )); then
                proxies+=("$ip:$puerto")
            fi
        fi
    done < "$archivoRecolector"

    if [[ ${#proxies[@]} -eq 0 ]]; then
        echo -e "${error} No se encontraron proxies válidos."
    else
        printf "%s\n" "${proxies[@]}" > "$archivoProxies"
        echo -e "${checkmark} Proxies procesados y guardados en '${cyan}$archivoProxies${reset}'."
    fi
}

# Menú para seleccionar el tipo de proxy y convertir el formato
function MostrarMenu {
    echo -e "\n${yellow}Seleccione el tipo de proxy:"
    echo -e "\n${cyan}1.${reset} HTTP"
    echo -e "${cyan}2.${reset} HTTPS"
    echo -e "${cyan}3.${reset} SOCKS4"
    echo -e "${cyan}4.${reset} SOCKS5"
    echo -e "${cyan}5.${reset} SOCKS4A\n"
    read -rp "Ingrese el número de opción: " opcion
}

# Convertir proxies al formato de JDownloader
function ConvertirProxies {
    MostrarMenu
    
    case $opcion in
        1) prefijo="http" ;;
        2) prefijo="https" ;;
        3) prefijo="socks4" ;;
        4) prefijo="socks5" ;;
        5) prefijo="socks4a" ;;
        *) echo -e "${error} Opción no válida."; exit 1 ;;
    esac

    if [[ ! -f "$archivoProxies" ]]; then
        echo -e "\n${error} El archivo '$archivoProxies' no existe. Asegúrese de haber procesado proxies correctamente."
        exit 1
    fi

    proxiesFormateados=()

    while IFS= read -r proxy; do
        proxiesFormateados+=("${prefijo}://${proxy}")
    done < "$archivoProxies"

    # Guardar proxies formateados en el archivo
    printf "%s\n" "${proxiesFormateados[@]}" > "$archivoJDownloader"
    echo -e "\n${checkmark} Proxies transformados y guardados en '${cyan}$archivoJDownloader${reset}'."
}

# Ejecutar las funciones
MostrarBanner
CrearCarpeta
LimpiarArchivos
ProcesarProxies

# Solo mostrar el menú si se encontraron proxies válidos
if [[ -f "$archivoProxies" && -s "$archivoProxies" ]]; then
    ConvertirProxies
else
    echo -e "\n${error} No se encontraron proxies válidos para convertir."
fi
