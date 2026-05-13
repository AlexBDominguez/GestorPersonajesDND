#!/usr/bin/env python3
"""Repair Phase 2 translations using hex SQL literals to avoid mojibake."""

import subprocess
import sys

from i18n_phase2_gen import (
    class_descriptions,
    racial_trait_names,
    spell_names,
    subclass_gl,
    subrace_descriptions,
)

CWD = "/home/alexandre.barbeito/GestorPersonajesDND/backend"
DB_CMD = [
    "docker",
    "compose",
    "exec",
    "-T",
    "mysql-db",
    "mysql",
    "-uroot",
    "-pdnd_root_password",
    "dnd_character_manager",
    "--default-character-set=utf8mb4",
]

CLASS_NAME_FIXES = {
    "barbarian": ("Bárbaro", "Bárbaro"),
    "bard": ("Bardo", "Bardo"),
    "cleric": ("Clérigo", "Clérigo"),
    "druid": ("Druida", "Druida"),
    "fighter": ("Guerrero", "Guerreiro"),
    "monk": ("Monje", "Monxe"),
    "paladin": ("Paladín", "Paladín"),
    "ranger": ("Explorador", "Explorador"),
    "rogue": ("Pícaro", "Pícaro"),
    "sorcerer": ("Hechicero", "Feiticeiro"),
    "warlock": ("Brujo", "Bruxo"),
    "wizard": ("Mago", "Mago"),
}


def sql_hex(value: str) -> str:
    return f"0x{value.encode('utf-8').hex().upper()}"


def build_sql() -> str:
    lines = [
        "SET NAMES utf8mb4;",
        "SET character_set_client = utf8mb4;",
        "",
        "-- Repair Phase 2 translations using UTF-8 hex literals",
        "",
    ]

    lines.append("-- Class names")
    for idx, (es, gl) in CLASS_NAME_FIXES.items():
        lines.append(
            "UPDATE classes "
            f"SET name_es={sql_hex(es)}, name_gl={sql_hex(gl)} "
            f"WHERE index_name='{idx}';"
        )

    lines.extend(["", "-- Spell names"])
    for idx, (es, gl) in spell_names.items():
        lines.append(
            "UPDATE spells "
            f"SET name_es={sql_hex(es)}, name_gl={sql_hex(gl)} "
            f"WHERE index_api='{idx}';"
        )

    lines.extend(["", "-- Class descriptions"])
    for idx, (es, gl) in class_descriptions.items():
        lines.append(
            "UPDATE classes "
            f"SET description_es={sql_hex(es)}, description_gl={sql_hex(gl)} "
            f"WHERE index_name='{idx}';"
        )

    lines.extend(["", "-- Subrace descriptions"])
    for idx, (es, gl) in subrace_descriptions.items():
        lines.append(
            "UPDATE subraces "
            f"SET description_es={sql_hex(es)}, description_gl={sql_hex(gl)} "
            f"WHERE index_name='{idx}';"
        )

    lines.extend(["", "-- Racial trait names"])
    for name, (es, gl) in racial_trait_names.items():
        escaped_name = name.replace("\\", "\\\\").replace("'", "\\'")
        lines.append(
            "UPDATE racial_traits "
            f"SET name_es={sql_hex(es)}, name_gl={sql_hex(gl)} "
            f"WHERE name='{escaped_name}';"
        )

    lines.extend(["", "-- Subclass Galician names"])
    for idx, gl in subclass_gl.items():
        lines.append(
            "UPDATE subclasses "
            f"SET name_gl={sql_hex(gl)} "
            f"WHERE index_name='{idx}';"
        )

    return "\n".join(lines) + "\n"


def run_sql(sql: str) -> subprocess.CompletedProcess:
    return subprocess.run(
        DB_CMD,
        input=sql.encode("utf-8"),
        capture_output=True,
        cwd=CWD,
    )


def print_process_output(result: subprocess.CompletedProcess) -> None:
    stdout = result.stdout.decode(errors="replace")
    stderr_lines = [
        line
        for line in result.stderr.decode(errors="replace").splitlines()
        if "Warning: Using a password" not in line
    ]
    if stdout:
        print(stdout)
    if stderr_lines:
        print("STDERR:\n" + "\n".join(stderr_lines), file=sys.stderr)


if __name__ == "__main__":
    sql = build_sql()
    print(f"Generated {sql.count(chr(10))} SQL lines")
    print("Executing repair SQL against MySQL container...")

    result = run_sql(sql)
    print_process_output(result)

    if result.returncode != 0:
        print(f"✗ Exit code: {result.returncode}", file=sys.stderr)
        sys.exit(result.returncode)

    print("✓ UTF-8 repair applied successfully.")

    verify_sql = """
SELECT 'classes.name_es' AS column_name, COUNT(*) AS suspect_rows FROM classes WHERE HEX(name_es) REGEXP 'C382|C383'
UNION ALL
SELECT 'classes.description_es', COUNT(*) FROM classes WHERE HEX(description_es) REGEXP 'C382|C383'
UNION ALL
SELECT 'spells.name_es', COUNT(*) FROM spells WHERE HEX(name_es) REGEXP 'C382|C383'
UNION ALL
SELECT 'subraces.description_es', COUNT(*) FROM subraces WHERE HEX(description_es) REGEXP 'C382|C383'
UNION ALL
SELECT 'racial_traits.name_es', COUNT(*) FROM racial_traits WHERE HEX(name_es) REGEXP 'C382|C383';
"""
    verify_result = run_sql(verify_sql)
    print_process_output(verify_result)

    if verify_result.returncode != 0:
        sys.exit(verify_result.returncode)
