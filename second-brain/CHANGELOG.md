# Changelog

All notable changes to the Second Brain plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-10-24

### Added
- Initial release of Second Brain plugin
- 7 skills for vault management:
  - `vault-session-start`: Pull and read protocol at session start
  - `write-note`: Create notes with proper conventions
  - `safe-sync`: Commit and push with explicit paths only
  - `capture-learning`: Record learnings (self-improving pattern)
  - `link-check`: Find broken wikilinks and orphans
  - `bootstrap-vault`: Set up new vault from scratch
  - `maintenance`: Update index.md and log.md
- `vault-sync.sh` helper script with 3 retries and rebase-then-push
- Comprehensive test suite with 9 test scenarios
- Full documentation in README.md
- Support for concurrent multi-agent writes via explicit path staging
- Obsidian-compatible vault structure (plain markdown + wikilinks)

### Security
- Never stores secrets in vault (enforced by protocol)
- User-owned git repository (no vendor lock-in)

[1.0.0]: https://github.com/andreolf/grokbot-plugins/releases/tag/second-brain-v1.0.0
