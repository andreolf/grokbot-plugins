---
name: voice-profile
description: Build a reusable writing-voice profile (markdown style guide) from a creator's past posts. Extracts tone, hooks, sentence structure, formatting habits, vocabulary patterns, emoji usage, and do/don't lists. Use when creating a voice profile from social media posts, blog content, or any text corpus.
---

# Voice Profile Builder

**When to use:** When you need to create or update a voice profile for a creator based on their past writing (posts, tweets, blog articles, etc.). This skill builds a reusable markdown style guide that other skills can reference.

## What This Skill Does

1. Analyzes a corpus of text (social media posts, blog articles, email newsletters)
2. Extracts writing patterns: tone, hooks, structure, vocabulary, formatting
3. Generates a markdown style guide (voice profile) that can be reused
4. Optionally runs statistical analysis on post characteristics

## Prerequisites

Before running this skill, you need:
- **Source text**: A collection of past posts/content (via X plugin, pasted text, CSV export, or text files)
- **Output location**: Where to save the voice profile (e.g., `examples/voice-profiles/`)

## Process

### 1. Gather Content

Collect at least 20-50 samples of the creator's writing. More is better for accuracy.

**Sources:**
- X/Twitter posts (via X plugin: `search_posts_all` for the creator's handle)
- Pasted text from exports
- CSV/JSON files with post data
- Blog posts or newsletter archives

```bash
# Example: if you have a CSV export
# Expected columns: text, created_at, engagement (optional)
```

### 2. Analyze Patterns

For each piece of content, identify:

**Tone and personality:**
- Formal vs casual
- Technical vs accessible
- Opinionated vs neutral
- Humorous vs serious
- First-person vs third-person

**Hook patterns:**
- How do posts start? (questions, bold claims, stories, data)
- Common opening phrases
- Attention-grabbing techniques

**Sentence structure:**
- Average sentence length (short/punchy vs long/flowing)
- Simple vs complex sentences
- Use of fragments
- Rhythm and pacing

**Formatting habits:**
- Paragraph breaks (frequent line breaks vs blocks)
- Use of lists (bullet points, numbered lists)
- Quotation style
- Emphasis (bold, italics, CAPS, emoji)

**Vocabulary and phrases:**
- Industry jargon level
- Common phrases and expressions
- Favorite transition words
- Technical terminology usage

**Emoji and special characters:**
- Frequency (none, occasional, heavy)
- Placement (start, end, inline)
- Types used (professional, playful, technical)

**Hashtags and mentions:**
- Frequency and placement
- Style (CamelCase, lowercase, minimal)

**Content themes:**
- What topics appear most?
- What angles or perspectives recur?

### 3. Run Statistical Analysis (Optional)

Use the helper script to extract basic stats:

```bash
./scripts/analyze-posts.sh input.csv output-stats.json
```

The script calculates:
- Average post length (characters, words)
- Emoji rate (per post)
- Hashtag rate
- Line break frequency
- Link frequency
- Common opening words
- Length distribution (short/medium/long)

### 4. Generate the Voice Profile

Create a markdown file with these sections:

```markdown
# Voice Profile: [Creator Name]

> **Generated:** YYYY-MM-DD  
> **Source:** [describe corpus, e.g., "500 X posts from @handle, Jan 2023 - Oct 2026"]  
> **Sample size:** [N posts/articles]

## Overview

[2-3 sentence summary of the overall voice]

## Tone and Personality

- **Formality:** [casual/semi-formal/formal]
- **Perspective:** [first-person/third-person/mix]
- **Attitude:** [opinionated/neutral/curious/skeptical]
- **Humor:** [frequent/occasional/rare/none]

## Hook Patterns

Most posts start with:
1. [Pattern 1, with example]
2. [Pattern 2, with example]
3. [Pattern 3, with example]

Common opening phrases:
- "[phrase 1]"
- "[phrase 2]"

## Sentence Structure

- **Average length:** [X words]
- **Style:** [punchy short sentences / flowing longer sentences / varied mix]
- **Fragments:** [common / rare]
- **Complexity:** [simple / moderate / complex]

## Formatting

- **Paragraphs:** [frequent line breaks (Twitter style) / standard paragraphs]
- **Lists:** [frequent / occasional / rare]
- **Emphasis:** [bold for X, italics for Y, CAPS for Z]
- **Quotation marks:** [straight "..." / curly "..." / minimal]

## Vocabulary

- **Jargon level:** [accessible / technical / expert]
- **Favorite words/phrases:** [list 10-15 recurring expressions]
- **Transition words:** [list common ones: "here's the thing", "but honestly", etc.]
- **Technical terms:** [list domain-specific vocabulary]

## Emoji Usage

- **Frequency:** [none / rare / occasional / heavy]
- **Style:** [professional (📊💡) / playful (🚀✨) / expressive (😂❤️)]
- **Placement:** [start of post / end / inline / varies]
- **Common emoji:** [list top 5-10 with usage context]

## Hashtags and Mentions

- **Hashtag frequency:** [X per post on average]
- **Style:** [#CamelCase / #lowercase / minimal hashtags]
- **Mention style:** [@handles checked live before posting / @handles from memory]

## Content Themes

[List 5-10 recurring topics or angles]

## Do's

✅ **DO:**
- [Specific guideline 1]
- [Specific guideline 2]
- [Specific guideline 3]
- [etc.]

Examples:
- DO start with a hook that makes readers pause
- DO use first-person for personal takes
- DO break dense ideas into short sentences
- DO use line breaks generously
- DO fact-check before posting

## Don'ts

❌ **DON'T:**
- [Anti-pattern 1]
- [Anti-pattern 2]
- [Anti-pattern 3]
- [etc.]

Examples:
- DON'T use hashtags unless they add value
- DON'T use @mentions from memory (check live on X)
- DON'T start with "Just" or "So"
- DON'T use emoji in serious/technical posts
- DON'T publish without a clear point

## Example Posts

[Include 3-5 representative examples from the source corpus, showing variety]

---

**Usage note:** Other skills (`x-post`, `x-thread`, etc.) can reference this profile. When drafting content, load the profile first and follow its guidelines.
```

### 5. Save and Validate

Save the voice profile to `examples/voice-profiles/[name].md`.

Test it by using it with the `x-post` or `x-thread` skills to draft content and checking if the output matches the source style.

## Example Workflow

```
1. User: "Build a voice profile from my last 200 X posts"

2. Agent loads voice-profile skill

3. Agent uses X plugin to fetch posts:
   search_posts_all(query="from:@handle", max_results=200)

4. Agent analyzes the posts and generates the profile markdown

5. Agent saves to examples/voice-profiles/username.md

6. Agent: "Voice profile created! Analyzed 200 posts. 
   Key traits: casual tone, frequent line breaks, rare emoji, 
   hooks with questions or bold claims. Profile saved to 
   examples/voice-profiles/username.md"
```

## Statistical Analysis Script

The plugin includes `scripts/analyze-posts.sh` which extracts quantitative patterns from a text corpus. See the script documentation for usage.

## Tips

- **Quality over quantity:** 50 good samples beats 500 low-quality ones
- **Recency matters:** Weight recent content more if the voice has evolved
- **Context matters:** Note if different voices are used for different contexts (professional vs personal)
- **Update periodically:** Voice profiles can evolve; refresh every 6-12 months
- **Be specific:** "Rare emoji" is better than "uses emoji"
- **Include examples:** Each guideline should have a concrete example

## Limitations

- This skill doesn't auto-publish or auto-update
- Statistical analysis is basic (word/character counts, not NLP)
- Doesn't detect sarcasm, irony, or complex tone shifts
- Best for consistent voices; struggles with highly varied styles

## Output

- A markdown voice profile file
- Optional: JSON file with statistical analysis
- Brief summary of key traits
