# Upgrade Plan: dnd-character-manager (20260316080547)

- **Generated**: 2026-03-16 09:06:22 CET
- **HEAD Branch**: dev
- **HEAD Commit ID**: 610453d

## Available Tools

**JDKs**
- JDK 17: **<TO_BE_INSTALLED>** (required by Step 1 for baseline on current runtime)
- JDK 21.0.10: /usr/lib/jvm/java-21-openjdk-amd64/bin (used by Steps 3 and 4)

**Build Tools**
- Maven 3.8.7: /usr/share/maven/bin
- Maven Wrapper: not present in project root, system Maven will be used

## Guidelines

- Use Java upgrade tools and the generated upgrade workflow artifacts.

## Options

- Working branch: appmod/java-upgrade-20260316080547
- Run tests before and after the upgrade: true

## Upgrade Goals

- Upgrade Java from 17 to 21 (LTS).

### Technology Stack

| Technology/Dependency | Current | Min Compatible | Why Incompatible |
| --------------------- | ------- | -------------- | ---------------- |
| Java | 17 | 21 | User requested target runtime upgrade to Java 21 LTS |
| Spring Boot | 3.2.5 | 3.2.5 | - |
| Spring Framework | 6.1.x (via Spring Boot 3.2.5) | 6.1.x | - |
| Hibernate | 6.4.x (via Spring Boot 3.2.5) | 6.4.x | - |
| Maven Compiler Plugin | 3.11.0 with source/target 17 | 3.11.0 with release/source/target 21 | Build still targets Java 17 |
| Docker build/runtime images | eclipse-temurin-17 (build and runtime) | eclipse-temurin-21 | Containerized runtime remains on Java 17 |
| JJWT (api/impl/jackson) | 0.12.3 | 0.12.3 | - |

### Derived Upgrades

- Update Maven compiler settings from Java 17 to Java 21 in `pom.xml` (properties and compiler plugin settings).
- Update Docker build and runtime base images from Temurin 17 to Temurin 21 in `Dockerfile` to keep runtime aligned with target Java.
- Validate full compilation and test execution using Java 21 as final runtime.

## Upgrade Steps

- **Step 1: Setup Environment**
  - **Rationale**: Install required JDK for baseline comparison because JDK 17 is not currently available on this machine.
  - **Changes to Make**:
    - [ ] Install JDK 17 using `#install_jdk`.
    - [ ] Verify JDK 17 and JDK 21 are both discoverable.
  - **Verification**:
    - Command: `#list_jdks`
    - Expected: JDK 17 and JDK 21 paths are available.

- **Step 2: Setup Baseline**
  - **Rationale**: Establish pre-upgrade compile/test baseline with Java 17 for later comparison.
  - **Changes to Make**:
    - [ ] Run baseline compile with Java 17 (`mvn clean test-compile -q`).
    - [ ] Run baseline tests with Java 17 (`mvn clean test -q`).
    - [ ] Record pass/fail and pass rate.
  - **Verification**:
    - Command: `mvn clean test-compile -q && mvn clean test -q`
    - JDK: JDK 17 installed in Step 1
    - Expected: Baseline compile/test status documented.

- **Step 3: Upgrade Build and Runtime Configuration to Java 21**
  - **Rationale**: Apply the actual project file changes required to move runtime and build target to Java 21.
  - **Changes to Make**:
    - [ ] Update `pom.xml` compiler properties (`maven.compiler.source`, `maven.compiler.target`) from 17 to 21.
    - [ ] Update `maven-compiler-plugin` configuration from source/target 17 to Java 21.
    - [ ] Update `Dockerfile` base images from Temurin 17 to Temurin 21.
    - [ ] Fix any compilation issues under Java 21.
  - **Verification**:
    - Command: `mvn clean test-compile -q`
    - JDK: /usr/lib/jvm/java-21-openjdk-amd64/bin
    - Expected: Compilation SUCCESS for main and test code.

- **Step 4: Final Validation**
  - **Rationale**: Ensure upgrade goals are met and all tests pass under Java 21.
  - **Changes to Make**:
    - [ ] Verify final Java target values in `pom.xml` and runtime image in `Dockerfile`.
    - [ ] Run clean compile and full tests on Java 21.
    - [ ] Resolve all remaining failures until 100% pass rate (or baseline-equivalent if baseline had failures).
  - **Verification**:
    - Command: `mvn clean test -q`
    - JDK: /usr/lib/jvm/java-21-openjdk-amd64/bin
    - Expected: Compilation SUCCESS + 100% test pass rate (or not lower than baseline).

## Key Challenges

- **Potential Java 21 compile regressions in existing code**
  - **Challenge**: Existing code may rely on Java 17 behavior or assumptions that fail on Java 21.
  - **Strategy**: Compile immediately after configuration updates and fix all compile errors in the same step.
- **Environment mismatch between local runtime and containers**
  - **Challenge**: Upgrading only `pom.xml` would leave Docker runtime at Java 17.
  - **Strategy**: Upgrade Docker build/runtime base images to Temurin 21 in the same upgrade step.
- **Unknown baseline test health**
  - **Challenge**: Existing tests might already fail before upgrade.
  - **Strategy**: Capture baseline pass rate on Java 17, then enforce final pass rate not lower than baseline and fix all upgrade-introduced failures.

## Plan Review

- All placeholders are filled.
- Upgrade path is feasible without intermediate framework migration because Spring Boot 3.2.5 already supports Java 21.
- Mandatory setup and final validation steps are included.
- No unfixable technical limitations identified at planning stage.
