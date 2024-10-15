#!/bin/sh

# Copyright (c) 2023 bobbyunknown
# https://github.com/bobbyunknown
# 
# Hak Cipta Dilindungi Undang-Undang
# https://rem.mit-license.org/

PACKAGE_NAME="luci-app-openclash"

get_latest_release_url() {
    REPO="bobbyunknown/OpenClash-lite"
    API_URL="https://api.github.com/repos/$REPO/releases"
    if [ "$1" = "dev" ]; then
        DOWNLOAD_URL=$(curl -s "$API_URL" | grep "browser_download_url.*dev.*ipk" | head -n 1 | cut -d '"' -f 4)
    else
        DOWNLOAD_URL=$(curl -s "$API_URL/latest" | grep "browser_download_url.*stable.*ipk" | head -n 1 | cut -d '"' -f 4)
    fi
    
    if [ ! -z "$DOWNLOAD_URL" ]; then
        FILENAME=$(basename "$DOWNLOAD_URL")
        echo "$DOWNLOAD_URL|$FILENAME"
    else
        echo ""
    fi
}

check_system_resources() {
    FREE_SPACE=$(df -h /tmp | awk 'NR==2 {print $4}')
    echo "Ruang disk tersedia di /tmp: $FREE_SPACE"
}

install_package() {
    local version=$1
    check_system_resources
    echo "Menginstal $PACKAGE_NAME versi $version..."
    opkg update && opkg install coreutils-nohup bash iptables dnsmasq-full curl ca-certificates ipset ip-full iptables-mod-tproxy iptables-mod-extra libcap libcap-bin ruby ruby-yaml kmod-tun kmod-inet-diag unzip luci-compat luci luci-base
    
    RELEASE_INFO=$(get_latest_release_url $version)
    if [ -z "$RELEASE_INFO" ]; then
        echo "Gagal mendapatkan informasi rilis. Silakan coba lagi nanti."
        read -p "Tekan Enter untuk melanjutkan..."
        return 1
    fi
    
    DOWNLOAD_URL=$(echo "$RELEASE_INFO" | cut -d'|' -f1)
    FILENAME=$(echo "$RELEASE_INFO" | cut -d'|' -f2)
    
    echo "Mengunduh $FILENAME..."
    if ! curl -L -o "/tmp/$FILENAME" "$DOWNLOAD_URL"; then
        echo "Gagal mengunduh file. Silakan periksa koneksi internet Anda."
        read -p "Tekan Enter untuk melanjutkan..."
        return 1
    fi
    
    if [ ! -f "/tmp/$FILENAME" ]; then
        echo "File tidak ditemukan setelah unduhan. Silakan coba lagi."
        read -p "Tekan Enter untuk melanjutkan..."
        return 1
    fi
    
    echo "File yang diunduh: /tmp/$FILENAME"
    ls -l "/tmp/$FILENAME"
    
    echo "Menginstal paket..."
    if ! opkg install "/tmp/$FILENAME"; then
        echo "Gagal menginstal paket. Silakan coba opsi force install."
        rm -f "/tmp/$FILENAME"
        read -p "Tekan Enter untuk melanjutkan..."
        return 1
    fi
    
    rm -f "/tmp/$FILENAME"
    echo "Instalasi $PACKAGE_NAME selesai."
    read -p "Tekan Enter untuk melanjutkan..."
}

force_install_package() {
    local version=$1
    check_system_resources
    echo "Melakukan force install $PACKAGE_NAME versi $version..."
    opkg update && opkg install coreutils-nohup bash iptables dnsmasq-full curl ca-certificates ipset ip-full iptables-mod-tproxy iptables-mod-extra libcap libcap-bin ruby ruby-yaml kmod-tun kmod-inet-diag unzip luci-compat luci luci-base
    
    RELEASE_INFO=$(get_latest_release_url $version)
    if [ -z "$RELEASE_INFO" ]; then
        echo "Gagal mendapatkan informasi rilis. Silakan coba lagi nanti."
        read -p "Tekan Enter untuk melanjutkan..."
        return 1
    fi
    
    DOWNLOAD_URL=$(echo "$RELEASE_INFO" | cut -d'|' -f1)
    FILENAME=$(echo "$RELEASE_INFO" | cut -d'|' -f2)
    
    echo "Mengunduh $FILENAME..."
    if ! curl -L -o "/tmp/$FILENAME" "$DOWNLOAD_URL"; then
        echo "Gagal mengunduh file. Silakan periksa koneksi internet Anda."
        read -p "Tekan Enter untuk melanjutkan..."
        return 1
    fi
    
    if [ ! -f "/tmp/$FILENAME" ]; then
        echo "File tidak ditemukan setelah unduhan. Silakan coba lagi."
        read -p "Tekan Enter untuk melanjutkan..."
        return 1
    fi
    
    echo "File yang diunduh: /tmp/$FILENAME"
    ls -l "/tmp/$FILENAME"
    
    echo "Melakukan force install paket..."
    if ! opkg install --force-reinstall "/tmp/$FILENAME"; then
        echo "Gagal melakukan force install paket."
        rm -f "/tmp/$FILENAME"
        read -p "Tekan Enter untuk melanjutkan..."
        return 1
    fi
    
    rm -f "/tmp/$FILENAME"
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
    echo "│  1. Install OpenClash (Stable)      │"
    echo "│  2. Install OpenClash (Dev)         │"
    echo "│  3. Force Install OpenClash (Stable)│"
    echo "│  4. Force Install OpenClash (Dev)   │"
    echo "│  5. Uninstall OpenClash             │"
    echo "│  6. Keluar                          │"
    echo "│                                     │"
    echo "└─────────────────────────────────────┘"
    echo
    read -p "Pilihan Anda [1-6]: " choice
    echo

    case $choice in
        1)
            install_package "stable"
            ;;
        2)
            install_package "dev"
            ;;
        3)
            force_install_package "stable"
            ;;
        4)
            force_install_package "dev"
            ;;
        5)
            uninstall_package
            ;;
        6)
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
