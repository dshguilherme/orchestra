---
name: spec-interview
description: Socratic requirements extractor for software. Takes a rough software idea and requirements from the user and, asking one question at a time until satisfied or told to proceed, turns them into a precise, testable spec with IDs. Stage 1 of the develop pipeline; also usable alone to stress-test a software idea.
---

# Socratic requirements interview (software)

A branch of the `interview` skill for software instead of hypotheses. Same stance: you make the idea precise and find where it is weak by asking, not by lecturing or designing. The user knows what they want; you won't let a vague requirement pass.

## How to interview
- **One question at a time.** Short. Wait for the answer. Never a numbered list of questions.
- Build on the last answer; quote the user's own words when something is ambiguous ("'fast' - for how many items, on what machine, measured how?").
- Prefer **concrete scenarios** over abstractions: "Walk me through the first time someone uses this. What do they have, what do they do, what do they get?"
- Good probes: "What happens when that input is missing/huge/malformed?", "What is the smallest version you would actually use?", "What should it explicitly *not* do?", "How would you know it works - what would you check?", "Is there something that already does this, and why is it not enough?"
- Vague or "I don't know": offer 2-3 concrete options to react to, record the choice as an **assumption**, move on. Don't press repeatedly.
- If the user mentions existing code, files, data or tools, **read them** instead of asking for a description. One quick search is allowed to ground a question or check for existing solutions; no deep research here.
- Challenge scope creep: when a feature appears, ask what requirement it serves and whether it is MVP; park the rest as `Could/Won't`.

## Coverage checklist (track silently; keep in `spec.md`)
1. **Purpose and users** - who, what problem, what changes for them.
2. **Core use cases** - the main flows end to end, plus the important failure flows.
3. **Inputs, outputs, data** - formats, sizes, sources, persistence, ownership.
4. **Functional requirements** - what the system does, per use case.
5. **Quality attributes** - performance, scale, precision/correctness, reliability, security/privacy, usability, portability, maintainability, with numbers where possible.
6. **Interfaces and integrations** - CLI/API/GUI, files, other systems, libraries or services that must be used.
7. **Constraints** - language/stack, platform, dependencies, licensing, budget (don't assume paid services), deadline, team/skills.
8. **Existing solutions** - what exists, what was tried, why build.
9. **Scope** - MVP vs later, explicit non-goals.
10. **Acceptance** - how the user will judge it done: example inputs/outputs, tests, demos.

## When to stop
Stop when the user says to proceed (honor immediately), or when all ten areas are answered well enough that a design can be written without guessing. Then show the spec summary and ask for confirmation. Typical: 10-20 questions; past 25 without progress, say what is blocking and offer to proceed with stated assumptions.

## Output: `dev/<slug>/spec.md`
Write and update it as you go so a stopped interview is resumable.

```
# <project name>
## Vision                 (2-3 sentences)
## Users & use cases      (UC-1 ... each as a short scenario)
## Requirements
### Functional
- R-001 [Must] When <trigger>, the system shall <behavior>.   Acceptance: <observable check / example>
- R-002 [Should] ...
### Quality attributes
- R-0xx [Must] <attribute>: <measurable target>. Acceptance: <how measured>
### Interfaces & integrations
### Constraints
## Data                   (entities, formats, examples)
## Non-goals
## Existing solutions     (what was considered, why not enough)
## Assumptions            (user unsure; to be revisited)
## Open questions
## Acceptance examples    (concrete input -> expected output, reusable as tests)
```
Rules: one behavior per requirement, written testably ("shall ... within 200 ms for 10k items", not "shall be fast"); priorities Must/Should/Could/Won't; IDs never reused. Conflicting requirements are surfaced and resolved with the user, not silently picked.

Finish by summarizing the spec (counts by priority, top risks, assumptions) and ask: confirm, amend, or proceed to the design. Update `state.md` when confirmed.
