# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**DungeonScroll** — D&D 5e character manager. Spring Boot 3 REST API backend + Flutter frontend (web/Android/iOS). Database: MySQL 8.0 via Docker. App name in code: `gestor_personajes_dnd`.

---

## Git

Never include `Co-Authored-By: Claude` lines in commit messages.

**Commit automatically when finishing a task that leaves changes in the working tree** — do not ask for confirmation first. Stage only the files relevant to the task and write a normal descriptive commit message. (This overrides the default "never commit without being asked" behavior for this repo.)

**Do not bump the version in `frontend/pubspec.yaml` on every commit.** The `version: X.Y.Z+N` build number should only be bumped right before a deploy/release (its own dedicated commit, e.g. `chore: update version to 1.0.0+14 in pubspec.yaml`), matching the existing history. When the user asks to deploy or build a release, bump the build number (`+N`) first if it hasn't already been bumped for this release.

---

## Local environment

**The real backend + MySQL database run on the user's VPS, not locally.** There is no local Docker MySQL/backend with production-equivalent data — do not attempt to start `docker compose up -d mysql-db` / `backend` to "test" or "verify" a change or to inspect data; any local container is empty/stale and not representative. To check live data or behavior, ask the user to run the query/check on the VPS, or reason from the source code instead.

**Manual UI/UX testing of Flutter changes is done by the user, not by Claude driving a local browser.** Do not launch `flutter run -d chrome` (or similar) to log in and click through the app to verify a change, since that requires real VPS-backed credentials and burns tokens the user would rather spend elsewhere — the user tests these themselves in their own session and reports back. It's fine to run `flutter analyze`/build checks for static verification. Only drive the app yourself if the user explicitly asks you to for that task.

---

## Commands

### Backend (from `backend/`)

```bash
# Start only MySQL (development)
docker compose up -d mysql-db

# Run backend locally with Maven
mvn spring-boot:run

# Build JAR
mvn clean package

# Deploy everything (MySQL + backend + Nginx for web Flutter)
docker compose up -d

# Execute SQL script against running container (root password from $MYSQL_ROOT_PASSWORD,
# already exported in the user's VPS shell — never write the password literally)
docker exec -i dnd-mysql mysql -u root -p$MYSQL_ROOT_PASSWORD dnd_character_manager < scripts/my_script.sql

# Initial data sync from D&D 5e API (run once after first boot)
curl -X POST http://localhost:8081/api/sync/all
```

Required `.env` variables (copy from `.env.example`): `MYSQL_ROOT_PASSWORD`, `MYSQL_USER`, `MYSQL_PASSWORD`, `SPRING_DATASOURCE_USERNAME`, `SPRING_DATASOURCE_PASSWORD`, `JWT_SECRET`, `ADMIN_INITIAL_PASSWORD`.

**On the VPS, `$MYSQL_ROOT_PASSWORD` is already exported in the shell** — any `docker exec ... mysql` command given to the user should use `-p$MYSQL_ROOT_PASSWORD` (or the relevant `$VAR`), never a literal password, so it can be copy-pasted directly.

**`docker-compose.yml` lives in `backend/`, not the repo root.** `docker compose up -d --build backend` fails with "no configuration file provided" if run from the repo root — either `cd backend` first or pass `-f backend/docker-compose.yml` and run everything from the repo root instead (simpler when the same command sequence also touches `backend/scripts/*.sql`, since that path only resolves from the root).

**Any command sequence that rebuilds the backend must start with `git pull`.** The VPS working tree doesn't update itself — if a session hands over a new/changed `.sql` script or a Java change together with a rebuild+deploy sequence, and the user's VPS checkout hasn't pulled that commit yet, `docker compose up -d --build` silently rebuilds the *old* code (the image build has nothing to do with what's staged/committed on the machine you're talking from) and the new `.sql` file plain doesn't exist on disk yet, producing a confusing "No such file or directory" that looks like a path/cwd mistake but is actually a stale checkout. Always lead a deploy sequence with `cd ~/GestorPersonajesDND && git pull`, every time, even if a previous message in the same session already included one — don't assume the user's shell state carries between separate command blocks they paste in.

**`docker compose up -d --build backend` returns as soon as the container starts, not when Spring Boot/Hibernate finishes booting.** If a command sequence rebuilds the backend (e.g. because a migration adds/changes a JPA entity, so `ddl-auto=update` needs to create a table before a `.sql` script can insert into it) and then immediately pipes a SQL script into `docker exec ... mysql`, the script can race ahead of Hibernate and fail with `Table '...' doesn't exist`. Whenever giving the user a command sequence that rebuilds the backend and then runs SQL against a table/column that rebuild is expected to create, insert a wait/confirmation step between them — e.g. `docker logs dnd-backend --tail 50 | grep -i "started\|error"` and have the user confirm the `Started ... in X seconds` line appears with no errors above it, or use `ScheduleWakeup`/a short sleep loop, before handing over the SQL command.

### Frontend (from `frontend/`)

```bash
flutter pub get           # Install dependencies
flutter run               # Run (defaults to first available device)
flutter run -d chrome     # Run as web app
flutter run -d <id>       # Run on specific device (flutter devices to list)
flutter build apk --release          # Android APK
flutter build web --release          # Web build (output: build/web/)
flutter analyze           # Static analysis
```

---

## Architecture

### Backend

Standard Spring Boot layered architecture: `Entity → Repository → Service → DTO → Controller`.

