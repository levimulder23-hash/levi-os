# Nate Herk — AI OS frameworks (course notes, 2026-09-10)

Sources: AIS-OS kit README + CLAUDE.md (github.com/nateherkai/AIS-OS), Skool "7 Day AIS Challenge" Day 7 (Executive Assistant 4-phase) and WAT CLAUDE.md, video "Steal My Exact AI OS Setup (5 hacks)".

## Four Cs (what you build), in order
1. Context — knows your business. Test: fresh session answers "what does this business do and who works here?" without browsing.
2. Connections — reaches your stuff. Test: "what's on my calendar tomorrow?" gives live data.
3. Capabilities — knows how to do the work. Test: a short phrase triggers a multi-step workflow that produces an artifact.
4. Cadence — runs without being asked. Test: laptop closed, a brief lands. **Last. Don't automate what doesn't work manually.**

## Three Ms (how you think)
- Mindset: Default Shift ("to what extent can AI be leveraged here?"), Function Breakdown (automate one tiny piece), Curiosity Rule (never run dark code you can't explain).
- Method: Find the constraint → EAD (Eliminate, Automate, Delegate; 60/30/10) → Map the process (trigger, sources, transforms, decisions, destination) → Autonomy Spectrum L0–L4, default to the lowest that works → tie to a KPI.
- Machine: Lego Principle, Assembly Line, Validation Chain, Iteration; operate with the Bike Method (manual → drafted → watched → hands-off), the Intern Rule (own identity, read-only by default, scoped keys, audit trail), the Kill Switch.

## Executive Assistant 4-phase
Home (one folder, concise CLAUDE.md pointing to context/.claude/projects/decisions/references/archives) → Life (interview) → Hands (one skill: do it manually once, turn it into a skill, iterate; then MCPs, subagents, scheduled tasks) → Grow (weekly nothing, monthly priorities, quarterly context refresh; log decisions; "remember that I prefer X").

## WAT
Workflows (markdown SOPs) → Agent (decides, coordinates) → Tools (deterministic scripts). Failure → fix the tool, update the workflow. Deliverables to cloud/git; local files for processing.

## 5 hacks (organization)
CLAUDE.md as a router (where things live) · have AI audit itself (read-only, then approve fixes) · crons to pull data in on a cadence · segment knowledge into distinct wikis · backtrack on mistakes and fix routing. Four context failure modes: poisoning, bloat, confusion, clash. Expertise context (always loaded) vs situational context (just in time).
