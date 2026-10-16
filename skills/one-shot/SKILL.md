---
name: one-shot
description: Interview-driven single-agent task execution with model selection. Runs the interview skill to sharpen a task brief into a spec, then executes it with an orchestrator and subagents on user-chosen models in a goal loop.
---

# one-shot

Runs a single task through orchestra's `interview` skill to clarify the spec, then executes it with a user-selected orchestrator and subagent model in a goal loop (retries allowed). No decomposition into a project, no persistent board.

## When to use

- The user invokes `/one-shot <task brief>` for a focused task that doesn't need a full pipeline
- Interview-driven clarity with lightweight execution
- Quick prototypes, spikes, research questions, code tasks with clear boundaries

Don't use for multi-stage projects (use `research` or `develop`) or anything requiring reviewer gates (use `build`).

## Prerequisites

- The `interview` skill (from orchestra) is available

## Procedure

1. **Parse the brief** from the message after `/one-shot`.
2. **Run the interview skill.** Interactive Q&A, one question at a time, until the task is a precise, testable spec with success criteria.
3. **Pick the orchestrator and subagent models.** Ask the user two things: which model orchestrates (the main session model) and which model the subagents use (the `model` parameter of the Agent tool: `sonnet`, `opus`, `haiku`, `fable`). Recommend the strongest model for the orchestrator (planning and judging) and a cheaper tier for the subagents (the legwork). A session cannot switch its own model: if the orchestrator differs from the current session model, either ask the user to change it in the model menu, or launch the orchestrator as an Agent with its `model` set and have it spawn the subagents.
4. **Execute in a goal loop.** The orchestrator splits the clarified spec into independent pieces, sends each to a subagent on the chosen model, checks the results against the spec's success criteria, and retries or re-dispatches until the criteria are met or the budget is exhausted.
5. **Return the result:** final output, artifacts, and any follow-up questions.

## Pitfalls

- If `interview` is unavailable, fall back to a manual clarification pass.
- Model names come from what the Agent tool accepts at run time, not from a hardcoded list.
- A session cannot change its own model, so do not try.
- The goal loop budget (default 20 turns) caps retries; the user can extend it by re-invoking.
- Nothing persists beyond the chat history and any files the task writes.
- If the task turns out to need decomposition into stages, stop and suggest `research` or `develop`.

## Verification

- The interview ends with a written spec the user agrees covers the task.
- Orchestrator and subagent model choices are recorded.
- The loop ends when the orchestrator judges every success criterion met, the budget runs out, or the user stops it.
- The final answer is delivered in the chat.
