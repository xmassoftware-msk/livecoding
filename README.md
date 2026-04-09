# Live Coding Config Repository

Repository for SuperCollider and TidalCycles configuration files with symlinks.

## Structure

```
liveCoding/
├── supercollider/     # SuperCollider configuration
│   ├── startup.scd
│   ├── bitwig-midi-mapping.scd
│   ├── sc_ide_conf.yaml
│   └── sclang_conf.yaml
├── tidal/             # TidalCycles configuration
│   └── BootTidal.hs
├── songs/             # Tidal song files (.tidal)
└── install.sh         # Symlink installation script
```

## Installation

Run the installation script to create symlinks:

```bash
./install.sh
```

This will:
- Link SuperCollider configs to `~/.config/SuperCollider/`
- Link BootTidal.hs to `~/.pulsar/packages/tidalcycles/lib/`
- Link .tidal files to `~/`

## Manual Symlinks (Alternative)

If you prefer to set up symlinks manually:

```bash
# Backup and remove original SuperCollider configs
mv ~/.config/SuperCollider/startup.scd ~/.config/SuperCollider/startup.scd.bak
mv ~/.config/SuperCollider/bitwig-midi-mapping.scd ~/.config/SuperCollider/bitwig-midi-mapping.scd.bak

# Create symlinks
ln -s ~/liveCoding/supercollider/startup.scd ~/.config/SuperCollider/startup.scd
ln -s ~/liveCoding/supercollider/bitwig-midi-mapping.scd ~/.config/SuperCollider/bitwig-midi-mapping.scd

# Backup Tidal config
mv ~/.pulsar/packages/tidalcycles/lib/BootTidal.hs ~/.pulsar/packages/tidalcycles/lib/BootTidal.hs.bak

# Create symlink
ln -s ~/liveCoding/tidal/BootTidal.hs ~/.pulsar/packages/tidalcycles/lib/BootTidal.hs
```

## Adding New Songs

Add your `.tidal` files to the `songs/` directory, then run the install script or manually link them to `~/`.

## SuperCollider Config

- `startup.scd` - Main startup file for SuperDirt initialization
- `bitwig-midi-mapping.scd` - MIDI CC parameter mappings for Bitwig integration

## TidalCycles Config

- `BootTidal.hs` - TidalCycles startup script loaded by GHCi