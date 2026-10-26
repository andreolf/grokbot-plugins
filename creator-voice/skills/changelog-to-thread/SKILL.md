---
name: changelog-to-thread
description: Convert a changelog or release notes into an X/Twitter thread. Takes structured release information and transforms it into an engaging social thread in a given voice. Draft only - never publishes automatically. Use when announcing product updates or releases on X.
---

# Changelog to Thread

**When to use:** When you have release notes or a changelog and want to announce it as an X/Twitter thread. Converts technical release information into engaging social content.

## Prerequisites

- **Changelog/release notes:** Source material (markdown, plain text, or URL)
- **Voice profile** (optional): A voice profile to match the creator's style
- **Context:** Product name, version number, release date

## Process

### 1. Parse the Changelog

Read and understand:
- **Version number** (e.g., v2.3.0)
- **Release date**
- **New features** (Added)
- **Improvements** (Changed)
- **Bug fixes** (Fixed)
- **Breaking changes** (if any)
- **Deprecations** (Deprecated)
- **Removed features** (Removed)

Common changelog formats:
- **Keep a Changelog format** (## [Version] - Date, ### Added, ### Changed, etc.)
- **Semantic release** (feat:, fix:, BREAKING CHANGE:)
- **Plain list** (bullet points or numbered)

### 2. Identify the Key Highlights

Not every changelog item belongs in the thread. Prioritize:
- **Headline features** (new major functionality)
- **User-visible improvements** (performance, UX, new capabilities)
- **Breaking changes** (users must know)
- **Notable bug fixes** (if they were high-impact or widely requested)

**Skip:**
- Internal refactors (unless they improve user experience)
- Minor dependency updates
- Small typo fixes
- Overly technical details that don't affect users

### 3. Structure the Thread

**Standard structure:**

**Tweet 1: Announcement hook**
- Version number + key headline
- "What's new in X v2.3.0" or "We just shipped X v2.3.0 🎉"
- Tease the biggest feature or improvement

**Tweet 2: Biggest feature**
- Explain the #1 new feature
- Why it matters, what problem it solves

**Tweets 3-N: Other highlights**
- One feature/improvement per tweet (or group related items)
- Use numbering if listing multiple items (1/, 2/, 3/)

**Tweet N+1: Breaking changes (if any)**
- Call out anything that breaks existing behavior
- Link to migration guide if available

**Tweet N+2: Closing**
- Thank contributors or community
- Link to full changelog
- CTA (try it, upgrade, give feedback)

### 4. Apply Voice (if profile provided)

If using a voice profile:
- Load the profile and apply its tone, sentence structure, formatting
- Follow the profile's emoji usage rules
- Match the profile's Do's and Don'ts

If no profile:
- Use a clear, friendly, professional tone
- Keep sentences short
- Focus on benefits, not just features

### 5. Draft the Thread

Write the tweets following the structure above.

**Tips:**
- **Lead with benefits:** "You can now X" beats "Added feature X"
- **Use examples:** Show what the feature enables
- **Celebrate:** Release threads can be positive and excited (if that matches the voice)
- **Be concise:** One concept per tweet
- **Visual hierarchy:** Use line breaks, emoji, or numbering to make the thread scannable

### 6. Review

Check:
- ✅ Covers the most important updates
- ✅ Explains *why* features matter, not just *what* they are
- ✅ Matches voice profile (if provided)
- ✅ Includes link to full changelog
- ✅ Notes breaking changes prominently (if any)
- ✅ All tweets under 280 characters

## Example

**Input changelog (Keep a Changelog format):**

```markdown
## [2.3.0] - 2026-10-25

### Added
- Real-time collaboration: multiple users can edit the same document simultaneously
- Dark mode support
- Export to PDF with custom templates
- Keyboard shortcuts panel (press ? to open)

### Changed
- Improved search performance (3x faster on large documents)
- Redesigned settings UI

### Fixed
- Fixed crash when uploading files over 50MB
- Fixed broken syntax highlighting in code blocks
```

**Voice profile:** Casual, first-person, short sentences, rare emoji, no hashtags

**Draft thread:**

```
Tweet 1/7:
We just shipped v2.3.0 🎉

The big one: real-time collaboration.

Multiple people can now edit the same doc at the same time. No more "who has the latest version?"
```
(168 characters)

```
Tweet 2/7:
It works like Google Docs.

You see cursors moving. Changes appear live. Conflicts resolve automatically.

Tested it with 10 people editing at once. Still smooth.
```
(165 characters)

```
Tweet 3/7:
Also new:

• Dark mode (finally)
• PDF export with custom templates
• Keyboard shortcuts panel (press ?)

The shortcuts panel was the #1 requested feature. Glad it's here.
```
(183 characters)

```
Tweet 4/7:
Performance improvements:

Search is now 3x faster on large documents.

We rewrote the indexing engine. You'll notice the difference if you have 100+ page docs.
```
(166 characters)

```
Tweet 5/7:
Fixed bugs:

• No more crash when uploading files over 50MB
• Syntax highlighting works again in code blocks

Both were annoying. Both are gone.
```
(157 characters)

```
Tweet 6/7:
Full changelog: https://example.com/changelog

If you're upgrading, it's a smooth update. No breaking changes.

Let us know if you hit any issues.
```
(154 characters)

```
Tweet 7/7:
Thanks to everyone who reported bugs and requested features.

We shipped 80% of what was on the roadmap. Next up: mobile app.

See you in v2.4.
```
(159 characters)

---

**Voice adherence:**
- ✅ Casual, first-person tone
- ✅ Short sentences
- ✅ Line breaks for readability
- ✅ One 🎉 emoji in hook (profile: rare emoji)
- ✅ No hashtags (per profile)
- ✅ Benefits-focused ("no more crash" vs "fixed bug")

**Structure:**
- Tweet 1: Hook + headline feature
- Tweet 2: Deep dive on headline feature
- Tweet 3: Other new features
- Tweet 4: Performance improvements
- Tweet 5: Bug fixes
- Tweet 6: Link to full changelog + upgrade note
- Tweet 7: Thank you + roadmap tease

## Tips

### Feature Presentation

**Before (technical):**
> Added real-time collaboration using WebSocket protocol with CRDT conflict resolution

**After (benefit-focused):**
> Real-time collaboration: multiple people can edit the same doc at the same time. No more "who has the latest version?"

### Bug Fix Presentation

**Before (dry):**
> Fixed issue #1234: application crashed on file upload when size exceeded 50MB limit

**After (user-focused):**
> Fixed: no more crash when uploading files over 50MB

### Breaking Changes

If the release has breaking changes:

```
⚠️ Breaking change:

[Explain what broke and why]

Migration guide: [link]

If you're affected, give yourself 20 minutes to update. We kept it as simple as possible.
```

## Common Mistakes

❌ **Don't:**
- List every single changelog item (prioritize)
- Use technical jargon without explanation
- Forget to link to the full changelog
- Skip breaking changes (users need to know)
- Make it all about features (celebrate the team, thank the community)
- Publish automatically (always draft only)

## Output Format

```
Thread: [Product] [Version] Release ([X] tweets)

---

Tweet 1/X ([Y] characters):
[Text]

Tweet 2/X ([Y] characters):
[Text]

[etc.]

---

Changelog coverage:
- [List of changelog sections included]
- [Any major items omitted and why]

Voice adherence (if profile provided):
- [Checklist]

Notes:
- [Any specific choices made]
```

## Variations

### Short Release (3-4 tweets)

For minor releases:
1. Hook + version
2. Top 2-3 changes
3. Link to full changelog

### Long Release (10+ tweets)

For major releases:
1. Hook
2. Feature 1 (2 tweets if complex)
3. Feature 2
4. Feature 3 (etc.)
5. Breaking changes (if any)
6. Thank you / contributors
7. Roadmap tease
8. Link to full changelog

### Hotfix Release (2-3 tweets)

For quick bug fixes:
1. "We just pushed a hotfix (v2.3.1)"
2. What was fixed and why it mattered
3. "Update now: [link]"

## Limitations

- Cannot auto-publish (draft only)
- Does not generate graphics or demo videos
- Cannot verify changelog URLs are accessible
- Prioritization is subjective (you may want to adjust highlighted features)

## Safety

- **Never publish automatically** - all output is draft only
- **Verify links** - ensure changelog URL and migration guide links work
- **Double-check breaking changes** - make sure they're called out clearly
