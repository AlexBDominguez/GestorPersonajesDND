package enumeration;

public enum EffectModifierType {
    AC,                    // Armor Class
    ATTACK_ROLL,           // Bonificador a tiradas de ataque
    DAMAGE,                // Bonificador a daño
    SAVING_THROW,          // Bonificador a saving throws
    ABILITY_CHECK,         // Bonificador a ability checks
    SKILL_CHECK,           // Bonificador a skill checks específicos
    INITIATIVE,            // Bonificador a iniciativa
    SPEED,                 // Modificador de velocidad
    HP_MAX,                // Modificador a HP máximo temporal
    ADVANTAGE,             // Ventaja en ciertos rolls
    DISADVANTAGE,          // Desventaja en ciertos rolls
    RESISTANCE,            // Resistencia a tipo de daño
    VULNERABILITY,         // Vulnerabilidad a tipo de daño
    IMMUNITY               // Inmunidad a tipo de daño
}