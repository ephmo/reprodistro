# ReproFed - Declarative Fedora Configuration Manager

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

## 🧩 Officially Supported Profiles

ReproFed officially supports and maintains the following system profiles:

- **gnome** – Fedora Workstation with GNOME desktop
- **kde** – Fedora KDE Plasma desktop
- **cosmic** – Fedora with the COSMIC desktop environment
- **server** – Minimal Fedora Server configuration

These profiles are **part of the core ReproFed repository** and are tested and supported by the project.

Additional profiles may exist in the community ecosystem [ReproFed-Profiles](https://github.com/ephmo/reprofed-profiles) but are not considered officially supported unless explicitly listed here.

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
chmod +x install.sh
sudo ./install.sh --install
```

### Maintenance

- **Update:** `sudo ./install.sh --update`
- **Uninstall:** `sudo ./install.sh --remove`

---

---

## 🤝 Contributing

Contributions, ideas, and feedback are welcome!

### Core Project Contributions

You may open issues or submit pull requests for:

- Bug fixes
- CLI improvements
- Documentation
- Core logic and infrastructure

### Profile Contributions

The **core ReproFed repository only maintains officially supported profiles** (gnome, kde, cosmic, server).

➡️ **New profile contributions must be submitted to the community repository:**

🔗 [https://github.com/ephmo/reprofed-profiles](https://github.com/ephmo/reprofed-profiles)

This separation keeps the core project stable while allowing the community to freely experiment, extend, and share additional profiles.

If you are unsure where your contribution belongs, feel free to open an issue for guidance.

---

## 📄 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

**ReproFed — Your Fedora, reproducible by design.**
