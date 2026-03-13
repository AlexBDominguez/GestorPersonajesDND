package enumeration;

public enum WeaponProperty {
    LIGHT,          // Can dual-wield
    FINESSE,        // Can use STR or DEX
    VERSATILE,      // Can use one or two hands
    HEAVY,          // Small creatures have disadvantage
    TWO_HANDED,     // Requires two hands
    THROWN,         // Can be thrown
    AMMUNITION,     // Requires ammunition
    LOADING,        // Can only fire once per action
    REACH,          // 10 ft reach instead of 5 ft
    SPECIAL         // Special rules
}
