# ReproFed

**Declarative Fedora Configuration Manager**

![Stage](https://img.shields.io/badge/stage-alpha-orange)
![License](https://img.shields.io/github/license/ephmo/reprofed)

---

ReproFed is a declarative configuration manager designed specifically for Fedora Linux. It allows you to define system profiles using simple YAML files and apply them reproducibly across installations and Fedora releases.

The goal of ReproFed is to make Fedora systems **predictable, reproducible, and easy to manage**.

---

## 🚀 Key Features

- **Declarative Configuration:** Define your desired system state in simple YAML profiles.
- **Reproducibility:** Replicate your exact setup across reinstalls and upgrades.
- **Version-Aware:** Profiles respect Fedora versioning for safe and explicit upgrades.
- **Modular Design:** Core actions are modular and extensible.
- **Fedora-Native CLI:** Familiar command-line interface designed for the Fedora ecosystem.

---

## 💡 Concept

ReproFed shifts the system management paradigm from manual tweaks to a desired-state model. Instead of manually running individual commands to install packages or change settings, you follow a simple workflow:

1. **Define:** Choose or create a YAML profile.
2. **Apply:** Use the ReproFed CLI to set the profile.
3. **Sync:** ReproFed automatically brings the system into the state declared in the profile.

---

## 🛠 Usage

### Profile Management

```bash
# List available profiles
reprofed --profile list

# View details of a specific profile
reprofed --profile info gnome

# Get current system profile
reprofed --profile get

# Apply a new profile
reprofed --profile set gnome
```

### Service & Update Management

```bash
# Manage the ReproFed systemd service
reprofed --service [status|enable|disable]

# Manage automatic system updates
reprofed --updates [status|enable|disable]
```

### Maintenance & Logs

```bash
# View system logs
reprofed --log

# General help and versioning
reprofed --version
reprofed --help
```

> **Tip:** Short options are supported (e.g., `reprofed -p set gnome` or `reprofed -s status`).

---

## 📥 Installation

> **Note:** ReproFed is currently intended for **advanced users and early adopters**.

```bash
# Clone the repository
git clone https://github.com/ephmo/reprofed.git
cd reprofed

# Run the installer
sudo chmod +x install.sh
sudo ./install.sh --install
```

### Maintenance

- **Update:** `sudo ./install.sh --update`
- **Uninstall:** `sudo ./install.sh --remove`

---

## ⚙️ Systemd Integration

ReproFed can run as a systemd service to ensure your profile is enforced or to manage updates automatically upon boot.

```bash
reprofed --service enable
```

---

## 🤝 Contributing

Contributions, ideas, and feedback are welcome! Whether you want to add new profiles, improve scripts, or report bugs, feel free to:

1. Open an **Issue** to discuss a bug or feature idea.
2. Submit a **Pull Request** with your improvements.

---

## 📄 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

**Your Fedora. Reproducible by design.**
