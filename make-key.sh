#!/bin/bash

#Includes
DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
. "$DIR/include.sh"

# Options
PRIV="MOK.priv"
DER="MOK.der"
CN="$1"
PART="$2"
SCRIPT_DIR=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
DISTRO=$(cat /etc/os-release | grep -io "^id=.*" | awk -F'=' '{print $2}' | sed 's/\"//g')
RHEL=("centos" "rhel" "fedora" "rocky")
DEB=("ubuntu" "debian" "linuxmint" "kali")
ALG=$(grep -Pio 'CONFIG_MODULE_SIG_HASH.*' /usr/lib/modules/$(uname -r)/source/.config | awk -F'"' '{print $2}')
KL="/usr/lib/modules/$(uname -r)/source/scripts"
EFI="/sys/firmware/efi"

# Check if user is root
rootcheck

# Ensure that arguments are specified
if [[ -z "$1" ]] || [[ -z "$2" ]]; then
    echo -e "$be${c[11]}Part 1 is for creating a MOK and Part 2 is for after rebooting$ee"
    echo -e "$be${c[10]}$0$ee $be${c[9]}<CN/Common Name> <Part 1|2>$ee"
    echo -e "Example: $0 mymok 1"
    exit
fi
echo ""

# If PART 1, then install MOK, if PART 2, then validate key and start signing LKMs
if [[ "$PART" == 1 ]]; then
    # Check if system is running with UEFI
    info 0 "Checking if the system is using UEFI"
    if [ -d $EFI ]; then
        echo -e "$be${c[14]}Boot-Mode:$ee $be${c[10]}UEFI$ee"
        echo -e "$be${c[13]}Compatability:$ee $be${c[10]}Success$ee"
    else
        echo -e "$be${c[14]}Boot-Mode:$ee $be${c[9]}BIOS$ee"
        echo -e "$be${c[13]}Compatability:$ee $be${c[9]}Failed$ee"
        exit
    fi
    echo ""

    # Ensure that kernel headers and kernel dev packages are installed
    info 0 "Guessing OS distro and installing kernel headers and gcc"
    echo ""
    if [[ $DISTRO == ${DEB[0]} ]] || [[ $DISTRO == ${DEB[1]} ]] || [[ $DISTRO == ${DEB[2]} ]] || [[ $DISTRO == ${DEB[3]} ]]; then
        allcheck 0 "Attempting to install kernel headers and gcc" apt install linux-headers-$(uname -r) build-essential -y
    elif [[ $DISTRO == ${RHEL[0]} ]] || [[ $DISTRO == ${RHEL[1]} ]] || [[ $DISTRO == ${RHEL[2]} ]] || [[ $DISTRO == ${RHEL[3]} ]]; then
        allcheck 0 "Attemping to install kernel headers and gcc" yum install kernel kernel-devel kernel-headers gcc -y
    else
        info 1 "Unable to guess the OS distro"
        echo ""
        exit
    fi
    
    # Create the MOK which will later be used to sign any LKMs
    info 0 "Creating the MOK" 
    openssl req -new -x509 -newkey rsa:2048 -keyout $PRIV -outform DER -out $DER -days 36500 -subj "/CN=$CN/" -nodes
    ifcheck "Creating the MOK"
    echo ""
    
    # Import the MOK, which will prompt for a temp password
    info 0 "Importing the MOK" 
    mokutil --import $DER
    ifcheck "Importing the MOK"
    echo ""

    # Check if the user would like to reboot now
    #echo -e "$be${c[11]}Would you like to reboot now? (y|n) "
    yesno "Would you like to reboot now?" && reboot -f
fi


### PART 1.5 ### Reboot and this system will automatically enter UEFI MOK management tool at boot ###
# 1. Select *Enroll MOK
# 2. Select *Continue
# 3. Select *Yes
# 4. Enter the password from eariler
# 5. Select the option to reboot

# PART 2
if [[ "$PART" == 2 ]]; then
    # Verify that the MOK has been installed
    echo -e "$be${c[13]}MOK: $(dmesg | grep -i EFI.*cert.*$CN)$ee"

    echo -e "\n$be${c[11]}If your MOK is installed, you should now be able to sign LKMs\nRemember to resign LKMs whenever the kernel updates$ee\n"
    
    echo -e "$be${c[11]}Run this to sign a LKM: $ee"
    echo -e "$be${c[12]}$KL/sign-file $ALG $SCRIPT_DIR/$PRIV $SCRIPT_DIR/$DER <lkm.ko>$ee"
fi

