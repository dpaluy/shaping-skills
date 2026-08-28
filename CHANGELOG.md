# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] (Unreleased)

### Added

- Cursor plugin manifest and local installation instructions
- Claude Code marketplace manifest and validated installation command
- Codex plugin validation for complete, materialized skill packages
- MIT LICENSE file (copyright David Paluy)
- New `slicing` skill — split out from breadboarding into its own skill with agents manifest
- CHANGELOG.md
- `license` field in package.json

### Fixed

- Claude Code plugin manifest no longer includes the unsupported `interface` field
- Codex plugin now packages all six skills as real directories instead of unsupported symlinks
- README.md: removed false claim that `.agents/skills/` exists in the repo
- README.md: added note that Codex users need to run `install.sh` first
- README.md: added `slicing` to the skills table
- `hooks/shaping-ripple.sh`: added `jq` availability check (exits gracefully if missing)
- `hooks/shaping-ripple.sh`: improved frontmatter matching — uses `head -20` and proper `---` delimited YAML extraction

### Changed

- `breadboarding/SKILL.md` split into two skills: `breadboarding` (core methodology) and `slicing` (vertical slices, demo-able increments)

## [0.1.1] - 2025-01-01

### Added

- Initial release with skills: shaping, breadboarding, breadboard-reflection, framing-doc, kickoff-doc
- Claude Code plugin support
- Pi package manifest
- Codex install script (`install.sh`)
- Ripple hook for shaping documents (`hooks/shaping-ripple.sh`)
