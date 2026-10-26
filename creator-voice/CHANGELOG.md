# Changelog

All notable changes to the creator-voice plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-10-26

### Added

- **voice-profile** skill: Build reusable writing-voice profiles from social media posts
  - Analyzes tone, hooks, sentence structure, formatting, vocabulary, emoji usage
  - Outputs markdown style guide for consistent voice
  - Statistical analysis via `analyze-posts.sh` helper script
  
- **humanize** skill: Remove AI writing patterns from text
  - Ported from biostartechnology/humanizer (MIT-0 license)
  - Based on Wikipedia's "Signs of AI writing" guide
  - Identifies and fixes 24+ common LLM patterns
  - Adds personality and soul to writing
  
- **x-post** skill: Draft X/Twitter posts in a given voice
  - Single posts up to 280 characters
  - Follows voice profile guidelines
  - Draft only, never auto-publishes
  
- **x-thread** skill: Draft X/Twitter threads in a given voice
  - Multi-tweet threads with proper structure
  - Numbered tweets, consistent voice
  - Draft only, never auto-publishes
  
- **changelog-to-thread** skill: Convert changelogs to X threads
  - Transforms technical release notes into engaging social content
  - Benefits-focused presentation
  - Highlights breaking changes
  
- **video-to-posts** skill: Repurpose video content into social posts
  - Works from transcripts or summaries
  - Platform-native adaptation (X, LinkedIn, Instagram)
  - Multiple post types (quotes, insights, teasers, lists)

- **analyze-posts.sh** script: Extract statistical patterns from post corpuses
  - Supports CSV, JSON, and plain text inputs
  - Calculates length, emoji rate, hashtag rate, link frequency
  - Identifies common opening words and length distribution

- Example voice profile: `example-tech-creator.md`
  - Fully documented synthetic example
  - Shows all required sections for a voice profile
  - Reference for creating custom profiles

- Test suite:
  - `validate-plugin.sh`: Schema and frontmatter validation
  - `test-plugin.sh`: Functional tests with fixtures
  - Test fixtures for CSV, JSON, and text formats

- Documentation:
  - Comprehensive README with install, usage, and examples
  - Detailed SKILL.md for each skill
  - Credits section for ported content (Humanizer)

### Security

- No auto-publish functionality (all skills draft only)
- No `curl | bash` patterns
- No hardcoded secrets
- @mention verification requirement (check live before use)
- Scripts operate only on specified input files

[1.0.0]: https://github.com/andreolf/grokbot-plugins/releases/tag/creator-voice-v1.0.0
