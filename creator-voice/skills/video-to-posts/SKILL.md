---
name: video-to-posts
description: Convert a video transcript or summary into platform-native social posts (X, LinkedIn, etc.). Takes long-form video content and repurposes it into bite-sized, shareable posts in a given voice. Draft only - never publishes automatically. Use when repurposing video content for social media.
---

# Video to Posts

**When to use:** When you have a video (YouTube, podcast, webinar, etc.) and want to repurpose it into social media posts. Takes a transcript or summary and creates platform-native posts.

## Prerequisites

- **Video transcript or summary:** Source material (via API, exported file, or pasted text)
- **Video URL:** Link to the original video
- **Target platform(s):** X/Twitter, LinkedIn, Instagram, etc.
- **Voice profile** (optional): A voice profile to match the creator's style
- **Goal:** Drive views, share insights, tease content, etc.

## Process

### 1. Analyze the Video Content

Read the transcript or summary and identify:

**Key moments:**
- Most interesting insights or quotes
- Surprising statistics or facts
- Controversial or bold claims
- Actionable takeaways
- Funny or memorable moments

**Structure:**
- What's the video about? (one-sentence summary)
- Who's the audience?
- What's the hook? (why should someone watch?)
- What are the main points? (3-5 key takeaways)

**Length:**
- Short video (<10 min): 2-3 posts
- Medium video (10-30 min): 3-5 posts
- Long video (30+ min): 5-8 posts

### 2. Choose Post Types

Different post types work for different content:

**Quote posts:**
- Pull a compelling quote from the transcript
- Format: "[Quote]" - [Person] (link to video)
- Works best for: thought-provoking statements, hot takes

**Insight posts:**
- Share a key takeaway or lesson
- Format: "In [video title], [person] explains: [insight]" (link)
- Works best for: educational content, how-tos

**Listicle posts:**
- "5 things I learned from [video]:"
- One bullet per takeaway
- Works best for: packed videos with multiple insights

**Teaser posts:**
- Pose a question the video answers
- Create curiosity gap
- Format: "[Intriguing question]. Watch: [link]"
- Works best for: controversial or surprising content

**Highlight posts:**
- Share the most memorable moment
- Format: "Best part of [video]: [moment]" (link)
- Works best for: interviews, debates, storytelling

**Call-out posts:**
- Tag or mention people discussed in the video
- Format: "Great conversation with @person about [topic]" (link)
- Works best for: interviews, collaborations

### 3. Platform Adaptation

Each platform has different norms:

**X/Twitter:**
- Length: 200-260 characters ideal (leave room for engagement)
- Style: Punchy, direct, line breaks
- Media: Video thumbnails or short clips work well
- Hashtags: Default to no hashtags unless voice profile explicitly allows them
- Format: Hook → Insight/quote → Link

**LinkedIn:**
- Length: Can be longer (1000+ characters)
- Style: Professional, first-person, storytelling
- Media: Video embeds work great (native LinkedIn video or YouTube link)
- Hashtags: 3-5 relevant ones
- Format: Context → Key takeaway → Link/CTA

**Instagram (caption for reel or carousel):**
- Length: Front-load the hook (first line matters)
- Style: Conversational, emoji-friendly
- Media: Must include visual (video clip, quote graphic)
- Hashtags: 5-10 relevant ones (separate comment recommended)
- Format: Hook → Body → CTA → Hashtags

**Threads/Bluesky:**
- Similar to X but can be slightly longer (500 characters)

### 4. Apply Voice (if profile provided)

Load the voice profile and apply:
- Tone and personality
- Sentence structure
- Emoji usage
- Hashtag style (default: no hashtags unless profile specifies otherwise)
- List format (e.g., '> ' prefix) and list length (e.g., exactly 10 items) if specified
- Do's and don'ts

If no profile, use platform best practices (default: no hashtags).

### 5. Draft the Posts

Create 2-5 posts depending on video length and content richness.

**Variety:**
- Don't make every post the same format
- Mix quote posts, insight posts, and teasers
- Vary hooks and angles

