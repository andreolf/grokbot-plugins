# Creator Voice

> **Build reusable writing-voice profiles, draft content in your voice, and humanize AI-written text.** A Cursor/Grok Bot plugin for creators who need consistent, authentic social media content without the AI tells.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## What is Creator Voice?

A plugin that helps creators:
1. **Build voice profiles** - Extract your writing style from past posts into a reusable markdown guide
2. **Draft in your voice** - Generate X posts, threads, changelogs, and video repurposing in your style
3. **Humanize AI text** - Strip common AI writing patterns to sound more natural
4. **Never auto-publish** - All skills draft only; you review and post manually

**Key principle:** Draft-only workflows. Skills help you write faster, but you stay in control of what gets published.

## Skills

| Skill | Use when | What it does |
|---|---|---|
| **voice-profile** | Creating a style guide from past posts | Analyzes tone, hooks, structure, emoji usage, creates markdown profile |
| **humanize** | Removing AI tells from text | Strips 24+ LLM patterns (inflated symbolism, AI vocab, em dashes, etc.) |
| **x-post** | Drafting single X/Twitter posts | Creates 280-char posts following your voice profile |
| **x-thread** | Drafting X/Twitter threads | Multi-tweet threads with structure and consistent voice |
| **changelog-to-thread** | Announcing releases on X | Converts technical release notes into engaging social thread |
| **video-to-posts** | Repurposing video content | Transforms transcripts/summaries into platform-native posts |

## Quick Start

### 1. Install the Plugin

**Grok Bot:**
```
Install "Creator Voice" from the plugin marketplace
```

**Cursor:**
```
Settings → Plugins → Install "Creator Voice"
```

### 2. Build a Voice Profile (Optional but Recommended)

```
In chat:
"Use the voice-profile skill to analyze my last 100 X posts and create a style guide"

Agent will:
- Fetch your posts (via X plugin or pasted data)
- Analyze patterns (tone, hooks, formatting, emoji, etc.)
- Generate a markdown voice profile
- Save to examples/voice-profiles/your-name.md
```

Or use the included example profile: `examples/voice-profiles/example-tech-creator.md`

### 3. Draft Content

**Draft an X post:**
```
"Using the voice-profile skill and my voice profile, draft an X post announcing our v2.0 release"

Agent outputs:
- Draft post (with character count)
- Voice adherence checklist
- Notes on choices made
```

**Draft a thread:**
```
"Using x-thread and my voice profile, create a 5-tweet thread explaining how AI agents work"

Agent outputs:
- Complete thread with numbered tweets
- Character counts per tweet
- Thread structure notes
```

**Humanize AI text:**
```
"Use the humanize skill to remove AI patterns from this draft"
[paste text]

Agent outputs:
- Rewritten text
- List of patterns removed
```

### 4. Review and Post

All skills output drafts only. You review, edit if needed, then post manually.

## How Voice Profiles Work

A voice profile is a markdown style guide that captures your writing patterns. It includes:

- **Tone and personality** (formal vs casual, opinionated vs neutral)
- **Hook patterns** (how you start posts: questions, bold claims, etc.)
- **Sentence structure** (short punchy vs long flowing, fragments, complexity)
- **Formatting** (line breaks, lists, emphasis, quotation style)
- **Vocabulary** (jargon level, favorite phrases, technical terms)
- **Emoji usage** (frequency, style, placement, common emoji)
- **Hashtags and mentions** (frequency, style, verification rules)
- **Do's and don'ts** (specific guidelines and anti-patterns)
- **Example posts** (representative samples from your corpus)

**Example section from a voice profile:**

```markdown
## Hook Patterns

Most posts start with:
1. **Hot takes:** "Hot take: [controversial opinion]"
2. **Questions:** "Why do we keep [doing X]?"
3. **Direct statements:** "Just shipped [X]"

## Don'ts

❌ **DON'T:**
- Use @mentions without checking they exist on X first
- Start with weak openings like "Just" or "So"
- Use emoji in technical or critical posts
```

Other skills (`x-post`, `x-thread`, etc.) load the voice profile and follow its guidelines when drafting.

