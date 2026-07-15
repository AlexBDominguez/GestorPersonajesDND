package services;

import entities.PlayerCharacter;
import org.springframework.stereotype.Service;

/**
 * Shared DSL for turning a formula string into a number for a given character — the same
 * small set of "ability modifier", "proficiency bonus", and level-threshold-table formulas
 * used by resource pools (ClassResource.maxFormula, #8.2 RESOURCE_POOL) and numeric bonuses
 * (NumericBonus.formula, #8.2 NUMERIC_BONUS). Extracted from
 * CharacterClassResourceService.calculateMaxAmount() so both mechanic types share one
 * evaluator instead of duplicating the switch.
 */
@Service
public class CharacterFormulaService {

    public int evaluate(PlayerCharacter character, String formula) {
        if (formula == null) return 0;

        switch (formula.toLowerCase()) {
            case "level":
                return character.getLevel();

            case "level_monk":
                return character.getLevel();

            case "level_sorcerer":
                return character.getLevel();

            case "proficiency_bonus":
                return character.getProficiencyBonus();

            case "charisma_modifier":
                return Math.max(1, character.calculateAbilityModifier("cha"));

            // Sin ningún suelo -- a diferencia de "charisma_modifier" (pensada para tamaños de
            // pool de recursos, donde un mínimo de 1 tiene sentido), un bonificador de daño plano
            // como Elemental Affinity/Agonizing Blast no debe forzar a +1 un modificador negativo o nulo.
            case "charisma_modifier_raw":
                return character.calculateAbilityModifier("cha");

            // Igual que charisma_modifier_raw, sin suelo -- para Empowered Evocation.
            case "intelligence_modifier_raw":
                return character.calculateAbilityModifier("int");

            case "level_half":
                return Math.max(1, character.getLevel() / 2);

            case "level_divided_3":
                return Math.max(1, character.getLevel() / 3);

            case "wisdom_modifier_min1":
                return Math.max(1, character.calculateAbilityModifier("wis"));

            case "intelligence_modifier_min1":
                return Math.max(1, character.calculateAbilityModifier("int"));

            case "constitution_modifier_min1":
                return Math.max(1, character.calculateAbilityModifier("con"));

            case "strength_modifier_min1":
                return Math.max(1, character.calculateAbilityModifier("str"));

            // Sin "minimum 1": usada por bonificadores donde un modificador negativo se
            // trata como +0 en vez de forzarse a un mínimo de 1 (p.ej. Aura of Protection
            // del Paladín, tal y como ya lo calculaba PlayerCharacterService antes de #8.2).
            case "charisma_modifier_min0":
                return Math.max(0, character.calculateAbilityModifier("cha"));

            case "twice_proficiency_bonus":
                return character.getProficiencyBonus() * 2;

            case "level_times_5":
                return character.getLevel() * 5;

            case "one_plus_charisma_modifier":
                return 1 + character.calculateAbilityModifier("cha");

            case "one_plus_level":
                return 1 + character.getLevel();

            // Remarkable Athlete (Fighter Champion): mitad del bono de competencia, redondeado
            // hacia arriba (p.ej. +2 -> +1, +3 -> +2).
            case "half_proficiency_bonus_round_up":
                return (character.getProficiencyBonus() + 1) / 2;

            // Tabla de usos de Furia del Bárbaro (no sigue proficiency bonus)
            case "barbarian_rage_table":
                return barbarianRageUses(character.getLevel());

            // Canalizar Divinidad del Clérigo: 1 uso a nivel 2, 2 a nivel 6, 3 a nivel 18
            case "channel_divinity_cleric_table":
                return levelThresholdTable(character.getLevel(),
                        new int[][]{{18, 3}, {6, 2}, {2, 1}});

            // Oleada de Acción del Guerrero: 1 uso a nivel 2, 2 a nivel 17
            case "action_surge_table":
                return levelThresholdTable(character.getLevel(),
                        new int[][]{{17, 2}, {2, 1}});

            // Indomable del Guerrero: 1 uso a nivel 9, 2 a nivel 13, 3 a nivel 17
            case "indomitable_table":
                return levelThresholdTable(character.getLevel(),
                        new int[][]{{17, 3}, {13, 2}, {9, 1}});

            // Dados de Superioridad del Battle Master: 4 a nivel 3, 5 a nivel 7, 6 a nivel 15
            case "battlemaster_superiority_dice_table":
                return levelThresholdTable(character.getLevel(),
                        new int[][]{{15, 6}, {7, 5}, {3, 4}});

            // Runas del Rune Knight: 1 invocación por runa conocida (desde nivel 3), 2 a partir
            // de nivel 15 (Master of Runes duplica los usos de cada runa).
            case "rune_knight_charges_table":
                return levelThresholdTable(character.getLevel(),
                        new int[][]{{15, 2}, {3, 1}});

            // Infusiones conocidas del Artificiero (Infuse Item): 4 a nivel 2, +2 en 6/10/14/18.
            case "artificer_infusions_known_table":
                return levelThresholdTable(character.getLevel(),
                        new int[][]{{18, 12}, {14, 10}, {10, 8}, {6, 6}, {2, 4}});

            // Objetos infusionados simultáneamente (Infuse Item): siempre la mitad de las
            // infusiones conocidas -- 2 a nivel 2, 3 a nivel 6, 4 a nivel 10, 5 a nivel 14, 6 a
            // nivel 18.
            case "artificer_infusions_active_table":
                return levelThresholdTable(character.getLevel(),
                        new int[][]{{18, 6}, {14, 5}, {10, 4}, {6, 3}, {2, 2}});

            // Enhanced Weapon/Enhanced Defense/Enhanced Arcane Focus: +1, +2 desde nivel 10.
            case "infusion_enhancement_bonus_table":
                return levelThresholdTable(character.getLevel(),
                        new int[][]{{10, 2}, {0, 1}});

            default:
                try {
                    return Integer.parseInt(formula);
                } catch (NumberFormatException e) {
                    System.err.println("Unknown formula: " + formula);
                    return 0;
                }
        }
    }

    private int barbarianRageUses(int level) {
        if (level >= 20) return 999;
        if (level >= 17) return 6;
        if (level >= 12) return 5;
        if (level >= 6)  return 4;
        if (level >= 3)  return 3;
        return 2;
    }

    // thresholds: filas {nivelMinimo, valor} ordenadas de mayor a menor nivelMinimo.
    // Devuelve el valor de la primera fila cuyo nivelMinimo <= level, o 0 si ninguna aplica.
    private int levelThresholdTable(int level, int[][] thresholdsDesc) {
        for (int[] row : thresholdsDesc) {
            if (level >= row[0]) return row[1];
        }
        return 0;
    }
}
