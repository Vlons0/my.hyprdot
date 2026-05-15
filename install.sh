#!/bin/bash

# 1. Variables de paquetes
PKGS=("kitty" "wofi" "amberol" "eww" "brightnessctl" "matugen-bin" "mpv" "gpu-screen-recorder-gtk-git" "ttf-jetbrains-mono-nerd" "jq" "hyprpaper" "imagemagick" "awww" "papirus-icon-theme" "flatpak" "wtype")

# Variable para los paquetes que se instalarán exclusivamente con paru
AUR_PACKAGES="hyprshade"

# 2. Rutas
DOTFILES_DIR=$(pwd)
CONFIG_DIR="$HOME/.config"

echo "--- Iniciando Instalación ---"

# 3. Verificación y actualización con yay
if ! command -v yay >/dev/null 2>&1; then
    echo "❌ Error: 'yay' no encontrado."
    exit 1
fi

echo "Sincronizando repositorios y actualizando sistema..."
yay -Syu --noconfirm

# 4. Verificación e Instalación de paru (Nuevo bloque)
if ! command -v paru >/dev/null 2>&1; then
    echo "📦 'paru' no encontrado. Instalando paru-bin..."
    sudo pacman -S --needed base-devel git --noconfirm
    git clone https://aur.archlinux.org/paru-bin.git /tmp/paru-bin
    (cd /tmp/paru-bin && makepkg -si --noconfirm)
    rm -rf /tmp/paru-bin
    echo "✅ Paru instalado."
fi

# 5. Instalar paquetes de AUR con paru usando la variable
echo "🎨 Instalando paquetes de AUR extra: $AUR_PACKAGES"
paru -S --needed --noconfirm $AUR_PACKAGES

# 6. Instalar lista principal de paquetes con yay (Tu ciclo original)
for PKG in "${PKGS[@]}"; do
    if ! pacman -Qi "$PKG" >/dev/null 2>&1; then
        echo "Instalando $PKG..."
        yay -S --noconfirm "$PKG"
    fi
done

# 7. Permisos de ejecución
echo "Dando permisos a los scripts..."
chmod +x ~/dotfiles/eww/scripts/theme_man \
         ~/dotfiles/eww/scripts/wall-online \
         ~/dotfiles/eww/scripts/wall-local \
         ~/dotfiles/eww/scripts/recorder

# 8. Despliegue de dotfiles
deploy_config() {
    local target="$CONFIG_DIR/$1"
    local source="$DOTFILES_DIR/$1"

    if [ -d "$source" ]; then
        echo "Limpiando y vinculando: $1"
        rm -rf "$target"
        ln -sf "$source" "$target"
    else
        echo "⚠️  No se encontró la carpeta '$1' en este repositorio."
    fi
}

deploy_config "kitty"
deploy_config "wofi"
deploy_config "hypr"
deploy_config "eww"
deploy_config "matugen"
deploy_config "waybar"

echo "✨ Proceso completado. Solo se modificaron las carpetas listadas."
