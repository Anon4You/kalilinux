# Kali Linux Installer for Termux

This repository provides a simple Bash script to install Kali Linux on Termux, allowing users to run either a command line interface (CLI) or a graphical user interface (GUI) version. The script automates the setup process and ensures all necessary dependencies are installed.

## Screenshot 📸

<details>
<summary>Click to view the screenshot</summary>

<p align="center">
  <img src="assets/screenshot.jpg">
</p>

</details>

## Features

- **CLI Installation**: Set up a command line version of Kali Linux within Termux.
- **GUI Installation**: Install Kali Linux with a graphical Xfce desktop environment.
- **Easy Usage**: Simple command-line arguments to choose the installation type.
- **User Creation**: Automatically creates a user for accessing the Kali environment.
- **Environment Setup**: Configures all necessary repositories and dependencies for smooth operation.

## Requirements

- [Termux](https://termux.com/)
- Internet connection

## Installation

To get started, clone this repository and navigate to the directory:

```bash
git clone https://github.com/Anon4You/kalilinux.git
cd kalilinux
```

Make the script executable:

```bash
chmod +x install_kali.sh
```

## Usage

Run the script with one of the following options:

### CLI Installation

To install the command line version of Kali Linux, execute:

```bash
./install_kali.sh --CLI
```

### GUI Installation

To install the graphical version of Kali Linux, execute:

```bash
./install_kali.sh --GUI
```

### Help

For help and usage information, run:

```bash
./install_kali.sh --help
```

## Post Installation

- After installation, you can log into the Kali environment by executing:

```bash
kalilinux
```

- For GUI installation, make sure to download the Termux-X11 app from [here](https://github.com/termux/termux-x11/releases/tag/nightly).

## Issues

If you encounter any issues, please report them on the [GitHub Issues page](https://github.com/Anon4You/kalilinux/issues/new).

## Contribution

Feel free to fork the repository and submit pull requests for improvements or additional features!

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author

**Alienkrishn** (Anon4You)

---

Enjoy your Kali Linux experience on Termux!