- **`entities/`** — JPA entities, `ddl-auto=update` so Hibernate manages the schema. `PlayerCharacter` is the central entity with many `@OneToMany` relationships (spells, skills, inventory, feats, etc.). DB column names are `snake_case` (Hibernate's default physical naming strategy converts camelCase fields automatically, e.g. `requiresAttunement` → `requires_attunement`) and **column order in the live table does not necessarily match the Java field declaration order** (e.g. on `items`, `source` is the last column, and `rarity` comes right after `stealth_disadvantage`, not where the entity declares it). When writing manual SQL scripts (`scripts/`) that insert into existing tables, always use explicit column names in the `INSERT` (`INSERT INTO table (col1, col2, ...) VALUES (...)`) instead of positional `VALUES (...)` — never assume the column order. If unsure, ask the user to run `DESCRIBE <table>;` on the VPS rather than guessing.
- **`ddl-auto=update` never widens an existing `@Enumerated(EnumType.STRING)` column's allowed value set.** Hibernate maps these to a native MySQL `ENUM(...)` (confirmed on `class_level_feature.type`, backed by `enumeration/FeatureType`), and `update` mode only adds missing tables/columns — it does not alter an existing enum column when the Java enum gains a new constant. Inserting a row with the new constant then fails with `ERROR 1265 Data truncated for column '...'` (MySQL strict mode rejecting the out-of-set value, coerced to `''`), which reads like a data problem but is actually a stale column definition. Entities with this pattern today: `ActiveEffect`, `User`, `Feat`, `CharacterDamageRelation`, `ClassLevelFeature`, `Proficiency`, `LevelUpTask` — adding a new constant to any of their backing enums needs a manual `ALTER TABLE <table> MODIFY COLUMN <col> VARCHAR(50);` on the VPS before the corresponding SQL patch script runs (widening to `VARCHAR` also means this never recurs for that column again, unlike appending just the one new value to the `ENUM(...)` list).
- **`repositories/`** — Spring Data JPA interfaces. One oddity: `CharacterFeatService.java` is misplaced in the `repositories/` package.
- **`services/`** — Business logic. `PlayerCharacterService` is the largest, orchestrating character creation, level-up, rests, and HP management.
- **`controllers/`** — REST endpoints, all under `/api/` prefix, port `8081`.
- **`dto/`** — DTOs used for all API input/output; entities are never returned directly.
- **`security/`** — Stateless JWT auth. Access token = 15 min, refresh token = 30 days. `JwtAuthenticationFilter` validates every request. `SecurityConfig` whitelists reference-data GET endpoints and `/api/auth/*`.
- **`sync/`** — Services that pull data from the public D&D 5e API (`https://www.dnd5eapi.co`). `BaseSyncService<T>` defines the contract. `SyncController` exposes `/api/sync/*` endpoints (publicly accessible, no auth required). Some data (feats, subclasses, subraces) was not available from the public API and is inserted manually via SQL scripts in `scripts/` (patch/seed scripts for manual content — `backups/` is reserved for actual DB dumps).
- **`config/`** — `AdminDataInitializer` seeds the admin user on startup using `ADMIN_INITIAL_PASSWORD`.

### Frontend

MVVM pattern with Provider:

- **`config/api_config.dart`** — Single source of truth for the base URL. Web release builds use an empty string (Nginx proxy); dev and mobile use the VPS IP `http://178.104.94.11:8081`. Change here to switch environments.
- **`services/http/api_client.dart`** — Centralized HTTP client. Handles JWT Bearer headers, automatic token refresh on 401, and calls `onSessionExpired` callback (wired in `main.dart` to `AuthViewModel.logout()`) when refresh fails.
- **`services/`** — Domain services (`CharacterService`, `SpellService`, `InventoryService`, etc.) that call `ApiClient` and parse responses. `WizardReferenceService` fetches reference data (races, classes, backgrounds) for the creation wizard.
- **`viewmodels/`** — `ChangeNotifier` classes. `CharacterSheetViewModel` is the largest; it owns all character sheet state including the consumable feature tracker (`_kConsumableFeatures` map with special negative constants for class-level calculations). `CharacterCreatorViewModel` drives the 7-step wizard.
- **`views/screens/sheet/tabs/`** — The character sheet is split into 7 tabs: Abilities, Skills, Combat, Spells, Features, Inventory, Info.
- **`views/screens/wizard/steps/`** — The creation/edit wizard steps (preferences → class → background → race → ability scores → spells → equipment).
- **`config/combat_features.dart`** — Hardcoded list of features that appear in the Combat tab.
- **`config/dnd_choice_options.dart`** — Hardcoded options for class feature choices shown in the wizard (fighting styles, invocations, metamagic, etc.).

### Level-Up System

`POST /api/characters/{id}/level-up` takes a `LevelUpRequest` DTO. The backend processes automatic features (HP, spell slot progression, class resources) and creates `PendingTask` entities for decisions that require player input (ASI/feat choice, subclass selection, learn spells, etc.). The frontend fetches pending tasks and renders them in `PendingTasksScreen`.

### Auth Flow

Login → `POST /api/auth/login` → returns `accessToken` (JWT) + `refreshToken`. Access token stored via `shared_preferences`; refresh token via `flutter_secure_storage`. `ApiClient` attempts one silent refresh on any 401; on failure, calls `onSessionExpired` to force logout.

### Deployment (Production)

`docker-compose.yml` runs three containers: `dnd-mysql` (port 3306), `dnd-backend` (port 8081), and `dnd-nginx` (port 80). Nginx serves the Flutter web build from `./frontend-dist/` and proxies `/api/` to the backend. To deploy a new web build: `flutter build web --release`, copy `build/web/` to `backend/frontend-dist/`, then `docker compose restart nginx`.
