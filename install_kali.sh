#!/data/data/com.termux/files/usr/bin/bash
#
# install-kali.sh
# Install Kali (proot-distro) with an XFCE4 desktop reachable from a
# Termux:X11 launcher. Survives the systemd-under-proot postinst failure.
#
# Env overrides:
#   DISTRO=name          distro to install (default: kali-rolling)
#   KALI_USER=name       desktop user to create (default: kali)
#   KALI_PASS=pass       password for that user (default: kali)
#   FRESH=1              wipe + recreate the distro before installing
#

show_banner() {
  red=$(tput setaf 1 2>/dev/null); green=$(tput setaf 2 2>/dev/null)
  yellow=$(tput setaf 3 2>/dev/null); blue=$(tput setaf 4 2>/dev/null)
  white=$(tput setaf 7 2>/dev/null); reset=$(tput sgr0 2>/dev/null)
  printf "${blue}\n
#    #    #    #       ###    #       ### #     # #     # #     #
#   #    # #   #        #     #        #  ##    # #     #  #   #
#  #    #   #  #        #     #        #  # #   # #     #   # #
###    #     # #        #     #        #  #  #  # #     #    #
#  #   ####### #        #     #        #  #   # #     #   # #
#   #  #     # #        #     #        #  #    ## #     #  #   #
#    # #     # ####### ###    ####### ### #     #  #####  #     #
                                                Termux && Termux-x11

${yellow}Kali Linux installer for Termux (proot-distro)${reset}
${green}Author: ${white}Alienkrishn [Anon4You]${reset}\n\n"
}

show_banner

set -euo pipefail

DISTRO="${DISTRO:-kali-rolling}"
KUSER="${KALI_USER:-kali}"
KPASS="${KALI_PASS:-kali}"
DESKTOP_PKGS="${DESKTOP_PKGS:-dbus-x11 xwayland xfce4-terminal kali-desktop-xfce pulseaudio}"

die() { echo "ERROR: $*" >&2; exit 1; }

login_c() { proot-distro login "$DISTRO" -- bash -c "$1"; }

install_host_deps() {
    echo "== host: updating + full-upgrading Termux =="
    pkg update -y
    pkg upgrade -y
    pkg install -y proot-distro x11-repo
    pkg install -y termux-x11-nightly dbus pulseaudio
}

patch_binaries() {
    echo "== container: applying proot/systemd workarounds =="
    login_c '
        shim() {
            local bin="$1"
            [ -f "$bin" ] || return 0
            [ "$(head -c6 "$bin" 2>/dev/null)" = "#!/bin/" ] && return 0
            mv "$bin" "$bin.real"
            printf "#!/bin/sh\nexit 0\n" > "$bin"
            chmod 755 "$bin"
            echo "    shimmed $bin"
        }
        for b in systemctl systemd-tmpfiles systemd-sysusers systemd-machine-id-setup udevadm; do
            for p in /usr/bin/$b /usr/sbin/$b /bin/$b /sbin/$b; do
                [ -e "$p" ] && [ ! -L "$p" ] && shim "$p"
            done
        done
        [ -s /etc/machine-id ] || printf "00000000000000000000000000000000\n" > /etc/machine-id
        if [ ! -x /usr/sbin/policy-rc.d ]; then
            printf "#!/bin/sh\nexit 101\n" > /usr/sbin/policy-rc.d
            chmod 755 /usr/sbin/policy-rc.d
        fi
    '
}