**Link placement:**
- X: End of post or middle (after hook)
- LinkedIn: End with CTA
- Instagram: "Link in bio" (URLs don't work in captions)

### 6. Review

Check:
- ✅ Captures the best moments from the video
- ✅ Each post stands alone (doesn't require watching the video to understand)
- ✅ Clear link to video (unless platform doesn't support links in captions)
- ✅ Matches voice profile (if provided)
- ✅ Platform-appropriate length and style
- ✅ Varied post types (not all the same)

## Example

**Input:**
- Video: 25-minute YouTube video about building AI agents
- Transcript: [assume we have the transcript]
- Target platform: X/Twitter
- Voice profile: Casual, technical, first-person, rare emoji, no hashtags

**Key moments identified:**
1. "Most AI agents fail because people try to automate everything at once"
2. Start with one task (example: email triage)
3. Log everything (debugging insight)
4. Use cheap models first (GPT-3.5 before GPT-4)
5. Agents are just loops (read → decide → execute)

**Draft posts:**

**Post 1 (teaser with question hook):**
```
Why do most AI agents fail before they even start?

New video breaks down the #1 mistake (and how to avoid it): https://youtu.be/example

Hint: it's not the model you choose.
```
(180 characters)

**Post 2 (key insight):**
```
Best advice from the video:

Start with the simplest possible task.

"Read this email and tell me if it's urgent" is a better first project than "build me an autonomous research assistant."

Watch: https://youtu.be/example
```
(237 characters)

**Post 3 (quote):**
```
"Agents are just loops. Read input → decide action → execute → repeat. That's it."

If you're building your first agent, watch this: https://youtu.be/example

The complexity comes from error handling, not the core logic.
```
(240 characters)

**Post 4 (tactical tip):**
```
Pro tip from the video:

Test with GPT-3.5 first. Way cheaper. Fast enough for early experiments.

Switch to GPT-4 only when you know your prompt works.

Saves $$ and iteration time: https://youtu.be/example
```
(215 characters)

**Post 5 (listicle thread):**
```
5 things I learned from building AI agents (from this video):

1. Start small (one task)
2. Log everything (you can't debug blind)
3. Use cheap models first
4. Agents are loops (not magic)
5. Error handling > fancy features

Watch: https://youtu.be/example
```
(267 characters)

---

**Voice adherence:**
- ✅ Casual, first-person tone
- ✅ Short sentences
- ✅ Technical but accessible
- ✅ No emoji (profile: very rare emoji, used none here)
- ✅ No hashtags (profile: no hashtags)
- ✅ Practical, no fluff

**Post variety:**
- Post 1: Teaser (question hook)
- Post 2: Key insight (actionable advice)
- Post 3: Quote (memorable line from video)
- Post 4: Tactical tip (saves money)
- Post 5: Listicle (comprehensive summary)

## Tips

### Finding the Best Moments

**Look for:**
- Counterintuitive insights ("Most people think X, but actually Y")
- Specific, actionable advice ("Do X before Y")
- Memorable phrases or analogies
- Bold claims or controversial takes
- Data or statistics that surprise

**Avoid:**
- Generic advice ("work hard, stay focused")
- Context-heavy moments that don't stand alone
- Inside jokes or references only viewers will get

### Timing Posts

If publishing manually:
- Space posts out (don't post all 5 at once)
- X: Post 1 the day the video drops, Post 2-3 the next day, Post 4-5 later in the week
- LinkedIn: Can post longer content immediately
- Instagram: Coordinate with video upload

### Creating Urgency

- "Just dropped: [video title]"
- "New video on [topic] - link in comments"
- "Answering the question everyone's been asking: [link]"

### Quote Attribution

If quoting someone else from the video:
```
"[Quote]" - [Person]

From our conversation about [topic]: [link]
```

## Common Mistakes

❌ **Don't:**
- Post identical content across all platforms (adapt for each)
- Use too many quotes (mix formats)
- Write posts that only make sense after watching the video
- Spam all posts at once (space them out if publishing)
- Forget to link to the video
- Publish automatically (always draft only)
- Use generic hooks ("Check out this video")
- Add hashtags unless the voice profile explicitly allows them (default: no hashtags)
- Ignore list format or list length specified in profile (e.g., if profile says "exactly 10 items with '> ' prefix", follow that)

## Output Format

```
Video to Posts: [Video Title]
Platform: [X / LinkedIn / Instagram / etc.]
Posts: [X] drafts

---

Post 1 ([format: quote/insight/teaser]) - [Y] characters:
[Text]

Post 2 ([format]) - [Y] characters:
[Text]

[etc.]

---

Video analysis:
- [Key moments identified]
- [Recommended posting schedule if applicable]

Voice adherence (if profile provided):
- [Checklist]

Platform adaptation:
- [Platform-specific notes]
```

## Variations

### Short Video (<5 min)

- 1-2 posts max
- Focus on the single biggest insight or quote
- Simple structure: Hook → Insight → Link

### Interview/Podcast

- Multiple posts with different guests or topics
- Quote the most interesting exchange
- Tag guests (if they're on the platform)

### Tutorial/How-To

- Listicle format works well (3-5 steps)
- Pull specific actionable tips
- Each post should teach something

### Webinar/Talk

- Share slides or key visuals (if available)
- Break into chapters (one post per section)
- Include timestamps in X posts if applicable

## Limitations

- Cannot auto-publish (draft only)
- Cannot create video clips or graphics (text only)
- Transcript quality affects output (auto-generated transcripts may have errors)
- Cannot verify video URL is accessible
- Platform algorithms favor different content at different times

## Safety

- **Never publish automatically** - all output is draft only
- **Verify video link** - ensure URL works before posting
- **Respect platform norms** - don't cross-post identical content
- **Check quotes** - ensure quoted text is accurate from transcript
