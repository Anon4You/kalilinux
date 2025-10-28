#!/usr/bin/env bash

##  Kali Linux :  Automated script to install kali linux in termux 
##  Author    : 	Alienkrishn [Anon4You]

##  Updated   : 	2025.08.14

## Provides ##
# PRETTY_NAME="Kali GNU/Linux Rolling"
# NAME="Kali GNU/Linux"
# VERSION_ID="2025.2"
# VERSION="2025.2"
# VERSION_CODENAME=kali-rolling

clear
CHROOT="$PREFIX/var/lib/proot-distro/installed-rootfs/debian/"

args="$@"

# check internet
ping -c 1 google.com >/dev/null 2>&1
if [ "$?" != '0' ]; then
  printf "No internet connection, Internet tera baap on karega madarchod!!\n"
  exit 1
fi

# color variable
red=$(tput setaf 1) green=$(tput setaf 2)
yellow=$(tput setaf 3) blue=$(tput setaf 4)
pink=$(tput setaf 5) cyan=$(tput setaf 6)
white=$(tput setaf 7) reset=$(tput sgr0)

Info(){
  printf "
${red}NOTE: ${cyan}Kali Linux installed successfully!

${green}To start Kali Linux:
${white}For CLI version: ${cyan}kalilinux
${white}For GUI version: ${cyan}First start kalilinux and type 'x11-start'

${yellow}Default credentials:
${white}Username: ${green}kali
${white}Password: ${green}kali

${yellow}Important GUI notes:
${white}1. Make sure Termux-X11 app is installed and running
${white}2. On first GUI start, it may take several minutes to initialize

${yellow}Report issues here: ${blue}https://github.com/Anon4You/kalilinux/issues/new 

${yellow}For usage visit: ${green}https://github.com/Anon4You/kalilinux?tab=readme-ov-file#usage-%%EF%%B8%%8F ${reset}
"
}
# Install required dependencies
install_dependencies() {
  printf "${green}\nInstalling required dependencies...\n${reset}"
  
  # Update packages
  apt update -y
  
  # Install basic dependencies
  apt install -y proot-distro wget curl
  
  # For GUI version, install additional packages
  if [[ ${args} == --GUI ]]; then
    printf "${yellow}\nInstalling GUI dependencies...\n${reset}"
    apt install -y x11-repo
    apt instsll -y termux-x11-nightly dbus pulseaudio
  fi
  
  printf "${green}\nDependencies installed successfully!\n${reset}"
}

# CLI installation
Install_cli() {
  echo -e "
apt-get update -y
apt install sudo curl -y
echo 'deb http://http.kali.org/kali kali-rolling main contrib non-free non-free-firmware' > /etc/apt/sources.list
curl -o /etc/apt/trusted.gpg.d/archive-keyring.gpg https://archive.kali.org/archive-keyring.gpg
apt-get update -y && apt-get dist-upgrade -y
useradd -m -s /bin/bash kali
echo 'kali:kali' | chpasswd 
echo 'kali  ALL=(ALL:ALL) ALL' >> /etc/sudoers.d/kali
curl -LO https://raw.githubusercontent.com/Anon4You/kalilinux/main/assets/.bashrc 
cp .bashrc /home/kali
sleep 1 
exit\n" > ${CHROOT}/root/.bashrc 
  proot-distro login debian
}

# GUI installation
Install_gui(){
  echo -e "
apt-get update -y
apt install sudo curl -y
rm -rf /etc/apt/sources.list
echo 'deb http://http.kali.org/kali kali-rolling main contrib non-free non-free-firmware' > /etc/apt/sources.list 
curl -o /etc/apt/trusted.gpg.d/archive-keyring.gpg https://archive.kali.org/archive-keyring.gpg
apt-get update -y && apt-get dist-upgrade -y
apt install dbus-x11 xwayland kali-desktop-xfce pulseaudio -y
curl -LO https://raw.githubusercontent.com/Anon4You/kalilinux/main/assets/.bashrc
useradd -m -s /bin/bash kali
echo 'kali:kali' | chpasswd 
echo 'kali  ALL=(ALL:ALL) ALL' >> /etc/sudoers.d/kali
cp .bashrc /home/kali
echo -e '#!/usr/bin/env bash 
export DISPLAY=:1
export PULSE_SERVER=127.0.0.1
startxfce4
' > /usr/bin/x11-start && chmod +x /usr/bin/x11-start 
sleep 1 
exit\n" > ${CHROOT}/root/.bashrc 
  proot-distro login debian
}

check_chroot(){
  if [[ -d ${CHROOT} ]]; then
    printf "\n${yellow}Existing debian found reseting...\n${reset}"
    proot-distro reset debian
  else
    proot-distro install debian
  fi
}

Help_menu(){
  printf "${red}
  ARGS                            Info
----------                    -------------
${green}
${0} --CLI :       will install command line kali linux in termux 

${0} --GUI :       to install kali linux with xfce4 desktop envirement

${0} --help :      for this menu 
${reset}
"
}

main(){
  printf "${blue}\n 
#    #    #    #       ###    #       ### #     # #     # #     #
#   #    # #   #        #     #        #  ##    # #     #  #   #
#  #    #   #  #        #     #        #  # #   # #     #   # #
###    #     # #        #     #        #  #  #  # #     #    #
#  #   ####### #        #     #        #  #   # # #     #   # #
#   #  #     # #        #     #        #  #    ## #     #  #   #
#    # #     # ####### ###    ####### ### #     #  #####  #     #
                                                Termux && Termux-x11 

${yellow}kalilinux installer script with [--CLI or --GUI] 
${green}Author: ${white}Alienkrishn [Anon4You]\n${reset}

"

  # Install dependencies first
  install_dependencies

  if [[ ${args} == --CLI ]]; then
    check_chroot
    Install_cli
    printf "pd login --user kali debian --shared-tmp\n" > $PREFIX/bin/kalilinux
    chmod +x $PREFIX/bin/kalilinux
    Info
  elif [[ ${args} == --GUI ]]; then
    check_chroot
    Install_gui
    printf "#!/usr/bin/env bash \ntermux-x11 :1 &\npulseaudio --start --load='module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1' --exit-idle-time=-1\nproot-distro login --user kali debian --shared-tmp\n" > $PREFIX/bin/kalilinux
    chmod +x $PREFIX/bin/kalilinux
    Info
    printf "\n${yellow}Please download and install Termux-x11 app from:${reset}"
    printf "\n${blue}https://github.com/termux/termux-x11/releases/tag/nightly${reset}\n"
    sleep 2
    xdg-open "https://github.com/termux/termux-x11/releases/tag/nightly"
  elif [[ ${args} == --help || ${args} == -h ]]; then
    Help_menu
  else
    Help_menu
  fi
}
main
