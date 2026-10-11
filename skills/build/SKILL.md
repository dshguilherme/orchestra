---
name: build
description: Executes the approved roadmap with parallel builder/critic subagent pairs using the gauntlet-loop method - a named, fetchable bar, blind comparison, no scores, loop until the work wins - to write the code and the manuscript draft. Stage 5 of the research pipeline.
---

# Build (gauntlet loop over the roadmap)

Method credit: the loop below follows the "Gauntlet Loop" skill by Jay E / RoboNuggets (github.com/robonuggets/gauntlet-loop, CC BY 4.0), itself based on a technique from Matt Shumer. It is reimplemented here as a native executor instead of generating a prompt for a separate session.

**Also executes software plans.** For the `develop` pipeline the inputs are `dev/<slug>/plan/roadmap.md` (from `dev-plan`), the vault (interfaces are its function/type notes, bars are in each task), and the real code repo. Same loop; the critic runs the tests and the bar comparisons, and after each wave you run `design-vault` sync mode and update node `status`. Ignore the manuscript-specific parts (journal, assembly of the paper); the final whole-project gauntlet compares the finished software against the spec's acceptance examples.

Inputs (research pipeline): `plan/roadmap.md`, `plan/interfaces.md`, `plan/bars.md`, `plan/journal.md`; approved in `state.md`.
Outputs: code in the project repo, `results/`, `manuscript/` (sections, figures, bib), `build/log.md`, `build/<task>/` (rounds, verdicts).

## Executing the DAG
For each **wave** in the roadmap, in order:
1. Launch every task in the wave **at once** (one message, many Agent calls). Code tasks use `isolation: "worktree"`; writing tasks own distinct files.
2. Each task runs its own gauntlet (below). Tasks in a wave are independent; do not serialize them.
3. When a task wins, merge its worktree/files, run the project tests, and record it in `build/log.md`. Resolve merge conflicts by the interfaces file, not by taste.
4. Unblock and start the next wave. Writing tasks that depend on results read `results/*.json`; never hand-copy numbers.
Failed or stuck tasks do not block independent branches; flag them and continue.

## The gauntlet for one task
Roles are **separate agents with fresh context**. A builder never judges its own work.

1. **Builder** (model per roadmap): gets the task, `interfaces.md` (frozen), relevant wiki notes, and the acceptance test. Produces the artifact. Writes it to `build/<task>/round-<n>/` (or in its worktree) and reports what it did.
2. **Critic** (`opus`, fresh context): receives the artifact and the **bar** (fetches it for real - reads the paper section, runs the benchmark, opens the figure), with labels removed and the order randomized. It must:
   - actually run/open the artifact (execute the code and tests, compare numbers to the bar, read the text);
   - **pick a winner** between the artifact and the bar, with concrete reasons and specific defects. **No numeric scores** - scores drift upward;
   - for code, check against the acceptance test and report measured values, not impressions.
3. If the bar wins, the critic's defect list goes back to a **new builder round** (a fresh builder given the artifact, the defects and the bar). Repeat.
4. The task is **done** when the artifact wins the blind comparison and the acceptance test passes. For code, "wins" means it matches the bar's reference results within the stated tolerance; for writing, a reader would pick our section as at least as clear, rigorous and well-placed as the exemplar's.

**Held-out tests (software plans).** If the task lists `held-out:` IDs, the critic is **harsh** and runs them:
- Builders and their worktrees never contain `plan/held-out/`, and the builder prompt says: do not read, search for, or ask about it. Public tests are the builder's to run.
- The critic runs `plan/held-out/run.*` against the builder's repo/worktree, plus the public tests, plus the bar comparison. All must pass for the task to win; one held-out failure means the bar wins.
- **Feedback discipline**: the critic reports to the next builder the requirement, test category and a *behavioral* description of the failure ("empty input is not rejected", "result drifts with input order"), never test source, exact inputs, or expected values. Otherwise the builder just fits the tests. Full detail goes only to `build/<task>/critic-private.md`, which builders do not receive; the user may read it.
- The critic also reads the diff for **overfitting**: hard-coded outputs, special cases keyed to example values, test-detection, references to the held-out path. Any of these is an automatic loss and is reported as such.
- If a held-out test looks wrong (a correct implementation could fail it), the critic flags it to the planner/user instead of the builder; the test is fixed and logged in `plan/held-out/CHANGELOG.md`.
- A task that passes all public tests but keeps failing the same held-out category for 3 rounds is the 5-round check-in trigger early: report which requirement is at stake.

**No fixed round count.** Instead of a cap, use a check-in: after 5 rounds on one task (or when defects stop changing), stop and report to the user what is stuck and offer: continue, change the bar, change the approach, or accept as-is. Reasons it's usually stuck: vague bar, bar not actually comparable, builder cannot see the defect, or the hypothesis itself doesn't hold up (then say so - negative results are findings).

## Domain rules
- **Code**: tests first for anything with a known answer (analytic solutions, manufactured solutions, convergence studies). Seeds fixed. Commit per task. No result goes into the paper unless a task produced it and a critic ran it.
- **Numerics honesty**: if the code does not reproduce a published result the plan depends on, that is the headline; surface it to the user at once instead of tuning until it "works".
- **Writing**: write to the notation sheet and skeleton; cite only citekeys in the wiki (`\cite{key}` / `[@key]`, matching the journal's format); no invented references. Leave `TBD(result:<id>)` markers until results exist, then fill from files.
- **Figures**: generated by scripts from `results/`, vector format, journal style; the critic compares against an exemplar figure.

## Assembly (serial tail)
After all waves: one agent assembles the manuscript in the journal template, resolves cross-references and labels, regenerates the bibliography from the wiki, rewrites abstract/intro/conclusion against the final results, and compiles. A fresh critic runs one more blind gauntlet on the **whole manuscript** against the best exemplar article. Write `manuscript/DRAFT.md|tex` as the output, update `state.md` (`stage: cite-check` ready) and report to the user: what was built, what the results showed (including anything that disagreed with the hypothesis), what is stuck.