sysusers_bootstrap() {
    echo "== container: making sure system/daemon users exist =="
    login_c '
        sysusers_create() {
            local f u g
            for f in /usr/lib/sysusers.d/*.conf; do
                [ -f "$f" ] || continue
                while read -r u g; do
                    [ -z "$u" ] && continue
                    case "$u" in
                        \#*|!*|"") continue ;;
                        g*) set -- $g; [ -n "$1" ] && grep -q "^$1:" /etc/group || groupadd --system "$1" 2>/dev/null ;;
                        u*) set -- $g; [ -n "$1" ] && grep -q "^$1:" /etc/passwd || useradd --system --shell /usr/sbin/nologin "$1" 2>/dev/null ;;
                    esac
                done < "$f"
            done
        }
        sysusers_create
        for u in messagebus polkitd pulse rtkit cups avahi _apt; do
            grep -q "^$u:" /etc/passwd || useradd --system --shell /usr/sbin/nologin "$u" 2>/dev/null || true
        done
        grep -q "^messagebus:" /etc/passwd && echo "    daemon users: OK" || echo "    WARNING: messagebus missing"
    '
}

recover() {
    login_c 'export DEBIAN_FRONTEND=noninteractive; dpkg --configure -a' >/dev/null 2>&1 || true
    login_c 'export DEBIAN_FRONTEND=noninteractive; apt-get install -f -y -o Dpkg::Options::="--force-confold" >/dev/null 2>&1' || true
}

verify_clean() {
    login_c 'dpkg --audit >/dev/null 2>&1; apt-get check >/dev/null 2>&1'
}

fresh_install() {
    echo "== host: recreating distro ${DISTRO} =="
    proot-distro list 2>&1 | grep -qE "^  \* ${DISTRO}([[:space:]]|$)" && proot-distro remove "$DISTRO"
    proot-distro install "$DISTRO"
}

bootstrap() {
    echo "== container: apt update + sudo/dbus =="
    login_c 'export DEBIAN_FRONTEND=noninteractive; apt-get update >/dev/null 2>&1'
    for i in 1 2 3; do
        if login_c 'export DEBIAN_FRONTEND=noninteractive; apt-get install -y --no-install-recommends sudo dbus >/dev/null 2>&1' && verify_clean; then
            return 0
        fi
        patch_binaries
        sysusers_bootstrap
        recover
    done
    die "could not install sudo/dbus"
}

add_user() {
    echo "== container: creating user ${KUSER}:${KPASS} =="
    login_c "
        id ${KUSER} >/dev/null 2>&1 || useradd -m -s /bin/bash ${KUSER}
        echo '${KUSER}:${KPASS}' | chpasswd
        printf '${KUSER}  ALL=(ALL:ALL) ALL\n' > /etc/sudoers.d/${KUSER}
        chmod 440 /etc/sudoers.d/${KUSER}
    "
}

install_desktop() {
    echo "== container: installing desktop (${DESKTOP_PKGS}) =="
    echo "    large download + many postinsts; first attempt aborts at systemd (expected):"
    for i in 1 2 3 4 5; do
        if login_c "export DEBIAN_FRONTEND=noninteractive; export APT_LISTCHANGES_FRONTEND=none; apt-get install -y -o Dpkg::Options::=\"--force-confold\" -o Dpkg::Options::=\"--force-confdef\" ${DESKTOP_PKGS}" && verify_clean; then
            echo "    desktop packages installed."
            return 0
        fi
        echo "    apt aborted at systemd postinst; patching and reconfiguring..."
        patch_binaries
        sysusers_bootstrap
        recover
    done
    login_c 'dpkg --audit'
    die "desktop install still has broken packages (see audit above)"
}

finalize_x11() {
    echo "== container: wiring X11 + sound env into the distro =="
    local RF="$PREFIX/var/lib/proot-distro/containers/${DISTRO}/rootfs"
    cat > "$RF/etc/profile.d/kali-x11.sh" <<'EOF'
if [ -z "$DISPLAY" ]; then export DISPLAY=:1; fi
if [ -z "$XDG_RUNTIME_DIR" ]; then export XDG_RUNTIME_DIR=/tmp/xdg-kali; fi
mkdir -p "$XDG_RUNTIME_DIR" 2>/dev/null
chmod 700 "$XDG_RUNTIME_DIR" 2>/dev/null
export XDG_SESSION_TYPE=x11
if [ -z "$PULSE_SERVER" ]; then export PULSE_SERVER=127.0.0.1; fi
EOF
    chmod 644 "$RF/etc/profile.d/kali-x11.sh"
    if ! grep -q "nethunter" "$RF/etc/hosts" 2>/dev/null; then
        printf "127.0.0.1  nethunter\n" >> "$RF/etc/hosts"
    fi
    echo "    DISPLAY=:1  XDG_RUNTIME_DIR  PULSE_SERVER  + /etc/hosts: OK"
}

make_launcher() {
    echo "== host: creating launcher ${PREFIX}/bin/kalilinux =="
    local L="${PREFIX}/bin/kalilinux"
    cat > "$L" <<EOF
#!/data/data/com.termux/files/usr/bin/bash
pkill -f com.termux.x11.Loader
pkill -f pulseaudio
termux-x11 :1 &
sleep 2
pulseaudio --start --load='module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1' --exit-idle-time=-1
proot-distro login ${DISTRO} --user ${KUSER} \\
    --hostname nethunter \\
    --shared-tmp \\
    --shared-x11
EOF
    chmod 755 "$L"
    echo "    launcher ready -> run:  kalilinux"
}

finish() {
    echo "== final verification =="
    login_c "
        dpkg --audit
        apt-get check
        sudo -V | head -1
        sudo -u ${KUSER} true && echo \"    sudo: OK for user ${KUSER}\"
        [ -x /usr/bin/startxfce4 ] && echo \"    startxfce4: present\"
    "
}

install_host_deps
command -v proot-distro >/dev/null 2>&1 || die "run me inside Termux (proot-distro missing)"
[ "${FRESH:-0}" = "1" ] && fresh_install
patch_binaries
sysusers_bootstrap
bootstrap
add_user
install_desktop
finalize_x11
make_launcher
finish

echo ""
echo "Done."
echo "  1) Open the 'Termux:X11' app on Android."
echo "  2) Run:  kalilinux        (starts termux-x11 + pulseaudio, logs into Kali as ${KUSER})"
echo "  3) Inside the shell, start the desktop with:  startxfce4"
echo "     (no sudo needed; DISPLAY=:1 is set automatically)"
echo "  4) Login user: ${KUSER}   pass: ${KPASS}   (sudo available)"