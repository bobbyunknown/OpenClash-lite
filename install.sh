#!/bin/sh

# Copyright (c) 2023 bobbyunknown
# https://github.com/bobbyunknown
# 
# Hak Cipta Dilindungi Undang-Undang
#

PACKAGE_NAME="luci-app-openclash"

get_latest_release_url() {
    REPO="bobbyunknown/OpenClash-lite"
    API_URL="https://api.github.com/repos/$REPO/releases/latest"
    DOWNLOAD_URL=$(curl -s "$API_URL" | grep "browser_download_url.*ipk" | cut -d '"' -f 4)
    echo "$DOWNLOAD_URL"
}

install_package() {
    echo "Menginstal $PACKAGE_NAME..."
    opkg update && opkg install coreutils-nohup bash iptables dnsmasq-full curl ca-certificates ipset ip-full iptables-mod-tproxy iptables-mod-extra libcap libcap-bin ruby ruby-yaml kmod-tun kmod-inet-diag unzip luci-compat luci luci-base
    
    DOWNLOAD_URL=$(get_latest_release_url)
    FILENAME=$(basename "$DOWNLOAD_URL")
    wget -O "/tmp/$FILENAME" "$DOWNLOAD_URL"
    
    opkg install "/tmp/$FILENAME"
    
    rm "/tmp/$FILENAME"
    echo "Instalasi $PACKAGE_NAME selesai."
    read -p "Tekan Enter untuk melanjutkan..."
}

force_install_package() {
    echo "Melakukan force install $PACKAGE_NAME..."
    opkg update && opkg install coreutils-nohup bash iptables dnsmasq-full curl ca-certificates ipset ip-full iptables-mod-tproxy iptables-mod-extra libcap libcap-bin ruby ruby-yaml kmod-tun kmod-inet-diag unzip luci-compat luci luci-base
    
    DOWNLOAD_URL=$(get_latest_release_url)
    FILENAME=$(basename "$DOWNLOAD_URL")
    wget -O "/tmp/$FILENAME" "$DOWNLOAD_URL"
    
    opkg install --force-overwrite "/tmp/$FILENAME"
    
    rm "/tmp/$FILENAME"
    echo "Force install $PACKAGE_NAME selesai."
    read -p "Tekan Enter untuk melanjutkan..."
}

uninstall_package() {
    echo "Menghapus $PACKAGE_NAME..."
    opkg remove "$PACKAGE_NAME"
    find / -type d -name "*openclash*" -exec rm -rf {} + 2>/dev/null
    find / -type f -name "*openclash*" -delete 2>/dev/null
    echo "Paket $PACKAGE_NAME dan file-file terkait berhasil dihapus."
    read -p "Tekan Enter untuk melanjutkan..."
}

while true; do
    clear
    echo "┌─────────────────────────────────────┐"
    echo "│     OpenClash-lite Installer        │"
    echo "│     github.com/bobbyunknown         │"
    echo "├─────────────────────────────────────┤"
    echo "│                                     │"
    echo "│  1. Install OpenClash               │"
    echo "│  2. Force Install OpenClash         │"
    echo "│  3. Uninstall OpenClash             │"
    echo "│  4. Keluar                          │"
    echo "│                                     │"
    echo "└─────────────────────────────────────┘"
    echo
    read -p "Pilihan Anda [1-4]: " choice
    echo

    case $choice in
        1)
            install_package
            ;;
        2)
            force_install_package
            ;;
        3)
            uninstall_package
            ;;
         4)
            echo "Keluar dari program."
            exit 0
            ;;
        *)
            echo "Pilihan tidak valid. Silakan coba lagi."
            ;;
    esac

    echo "Operasi selesai."
    echo
done