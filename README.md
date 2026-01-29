# 🐧 Kali Linux Installer for Termux (2025.4)

[![GitHub License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Termux Supported](https://img.shields.io/badge/Termux-Supported-brightgreen)](https://termux.com)
[![Kali 2025 Verified](https://img.shields.io/badge/Kali-2025.4%20Verified-blueviolet)](https://www.kali.org)

**Now with fixed 2025 repository signing keys**  
The installer has been updated to work with Kali's new 2025 archive signing key

## 📥 Installation


# CLI Version
`bash <(curl -sL is.gd/alienkrishn_kalilinux) --CLI
`
# GUI Version 
`bash <(curl -sL is.gd/alienkrishn_kalilinux) --GUI
`

## 🛠️ What's New
- ✅ Fixed repository signing key (2025 update)
- ✅ Working `apt update` and `apt install`
- ✅ All Kali 2025.4 tools available
- ✅ Better ARM64 compatibility

## ✨ Features
- **Your Options**:
  - `--CLI` for command-line version
  - `--GUI` for Xfce desktop
- **New Under the Hood**:
  - Updated Kali GPG keys
  - Fixed package verification
  - 2025 repository support

## 🚀 Usage (Same as Before)
```bash
kalilinux  # Enter environment (unchanged)
x11-start  # For GUI version (original command)
```

## ⚠️ Important Fix
The script now includes Kali's **2025 signing key** that was added after:
```text
The previous error you'd see:
E: The repository 'https://http.kali.org/kali kali-rolling Release' 
is not signed because the public key is not available: NO_PUBKEY ED444FF07D8D0BF6
```
## ⚠️ Important Note
if `x11-start' not working try installing dependencies manually by executing this command in kali
```
sudo apt install dbus-x11 xwayland kali-desktop-xfce pulseaudio -y
```

## 📜 Everything Else Unchanged
- Same simple installation process
- Same commands you're familiar with
- Now just works with 2025 repositories

## Maintained by [Alienkrishn](https://github.com/Anon4You)  
