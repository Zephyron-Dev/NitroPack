# 🎮 NitroPack - Ultimate Nintendo Switch CFW Bundle

<div align="center">

![NitroPack Banner](https://img.shields.io/badge/NitroPack-CFW%20Bundle-ff4444?style=for-the-badge&logo=nintendo-switch&logoColor=white)
[![GitHub Release](https://img.shields.io/github/v/release/YOUR_USERNAME/NitroPack?style=for-the-badge&color=00d4aa)](https://github.com/YOUR_USERNAME/NitroPack/releases/latest)
[![Build Pack](https://img.shields.io/github/actions/workflow/status/YOUR_USERNAME/NitroPack/build-pack.yml?style=for-the-badge&label=Auto%20Build)](https://github.com/YOUR_USERNAME/NitroPack/actions)
[![License](https://img.shields.io/badge/License-MIT-blue?style=for-the-badge)](LICENSE)

**The goated all-in-one CFW bundle for Nintendo Switch**

*Auto-updated weekly with latest releases • Zero configuration needed*

[📥 Download Latest](https://github.com/YOUR_USERNAME/NitroPack/releases/latest) | [📖 Install Guide](#-installation) | [❓ FAQ](#-faq)

</div>

---

## ⚠️ IMPORTANT LEGAL DISCLAIMER

> **THIS SOFTWARE IS PROVIDED FOR EDUCATIONAL AND RESEARCH PURPOSES ONLY.**
>
> - You **MUST** own legitimate copies of any games you play
> - Piracy is **illegal** and not supported or encouraged by this project
> - Using CFW may void your warranty and carries risk of console ban
> - The maintainers are **NOT** responsible for any damage to your console, bans, or legal issues
> - By downloading and using NitroPack, you agree to these terms
>
> **Always back up your NAND before installing CFW!**

---

## 📦 What's Included

NitroPack bundles the latest versions of essential CFW components:

| Component | Description | Source |
|-----------|-------------|--------|
| **Atmosphere** | The leading open-source CFW for Nintendo Switch | [Atmosphere-NX](https://github.com/Atmosphere-NX/Atmosphere) |
| **Hekate** | Bootloader, payload launcher, and toolbox | [CTCaer/hekate](https://github.com/CTCaer/hekate) |
| **Sigpatches** | Signature patches for running homebrew | [ITotalJustice/patches](https://github.com/ITotalJustice/patches) |
| **Tinfoil** | NSP/NSZ/XCI installer and title manager | [Official Site](https://tinfoil.io) |
| **DBI** | Advanced file manager and installer | [rashevskyv/dbi](https://github.com/rashevskyv/dbi) |
| **NXThemeInstaller** | Custom theme installer | [exelix11/SwitchThemeInjector](https://github.com/exelix11/SwitchThemeInjector) |
| **Goldleaf** | Multi-purpose title manager | [XorTroll/Goldleaf](https://github.com/XorTroll/Goldleaf) |
| **JKSV** | Save data manager | [J-D-K/JKSV](https://github.com/J-D-K/JKSV) |
| **NX-Shell** | File browser | [joel16/NX-Shell](https://github.com/joel16/NX-Shell) |
| **Homebrew Menu** | Included with Atmosphere | Built-in |

### Pre-configured Files
- ✅ `hekate_ipl.ini` - Boot configuration with Atmosphere autoboot
- ✅ `exosphere.ini` - Blanked prodinfo for online safety
- ✅ `system_settings.ini` - Optimized system settings
- ✅ `override_config.ini` - Album override for homebrew menu

---

## 🚀 Installation

### Prerequisites
- Nintendo Switch with RCM exploit capability (unpatched V1 units, some Mariko via modchip)
- microSD card (64GB+ recommended, FAT32 or exFAT formatted)
- RCM jig or alternative method to enter RCM mode
- Payload injector (TegraRcmGUI on Windows, fusee-launcher on Linux/Mac)

### Quick Install (Fresh Install)

1. **Download** the latest `NitroPack-vX.X.X.zip` from [Releases](https://github.com/YOUR_USERNAME/NitroPack/releases/latest)

2. **Extract** the ZIP contents directly to the **root** of your SD card
   ```
   SD Card Root/
   ├── atmosphere/
   ├── bootloader/
   ├── config/
   ├── switch/
   ├── hbmenu.nro
   └── ... (other files)
   ```

3. **Insert** SD card into your Switch

4. **Enter RCM mode** using your jig

5. **Inject** `hekate_ctcaer_X.X.X.bin` payload (found in `bootloader/` folder)

6. **Boot Atmosphere** from Hekate menu or wait for autoboot

### Updating Existing CFW

1. **Back up** your `Nintendo/` folder and any saves
2. **Delete** old `atmosphere/`, `bootloader/`, `switch/` folders
3. Follow Quick Install steps above
4. Your saves and games remain intact in `Nintendo/` folder

---

## 📁 Folder Structure

```
SD Card Root/
├── atmosphere/           # Atmosphere CFW files
│   ├── config/          # Atmosphere configuration
│   ├── contents/        # LayeredFS mods & sysmodules
│   ├── exefs_patches/   # IPS patches (sigpatches)
│   ├── kips/            # Kernel patches
│   └── hosts/           # DNS blocking (optional)
├── bootloader/          # Hekate bootloader
│   ├── hekate_ipl.ini   # Boot configuration
│   ├── payloads/        # Additional payloads
│   └── sys/             # Hekate system files
├── config/              # Global config folder
│   └── ...
├── switch/              # Homebrew applications
│   ├── tinfoil/         # Tinfoil installer
│   ├── DBI/             # DBI file manager
│   ├── Goldleaf/        # Goldleaf title manager
│   ├── JKSV/            # Save manager
│   └── ...
├── hbmenu.nro           # Homebrew menu
├── exosphere.ini        # Exosphere config
└── boot.dat             # Hekate payload (for modchips)
```

---

## ⚙️ Configuration

### Hekate Autoboot
By default, NitroPack is configured to autoboot into Atmosphere CFW after 5 seconds. To change this:

1. Hold **VOL-** while injecting payload to access Hekate menu
2. Go to **Options** → **Auto Boot** → Select your preference

### Homebrew Menu Access
- **Album Override** (Default): Hold **R** while launching Album
- **Title Override**: Hold **R** while launching any game

### Blank Prodinfo (emuMMC recommended)
The included `exosphere.ini` blanks your console's serial number when booting CFW, adding a layer of protection against bans. **However, this is NOT foolproof.**

> ⚠️ **For maximum safety, always use emuMMC (emulated NAND) and never go online in CFW!**

---

## 🔧 Troubleshooting

### "No SD Card" Error
- Ensure SD card is FAT32 or exFAT formatted
- Check SD card is fully inserted
- Try a different SD card

### Black Screen After Payload Injection
- Re-download NitroPack (corrupted files)
- Check if Atmosphere version matches your Switch firmware
- Try injecting `fusee.bin` directly instead of Hekate

### Games Won't Launch / Sigpatch Errors
- Make sure you extracted the full ZIP to SD root
- Verify sigpatches are present in `atmosphere/exefs_patches/`
- Update to latest NitroPack if your firmware is newer

### Error 2002-4153 (Corrupt Data)
- Delete `atmosphere/contents/` folder
- Re-extract NitroPack

---

## ❓ FAQ

**Q: Is this safe? Will I get banned?**
> No method is 100% safe. Using CFW always carries ban risk. Use emuMMC, stay offline in CFW, and never use cheats online.

**Q: Do I need to update NitroPack when Nintendo releases new firmware?**
> Yes, wait for Atmosphere to support the new firmware, then download the latest NitroPack which will include updated sigpatches.

**Q: Can I use this with emuMMC?**
> Yes! Hekate can create and boot emuMMC. This is the recommended way to use CFW.

**Q: How do I add more homebrew apps?**
> Place `.nro` files in the `switch/` folder on your SD card.

**Q: Where do I get games?**
> **Purchase them legitimately.** You can dump your own cartridges using NXDumpTool (not included).

---

## 🔄 Auto-Updates

NitroPack is automatically rebuilt every week (or when manually triggered) with the latest versions of all components. Check the [Releases](https://github.com/YOUR_USERNAME/NitroPack/releases) page for updates.

Each release includes a detailed changelog of component versions.

---

## 🙏 Credits & Acknowledgments

NitroPack is a compilation of incredible work by the Switch homebrew community:

- **[Atmosphère-NX Team](https://github.com/Atmosphere-NX)** - Atmosphere CFW
- **[CTCaer](https://github.com/CTCaer)** - Hekate bootloader
- **[ITotalJustice](https://github.com/ITotalJustice)** - Sigpatches
- **[Blawar](https://github.com/blawar)** - Tinfoil
- **[rashevskyv](https://github.com/rashevskyv)** - DBI
- **[exelix11](https://github.com/exelix11)** - NXThemeInstaller
- **[XorTroll](https://github.com/XorTroll)** - Goldleaf
- **[J-D-K](https://github.com/J-D-K)** - JKSV
- **[joel16](https://github.com/joel16)** - NX-Shell

**This project would not exist without their dedication to the homebrew scene. ❤️**

---

## 📜 License

This repository (build scripts, configs) is licensed under MIT. See [LICENSE](LICENSE).

Individual components retain their original licenses:
- Atmosphere: GPLv2
- Hekate: GPLv2
- Other components: See their respective repositories

---

## ⚠️ Final Warning

**Using custom firmware is at your own risk.** The creators of NitroPack:
- Do NOT condone piracy
- Do NOT provide support for piracy
- Are NOT responsible for bans, bricks, or legal issues
- Recommend using emuMMC and staying offline

**Own your games. Support developers. Happy brewing! 🍺**

---

<div align="center">

Made with ☕ by the community, for the community

*Star ⭐ this repo if NitroPack helped you!*

</div>
