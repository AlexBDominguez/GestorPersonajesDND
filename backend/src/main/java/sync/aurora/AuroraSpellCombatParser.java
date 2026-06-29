package sync.aurora;

import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Best-effort extraction of Hit/DC/damage data from Aurora's free-text spell descriptions.
 * Aurora (unlike the public D&D 5e API) only gives us prose, so this mirrors the official
 * sourcebook phrasing patterns (attack/save clause, "Xd Y <type> damage", and the two standard
 * scaling templates) with regexes instead of structured JSON. Anything that doesn't match a
 * known pattern is simply left null — same graceful degradation as before this parser existed,
 * just with fewer gaps. Not meant to be perfect: irregular spells (Magic Missile's extra darts,
 * Scorching Ray's extra rays, flat non-dice scaling…) are intentionally left unparsed, same
 * limitation the public 5e API itself has for those cases.
 */
final class AuroraSpellCombatParser {

    private AuroraSpellCombatParser() {}

    static final class Result {
        String attackType;     // "melee" | "ranged" | null
        String dcType;         // "STR".."CHA" | null
        String damageType;     // "Fire", "Psychic"... | null
        String damageBase;     // "2d8" | null
        Map<Integer, String> damageAtSlotLevel = new LinkedHashMap<>();
    }

    private static final Set<String> DAMAGE_TYPES = Set.of(
        "acid", "bludgeoning", "cold", "fire", "force", "lightning", "necrotic",
        "piercing", "poison", "psychic", "radiant", "slashing", "thunder"
    );

    private static final Map<String, String> ABILITY_ABBR = Map.of(
        "strength", "STR", "dexterity", "DEX", "constitution", "CON",
        "intelligence", "INT", "wisdom", "WIS", "charisma", "CHA"
    );

    private static final Pattern MELEE_ATTACK  = Pattern.compile("melee spell attack", Pattern.CASE_INSENSITIVE);
    private static final Pattern RANGED_ATTACK = Pattern.compile("ranged spell attack", Pattern.CASE_INSENSITIVE);

    private static final Pattern SAVE = Pattern.compile(
        "(strength|dexterity|constitution|intelligence|wisdom|charisma) saving throw",
        Pattern.CASE_INSENSITIVE);

    private static final Pattern DAMAGE = Pattern.compile(
        "(\\d+d\\d+)(?:\\s*\\+\\s*[^\\s,.;]+)?\\s+([a-zA-Z]+)\\s+damage");

    // "the damage increases by 1d6 ... for each slot level above 2nd" (leveled spells, linear upcast)
    private static final Pattern UPCAST_LINEAR = Pattern.compile(
        "damage increases by (\\d+)d(\\d+)[^.]*?for each slot level above (\\d+)(?:st|nd|rd|th)",
        Pattern.CASE_INSENSITIVE);

    // "...increases by 1d6 when you reach 5th level (2d6), 11th level (3d6), and 17th level (4d6)" (cantrips).
    // Aurora sometimes rewords the bit between "increases by XdY" and "5th level" (e.g. "when you
    // reach certain levels:"), so that span is left loose — only the parenthesized totals matter.
    private static final Pattern CANTRIP_SCALE = Pattern.compile(
        "increases by \\d+d\\d+[^.]*?5th level \\((\\d+d\\d+)\\)[^.]*?11th level \\((\\d+d\\d+)\\)[^.]*?17th level \\((\\d+d\\d+)\\)",
        Pattern.CASE_INSENSITIVE);

    // "...3rd- or 4th-level spell slot, the damage increases to 3d8." / "...spell slot of 7th level or higher, the damage increases to 5d8."
    private static final Pattern UPCAST_EXPLICIT = Pattern.compile(
        "(\\d+)(?:st|nd|rd|th)[^.]{0,60}?level[^.]{0,40}?,\\s*the damage increases to (\\d+d\\d+)",
        Pattern.CASE_INSENSITIVE);

    static Result parse(String description, int spellLevel) {
        Result r = new Result();
        if (description == null || description.isBlank()) return r;

        boolean melee  = MELEE_ATTACK.matcher(description).find();
        boolean ranged = RANGED_ATTACK.matcher(description).find();
        if (melee != ranged) r.attackType = melee ? "melee" : "ranged"; // ambiguous (both/neither) -> leave null

        Matcher saveM = SAVE.matcher(description);
        if (saveM.find()) r.dcType = ABILITY_ABBR.get(saveM.group(1).toLowerCase());

        Matcher dmgM = DAMAGE.matcher(description);
        if (dmgM.find() && DAMAGE_TYPES.contains(dmgM.group(2).toLowerCase())) {
            r.damageBase = dmgM.group(1);
            r.damageType = capitalize(dmgM.group(2).toLowerCase());
            r.damageAtSlotLevel.put(spellLevel > 0 ? spellLevel : 1, r.damageBase);
        }
        if (r.damageBase == null) return r; // nothing to scale without a base damage roll

        if (spellLevel == 0) {
            Matcher cantripM = CANTRIP_SCALE.matcher(description);
            if (cantripM.find()) {
                r.damageAtSlotLevel.put(5, cantripM.group(1));
                r.damageAtSlotLevel.put(11, cantripM.group(2));
                r.damageAtSlotLevel.put(17, cantripM.group(3));
            }
            return r;
        }

        Matcher linearM = UPCAST_LINEAR.matcher(description);
        if (linearM.find()) {
            int incCount = Integer.parseInt(linearM.group(1));
            int incDie   = Integer.parseInt(linearM.group(2));
            int threshold = Integer.parseInt(linearM.group(3));
            DiceCount base = DiceCount.parse(r.damageBase);
            if (base != null && base.die() == incDie && threshold == spellLevel) {
                for (int lvl = spellLevel + 1; lvl <= 9; lvl++) {
                    int extraSteps = lvl - spellLevel;
                    r.damageAtSlotLevel.put(lvl, (base.count() + incCount * extraSteps) + "d" + incDie);
                }
            }
            return r;
        }

        Matcher explicitM = UPCAST_EXPLICIT.matcher(description);
        Map<Integer, String> thresholds = new LinkedHashMap<>();
        while (explicitM.find()) {
            thresholds.put(Integer.parseInt(explicitM.group(1)), explicitM.group(2));
        }
        if (!thresholds.isEmpty()) {
            Integer[] levels = thresholds.keySet().toArray(new Integer[0]);
            for (int i = 0; i < levels.length; i++) {
                int from = levels[i];
                int to = (i + 1 < levels.length) ? levels[i + 1] - 1 : 9;
                String dice = thresholds.get(from);
                for (int lvl = from; lvl <= to; lvl++) {
                    r.damageAtSlotLevel.put(lvl, dice);
                }
            }
        }
        return r;
    }

    private static String capitalize(String s) {
        return s.isEmpty() ? s : Character.toUpperCase(s.charAt(0)) + s.substring(1);
    }

    private record DiceCount(int count, int die) {
        static DiceCount parse(String dice) {
            int idx = dice.indexOf('d');
            if (idx < 0) return null;
            try {
                return new DiceCount(Integer.parseInt(dice.substring(0, idx)),
                                      Integer.parseInt(dice.substring(idx + 1)));
            } catch (NumberFormatException e) {
                return null;
            }
        }
    }
}
