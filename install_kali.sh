#!/usr/bin/env bash

##  Kali Linux :  Automated script to install kali linux in termux 
##  Author 	   : 	Alienkrishn [Anon4You]
##  Version 	 : 	2025.2.12

clear
CHROOT="$PREFIX/var/lib/proot-distro/installed-rootfs/debian/"

args="$@"

# cheack internet
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
${red}NOTE: ${cyan}Kali Linux installed successfuly execute ${green}'kalilinux' ${cyan}to login Kali shell

${yellow}Report issus here: ${blue}https://github.com/Anon4You/kalilinux/issues/new 

${yellow}For usage kindly visit the readme file of this repository
${white}From here: ${green}https://github.com/Anon4You/kalilinux?tab=readme-ov-file#usage ${reset}
}
"
}
# requrements
Install_cli() {
  echo -e "
apt-get update -y
apt install gnupg sudo curl -y
echo 'deb http://http.kali.org/kali kali-rolling main contrib non-free non-free-firmware' > /etc/apt/sources.list
curl -sSL https://archive.kali.org/archive-key.asc | apt-key add
mv /etc/apt/trusted.gpg /etc/apt/trusted.gpg.d
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


Install_gui(){
  [ -e $PREFIX/etc/apt/sources.list.d/x11.list ] || { printf "${green}\nx11-repo not found!, Installing... x11-repo\n${reset}"; apt install x11-repo -y 1; }
  command -v termux-x11 > /dev/null 2>&1 || { printf "${green}\ntermux-x11 not found!, Installing...termux-x11\n${reset}"; apt install termux-x11-nightly -y 1; }
  command -v dbus > /dev/null 2>&1 || { printf "${green}\ndbus not found!, Installing...dbus\n${reset}"; apt install dbus -y 1; }
  echo -e "
apt-get update -y
apt install gnupg sudo curl -y
rm -rf /etc/apt/sources.list
echo 'deb http://http.kali.org/kali kali-rolling main contrib non-free non-free-firmware' > /etc/apt/sources.list
curl -sSL https://archive.kali.org/archive-key.asc | apt-key add
mv /etc/apt/trusted.gpg /etc/apt/trusted.gpg.d
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
  if ! hash proot-distro > /dev/null 2>&1; then
    apt install proot-distro -y
  fi
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
  printf "\nPlease download and install Termux-x11 app..."
  sleep 2
  xdg-open "https://github.com/termux/termux-x11/releases/tag/nightly"
elif [[ ${args} == --help || ${args} == -h ]]; then
  Help_menu
else
  Help_menu
fi
}
main
