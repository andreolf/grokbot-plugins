---
name: x-post
description: Draft X/Twitter posts in a given voice profile. Creates single posts (up to 280 characters) following the style guide from a voice profile. Draft only - never publishes automatically. Use when writing X posts in a specific creator's voice.
---

# X Post Drafter

**When to use:** When you need to draft an X/Twitter post in a specific creator's voice. Always draft only - never auto-publish.

## Prerequisites

- **Voice profile:** A voice profile markdown file (created by the `voice-profile` skill)
- **Topic/message:** What the post should communicate
- **Context:** Any relevant links, quotes, or references

## Process

### 1. Load the Voice Profile

Read the voice profile markdown file to understand:
- Tone and personality
- Hook patterns
- Sentence structure preferences
- Formatting habits
- Emoji usage
- Hashtag style
- Do's and don'ts

```bash
# Example
cat examples/voice-profiles/username.md
```

### 2. Understand the Requirements

Ask if not provided:
- **What's the message?** (main point or topic)
- **What's the goal?** (inform, entertain, start discussion, share news)
- **Any links or media?** (URL, image reference, video)
- **Any constraints?** (must mention someone, must include specific phrase)

### 3. Draft the Post

Follow the voice profile guidelines:

**Length:** X posts are max 280 characters. Aim for 200-260 for link posts (URLs take ~23 chars).

**Structure:**
1. Hook (first line/sentence) - follow the profile's hook patterns
2. Body (develop the point)
3. Call-to-action or closer (optional)

**Apply voice rules:**
- Match sentence length from profile
- Use line breaks as specified in profile
- Follow emoji frequency/placement rules
- Apply hashtag style (or avoid if profile says so)
- Use first-person/third-person as profile indicates

**Mentions:** If the profile says "check @handles live on X before use," note that handles should be verified.

### 4. Review Against Profile

Check the draft against the profile's Do's and Don'ts:

✅ **DO items**: Confirm each is followed  
❌ **DON'T items**: Confirm none are violated

### 5. Present the Draft

Show the draft with character count and any notes.

```
Draft post (247 characters):

[Post text here]

---
Notes:
- Followed profile's "hook with question" pattern
- Used line break after hook (per profile)
- No emoji (profile: rare emoji, professional tone)
- No hashtags (profile: minimal hashtags)
- @mention should be verified on X before posting
```

## Example Workflow

**Input:**
- Voice profile: `examples/voice-profiles/tech-creator.md`
- Topic: New AI feature announced by OpenAI
- Goal: Share news and opinion

**Profile summary:**
- Tone: casual but informed
- Hooks: often start with questions or "hot take"
- Line breaks: frequent (Twitter style)
- Emoji: rare, only 🔥 or 💡 for big news
- No hashtags
- First-person opinions

**Draft:**

```
Hot take: OpenAI's new "reasoning" mode is impressive but kinda misleading.

It's not actually reasoning. It's just showing you more of the inference chain.

Still cool. But let's not pretend it's AGI.
```

**Character count:** 212

**Check against profile:**
- ✅ Hook: "Hot take" (profile lists this as common opener)
- ✅ Line breaks after each sentence (profile: frequent breaks)
- ✅ First-person opinion (profile: opinionated voice)
- ✅ No emoji (profile: rare emoji)
- ✅ No hashtags (profile: minimal hashtags)
- ✅ Casual but informed tone (matches profile)

## Tips

- **Read the profile first**: Don't skip loading the voice profile
- **Match the rhythm**: If the profile says short punchy sentences, use them
- **Hook matters**: The first line is everything on X
- **Line breaks**: Most X profiles use frequent line breaks (Twitter style)
- **Draft multiple**: Offer 2-3 versions if the topic allows
- **Character count**: Always include it in your output
- **Verify @mentions**: If a profile requires live checks, note that in the output

## Common Mistakes

❌ **Don't:**
- Publish automatically (always draft only)
- Ignore the voice profile Do's/Don'ts
- Use @mentions without verifying they exist (if profile requires it)
- Add hashtags if the profile says "minimal hashtags"
- Use emoji heavily if the profile says "rare emoji"
- Make every sentence the same length (vary rhythm)

## Output Format

```
Draft post ([X] characters):

[Post text]

---
Voice adherence:
- [Checklist of key profile rules followed]
- [Any notes about choices made]

Optional: [2-3 alternative versions if requested]
```

## Example: Multiple Drafts

**Input:** Announce a new blog post about API design

**Profile:** Technical, casual, no emoji, short sentences, first-person

**Drafts:**

**Option 1 (direct):**
```
New post: How to design APIs that don't make developers cry.

Spoiler: versioning matters more than you think.

https://example.com/api-design
```
(143 characters)

**Option 2 (question hook):**
```
Why do so many APIs feel like they were designed by someone who's never used an API?

Wrote about this: https://example.com/api-design
```
(137 characters)

**Option 3 (hot take):**
```
Hot take: If your API requires a 50-page guide to get started, you've already lost.

Here's how to fix it: https://example.com/api-design
```
(140 characters)

---

## Limitations

- Cannot auto-publish (draft only)
- Cannot fetch live character count with media (images/videos add weight)
- Cannot verify @mentions exist on X (note in output if profile requires it)
- X algorithm and virality are unpredictable - good voice match doesn't guarantee engagement

## Safety

- **Never publish automatically** - all output is draft only
- **Verify @mentions live** - if the profile requires it, include a note
- **Check links** - ensure URLs work before posting
- **Review for tone** - make sure the draft matches intended sentiment
