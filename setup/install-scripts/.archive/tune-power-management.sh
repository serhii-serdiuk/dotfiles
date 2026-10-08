#!/bin/bash

LOGFILE=/var/log/setup-tlp.log

# OS (e.g. Tuxedo or Fedora)
OS=`lsb_release -i | awk {' print $3 '}`

log() {
	echo -e "`date` - $*" 2>&1 | sudo tee -a $LOGFILE
}

if [[ $OS == "Tuxedo" || $OS == "Ubuntu" ]]; then
    log "Do nothing"
elif [ $OS == "Fedora" ]; then
    sudo systemctl stop power-profiles-daemon.service
    # sudo systemctl mask power-profiles-daemon.service
    sudo dnf remove -y power-profiles-daemon
    sudo dnf install -y powertop tlp tlp-rdw
    sudo systemctl enable tlp.service
    sudo systemctl mask systemd-rfkill.service systemd-rfkill.socket
fi



# POWER CONSUMPTION INVESTIGATION

# installed Fedora (on Wayland with tlp)
# 30W (monitor not connected but it was connected before so dGPU was activated) / 30W (monitor connected)

# boot from USB (Power Profiles Daemon)
# 30W / 30W

# openSUSE/Fedora
# nvidia driver: 11W (after monitor disconnected) / 14W (monitor connected)

# Fedora on X11 with open source driver - BEST COMBO
# 5W / 22W
# ISSUES: screen tearing

# IMPROVEMENTS:
# fix screen tearing on X11 with open source driver OR decrease consumption on Wayland and heat after external monitor connected with going back to normal when disconnected OR fix installation of nvidia driver
# try offload feature on open source driver to decrease consumption even more on X11 (and maybe on Wayland?)
# achive 5W in idle using nvidia driver, increase when monitor connected (to 15W) and return to normal when disconnected


# Useful links for NVIDIA setup:
# https://docs.fedoraproject.org/en-US/quick-docs/setup_rpmfusion/
# https://rpmfusion.org/Howto/NVIDIA#Current_GeForce.2FQuadro.2FTesla
# https://rpmfusion.org/Howto/Optimus
# https://wiki.archlinux.org/title/NVIDIA_Optimus_(%D0%A0%D1%83%D1%81%D1%81%D0%BA%D0%B8%D0%B9)#%D0%98%D1%81%D0%BF%D0%BE%D0%BB%D1%8C%D0%B7%D1%83%D1%8F_PRIME_Render_Offload
# https://www.reddit.com/r/Fedora/comments/x744u2/sharing_my_experience_setting_up_fedora_36_in_my/
#    39  sudo dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
#    40  sudo dnf install https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
#    41  sudo dnf install akmod-nvidia
#    42  modinfo -F version nvidia
# sudo vim /etc/modprobe.d/blacklist.conf (it seems not necessary)


# Investigation of increased power consumption after update on test system

# https://www.omgubuntu.co.uk/2018/02/better-battery-life-on-fedora-linux

# I had the same issue, ok try this in terminal:
#
# cat /sys/kernel/debug/pmc_core/package_cstate_show
#
# Result:
#
# Package C2 : 1003764950
#
# Package C3 : 264638875
#
# Package C6 : 1293716
#
# Package C7 : 7731429
#
# Package C8 : 627324241
#
# Package C9 : 0
#
# If the result shows 0 for c6 c7 c8 etc, its showing that the cpu is not completely using power conserving states. Anyways I solved it through changing the hard disk type form RAID to AHCI in bios.

# https://hansdegoede.livejournal.com/18412.html
