#!/bin/bash

# LiveCoding Config Installer
# Creates symlinks from repo files to their system locations

# Get the absolute path of this script
SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]}")"
# Get repo directory (directory where this script is located)
REPO_DIR="$(dirname "$SCRIPT_PATH")"

echo "=== LiveCoding Config Installer ==="
echo "Repository: $REPO_DIR"
echo ""

# Function to create symlink with backup
create_link() {
    local src="$1"
    local dest="$2"
    
    if [ -e "$dest" ] || [ -L "$dest" ]; then
        if [ -L "$dest" ]; then
            echo "Removing existing symlink: $dest"
            rm "$dest"
        else
            echo "Backing up: $dest -> ${dest}.bak"
            mv "$dest" "${dest}.bak"
        fi
    fi
    
    ln -s "$src" "$dest"
    echo "Created symlink: $dest -> $src"
}

# SuperCollider configs
echo ""
echo "--- SuperCollider ---"
SUPERCOLLIDER_DIR="$HOME/.config/SuperCollider"

create_link "$REPO_DIR/supercollider/startup.scd" "$SUPERCOLLIDER_DIR/startup.scd"
create_link "$REPO_DIR/supercollider/bitwig-midi-mapping.scd" "$SUPERCOLLIDER_DIR/bitwig-midi-mapping.scd"
create_link "$REPO_DIR/supercollider/vst-effects.scd" "$SUPERCOLLIDER_DIR/vst-effects.scd"
create_link "$REPO_DIR/supercollider/vst-params-helper.scd" "$SUPERCOLLIDER_DIR/vst-params-helper.scd"
create_link "$REPO_DIR/supercollider/sc_ide_conf.yaml" "$SUPERCOLLIDER_DIR/sc_ide_conf.yaml"
create_link "$REPO_DIR/supercollider/sclang_conf.yaml" "$SUPERCOLLIDER_DIR/sclang_conf.yaml"

# TidalCycles BootTidal.hs
echo ""
echo "--- TidalCycles ---"
TIDAL_DIR="$HOME/.pulsar/packages/tidalcycles/lib"

if [ -d "$TIDAL_DIR" ]; then
    create_link "$REPO_DIR/tidal/BootTidal.hs" "$TIDAL_DIR/BootTidal.hs"
else
    echo "WARNING: TidalCycles package not found at $TIDAL_DIR"
    echo "Skipping BootTidal.hs symlink"
fi

# Tidal song files
echo ""
echo "--- Tidal Song Files ---"
for song in "$REPO_DIR/songs"/*.tidal; do
    if [ -f "$song" ]; then
        filename=$(basename "$song")
        create_link "$song" "$HOME/$filename"
    fi
done

# Copy BootTidal.hs to project root (Pulsar looks for it there)
if [ -f "$REPO_DIR/tidal/BootTidal.hs" ]; then
    cp "$REPO_DIR/tidal/BootTidal.hs" "$REPO_DIR/BootTidal.hs"
    echo "Copied BootTidal.hs to project root (for Pulsar)"
fi

# VST Plugins
echo ""
echo "--- VST Plugins ---"
VST_DIR="$HOME/.vst3"

if [ -d "$REPO_DIR/supercollider/vst-plugins" ]; then
    mkdir -p "$VST_DIR"
    
    for plugin in "$REPO_DIR/supercollider/vst-plugins"/*.vst3; do
        if [ -d "$plugin" ]; then
            pluginname=$(basename "$plugin")
            create_link "$plugin" "$VST_DIR/$pluginname"
        fi
    done
else
    echo "VST plugins directory not found in repo"
fi

echo ""
echo "=== Installation Complete ==="
echo ""
echo "Symlinks created. Original files backed up with .bak extension."
echo ""
echo "Repository: $REPO_DIR"
echo ""
echo "NEXT STEPS:"
echo "1. Restart SuperCollider to load VST plugins"
echo "2. VSTPlugin.search will run automatically on startup"
echo "3. Verify plugins loaded:"
echo "   VSTPlugin.pluginList.printAll"