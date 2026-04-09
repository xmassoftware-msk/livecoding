#!/bin/bash

# LiveCoding Config Installer
# Creates symlinks from repo files to their system locations

REPO_DIR="$HOME/liveCoding"

echo "=== LiveCoding Config Installer ==="
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

echo ""
echo "=== Installation Complete ==="
echo ""
echo "Symlinks created. Original files backed up with .bak extension."
echo ""
echo "Git repository structure:"
echo "  $REPO_DIR/"
echo ""
echo "To initialize git repository:"
echo "  cd $REPO_DIR"
echo "  git init"
echo "  git add ."
echo "  git commit -m 'Initial commit'"