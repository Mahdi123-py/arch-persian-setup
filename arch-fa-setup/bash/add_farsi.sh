#!/bin/bash

echo "Adding Farsi (Persian) support to Arch Linux..."

# Install Farsi fonts
echo "Installing Farsi fonts..."
sudo pacman -S --noconfirm noto-fonts
if ! command -v yay &> /dev/null; then
    echo "Installing yay..."
    sudo pacman -S --noconfirm yay
fi
yay -S --noconfirm ttf-farsiweb ttf-vazirmatn ttf-vazir-code
if [ $? -ne 0 ]; then
    echo "yay failed, trying paru..."
    if ! command -v paru &> /dev/null; then
        echo "Installing paru..."
        sudo pacman -S --noconfirm paru
    fi
    paru -S --noconfirm ttf-farsiweb ttf-vazirmatn ttf-vazir-code
    if [ $? -ne 0 ]; then
        echo "Failed to install AUR fonts. Please install manually: yay -S ttf-farsiweb ttf-vazirmatn ttf-vazir-code"
    fi
fi

# Detect desktop environment
DE=$XDG_CURRENT_DESKTOP

echo "Detected desktop: $DE"

case $DE in
    "Hyprland")
        echo "Setting up for Hyprland..."
        # Backup configs
        cp ~/.config/hypr/hyprland/input.conf ~/.config/hypr/hyprland/input.conf.backup
        cp ~/.config/hypr/hyprland/keybinds.conf ~/.config/hypr/hyprland/keybinds.conf.backup

        # Set layout
        sed -i 's/kb_layout = us/kb_layout = us,ir/' ~/.config/hypr/hyprland/input.conf
        sed -i '/kb_options =/d' ~/.config/hypr/hyprland/input.conf
        sed -i '/bind.*switchxkblayout/d' ~/.config/hypr/hyprland/keybinds.conf

        # Ask for shortcut
        echo "Select shortcut for Hyprland:"
        echo "1. Ctrl + Alt"
        echo "2. Super + Alt"
        echo "3. Alt + Shift"
        read -p "Enter choice (1-3): " choice

        case $choice in
            1)
                sed -i '/kb_layout = us,ir/a\    kb_options = grp:ctrl_alt_toggle' ~/.config/hypr/hyprland/input.conf
                ;;
            2)
                sed -i '/# Testing/i\# Switch keyboard layout\nbind = Super, Alt_L, exec, hyprctl switchxkblayout current next' ~/.config/hypr/hyprland/keybinds.conf
                ;;
            3)
                sed -i '/kb_layout = us,ir/a\    kb_options = grp:alt_shift_toggle' ~/.config/hypr/hyprland/input.conf
                ;;
            *)
                echo "Defaulting to Ctrl + Alt"
                sed -i '/kb_layout = us,ir/a\    kb_options = grp:ctrl_alt_toggle' ~/.config/hypr/hyprland/input.conf
                ;;
        esac

        hyprctl reload
        ;;

    "GNOME")
        echo "Setting up for GNOME..."
        # Add layouts
        gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'us'), ('xkb', 'ir')]"

        # Ask for shortcut
        echo "Select shortcut for GNOME:"
        echo "1. Super + Space"
        echo "2. Ctrl + Alt + Space"
        echo "3. Alt + Shift"
        read -p "Enter choice (1-3): " choice

        case $choice in
            1)
                gsettings set org.gnome.desktop.wm.keybindings switch-input-source "['<Super>space']"
                ;;
            2)
                gsettings set org.gnome.desktop.wm.keybindings switch-input-source "['<Control><Alt>space']"
                ;;
            3)
                gsettings set org.gnome.desktop.wm.keybindings switch-input-source "['<Alt>Shift_L']"
                ;;
            *)
                echo "Defaulting to Super + Space"
                gsettings set org.gnome.desktop.wm.keybindings switch-input-source "['<Super>space']"
                ;;
        esac
        ;;

    "KDE")
        echo "Setting up for KDE..."
        # Set layouts
        kwriteconfig5 --file kxkbrc --group Layout --key LayoutList us,ir
        kwriteconfig5 --file kxkbrc --group Layout --key Use true
        kwriteconfig5 --file kxkbrc --group Layout --key VariantList ,pes_keypad

        # Ask for shortcut
        echo "Select shortcut for KDE:"
        echo "1. Ctrl + Alt + K"
        echo "2. Super + Space"
        echo "3. Alt + Shift"
        read -p "Enter choice (1-3): " choice

        case $choice in
            1)
                kwriteconfig5 --file kglobalshortcutsrc --group kcm_touchpad --key "Switch to Next Keyboard Layout" "Ctrl+Alt+K,none,Switch to Next Keyboard Layout"
                ;;
            2)
                kwriteconfig5 --file kglobalshortcutsrc --group kcm_touchpad --key "Switch to Next Keyboard Layout" "Meta+Space,none,Switch to Next Keyboard Layout"
                ;;
            3)
                kwriteconfig5 --file kglobalshortcutsrc --group kcm_touchpad --key "Switch to Next Keyboard Layout" "Alt+Shift,none,Switch to Next Keyboard Layout"
                ;;
            *)
                echo "Defaulting to Ctrl + Alt + K"
                kwriteconfig5 --file kglobalshortcutsrc --group kcm_touchpad --key "Switch to Next Keyboard Layout" "Ctrl+Alt+K,none,Switch to Next Keyboard Layout"
                ;;
        esac

        # Restart plasmashell
        killall plasmashell && plasmashell &
        ;;

    *)
        echo "Unsupported desktop environment: $DE. Please set up keyboard manually."
        echo "Installed fonts. For keyboard, add 'us,ir' layout and set switch shortcut in your DE settings."
        ;;
esac

echo "Farsi support setup complete!"