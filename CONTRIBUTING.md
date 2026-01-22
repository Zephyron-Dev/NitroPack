# Contributing to NitroPack

Thank you for your interest in contributing to NitroPack! This document provides guidelines for contributing to the project.

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
- [Reporting Bugs](#reporting-bugs)
- [Suggesting Enhancements](#suggesting-enhancements)
- [Pull Requests](#pull-requests)
- [Development Setup](#development-setup)

## 📜 Code of Conduct

### Our Pledge

We pledge to make participation in our project a harassment-free experience for everyone. We expect all contributors to be respectful and professional.

### Important Rules

1. **No Piracy Discussion** - Do not share, request, or discuss pirated content
2. **Legal Content Only** - All contributions must be legal and original
3. **Respect Original Authors** - Give credit where credit is due
4. **Be Helpful** - Help others learn and troubleshoot

## 🤝 How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check existing issues to avoid duplicates.

When filing a bug report, include:

- **Clear title** describing the issue
- **Steps to reproduce** the problem
- **Expected behavior** vs actual behavior
- **Screenshots** if applicable
- **Environment info**:
  - Switch firmware version
  - Atmosphere version
  - NitroPack version
  - SD card size/type

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion:

- **Use a clear title** that describes the enhancement
- **Provide a detailed description** of the suggested enhancement
- **Explain why** this would be useful
- **List any alternatives** you've considered

### Pull Requests

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Test thoroughly
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

#### Pull Request Guidelines

- Follow existing code style
- Update documentation if needed
- Add comments for complex logic
- Test with actual hardware if possible
- Keep changes focused and atomic

## 🛠️ Development Setup

### Prerequisites

- Linux, macOS, or WSL2 on Windows
- Git
- Bash 4.0+
- Required tools: `curl`, `wget`, `unzip`, `jq`, `zip`

### Local Testing

1. Clone the repository:
   ```bash
   git clone https://github.com/YOUR_USERNAME/NitroPack.git
   cd NitroPack
   ```

2. Make the script executable:
   ```bash
   chmod +x scripts/assemble_pack.sh
   ```

3. Run a local build:
   ```bash
   ./scripts/assemble_pack.sh --output ./test-build
   ```

4. (Optional) Set GitHub token for higher API rate limits:
   ```bash
   export GITHUB_TOKEN="your_personal_access_token"
   ./scripts/assemble_pack.sh
   ```

### Testing the Workflow Locally

You can use [act](https://github.com/nektos/act) to test GitHub Actions locally:

```bash
# Install act
brew install act  # macOS
# or see https://github.com/nektos/act for other platforms

# Run the workflow
act -j build
```

## 📁 Project Structure

```
NitroPack/
├── .github/
│   └── workflows/
│       └── build-pack.yml    # GitHub Actions workflow
├── scripts/
│   └── assemble_pack.sh      # Standalone build script
├── configs/                  # Config file templates
│   ├── hekate_ipl.ini
│   ├── exosphere.ini
│   ├── system_settings.ini
│   └── override_config.ini
├── README.md                 # Main documentation
├── CONTRIBUTING.md           # This file
├── LICENSE                   # MIT License
└── .gitignore
```

## 🔧 Adding New Components

To add a new homebrew component:

1. Add the GitHub repo to the workflow variables
2. Add download logic in the appropriate step
3. Add extraction/placement logic
4. Update the version tracking
5. Update README.md with the new component
6. Test the full build

### Example: Adding a New NRO App

```bash
# In assemble_pack.sh, add:

download_newapp() {
    log_info "Fetching NewApp release info..."
    
    local release_info=$(get_latest_release "author/newapp")
    local version=$(get_release_tag "$release_info")
    VERSIONS["newapp"]=$version
    
    local url=$(get_asset_url "$release_info" "NewApp\\.nro$")
    if [ -n "$url" ]; then
        download_file "$url" "$DOWNLOADS/NewApp.nro" "NewApp"
    fi
}
```

## ❓ Questions?

Feel free to open an issue with the `question` label if you need help or clarification.

---

Thank you for contributing to NitroPack! 🎮
