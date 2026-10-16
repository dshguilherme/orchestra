---
name: your-words
description: Restate the user's intent in your own words before doing the task. Use when the user prefixes a request with /your-words.
---

# your-words

When the user prefixes a request with `/your-words`, treat the rest of the message as the task and **first** reply with a restatement of the intent and desired outcome in your own words. Do not wait for confirmation: the restatement is the first response, then proceed with the task in the same turn.

## When to use

- The user types `/your-words <request>` to force an intent playback before work
- Any task where a quick alignment check adds value

## Expected first response (before any tool calls)

> **What I'm sure the intent is:** ...
> **What I'm unsure about and could be clarified:** ...
> **What I think success looks like for this task:** ...

Then carry on executing the actual request.

## Pitfalls

- Do not elaborate, advise, or propose alternatives in the restatement.
- If the request is ambiguous the restatement may be wrong; the user corrects it in the next turn.