## Skills Documentation

### voice-profile

**Use when:** Creating or updating a voice profile from a corpus of posts.

**Input:**
- Past posts (via X plugin, CSV export, or pasted text)
- Minimum 20-50 samples (more is better)

**Output:**
- Markdown voice profile saved to `examples/voice-profiles/`
- Optional: JSON with statistical analysis

**Bonus:** Includes `analyze-posts.sh` script for quantitative analysis (average length, emoji rate, hashtag rate, opening words, etc.)

[Full documentation](skills/voice-profile/SKILL.md)

---

### humanize

**Use when:** Editing AI-generated text to remove common LLM patterns.

**Based on:** Wikipedia's "Signs of AI writing" guide  
**Credit:** Ported from biostartechnology/humanizer (MIT-0 license)

**Detects and fixes 24+ patterns:**
- Inflated symbolism ("serves as a testament to")
- AI vocabulary (pivotal, landscape, delve, showcase)
- Em dash overuse
- Rule of three
- Negative parallelisms ("It's not just X, it's Y")
- Promotional language (vibrant, nestled, breathtaking)
- Vague attributions ("Industry experts believe")
- And more...

**Also adds personality:**
- Varies sentence rhythm
- Injects opinions and first-person voice
- Acknowledges complexity and mixed feelings
- Removes generic, soulless writing

[Full documentation](skills/humanize/SKILL.md)

---

### x-post

**Use when:** Drafting a single X/Twitter post (up to 280 characters) in a specific voice.

**Input:**
- Voice profile (markdown file)
- Topic or message
- Optional: links, media, constraints

**Output:**
- Draft post with character count
- Voice adherence checklist
- Notes on choices made

**Never auto-publishes.** You review and post manually.

[Full documentation](skills/x-post/SKILL.md)

---

### x-thread

**Use when:** Drafting an X/Twitter thread (2+ connected tweets) in a specific voice.

**Input:**
- Voice profile
- Topic or content to cover
- Goal (inform, explain, tell story, share insights)

**Output:**
- Complete thread with numbered tweets (1/X format)
- Character counts per tweet
- Thread structure notes
- Voice adherence checklist

**Ideal thread length:** 5-8 tweets. Longer threads (10+) are harder to maintain engagement.

[Full documentation](skills/x-thread/SKILL.md)

---

### changelog-to-thread

**Use when:** Converting release notes or changelog into an X thread.

**Input:**
- Changelog or release notes (markdown, text, or URL)
- Version number, release date
- Optional: voice profile

**Output:**
- X thread announcing the release
- Benefits-focused (not just features)
- Breaking changes highlighted
- Link to full changelog

**Works with:**
- Keep a Changelog format
- Semantic release format
- Plain lists or markdown

[Full documentation](skills/changelog-to-thread/SKILL.md)

---

### video-to-posts

**Use when:** Repurposing video content (YouTube, podcast, webinar) into social posts.

**Input:**
- Video transcript or summary
- Video URL
- Target platform(s): X, LinkedIn, Instagram
- Optional: voice profile

**Output:**
- 2-8 posts depending on video length
- Multiple formats (quotes, insights, teasers, lists)
- Platform-adapted (X: punchy, LinkedIn: storytelling, etc.)

**Post types:**
- Quote posts (compelling lines from transcript)
- Insight posts (key takeaways)
- Listicle posts (5 things I learned)
- Teaser posts (curiosity-gap questions)

[Full documentation](skills/video-to-posts/SKILL.md)

---

## Helper Scripts

### analyze-posts.sh

Extract statistical patterns from a corpus of posts.

**Usage:**
```bash
./scripts/analyze-posts.sh input.csv output-stats.json
./scripts/analyze-posts.sh input.json output-stats.json
./scripts/analyze-posts.sh input.txt output-stats.json --format text
```

**Supports:**
- CSV (with `text` column)
- JSON (array of objects with `text` field)
- Plain text (one post per line or blank-line separated)

