---
name: x-thread
description: Draft X/Twitter threads in a given voice profile. Creates multi-tweet threads following the style guide from a voice profile. Draft only - never publishes automatically. Use when writing X threads in a specific creator's voice.
---

# X Thread Drafter

**When to use:** When you need to draft an X/Twitter thread (2+ connected tweets) in a specific creator's voice. Always draft only - never auto-publish.

## Prerequisites

- **Voice profile:** A voice profile markdown file (created by the `voice-profile` skill)
- **Topic/content:** What the thread should cover
- **Goal:** Inform, explain, tell a story, share insights, etc.

## Process

### 1. Load the Voice Profile

Read the voice profile to understand the creator's style (same as `x-post` skill).

### 2. Plan the Thread Structure

Threads need structure. Common patterns:

**Announcement thread:**
1. Hook tweet (what's being announced)
2. Why it matters
3. Key details (2-3 tweets)
4. Closing CTA or link

**Explainer thread:**
1. Hook (question or bold claim)
2. Context/background
3. Explanation (3-5 tweets, one concept per tweet)
4. Conclusion or takeaway

**Story thread:**
1. Hook (start of story)
2. Build-up (2-3 tweets)
3. Turning point or key moment
4. Resolution or lesson

**Listicle thread:**
1. Hook (e.g., "5 things I learned about X")
2. One tweet per item (numbered: 1/, 2/, 3/)
3. Optional: closing summary

### 3. Draft the Hook Tweet

The first tweet is critical - it must grab attention and signal what the thread is about.

Apply the profile's hook patterns:
- Questions
- Bold claims
- Statistics or surprising facts
- Personal stories
- Contrarian takes

**Include thread indicator:**
Most threads use "🧵" or "(thread)" or "1/" in the first tweet.

### 4. Draft Individual Tweets

Each tweet in the thread should:
- **Stand alone**: Make sense if read in isolation
- **Flow**: Connect smoothly to the next tweet
- **One idea**: Don't cram multiple points into one tweet
- **Match voice**: Follow the profile's sentence structure, tone, formatting

**Length:**
- Aim for 200-260 characters per tweet (not 280, to leave room for variation)
- Vary tweet length to avoid monotony

**Formatting:**
- Follow the profile's line break preferences
- Apply emoji rules from profile
- Use numbering if the profile does (1/, 2/, 3/ or 1. 2. 3.)

**Threading:**
Number tweets clearly: "1/8", "2/8", etc., or "1.", "2.", etc.

### 5. Draft the Closing Tweet

The last tweet should:
- Summarize or reinforce the main point
- Provide a call-to-action (if appropriate)
- Link to more info (blog post, product, etc.)

**Common closings:**
- "If you found this helpful, follow me for more [topic]"
- "Read the full post: [link]"
- "Questions? Drop them below"
- Or just end with the final point (no explicit CTA)

### 6. Review the Thread

**Flow check:**
- Read the thread straight through
- Does it build logically?
- Are transitions smooth?

**Voice check:**
- Compare each tweet to the profile's Do's and Don'ts
- Consistent tone throughout?
- Matches sentence structure and formatting?

**Length check:**
- No tweets over 280 characters
- Varied lengths?

### 7. Present the Draft

Show the complete thread with tweet numbers, character counts, and notes.

## Example Workflow

**Input:**
- Voice profile: `examples/voice-profiles/tech-creator.md`
- Topic: Explain how to start with AI agents
- Goal: Educational thread for beginners

**Profile summary:**
- Casual, first-person
- Short sentences
- Line breaks after each sentence
- Rare emoji (only 💡 for key points)
- No hashtags

**Draft Thread:**

```
🧵 How to actually start building with AI agents (without losing your mind)

A beginner-friendly thread.
```
(108 characters, tweet 1/7)

```
First: ignore the hype.

You don't need to understand transformers or backpropagation.

You just need to know what you want the agent to do.
```
(146 characters, tweet 2/7)

```
Start with the simplest possible task.

"Read this email and tell me if it's urgent" is a better first project than "build me an autonomous research assistant."
```
(166 characters, tweet 3/7)

```
Pick a framework.

LangChain if you want batteries included.
LlamaIndex if you're focused on retrieval.
Or just raw OpenAI API if you like control.

All are fine for learning.
```
(179 characters, tweet 4/7)

```
💡 Key insight: agents are just loops.

Read input → decide action → execute → repeat.

That's it. The complexity comes from how you handle errors and edge cases.
```
(163 characters, tweet 5/7)

```
Test with cheap models first.

GPT-3.5 is way cheaper than GPT-4 and fast enough for early experiments.

Switch to GPT-4 only when you know your prompt works.
```
(166 characters, tweet 6/7)

```
Final tip: log everything.

You can't debug what you can't see.

Start here: https://example.com/agent-quickstart

Questions? I'm here.
```
(139 characters, tweet 7/7)

---

**Voice adherence:**
- ✅ Hook with clear promise ("without losing your mind")
- ✅ Short sentences throughout
- ✅ Line breaks after each sentence (per profile)
- ✅ Casual, first-person tone
- ✅ One 💡 emoji for key insight (profile: rare emoji)
- ✅ No hashtags (profile: minimal hashtags)
- ✅ Practical, no fluff

**Thread structure:**
- Tweet 1: Hook + thread indicator
- Tweets 2-6: Step-by-step guidance (one concept per tweet)
- Tweet 7: Closing with CTA and link

## Tips

### Thread Structure

- **Keep it tight**: 5-8 tweets is ideal. 10+ is hard to maintain attention.
- **One idea per tweet**: Don't cram. If a point needs more space, split it.
- **Vary length**: Don't make every tweet 250 characters. Mix it up.
- **Use numbers**: "1/7" or "1." helps readers track progress.

### Voice Consistency

- **Maintain tone**: The voice should be consistent across all tweets.
- **Formatting**: If the profile uses line breaks, use them in every tweet (unless one tweet is a single short sentence).
- **Rhythm**: If the profile says "short punchy sentences," apply that throughout.

### Engagement

- **Hook matters most**: If the first tweet doesn't grab attention, the thread dies.
- **Mid-thread hooks**: Add a surprising fact or bold claim halfway through to keep readers engaged.
- **Closing CTA**: Give readers a next action (follow, read more, reply).

### Common Thread Patterns

**Educational (how-to):**
1. Hook: promise a clear outcome
2. Step 1
3. Step 2
4. Step 3 (etc.)
5. Common mistakes to avoid
6. Closing CTA

**Insight/analysis:**
1. Hook: bold claim or question
2. Context/setup
3. Data or evidence
4. Interpretation
5. Implications
6. Conclusion

**Story:**
1. Hook: start in the middle of action
2. Context
3. Rising action
4. Climax/turning point
5. Resolution
6. Lesson learned

## Common Mistakes

❌ **Don't:**
- Publish automatically (always draft only)
- Make every tweet the same length (vary rhythm)
- Cram too much into one tweet (split if needed)
- Forget the hook (first tweet is everything)
- Ignore the profile's voice (consistency matters)
- Go over 280 characters per tweet
- Use @mentions without verifying they exist (if profile requires it)
- Add too many threads (5-8 tweets is ideal)

## Output Format

```
Thread: [Title/Topic] ([X] tweets)

---

Tweet 1/X ([Y] characters):
[Text]

Tweet 2/X ([Y] characters):
[Text]

[etc.]

---

Voice adherence:
- [Checklist of key profile rules followed]

Thread structure:
- [Brief description of structure used]

Notes:
- [Any specific choices or alternatives]
```

## Limitations

- Cannot auto-publish (draft only)
- Cannot preview how the thread will render in the X UI
- Cannot verify @mentions exist on X (note in output if profile requires it)
- X algorithm favors different content at different times - good voice match doesn't guarantee performance

## Safety

- **Never publish automatically** - all output is draft only
- **Verify @mentions live** - if the profile requires it, include a note
- **Check all links** - ensure URLs work before posting
- **Review for coherence** - read the thread straight through to ensure it flows
