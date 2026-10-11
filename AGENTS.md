# Project Rules & Guidelines

> Note: This file mirrors and enforces the instructions from [CLAUDE.md](file:///Users/ahmedelsersy/Home/StudioProjects/1-Projectsـgoogleـplay/index_pharma_store/CLAUDE.md). It is loaded automatically by the agent in all sessions.

---

# Section A — General Engineering Rules

## 1) Architecture & Separation of Concerns (STRICT ENFORCEMENT)
- Follow layer boundaries strictly: `presentation` → `domain` → `data`
- Never bypass layers or mix responsibilities
- UI / Presentation layer has **ZERO** business logic — only rendering, interaction, and state observation
- Business logic lives strictly in the `domain` layer
- Data access (APIs, databases, storage) lives strictly in the `data` layer
- Do not introduce new abstractions or patterns without justification

## 2) Shared Code
- Any reusable logic, utility, constant, extension, or helper used in 2+ places goes in `core/`
- Always check `core/` before creating new shared code — never duplicate across features

## 3) Error Handling
- Errors flow cleanly across layers — never skip layers
- Handle null, empty, loading, and error states explicitly — no silent failures
- Catch errors at the boundary (data layer), not deep inside business logic

## 4) Change Discipline
- Make the smallest change that solves the problem
- Fix root causes, not symptoms
- Don't refactor unrelated code unless explicitly requested
- Never break existing functionality, APIs, flows, or UX unless explicitly instructed
- Read relevant code before modifying it — state assumptions when unclear

## 5) Dependencies
- Don't add new packages without justification
- Any new package must be: latest stable, well-maintained, production-grade

## 6) Security
- Never hardcode secrets, tokens, or credentials
- Never log sensitive information
- Validate all external and API input
- Proactively flag security risks when spotted

## 7) Testing
- Write tests for domain and data layer logic
- Bug fixes must include a reproducing test
- Tests must be deterministic — no flaky or timing-dependent tests
- One behavior per test case

## 8) Workflow
- Before marking any task done → review code thoroughly against these standards
- PR descriptions must always be in markdown (`.md`) format

---

# Section B — Flutter / Dart Specific Rules

## 1) State Management
- Use **Cubit / Bloc** for feature and application state — NOT Riverpod, Provider, or GetX
- Cubits depend **ONLY** on use cases — never directly on repositories or data sources
- `setState` is allowed **ONLY** for local UI state (e.g., toggles, form focus) — never for business logic
- Keep `setState` scoped to the smallest widget possible to avoid redundant rebuilds up the tree

## 2) No Code Generation
- **No Freezed. No build_runner.** Use Dart 3+ native features instead:
  - `sealed class` for state unions with exhaustive pattern matching
  - `switch` expressions and records for lightweight data

## 3) Domain Layer Purity
- Domain layer must have **ZERO** Flutter imports
- **No `package:flutter/...`** in any file under `domain/`

## 4) Feature Folder Structure
```
features/{feature_name}/
├── data/
├── domain/
└── presentation/
```

## 5) Error Handling Contract
- **Data layer**: catch exceptions and map to typed `Failure` classes
- **Domain layer**: return `ApiResult<T>` from use cases and repositories
- **Presentation layer**: map failures to user-friendly messages and UI states

## 6) Dependency Injection
- Use **`get_it`** as the service locator — not `Provider` or constructor-only injection
- Register dependencies in a single `core/di/` setup file
- Cubits, use cases, and repositories are resolved via `get_it`, not instantiated manually

## 7) Build Method Discipline
- Prefer `const` constructors wherever possible
- **NEVER** create `TextEditingController`, `AnimationController`, `FocusNode`, or other expensive objects inside `build()`
- Avoid heavy work inside `build()` methods
- Dispose controllers and focus nodes in `StatefulWidget.dispose()`
- Prefer small, composed widgets to minimize rebuild scope
- Use `BlocBuilder` / `BlocSelector` on the smallest widget that needs the state — never at the top of the tree
