# Structured-Prompt-Driven Development (SPDD)

**Fonte:** https://martinfowler.com/articles/structured-prompt-driven/  
**Publicado:** 28 Abril 2026  
**Autores:** Wei Zhang & Jessie Jie Xia (Thoughtworks)

---

## Core Concept

SPDD treats prompts as "first-class delivery artifacts" that are version controlled, reviewed, and reused. Rather than relying on ad-hoc AI chats, the methodology creates structured, governed prompts that capture requirements, domain models, design intent, constraints, and task breakdowns.

---

## The Problem It Solves

While LLM coding assistants improve individual developer speed, they create downstream challenges:
- Ambiguous requirements transform into code quickly, scaling misunderstandings
- Code reviews become difficult with high change volumes
- Integration and testing issues emerge from unaligned generation
- Production risk increases with larger code volumes

The authors note: *"local speed improves. But that doesn't automatically translate into system-level throughput."*

---

## Key Components

### The REASONS Canvas

A seven-part framework for generating effective prompts:

**Abstract parts (intent & design):**
- **R** — Requirements: Problem statement and definition of done
- **E** — Entities: Domain entities and relationships
- **A** — Approach: Strategy for meeting requirements
- **S** — Structure: System fit, components, dependencies

**Specific parts (execution):**
- **O** — Operations: Concrete, testable implementation steps

**Governance parts:**
- **N** — Norms: Engineering standards (naming, observability, defensive coding)
- **S** — Safeguards: Non-negotiable boundaries (invariants, performance, security)

This structure *"aligns intent and boundaries before code is generated, moving uncertainty to the left."*

---

## The SPDD Workflow

The methodology follows these principles:

1. **Prompt-first discipline**: When reality diverges from expectations, update the prompt before changing code
2. **Version control**: Prompts stay in git alongside code
3. **Closed-loop feedback**: Changes on either side (requirements or code) synchronize back
4. **Reusable assets**: Successful patterns accumulate into a prompt library

### Workflow Steps

1. Create initial requirements — Convert business needs into structured user stories (`/spdd-story`)
2. Clarify analysis — Review for business-level issues and define scope
3. Generate analysis context — Use `/spdd-analysis` to extract domain concepts and risks
4. Generate structured prompt — Use `/spdd-reasons-canvas` to create the REASONS Canvas
5. Generate code — Use `/spdd-generate` to implement following the Canvas strictly
6. Generate tests — Create unit tests aligned with the specification (`/spdd-api-test`)

**Critical rule:** *"When reality diverges, fix the prompt first — then update the code."*

---

## Practical Example: Billing Engine Enhancement

The article demonstrates SPDD through enhancing an existing billing system to support:
- Model-aware pricing (different rates by AI model)
- Multi-plan billing (Standard with quotas; Premium without)
- Extensible architecture for future pricing models

### Step 1–2: Requirements & Analysis

The team uses `/spdd-story` to break requirements into INVEST-compliant stories, then clarifies scope boundaries and definition of done through collaborative review.

### Step 3: Analysis Generation

The `/spdd-analysis` command extracts domain keywords, scans relevant codebase sections, and produces strategic analysis covering concepts, risks, and direction — outputs that avoid granular implementation details while capturing high-level architectural intent.

### Step 4: Canvas Generation

The `/spdd-reasons-canvas` command creates the executable blueprint with all seven REASONS dimensions, progressing from strategic clarity to concrete method signatures and parameter types.

### Step 5: Code Generation

The `/spdd-generate` command reads the Canvas and generates code task-by-task, strictly adhering to Operations, Norms, and Safeguards with *"no improvisation, no features beyond what the spec defines."*

### Step 6: Testing

The `/spdd-api-test` command generates cURL-based test scripts covering normal scenarios, boundary conditions, and error cases. Unit tests follow a template-driven approach using `/spdd-sync` to maintain prompt-code alignment.

---

## Review & Iteration Pattern

The workflow handles two types of code changes differently:

