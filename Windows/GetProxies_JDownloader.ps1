# https://hmy.name/proxy-list/
# https://hide.mn/es/proxy-list/

# Definir colores
$green = [System.ConsoleColor]::Green
$reset = [System.ConsoleColor]::White
$cyan = [System.ConsoleColor]::Cyan
$red = [System.ConsoleColor]::Red
$yellow = [System.ConsoleColor]::Yellow
$blue = [System.ConsoleColor]::Blue
$magenta = [System.ConsoleColor]::Magenta

# Iconos
$checkmark = "[+]"
$errorIcon = "[-]"   # Cambiado de $error a $errorIcon
$info = "[*]"
$unknown = "[!]"
$process = "[>>]"
$indicator = "==>"

# Ruta de la carpeta y archivos
$carpetaDestino = "Proxies"
$archivoRecolector = "$carpetaDestino\recolector.txt"
$archivoProxies = "$carpetaDestino\proxies.txt"
$archivoJDownloader = "$carpetaDestino\proxies_jdownloader.txt"

# Crear la carpeta si no existe
function Crear-Carpeta {
    if (-not (Test-Path $carpetaDestino)) {
        New-Item -ItemType Directory -Path $carpetaDestino | Out-Null
        Write-Mensaje "$checkmark Carpeta '$carpetaDestino' creada." -color $green
    } else {
        Write-Mensaje "$info Carpeta '$carpetaDestino' ya existe." -color $yellow
    }
}

# Limpiar archivos antiguos si existen
function Limpiar-Archivos {
    $archivos = @($archivoProxies, $archivoJDownloader)
    foreach ($archivo in $archivos) {
        if (Test-Path $archivo) {
            Remove-Item $archivo
            Write-Mensaje "$checkmark Archivo '$archivo' eliminado." -color $green
        }
    }
}

# Leer proxies desde recolector.txt y guardarlos en proxies.txt
function Procesar-Proxies {
    if (-not (Test-Path $archivoRecolector)) {
        Write-Mensaje "$errorIcon El archivo '$archivoRecolector' no existe." -color $red
        exit 1
    }
    
    Write-Mensaje "$process Procesando el archivo '$archivoRecolector'...`n" -color $yellow
    
    # Patr�n actualizado para capturar IP y puerto
    $patronProxies = '\b(\d{1,3}\.){3}\d{1,3}[\s](\d{2,5})\b'
    $proxies = @()

    Get-Content $archivoRecolector -Encoding UTF8 | ForEach-Object {
        if ($_ -match $patronProxies) {
            $proxy = "$($matches[0])" -replace '\s', ':'
            Write-Mensaje "$info Proxy encontrado: $proxy" -color $cyan
            $proxies += $proxy
        }
    }

    if ($proxies.Count -eq 0) {
        Write-Mensaje "`n$errorIcon No se encontraron proxies v�lidos.`n" -color $red
    } else {
        $proxies | Out-File -FilePath $archivoProxies -Encoding UTF8
        Write-Mensaje "`n$checkmark Proxies procesados y guardados en '$archivoProxies'.`n" -color $green
    }
}

# Men� para seleccionar el tipo de proxy
function Mostrar-Menu {
    Write-Host "$blue Seleccione el tipo de proxy:`n" -ForegroundColor $blue
    Write-Host "1. HTTP" -ForegroundColor $blue
    Write-Host "2. HTTPS" -ForegroundColor $blue
    Write-Host "3. SOCKS4" -ForegroundColor $blue
    Write-Host "4. SOCKS5" -ForegroundColor $blue
    Write-Host "5. SOCKS4A" -ForegroundColor $blue
    Write-Host "6. Salir" -ForegroundColor $blue
    return Read-Host "`n$indicator Ingrese el n�mero de opci�n"
}

# Convertir proxies al formato de JDownloader
function Convertir-Proxies {
    while ($true) {
        $opcion = Mostrar-Menu
        
        switch ($opcion) {
            1 { $prefijo = "http" }
            2 { $prefijo = "https" }
            3 { $prefijo = "socks4" }
            4 { $prefijo = "socks5" }
            5 { $prefijo = "socks4a" }
            6 { Write-Mensaje "`n$info Saliendo...`n" -color $yellow; exit 0 }
            default { Write-Mensaje "$errorIcon Opci�n no v�lida." -color $red; continue }
        }

        if (-not (Test-Path $archivoProxies)) {
            Write-Mensaje "$errorIcon El archivo '$archivoProxies' no existe. Aseg�rese de haber procesado proxies correctamente." -color $red
            exit 1
        }

        $proxiesFormateados = @()
        Get-Content $archivoProxies -Encoding UTF8 | ForEach-Object {
            $proxiesFormateados += "${prefijo}://$($_ -replace '\s', ':')"
        }

        # Guardar proxies formateados
        $proxiesFormateados | Out-File -FilePath $archivoJDownloader -Encoding UTF8
        Write-Mensaje "`n$checkmark Proxies transformados y guardados en '$archivoJDownloader'.`n" -color $green
        break
    }
}

# Mostrar el banner
function Mostrar-Banner {
    Write-Host "`n=========================================" -ForegroundColor $magenta
    Write-Host " Extractor de Proxies para JDownloader 2" -ForegroundColor $magenta
    Write-Host "=========================================`n" -ForegroundColor $magenta
}

# Funci�n para escribir mensajes con color
function Write-Mensaje {
    param (
        [string]$mensaje,
        [ConsoleColor]$color
    )

    try {
        $originalColor = $Host.UI.RawUI.ForegroundColor
        $Host.UI.RawUI.ForegroundColor = $color
        Write-Host $mensaje
        $Host.UI.RawUI.ForegroundColor = $originalColor
    } catch {
        Write-Host "$errorIcon Error al escribir el mensaje: $_" -ForegroundColor $red
    }
}

# Ajustar codificaci�n de salida
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Ejecutar funciones
Mostrar-Banner
Crear-Carpeta
Limpiar-Archivos
Procesar-Proxies
Convertir-Proxies
