# Project Rules & Guidelines — AGENTS.md

> **Mandatory Reference:** This document defines the engineering rules, architecture, and working practices for this project, mirroring and enforcing the master guidelines in [Flutter_Rules.md](file:///Users/ahmedelsersy/Home/StudioProjects/1-Projectsـgoogleـplay/index_pharma_store/Flutter_Rules.md). It is loaded automatically by the agent in all sessions and must be strictly followed.

---

# Section A — Mandatory Working Practices

## 1) Understand, Plan, Then Implement (Mandatory)
- Inspect the project structure, `pubspec.yaml`, entry points, routing, state management, and dependency injection before writing code.
- Understand the data flow and responsibilities of the files related to the task.
- Do not start implementing a large feature immediately; present an ordered plan and wait for approval before implementation.
- Work step by step, focusing on one complete feature at a time.
- Do not create files, layers, or services by default before confirming they are needed.
- Do not guess APIs, backends, data models, or undocumented behavior; identify missing information first.
- Briefly explain important architectural decisions, especially when more than one solution is possible.

## 2) Write Code the Project Owner Can Understand
- Write clear, direct, maintainable Dart code rather than clever or overly compressed code.
- Avoid unnecessary complexity, abstractions, and boilerplate layers that add no value.
- Do not put an entire feature in one file, and do not split it into many files without clear responsibilities.
- Use meaningful names and maintain consistent naming conventions across the project.
- When adding a feature, explain each layer's responsibility and the data flow between layers before moving to the next step.
- Do not merely generate code; ensure it fits the existing files and that its logic can be followed and understood.

## 3) Change Discipline
- Make the smallest correct change that satisfies the requirement.
- Fix root causes instead of symptoms.
- Do not refactor files unrelated to the task.
- Do not delete or replace existing code before understanding its usage.
- Preserve existing behavior and public interfaces unless a change is requested.
- Review `git diff` and Git status before broad changes, and never discard the owner's work.
- Do not run deletion, reset, or other destructive commands without explicit permission.

---

# Section B — Preferred Flutter Architecture

## 1) Default Architecture (Mandatory for New Projects)
- Use **Clean Architecture with a Feature-First structure**.
- Separate responsibilities into `presentation/`, `domain/`, and `data/` for each feature when a Domain layer is genuinely needed.
- Follow this dependency direction: **Presentation → Domain ← Data**.
- Do not let the UI access APIs, databases, or local storage directly.
- Do not let a `Cubit` call `Dio` or a Data Source directly.
- Do not put business rules inside Widgets, `build()`, or UI event handlers.
- **Domain Layer Purity:** Domain layer must have **ZERO** Flutter imports (`package:flutter/...`).
- Do not add useless layers or Use Cases just to satisfy an architectural checklist; preserve boundaries without adding unnecessary complexity.

## 2) Feature Implementation Order
Follow this order when applicable, and do not bypass a layer without a clear reason:

**Model / Entity → Data Source or Service → Repository → Use Case → Cubit → UI**

- **Entity:** Represents a business concept in Domain, when Domain/Data separation is used.
- **Model:** Represents an external data format and its conversion, within Data.
- **Data Source / Service:** Handles a data source such as an API, database, or storage.
- **Repository:** Provides a consistent data interface and maps source results to the appropriate result.
- **Use Case:** Represents a meaningful business operation when logic or separation justifies it.
- **Cubit:** Manages feature state and coordinates Use Cases, or follows the existing project's established Repository contract.
- **UI:** Renders state and handles user interaction only; it must not contain business logic or directly access data.

*Do not create every file automatically when it is not needed. Follow the flow and responsibilities, not a fixed file count.*

## 3) Folder Structure
Prefer a feature-first structure instead of collecting all application files into large generic folders.

```text
lib/
  core/
    constants/
    errors/
    network/
    di/
    routing/
    theme/
    localization/
    widgets/
  features/
    feature_name/
      data/
        datasources/
        models/
        repositories/
      domain/
        entities/
        repositories/
        usecases/
      presentation/
        cubit/
        pages/
        widgets/
```

- Treat this as a guide that can be adapted to the actual project, not a reason to move existing files without need.
- Put genuinely cross-feature shared code in `core/`.
- Do not put feature-specific business logic in `core/`.

---

# Section C — Preferred Technologies and Usage Rules

## 1) State Management
- Use **`flutter_bloc` with Cubit/Bloc** for application and feature state.
- Prefer **Cubit** for straightforward state and operations; use Bloc when event-stream complexity provides a clear benefit.
- Do not use `GetX`, `Provider`, or `Riverpod` instead of Cubit in a new project unless the owner explicitly requests it or an existing constraint requires it.
- `setState` is allowed only for small, local UI state, such as password visibility or expanding a UI element.
- Do not use `setState` for business rules or feature state shared across screens.
- Represent loading, success, empty-data, and failure states clearly.
- Do not put the entire application state into one Cubit; give each Cubit a clear scope.

## 2) Routing
- Use **`go_router`** for routing in new projects.
- Keep route definitions in a clear location; do not trigger navigation arbitrarily from data or Domain layers.
- Use `redirect` or route guards when authentication or roles require them.
- Pass only the data needed for navigation; avoid passing large objects between screens without a reason.
- Do not replace an existing routing system without reviewing the impact and obtaining approval when needed.

## 3) Dependency Injection (DI)
- Use **`get_it`** to register and resolve dependencies in new projects that need DI.
- Keep registrations in a clear setup location such as `core/di/`.
- Register Data Sources, Repositories, Use Cases, and Cubits as needed and in an appropriate order.
- Do not create dependencies manually inside Widgets or every screen.
- Avoid duplicate registrations or unintended multiple instances.
- Do not register every Cubit in `main.dart`; scope it to the feature, route, or screen that needs it.
- Do not introduce DI into a small project that does not need it, or replace an existing solution without justification.

## 4) Network Requests
- Use **`Dio`** for HTTP/API requests in new projects when networking is needed.
- Centralize client configuration such as `baseUrl`, timeouts, headers, and error handling where appropriate.
- Do not repeat `Dio` configuration in every Repository.
- Separate DTOs/Models from Entities when the architecture calls for it.
- Handle network failures, timeouts, unsuccessful responses, and unexpected payloads explicitly.
- **Never place private secrets, tokens, or credentials in client-side code.**
- Do not invent endpoints, field names, or API contracts; inspect the documentation or ask for backend details.
- Do not add a network client to a fully local feature.

## 5) Local Storage
- Use **`SharedPreferences`** for simple preferences and primitive values, such as settings and small flags.
- Use **`Hive`** when the project needs suitable structured local storage or caching.
- Do not use SharedPreferences for large or sensitive data.
- Put storage access behind a Service/Data Source rather than calling it directly from the UI or Cubit.
- Do not assume Hive or SharedPreferences is appropriate for every data type; choose based on the actual need.
- Do not add another database or storage system without a clear reason.

## 6) UI and Responsive Design
- Follow the existing or owner-approved design; do not invent a new design system without permission.
- Use **`flutter_screenutil`** if the project already depends on it or it is required by the project's setup.
- Avoid fixed dimensions that break layouts on supported screen sizes.
- Split UI into small Widgets with clear responsibilities.
- Use `const` constructors wherever appropriate.
- **Never create Controllers (`TextEditingController`, `AnimationController`, etc.) or expensive objects inside `build()`.**
- Place `BlocBuilder` or `BlocSelector` at the smallest scope that needs state updates — never at the top of the tree.
- Dispose of Controllers, FocusNodes, and other disposable resources in `StatefulWidget.dispose()`.
- Do not put a complete, large UI into one oversized file when it can be divided into understandable parts.

## 7) Localization and Text Direction
- When Arabic and English are supported, use **`easy_localization`** if the project already uses it or it is the project's approved choice.
- Do not hardcode user-facing text in Widgets when the project uses translation files.
- Preserve **RTL for Arabic and LTR for English**, and verify alignment, icons, and navigation direction where relevant.
- Do not assume every project needs multiple languages; follow the product requirements.

## 8) Models and Validation
- Use clear models and conversion boundaries when the data requires them.
- **No unnecessary code generation:** Do not automatically add Freezed or `build_runner`. Inspect existing tooling first and prefer **Dart 3+ native features** (e.g., `sealed class` for state unions with exhaustive pattern matching, switch expressions, and records).
- Validate user input and data from external services.
- Keep important validation rules testable; do not rely on UI validation alone.
- Avoid duplicating the same conversion or validation rules across layers without a reason.

---

# Section D — Flutter/Dart Code Quality

## 1) Coding Standards
- Follow the official Dart style and the project's existing `flutter_lints` rules.
- Use clear names for types, functions, variables, and files.
- Keep functions focused while preserving readability; do not split them mechanically without benefit.
- Avoid unnecessary `dynamic` and forced casts.
- Handle `null` explicitly; do not use `!` merely to silence the analyzer.
- Do not leave `TODO`, `FIXME`, or experimental code without explanation and approval.
- Avoid comments that restate obvious code; comment on reasons or non-obvious constraints.

## 2) Error Handling
- Map external-source errors to an appropriate result or Failure type (e.g., typed `Failure` classes / `ApiResult<T>`).
- Catch errors at the boundary (data layer), not deep inside business logic.
- Do not display `Exception.toString()` directly to users; map failures to user-friendly messages.
- Do not swallow errors without safe logging or suitable mapping.
- Keep operation-result contracts consistent within a feature.
- Do not impose a specific Result or Failure type if the project already has a clear alternative.

## 3) Testing
- Add tests for business logic, Repositories, and Cubits when appropriate.
- Test expected behavior, failure paths, and important edge cases.
- For bug fixes, add a reproducing test when practical.
- Avoid tests that depend on real networks or timing unless necessary.
- Run `flutter analyze` and targeted tests, then the relevant build when needed.
- **Never claim a command succeeded unless it was actually run.**

## 4) Dependencies and Builds
- Do not upgrade every package just because newer versions exist.
- When fixing a build issue, start from the actual error and make the smallest supported change.
- Do not edit `pubspec.lock` manually or add `dependency_overrides` as a quick fix without a documented reason.
- Check Flutter, Dart, and platform compatibility before upgrading packages.
- Run `flutter pub get` when dependencies change, followed by appropriate checks.
- Do not run `flutter clean` or delete build files randomly; do so only when evidence supports the need.

---

# Section E — Implementation and Communication Style

## 1) Work in Stages
- Break features into small, reviewable steps.
- If asked only to analyze and plan, do not implement before approval.
- Do not change several layers at once when incremental implementation and verification would be clearer.
- After each major stage, summarize what is complete and what comes next.

## 2) Working with Project Files
- Inspect a file, its context, and its usages before changing it.
- If the owner asks to review files one by one, do not move to the next file until they confirm, when that is the agreed workflow.
- When explaining a file, describe its responsibility, inputs, outputs, and relationship to other layers.
- Do not provide disconnected code blocks that rely on unverified filenames or APIs.

## 3) Final Report
When completing a task, clearly state:
1. What changed.
2. Which files were created or modified.
3. Important technical decisions.
4. Checks that were actually run and their results.
5. What remains unverified or needs follow-up.

---

# Section F — Pre-Delivery Checklist

- [ ] The implementation follows the project's approved architecture.
- [ ] Preferred technologies were used without unauthorized alternatives.
- [ ] No unverified backend, API, or dependency was introduced.
- [ ] Business logic was kept out of the UI.
- [ ] Existing services and helpers were reused where appropriate.
- [ ] Loading, success, empty, and failure states were handled where relevant.
- [ ] The final changes were reviewed.
- [ ] Appropriate checks were run, or the reason they were not run was stated.
- [ ] No unrun check was reported as successful.

---

**Core Rule Summary:**
For Flutter projects, default to **Clean Architecture + Feature-First + Cubit/Bloc + GoRouter + GetIt**. Use **Dio** for networking and **SharedPreferences** or **Hive** according to the storage need. Inspect the project first, respect explicit requirements and existing technologies, and never replace this approach with external preferences without permission.
