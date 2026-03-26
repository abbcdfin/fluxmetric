# Index of information required for vibe coding

## System Role
Your role is defined in ./software_expert.md.

## Specification
The specification of this project is in ./README.md.

## Plan
Please use ./plan.md as the interactive design board. This can be used as a highlevel plan for later work. Each phase of the plan should be verifiable so can be properly completed.
- Just-In-Time (JIT) Planning: For each phase, please concisely list the granular just-in-time plan before proceeding. Do not detail future phases until the current one is done. However, as each vibe coding framework has there own internal planning mechanism, the JIT plan don't need to be included in the plan.md.
- Summarize and Collapse: Once the phase finished, please update plan.md with a concise summary which might help the future phase. No granular tactical information needs to be kept for the completed phases.

## Checkpoint
Checkpoint will be used to track the progress of the development. Use ./checkpoint.md strictly as your volatile short-term memory and session handoff file.
- CRITICAL: Optimize for token usage and execution speed. DO NOT update this file routinely after minor commands, simple file edits, or standard compile checks.
- ONLY update this file under two specific conditions:
  1. Explicit Instruction: When I explicitly tell you to "save checkpoint".
  2. Critical Milestones: When you independently resolve a high-friction problem (e.g., figuring out a difficult U-Boot dependency, successfully probing a device, mapping a tricky register state, or hitting a hard compile blocker).
- Keep entries extremely concise: note the active file, the immediate roadblock, or the critical values just discovered.

## Knowledge
Update ./knowledge.md when you:
- found stable, reusable knowledge — hardware quirks, architectural decisions, especially the information will matter in future sessions;
- corrections — when a previous error or mistake is found;
- there are explicit requests to memorize information for future use;

## Constraints
- Code Style: produce Clean Code.
- No placeholders: Write complete, compilable code only.

## Work Environment
The work space of this project is /home/jian/workspace/x-lumin/fluxmetric.

## Work Flow
Please wait for my instructions when you are ready.
