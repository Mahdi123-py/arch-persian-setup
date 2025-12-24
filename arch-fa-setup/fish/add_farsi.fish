#!/usr/bin/env fish

echo "Adding Farsi (Persian) support to Arch Linux..."

# Install Farsi fonts
echo "Installing Farsi fonts..."
sudo pacman -S --noconfirm noto-fonts

# Check if yay is installed, install if not
if not command -q yay
    echo "Installing yay..."
    sudo pacman -S --noconfirm yay
end

yay -S --noconfirm ttf-farsiweb ttf-vazirmatn ttf-vazir-code
if test $status -ne 0
    echo "yay failed, trying paru..."
    if not command -q paru
        echo "Installing paru..."
        sudo pacman -S --noconfirm paru
    end
    paru -S --noconfirm ttf-farsiweb ttf-vazirmatn ttf-vazir-code
    if test $status -ne 0
        echo "Failed to install AUR fonts. Please install manually: yay -S ttf-farsiweb ttf-vazirmatn ttf-vazir-code"
    end
end

# Detect desktop environment
set DE (echo $XDG_CURRENT_DESKTOP)

echo "Detected desktop: $DE"

switch $DE
    case "Hyprland"
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
        read -P "Enter choice (1-3): " choice

        switch $choice
            case 1
                sed -i '/kb_layout = us,ir/a\    kb_options = grp:ctrl_alt_toggle' ~/.config/hypr/hyprland/input.conf
            case 2
                sed -i '/# Testing/i\# Switch keyboard layout\nbind = Super, Alt_L, exec, hyprctl switchxkblayout current next' ~/.config/hypr/hyprland/keybinds.conf
            case 3
                sed -i '/kb_layout = us,ir/a\    kb_options = grp:alt_shift_toggle' ~/.config/hypr/hyprland/input.conf
            case '*'
                echo "Defaulting to Alt + Shift"
                sed -i '/kb_layout = us,ir/a\    kb_options = grp:alt_shift_toggle' ~/.config/hypr/hyprland/input.conf
        end

        hyprctl reload

    case "GNOME"
        echo "Setting up for GNOME..."
        # Add layouts
        gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'us'), ('xkb', 'ir')]"

        # Ask for shortcut
        echo "Select shortcut for GNOME:"
        echo "1. Super + Space"
        echo "2. Ctrl + Alt + Space"
        echo "3. Alt + Shift"
        read -P "Enter choice (1-3): " choice

        switch $choice
            case 1
                gsettings set org.gnome.desktop.wm.keybindings switch-input-source "['<Super>space']"
            case 2
                gsettings set org.gnome.desktop.wm.keybindings switch-input-source "['<Control><Alt>space']"
            case 3
                gsettings set org.gnome.desktop.wm.keybindings switch-input-source "['<Alt>Shift_L']"
            case '*'
                echo "Defaulting to Super + Space"
                gsettings set org.gnome.desktop.wm.keybindings switch-input-source "['<Super>space']"
        end

    case "KDE"
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
        read -P "Enter choice (1-3): " choice

        switch $choice
            case 1
                kwriteconfig5 --file kglobalshortcutsrc --group kcm_touchpad --key "Switch to Next Keyboard Layout" "Ctrl+Alt+K,none,Switch to Next Keyboard Layout"
            case 2
                kwriteconfig5 --file kglobalshortcutsrc --group kcm_touchpad --key "Switch to Next Keyboard Layout" "Meta+Space,none,Switch to Next Keyboard Layout"
            case 3
                kwriteconfig5 --file kglobalshortcutsrc --group kcm_touchpad --key "Switch to Next Keyboard Layout" "Alt+Shift,none,Switch to Next Keyboard Layout"
            case '*'
                echo "Defaulting to Ctrl + Alt + K"
                kwriteconfig5 --file kglobalshortcutsrc --group kcm_touchpad --key "Switch to Next Keyboard Layout" "Ctrl+Alt+K,none,Switch to Next Keyboard Layout"
        end

        # Restart plasmashell or something
        killall plasmashell && plasmashell &

    case '*'
        echo "Unsupported desktop environment: $DE. Please set up keyboard manually."
        echo "Installed fonts. For keyboard, add 'us,ir' layout and set switch shortcut in your DE settings."
end

echo "Farsi support setup complete!"