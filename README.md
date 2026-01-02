# ReproFed

Declarative Fedora Configuration Manager

![Status](https://img.shields.io/badge/status-maintained-green)
![License](https://img.shields.io/github/license/ephmo/reprofed)

ReproFed is a declarative configuration manager designed specifically for Fedora Linux. It allows you to define system profiles using simple YAML files and apply them reproducibly across installations and Fedora releases.

The goal of ReproFed is to make Fedora systems **predictable, reproducible, and easy to manage**.

---

## ⚠️ Read this before using ReproFed

### ℹ️ Declarative Package Management

ReproFed follows a **strict declarative model**.

When a profile is applied:

- Only the **package groups and packages declared in the profile** are kept on the system
- Any **undeclared package groups or packages may be removed**
- This ensures a clean, predictable, and reproducible system state

This behavior is intentional and is what allows ReproFed to switch cleanly between desktop environments or between desktop and server setups **without leaving leftover packages or system bloat**.

### 📦 Supported Third-Party Repositories

ReproFed supports enabling and managing the following third-party repositories when they are declared in a profile:

- rpmfusion-free
- rpmfusion-nonfree
- Visual Studio Code (vscode)
- COPR repositories

These repositories are **only enabled when explicitly declared** in the active profile and are managed declaratively, just like packages and package groups.

This ensures:

- Predictable repository state
- No unexpected third-party sources enabled by default
- Full reproducibility across systems and installations

### ➕ Adding Extra Packages

If you want additional packages beyond what a profile provides, you have two supported options:

- **Install packages manually** after applying a profile (they may be removed on the next profile sync if not declared)
- **Create a custom profile** or use a community profile and declare additional package groups and extra individual packages

### 🛑 Do Not Modify Official Profiles

Official profiles provided by ReproFed are **managed by the project** and may be **overwritten during updates**.

To customize behavior:

- ❌ Do not modify official profiles directly
- ✅ Create a new custom profile based on an official one
- ✅ Or use and extend a profile from the community repository

Community profiles can be found here: [ReproFed-Profiles](https://github.com/ephmo/reprofed-profiles)

### 💡 Recommendation

For long-term stability and reproducibility:

- Treat profiles as the **source of truth**
- Keep all desired packages declared in your profile
- Use custom or community profiles for personalization

---

## 🚀 Key Features

- **Declarative Configuration:** Define your desired system state in simple YAML profiles.
- **Reproducibility:** Replicate your exact setup across reinstalls and upgrades.
- **Version-Aware:** Profiles respect Fedora versioning for safe and explicit upgrades.

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
- **cosmic** – Fedora with the COSMIC desktop
- **server** – Minimal Fedora Server configuration

These profiles are **part of the ReproFed repository** and are tested and supported by the project.

Additional profiles may exist in the community ecosystem [ReproFed-Profiles](https://github.com/ephmo/reprofed-profiles) but are not considered officially supported unless explicitly listed here.

---

## 🎯 Target Audience

ReproFed is designed for users who want to switch between desktop environments — or between desktop and server configurations — **without reinstalling Fedora from scratch**.

It is especially useful for those who want to avoid leftover packages, system bloat, or unwanted components that often remain after manually removing a previous desktop environment.

This application is not intended for absolute beginners. It is aimed at users who are comfortable working with the terminal and are not afraid to manage their system using command-line tools.

---

## 🛠 Usage

> **Important:** Before making any system changes, save all your work and close any open applications.

To safely apply a profile, it is recommended to **switch to a TTY and stop the graphical session**. This prevents conflicts while desktop-related packages are added or removed.

### Switch to a TTY and stop the graphical session

1. Switch to a TTY using **Ctrl + Alt + F3** (or F2–F6).
2. Log in with your user.
3. Isolate the multi-user (non-graphical) target:

```bash
sudo systemctl isolate multi-user.target
```

### Profile Management

List all profiles.

```bash
reprofed --list
```

Apply a profile (e.g., `gnome`).

```bash
sudo reprofed --apply gnome
```

> **Tip:** Short options are supported (e.g., `sudo reprofed -a gnome`).

---

## 📥 Installation

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

The **ReproFed repository only maintains officially supported profiles**.

➡️ **New profile contributions must be submitted to the community repository:**

🔗 [https://github.com/ephmo/reprofed-profiles](https://github.com/ephmo/reprofed-profiles)

This separation keeps the core project stable while allowing the community to freely experiment, extend, and share additional profiles.

If you are unsure where your contribution belongs, feel free to open an issue for guidance.

---

## 📄 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

**ReproFed — Your Fedora, reproducible by design.**