**Logic Corrections (Behavior Changes):** Update the prompt first using `/spdd-prompt-update`, then regenerate code. This maintains intent as the source of truth.

**Refactoring (Style/Structure):** Refactor code directly, then use `/spdd-sync` to update prompt documentation, keeping the Canvas accurate.

---

## Key Workflow Commands

| Command | Purpose |
|---------|---------|
| `/spdd-story` | Break requirements into independent user stories |
| `/spdd-analysis` | Extract domain concepts and strategic direction |
| `/spdd-reasons-canvas` | Generate complete REASONS Canvas specification |
| `/spdd-generate` | Implement code from Canvas, task by task |
| `/spdd-api-test` | Generate functional test scripts |
| `/spdd-prompt-update` | Incrementally update Canvas for requirement changes |
| `/spdd-sync` | Synchronize code changes back into prompt |

---

## Three Core Skills Required

### Abstraction First

Design object relationships, boundaries, and collaborations before generating code. Without clear structure upfront, AI often implements details while the architecture deteriorates — resulting in unclear responsibilities, duplicated logic, and inconsistent interfaces that surface during review.

### Alignment

Lock intent and constraints explicitly before implementation. This means agreeing on what will/won't be done and establishing standards and hard boundaries upfront, preventing *"fast output and slow rework."*

### Iterative Review

Establish disciplined review-and-iterate loops. Without this discipline, teams either continuously patch outputs until solutions drift or restart repeatedly, losing control of time and cost.

---

## Where SPDD Fits

**Highly Recommended (★★★★★):**
- Scaled, standardized delivery (repeatable business logic)
- High compliance environments (regulatory/security constraints)

**Well-Suited (★★★★☆):**
- Multi-person delivery requiring auditability
- Complex refactoring across systems

**Limited Value (★★☆☆☆):**
- Production firefighting (when speed trumps discipline)
- Exploratory spikes (validation over quality)
- One-off scripts (overhead exceeds value)

**Not Suitable (★☆☆☆☆):**
- Poorly defined domains without clear business rules
- Creative/aesthetic work driven by taste rather than logic

---

## How SPDD Differs from Specification-Driven Development

While both begin with clear specifications, SPDD adds:

1. **Prompt as maintained artifact:** Not generated once but evolved alongside code through defined workflows
2. **Engineering completeness:** Captures not just what the system does but chosen approach, structure, norms, and safeguards
3. **Bidirectional synchronization:** Changes flow both directions — requirement changes update prompts, code refactoring syncs back to documentation
4. **Team control repeatable:** Consistent governance mechanism across iterations rather than one-time detailed specs

---

## Return on Investment Analysis

**Benefits:**
- **Determinism:** Precise specifications reduce LLM hallucination (high impact, immediate)
- **Traceability:** Changes traceable to source prompts (high impact, immediate)
- **Faster reviews:** Code arrives closer to standards (high impact, short-term)
- **Explainability:** Visible intent and behavior (medium-high impact, gradual)
- **Safer evolution:** Well-defined boundaries enable lower-risk changes (high impact, long-term)

**Upfront Investments:**
- Mindset shift toward design-first approaches
- Senior expertise required for translating business rules into abstractions
- Automation tooling setup (supported by the open-source `openspdd` CLI tool)

---

## Broader Vision

The authors note this represents an evolution: *"SPDD should depend less on personal craftsmanship and more on a mature, organization-level asset system."* Future work aims to lower barriers so expertise isn't required upfront, making high-quality standardized outcomes accessible regardless of seniority level.

---

## Fundamental Premise

The article closes with two key insights:

> *"In engineering, if you don't know what you are doing, you shouldn't be doing it."* — Richard Hamming

> *"In the AI era, software development isn't a contest of model IQ. It's a contest of engineer cognitive bandwidth – how clearly we can think, frame problems, and make decisions."*

SPDD operationalizes this by forcing clarity before generation, treating prompts as governed assets, and maintaining tight synchronization between intent and implementation throughout the development lifecycle.
