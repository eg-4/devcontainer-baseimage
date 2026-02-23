---
description: 'Comprehensive software design guidelines (SOLID, DRY, YAGNI, LoD) with examples to facilitate deep reasoning and high-quality refactoring.'
applyTo: 'export/scripts/*.sh, scripts/*.sh'
---

# Software Design Principles Instructions

These instructions guide the process to embody well-established engineering principles. **The goal is not just to write code, but to write code that is clear, correct, and evolvable.**

## Usage Modes & Reasoning

- **"Refactor":** Identify smells -> Map to Principle -> Explain *Why* -> Propose Changes.
- **"Is this good?":** detailed assessment (Principle -> Observation -> Impact -> Action).
- **New Code:** Design responsibilities (Who does what?) before implementation details.

## 1. SOLID Principles Deep Dive

### 1.1 Single Responsibility (SRP)

- **Concept:** Separate things that change for different reasons.
- **Heuristics:**
  - Separate **Business Logic** from **Infrastructure** (API/DB).
  - Separate **Calculation** from **Formatting**.
- **Action:** If a class handles both `Processing` and `Reporting`, extract the volatile concern first.

### 1.2 Open/Closed (OCP) & YAGNI Balance

- **Concept:** Open for extension, closed for modification.
- **Critical Guardrail:** Do not apply OCP speculatively.
  - *One concrete case:* Use simple `if/else`.
  - *Two concrete cases:* Consider refactoring to Strategy/Template.
  - *Reasoning:* Abstractions carry a cognitive cost. Pay it only when the extensibility benefit is proven.

### 1.3 Liskov Substitution (LSP)

- **Concept:** Subtypes must be substitutable for base types.
- **Red Flags (LSP Violations):**
  - **Preconditions:** Subclass requires stricter input (e.g., Base accepts `any int`, Subclass only `positive int`).
  - **Postconditions:** Subclass returns a wider range or throws new unchecked exceptions.
  - **"Not Supported":** Overriding a method just to throw an error implies the inheritance hierarchy is wrong.
- **Fix:** Prefer Composition over Inheritance.

### 1.4 Interface Segregation (ISP)

- **Concept:** Many client-specific interfaces > One general-purpose interface.
- **Signal:** If you implement a method as a "no-op" (empty body) just to satisfy an interface, split the interface.

### 1.5 Dependency Inversion (DIP)

- **Concept:** Depend on abstractions.
- **Context:** This applies primarily to *volatile* dependencies (DB, Network, FileSystem). Do not over-abstract pure logic or value objects.

## 2. DRY vs. Incidental Duplication

- **Rule:** DRY is about **Duplicated Knowledge**, not just duplicated text.
- **Context:**
  - If two blocks of code change together? -> **DRY violation.** Extract it.
  - If two blocks look same but evolve independently? -> **Incidental.** Leave it. Merging them creates unnecessary coupling.

## 3. Law of Demeter (LoD)

- **Rule:** Avoid coupled graph traversal (`a.getB().getC().do()`).
- **Mental Model:**
  1. **Transformation Pipeline (ALLOWED):** `items.filter().map().reduce()`. Verbs transforming values. This is fine.
  2. **Traversal Train Wreck (FORBIDDEN):** `user.getAccount().getPlan().getPrice()`. Nouns exposing structure.
- **Remediation:**
  - *Bad:* `if (order.getItems().isEmpty()) ...`
  - *Good (Tell-Don't-Ask):* `if (order.isEmpty()) ...` - Move the query into the domain object.

## 4. Decision Heuristics Matrix

Use this table to quickly map observations to the correct principle.

| Observation / Situation | Principle Emphasis |
| ----------------------- | ------------------ |
| Frequent divergent change in one class | **SRP** (Split responsibilities) |
| Switch statements proliferating | **OCP** (Consider Strategy Pattern) |
| Duplicate algorithms (subtle diffs) | **DRY** (Verify semantic match first) |
| Planned but uncertain feature | **YAGNI** (Wait / Add TODO) |
| Deep object graph traversal | **LoD** (Encapsulate / Facade) |

## 5. Minimal Example Synthesis (Few-Shot Priming)

**Bad Example (Violates SRP, DIP, LoD):**

```typescript
class OrderService {
  process(id: string) {
    const order = db.find(id); // Direct dependency
    const total = order.items.reduce((s, i) => s + i.price, 0); // Logic mixed with I/O
    emailClient.send(order.user.email, total); // Train wreck
  }
}
```

**Good Example (Refactored):**

```typescript
// Dependencies injected (DIP)
class OrderService {
  constructor(private repo: OrderRepository, private mailer: Mailer) {}

  process(id: string) {
    const order = this.repo.findById(id);
    order.calculateTotal(); // Logic in Domain (SRP/LoD)
    this.mailer.sendReceipt(order); // Task delegated
  }
}
```

## 6. Output Template

Generate responses using this structure to ensure reasoning is visible:

```text
**Assessment:**
- **Principle:** [Name]
- **Context:** [Why this principle matters here]
- **Observation:** [Code smell]
- **Proposed Action:** [Fix]

**Refactor Plan:**
...
```
