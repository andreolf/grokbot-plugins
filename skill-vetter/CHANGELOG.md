# Changelog

All notable changes to the Skill Vetter plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-10-27

### Added
- Initial release of Skill Vetter plugin
- `vet-skill` skill for vetting individual skills
- `vet-plugin` skill for vetting entire plugins
- `vet.sh` static analysis script with checks for:
  - Data exfiltration (webhooks, pastebins, external URLs)
  - Credential reads (~/.ssh, ~/.aws, browser cookies, keychains)
  - Remote code execution (curl|sh, wget|bash, unpinned downloads)
  - Hidden instructions (base64/hex blobs, zero-width unicode, HTML comments)
  - Over-broad permissions (sudo, wildcard paths)
- Test fixtures (2 known-good, 6 known-bad)
- Test suite with validation and functional tests
- Comprehensive README with examples and usage guide
- MIT LICENSE
- Plugin manifest and logo

### Credits
- Adapted from spclaudehome/skill-vetter on ClawHub (MIT-0 license)
- Original: https://clawhub.ai/spclaudehome/skills/skill-vetter
