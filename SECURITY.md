# Security Policy

## 🔒 Security Considerations

Using custom firmware on your Nintendo Switch carries inherent risks. This document outlines security best practices when using NitroPack.

## ⚠️ Risk Acknowledgment

By using NitroPack, you acknowledge:

1. **Ban Risk**: Nintendo may ban your console from online services
2. **Warranty Void**: Modifying your Switch voids the warranty
3. **Brick Risk**: Incorrect use could damage your console
4. **Legal Risk**: Using CFW for piracy is illegal

## 🛡️ Recommended Safety Practices

### 1. Always Use emuMMC

- **emuMMC** creates a separate, emulated NAND on your SD card
- Keeps your real NAND (sysMMC) clean for legitimate online play
- Set up via Hekate > Tools > Create emuMMC

### 2. Backup Your NAND

Before installing any CFW:
1. Boot Hekate
2. Go to Tools > Backup eMMC
3. Backup both BOOT0/BOOT1 and rawnand.bin
4. Store backups safely on your PC

### 3. Blank PRODINFO (Included by Default)

NitroPack includes `exosphere.ini` configured to blank your console's serial number when using emuMMC. This helps prevent Nintendo from identifying your console.

**Note**: This is NOT a guarantee against bans.

### 4. Block Nintendo Servers

For maximum protection, enable DNS blocking:
1. Navigate to `SD:/atmosphere/hosts/`
2. Edit `emummc.txt`
3. Uncomment the Nintendo server blocks
4. Reboot into CFW

### 5. Never Go Online in CFW

The safest practice is to never connect to Nintendo's servers while in CFW:
- Enable airplane mode
- Use DNS blocking
- Don't play online games in CFW

## 🔐 NitroPack Security Features

| Feature | Purpose | Enabled by Default |
|---------|---------|-------------------|
| Blank PRODINFO (emuMMC) | Hides console identity | ✅ Yes |
| Blank PRODINFO (sysMMC) | Hides console identity | ❌ No (dangerous) |
| DNS host templates | Block Nintendo servers | ⚠️ Templates only |
| Disable error reporting | Prevent crash logs | ✅ Yes |

## 📋 Reporting Security Issues

If you discover a security vulnerability in the NitroPack build scripts:

1. **DO NOT** create a public issue
2. Email the maintainers privately (if contact available)
3. Or create a private security advisory

We do not handle security issues with:
- Atmosphere, Hekate, or other upstream projects (report to them directly)
- Nintendo's systems
- Piracy-related concerns

## 🔄 Keeping Updated

Security depends on using the latest versions:

1. **Update NitroPack** when new releases are available
2. **Update firmware** only after Atmosphere supports it
3. **Update sigpatches** with each firmware update
4. **Monitor** Atmosphere and Hekate repos for security advisories

## ⚖️ Legal Disclaimer

NitroPack is provided for **educational purposes only**:

- We do NOT condone piracy
- We do NOT provide tools for illegal activities
- We are NOT responsible for any bans, bricks, or legal issues
- Users are responsible for complying with local laws

## 📚 Resources

- [Atmosphere Documentation](https://github.com/Atmosphere-NX/Atmosphere)
- [Hekate Documentation](https://github.com/CTCaer/hekate)
- [Switch Homebrew Wiki](https://switchbrew.org/)

---

**Stay safe and own your games!** 🎮