**Outputs:**
```json
{
  "total_posts": 200,
  "length": {
    "characters": {"average": 185, "median": 165, "min": 42, "max": 279},
    "words": {"average": 32, "median": 28}
  },
  "features": {
    "emoji_rate_percent": 12.5,
    "hashtag_rate_percent": 8.0,
    "link_rate_percent": 25.0
  },
  "opening_words": {
    "hot": 15,
    "just": 12,
    "here's": 10,
    "why": 9
  },
  "length_distribution": {
    "short": {"count": 45, "percent": 22.5},
    "medium": {"count": 110, "percent": 55.0},
    "long": {"count": 45, "percent": 22.5}
  }
}
```

Use this data to inform your voice profile.

---

## Example Workflow: Full Content Pipeline

**Scenario:** You run a DevTools startup and want consistent X presence.

### Step 1: Build Voice Profile (One-Time Setup)

```
Agent command:
"Use voice-profile to analyze my last 200 X posts and create a style guide"

Agent:
1. Fetches your posts via X plugin
2. Analyzes patterns (tone, hooks, emoji, hashtags)
3. Runs analyze-posts.sh for stats
4. Generates markdown voice profile
5. Saves to examples/voice-profiles/yourname.md

Output:
✓ Voice profile created
  - Tone: casual, first-person, opinionated
  - Hooks: questions and "hot take" openers
  - Emoji: rare (5% of posts, only 🚀💡🔥)
  - Hashtags: minimal
  - Profile saved to examples/voice-profiles/yourname.md
```

### Step 2: Weekly Release Announcement

```
Agent command:
"We just released v2.3.0. Use changelog-to-thread with my voice profile to draft an announcement thread.

Changelog:
- Real-time collaboration
- Dark mode
- PDF export
- 3x faster search"

Agent:
1. Loads your voice profile
2. Reads changelog
3. Structures thread (hook, features, closing)
4. Drafts in your voice

Output:
Thread: ProductName v2.3.0 Release (6 tweets)

Tweet 1/6 (168 characters):
We just shipped v2.3.0 🎉

The big one: real-time collaboration.

Multiple people can now edit the same doc at the same time.
No more "who has the latest version?"

[... tweets 2-6 ...]

✓ Matches voice profile (casual, punchy, rare emoji)
✓ Benefits-focused
✓ All tweets under 280 chars
```

### Step 3: Repurpose Founder Interview

```
Agent command:
"I did a 30-min podcast interview about AI agents. Here's the transcript.

Use video-to-posts with my voice profile to create 5 X posts from the best moments."

Agent:
1. Reads transcript
2. Identifies key insights and quotes
3. Creates variety of post types (quote, insight, listicle)
4. Applies your voice

Output:
Video to Posts: Podcast Interview
Platform: X
Posts: 5 drafts

Post 1 (quote) - 187 characters:
"Most AI agents fail because people try to automate everything at once.
Start with one task. Email triage beats 'do everything.'"

From our podcast: [link]

[... posts 2-5 ...]

✓ Matches voice profile
✓ Variety of formats
✓ All posts standalone
```

### Step 4: Humanize AI-Assisted Draft

```
Agent command:
"I used ChatGPT to draft this blog intro, but it sounds too AI-ish.
Use humanize to strip the AI patterns:

[paste AI-generated intro]"

Agent:
1. Identifies AI patterns (pivotal, testament, em dashes, rule of three)
2. Rewrites to sound human
3. Adds personality and opinion

Output:
Before (AI):
The new software update serves as a testament to the company's
commitment to innovation. Moreover, it provides a seamless, intuitive,
and powerful user experience—ensuring users can accomplish their goals
efficiently.

After (Humanized):
The software update adds batch processing, keyboard shortcuts, and
offline mode. Early feedback from beta testers has been positive, with
most reporting faster task completion.

Changes:
- Removed "serves as a testament" (inflated symbolism)
- Removed rule of three (seamless, intuitive, powerful)
- Removed em dash overuse
- Replaced vague claims with specific features
```

### Result

- Consistent voice across all content
- Faster content creation (drafts in minutes)
- Less AI-sounding text
- You review and post manually (full control)

---

## Safety & Security

This plugin follows Cursor/Grok Bot marketplace security guidelines:

✅ **No auto-publish** - All skills draft only; you post manually  
✅ **No curl | bash** - All scripts are committed and reviewable  
✅ **No secret reads** - Never accesses credentials or environment secrets  
✅ **No obfuscation** - All code is plain bash and markdown  
✅ **@mention verification** - Voice profiles require checking handles live before use  
✅ **Scoped scripts** - Helper scripts operate only on specified input files  

The plugin:
- Never publishes content automatically
- Never executes remote code
- Never reads or writes secrets
- Only processes files you explicitly provide

---

## Testing

Run the test suite:

```bash
cd creator-voice

# Schema and frontmatter validation
./tests/validate-plugin.sh

# Functional tests
./tests/test-plugin.sh
```

Tests cover:
- Plugin manifest schema validation
- Skill frontmatter validation
- analyze-posts.sh with CSV, JSON, and text inputs
- Output statistics validation
- Example voice profile structure
- Security scan (no curl|sh, no hardcoded secrets)

---

## FAQ

**Q: Does this auto-post to X/Twitter?**  
A: No. All skills draft only. You review and post manually. This ensures you stay in control and can fact-check before publishing.

**Q: Do I need a voice profile to use the skills?**  
A: No, but it's recommended. Without a profile, skills use sensible defaults or you can provide guidelines directly. The profile makes drafts more consistent with your existing voice.

**Q: Can I use the humanize skill on someone else's writing?**  
A: Yes, but only for legitimate editing (your own AI-assisted drafts, helping colleagues improve clarity). Never use it to misrepresent authorship or hide AI use where disclosure is required (academic, professional, legal contexts).

**Q: What platforms does video-to-posts support?**  
A: Currently X/Twitter, LinkedIn, and Instagram (caption text). The skill adapts style per platform (X: punchy, LinkedIn: storytelling, Instagram: visual-first with caption).

**Q: How accurate is analyze-posts.sh?**  
A: It's basic statistical analysis (word counts, regex patterns). It won't detect sarcasm, complex tone shifts, or NLP features. Good enough for voice profiles. For deep analysis, use specialized NLP tools.

**Q: Can I share voice profiles with my team?**  
A: Yes! Voice profiles are just markdown files. Commit them to your repo or share via file. Multiple agents can load the same profile for consistent brand voice.

**Q: Does the X plugin auto-publish?**  
A: This plugin (creator-voice) does not use the X plugin to publish. It only reads posts (for voice-profile) or drafts text (for x-post/x-thread). You post manually via X's UI.

**Q: What if I want to publish automatically?**  
A: Use a different tool (Buffer, Hootsuite, X API directly). This plugin is intentionally draft-only for safety and control.

---

## Credits

### Humanizer Skill

The `humanize` skill is adapted from **biostartechnology/humanizer** on ClawHub:
- **Original author:** biostartechnology
- **Source:** https://clawhub.ai/biostartechnology/skills/humanizer
- **License:** MIT-0 (no attribution required, but credited here)
- **Reference:** Based on Wikipedia's ["Signs of AI writing"](https://en.wikipedia.org/wiki/Wikipedia:Signs_of_AI_writing) guide

Thank you to the ClawHub community and WikiProject AI Cleanup for the comprehensive pattern list.

---

## Contributing

This plugin is part of the `grokbot-plugins` monorepo. To contribute:

1. Fork: https://github.com/andreolf/grokbot-plugins
2. Create a branch: `git checkout -b feature/your-feature`
3. Make changes and test: `./tests/validate-plugin.sh && ./tests/test-plugin.sh`
4. Submit a PR with description and test results

---

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history.

---

## License

MIT License — see [LICENSE](LICENSE)

---

## Author

Francesco Andreoli ([@francescoswiss](https://twitter.com/francescoswiss))

---

## Links

- [GitHub Repository](https://github.com/andreolf/grokbot-plugins)
- [Submit an Issue](https://github.com/andreolf/grokbot-plugins/issues)
- [Cursor Plugins](https://cursor.com/marketplace)
- [Grok Bot Marketplace](https://x.ai/bot/marketplace)
