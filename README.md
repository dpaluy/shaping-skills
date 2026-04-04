# Shaping Skills

Skills for shaping product ideas into buildable software with LLM coding agents.

This repo encodes a workflow from [Shape Up](https://basecamp.com/shapeup):

1. Capture the problem and initial solution shape
2. Check fit between requirements and the shape
3. Spike unknowns
4. Breadboard the selected shape into concrete affordances and wiring
5. Slice the system into demoable vertical scopes
6. Build slice by slice

The skills work with Pi, Codex, and Claude.

This package is adapted from the original [rjs/shaping-skills](https://github.com/rjs/shaping-skills) project.

[Shaping 0-1 with Claude Code](https://x.com/rjs/status/2020184079350563263) shows the workflow end to end: blank directory -> shaping doc -> spikes -> breadboard -> slices -> working product.

Canonical skill content lives in `skills/`. Tool-specific manifests and plugin folders point at that single source of truth.

## What These Skills Produce

- **Frame**: source material, problem, and outcome
- **Shaping doc**: requirements (`R`), shapes (`A`, `B`, `C`), fit checks, and breadboards
- **Spike docs**: separate investigation files for unknowns
- **Slices doc**: vertical implementation slices with demos and wiring
- **Slice plans**: markdown build-plan files for each slice (`V1-plan.md`, etc.)

The point is not to make prettier markdown. The point is to force the agent to separate requirements from mechanisms, expose unknowns, and make scope decisions explicit before it starts coding.

## Skills

| Skill | What it does | Use it when |
|------|---------------|-------------|
| `shaping` | Captures requirements, shapes, fit checks, spikes, and slice handoff | You are defining a feature, comparing solutions, or scoping work before implementation |
| `breadboarding` | Maps UI affordances, code affordances, stores, places, and wiring | You need to understand or detail how a system works in concrete terms |
| `breadboard-reflection` | Syncs a breadboard to the implementation and surfaces design smells | You already have a breadboard and want to check it against the code |
| `framing-doc` | Distills transcripts into a frame with problem, outcome, and evidence | You have source conversations and need the "why now" documented |
| `kickoff-doc` | Converts a kickoff transcript into a builder-facing territory map | The work is shaped and you want a usable handoff doc |

## Typical Workflow

### 1. Start with shaping

Ask the agent to use the `shaping` skill before implementation starts.

Examples:

```text
Use your shaping skill to capture the requirements and tease apart the key parts of solution A.
```

```text
Help me shape this feature before we build it.
```

### 2. Check fit

Once the first shape exists, inspect how well it satisfies the requirements.

Examples:

```text
Show me R x A.
```

```text
Rotate the fit check and show me A x R.
```

This is the core move. It shows what is solved, what is still fuzzy, and what needs investigation.

### 3. Spike the unknowns

When part of the shape is still hand-wavy, spike it.

Examples:

```text
Please spike A2.
```

```text
Can you spike the local LLM piece?
```

Spikes should produce separate markdown files so the findings are preserved and can feed back into the shape.

### 4. Breadboard the chosen shape

Once the shape is good enough, translate it into concrete affordances and wiring.

Example:

```text
Let's breadboard A.
```

Breadboarding is what makes slicing sane. Without it, vertical slicing turns into guesswork.

### 5. Slice vertically

Once the breadboard exists, slice the system into demoable scopes.

Example:

```text
Let's slice it.
```

Each slice should end in a real demo, not a horizontal layer. The goal is to build something you can show, learn from, and either continue or cut.

### 6. Build one slice at a time

After slicing, have the agent write the first slice's implementation plan and self-test approach into a markdown file instead of presenting the plan in terminal output.

Example:

```text
Please write `V1-plan.md` for the first slice. Include how you will test it yourself to ensure it's working, then open the markdown file for review.
```

## Installation

### Claude Code

```
/plugin marketplace add dpaluy/shaping-skills
/plugin install shaping-skills
```

### Pi

Install directly from a local path:

```bash
pi install /absolute/path/to/shaping-skills
```

Or install from git:

```bash
pi install git:github.com/dpaluy/shaping-skills
```

After publishing to npm, install with:

```bash
pi install npm:@dpaluy/shaping-skills
```

Pi discovers the skills from the package manifest and conventional `skills/` directory.

### Codex

You can use this repo in Codex in three ways:

1. Open this repo directly in Codex. The repo already exposes the skills through `.agents/skills/`.
2. Install the skills globally for your user:

```bash
./install.sh --user
```

This copies the skills into `~/.agents/skills/` and symlinks them into `~/.claude/skills/`.

3. Install the skills only into the current project:

```bash
./install.sh --project
```

This copies the skills into `.agents/skills/` and symlinks them into `.claude/skills/` for the directory where you run the command.

A publishable Codex plugin layout is also available in `plugins/shaping-skills/`.

## Ripple Hook

The repo includes a hook that reminds Claude to check ripple effects when editing shaping documents. When a `.md` file with `shaping: true` in its frontmatter is written or edited, the hook prompts a short checklist:

- update affordance tables before re-rendering Mermaid
- update fit checks when requirements or shape parts change
- update work stream detail when the work stream design changes

To install:

1. Symlink the hook script:

```bash
REPO=/absolute/path/to/shaping-skills
mkdir -p ~/.claude/hooks
ln -s "$REPO/hooks/shaping-ripple.sh" ~/.claude/hooks/shaping-ripple.sh
```

2. Add the hook to `~/.claude/settings.json`:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/shaping-ripple.sh",
            "timeout": 5
          }
        ]
      }
    ]
  }
}
```
