#!/bin/bash

# =============================================================================
# Script Name: Batokpipe.sh
# Description: This script performs Update PipeNetwork operations.
# Author: Batok
# Date Created: 2024-12-22
# Version: 1.0
# License: MIT License
# =============================================================================

# Your script code starts here
echo "██████╗  █████╗ ████████╗ ██████╗ ██╗  ██╗
██╔══██╗██╔══██╗╚══██╔══╝██╔═══██╗██║ ██╔╝
██████╔╝███████║   ██║   ██║   ██║█████╔╝ 
██╔══██╗██╔══██║   ██║   ██║   ██║██╔═██╗ 
██████╔╝██║  ██║   ██║   ╚██████╔╝██║  ██╗
╚═════╝ ╚═╝  ╚═╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝
                                          "

# Minta pengguna memasukkan address reward
echo "Masukkan address EVM yg connect ke Website :"
read -r REWARD_ADDRESS

# Pastikan input address tidak kosong
if [[ -z "$REWARD_ADDRESS" ]]; then
  echo "Error: Reward address tidak boleh kosong."
  exit 1
fi

# Hentikan layanan cysic jika sedang berjalan
sudo systemctl stop cysic

# Hapus file database cysic-verifier
sudo rm -rf cysic-verifier/data/cysic-verifier.db

# Unduh dan jalankan skrip setup dari GitHub dengan address yang dimasukkan
curl -L https://github.com/cysic-labs/phase2_libs/releases/download/v1.0.0/setup_linux.sh > ~/setup_linux.sh
bash ~/setup_linux.sh "$REWARD_ADDRESS"

# Membuat file konfigurasi systemd untuk cysic service
sudo tee /etc/systemd/system/cysic.service > /dev/null << EOF 
[Unit]
Description=Cysic Verifier Node 
After=network-online.target

[Service]
User=$USER
ExecStart=/bin/bash -c 'cd $HOME/cysic-verifier && bash start.sh' 
Restart=always
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF

# Muat ulang systemd untuk mengenali layanan cysic
sudo systemctl daemon-reload

# Aktifkan layanan cysic untuk start otomatis pada boot
sudo systemctl enable cysic

# Mulai layanan cysic
sudo systemctl start cysic

# Tampilkan log cysic secara real-time
sudo journalctl -u cysic -f --no-hostname -o cat
