# Dotfiles — ExploitEngineer

![Arch Linux + Hyprland](https://img.shields.io/badge/Arch%20Linux-Hyprland-blue?style=flat-square\&logo=arch-linux)
![Status](https://img.shields.io/badge/status-active-success?style=flat-square)
![License](https://img.shields.io/badge/license-MIT-green?style=flat-square)

Welcome to my **personal dotfiles** repository! 🛠️
This repo contains my full **\~/.config** setup for **Arch Linux + Hyprland**, and scripts to **install, backup, and manage** these dotfiles easily.

---

## 📦 Features

* Organized `~/.config` structure
* One-command installation via GNU **stow**
* Automatic **backup** of existing configs
* Supports **partial installs** for specific configs
* Fallback script using **rsync** if stow is unavailable
* Easy **uninstall** of symlinks

---

## 📂 Repository Structure

```bash
~/dotfiles
├── .config/
│   ├── hypr/
│   ├── waybar/
│   ├── kitty/
│   ├── nvim/
│   ├── ...
├── install-stow.sh      # Recommended installation method
├── install.sh           # Manual rsync-based installer
├── uninstall-stow.sh    # Removes symlinks created by stow
└── README.md
```

> **Note:** We intentionally exclude `zed` configs from this repository.

---

## 🚀 Installation

### **1. Clone the repository**

```bash
git clone https://github.com/ExploitEngineer/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

---

### **2. Install using GNU Stow (Recommended)**

This is the safest and cleanest way to manage dotfiles.

#### **2.1 Install stow (if not installed)**

```bash
sudo pacman -S stow
```

#### **2.2 Run the install script**

```bash
./install-stow.sh
```

This will:

* Automatically back up existing configs to `~/.dotfiles-backup/<timestamp>`
* Symlink everything from `~/dotfiles/.config/` → `~/.config/`

#### **2.3 Install only specific configs**

If you only want certain configs (e.g., hypr + waybar):

```bash
./install-stow.sh hypr waybar
```

---

### **3. Install using rsync (Fallback)**

If you don't want symlinks and prefer direct copying:

```bash
./install.sh
```

This will:

* Copy everything from `.config/` into `~/.config/`
* Backup any conflicting configs into `~/.dotfiles-backup/<timestamp>`

---

### **4. Uninstall (Revert stow links)**

To remove all symlinks created by GNU stow:

```bash
./uninstall-stow.sh
```

> Backups created during installation remain safe in `~/.dotfiles-backup/`.

---

## 🔄 Backups

Every time you install using **stow** or **rsync**, existing configs are **moved** to:

```bash
~/.dotfiles-backup/<timestamp>/
```

You can restore them manually if needed.

---

## ⚡ Quick Commands

| Action                   | Command                                                                |
| ------------------------ | ---------------------------------------------------------------------- |
| Clone repo               | `git clone https://github.com/ExploitEngineer/dotfiles.git ~/dotfiles` |
| Install everything       | `./install-stow.sh`                                                    |
| Install specific configs | `./install-stow.sh hypr waybar kitty`                                  |
| Fallback rsync install   | `./install.sh`                                                         |
| Uninstall stow links     | `./uninstall-stow.sh`                                                  |

---

## 🛠️ Troubleshooting

### **1. "warning: adding embedded git repository"**

If you see this when pushing, remove any unwanted `.git` folders inside `.config`:

```bash
rm -rf ~/dotfiles/.config/<package>/.git
```

### **2. Stow not found**

Install it:

```bash
sudo pacman -S stow
```

### **3. Conflicts with existing configs**

Check the backup folder:

```bash
ls ~/.dotfiles-backup/
```

---

## 🧠 Pro Tip

Want your dotfiles synced across devices? Just:

```bash
git pull origin main
./install-stow.sh
```

This will fetch the latest configs and apply them instantly.

---

## 📜 License

This repository is licensed under the **MIT License** — free to use and modify.

---

## 🤝 Contributing

Found an issue or have suggestions? Feel free to fork the repo and submit a PR.

**Repo:** [ExploitEngineer/dotfiles](https://github.com/ExploitEngineer/dotfiles)

---

### 🎯 Final Words

> This setup is optimized for **Arch Linux + Hyprland** but can be adapted to other distros easily.

Happy hacking! 🚀
