package sync.aurora;

import entities.*;
import org.springframework.stereotype.Service;
import repositories.*;

import java.util.*;
import java.util.stream.Collectors;

/**
 * Maps Aurora Weapon, Armor, Magic Item and Item (adventuring gear) elements
 * to Item JPA entities.
 *
 * PHB items are skipped (already in DB from dnd5eapi.co).
 *
 * Mechanical bonus fields bonusAc/bonusToHit/set*To are populated from the
 * structured data Aurora already provides for the two clean, unambiguous
 * cases (see #21 in Aurora_Fixes.md): a flat weapon/armor enhancement bonus
 * (setters "enhancement") and an ability score override
 * (`<stat name="<ability>:score:set">`, e.g. Belts of Giant Strength).
 * bonusSavingThrows is left untouched — no structured Aurora rule for it was
 * found. Cases that need a formula (e.g. AC += Charisma modifier, seen on
 * the Dragon Masks) or a flat ability-score bonus with no matching Item
 * field (e.g. Belt of Dwarvenkind's +2 Constitution) are deliberately left
 * untouched too — out of scope for this pass, see Aurora_Fixes.md #21.
 */
@Service
public class AuroraItemMapper {

    private final AuroraRegistry registry;
    private final ItemRepository itemRepo;
    private final ContentSourceRepository sourceRepo;

    private static final Set<String> HANDLED_TYPES = Set.of("Weapon", "Armor", "Magic Item", "Item");

    public AuroraItemMapper(AuroraRegistry registry,
                            ItemRepository itemRepo,
                            ContentSourceRepository sourceRepo) {
        this.registry = registry;
        this.itemRepo = itemRepo;
        this.sourceRepo = sourceRepo;
    }

    public Map<String, Object> sync() {
        if (registry.isEmpty()) {
            return Map.of("error", "Registry is empty — run POST /api/sync/aurora/fetch first.");
        }
        Set<String> allowed = allowedSources();
        int created = 0, updated = 0, skipped = 0;

        for (String auroraType : HANDLED_TYPES) {
            for (AuroraElement el : registry.getByType(auroraType)) {
                String src = AuroraSourceMapper.toShortName(el.getSource());
                if ("PHB".equals(src) || !allowed.contains(src)) { skipped++; continue; }

                try {
                    Item item = itemRepo.findByIndexName(el.getId()).orElse(new Item());
                    boolean isNew = item.getId() == null;

                    item.setIndexName(el.getId());
                    item.setName(el.getName());
                    item.setSource(src);
                    item.setDescription(el.getDescription());
                    item.setItemType(toItemType(auroraType));
                    item.setCategory(el.getSetters().getOrDefault("category", ""));
                    item.setWeight(parseDouble(el.getSetters().get("weight"), 0.0));
                    item.setCostInCopper(parseCost(el.getSetters().get("cost")));

                    switch (auroraType) {
                        case "Weapon"    -> applyWeaponData(el, item);
                        case "Armor"     -> applyArmorData(el, item);
                        case "Magic Item"-> applyMagicItemData(el, item);
                    }
                    applyMechanicalBonuses(el, item);

                    itemRepo.save(item);
                    if (isNew) created++; else updated++;
                } catch (Exception e) {
                    System.err.printf("[Aurora] %s '%s' (%s): %s%n", auroraType, el.getName(), src, e.getMessage());
                    skipped++;
                }
            }
        }

        System.out.printf("[Aurora] Items: created=%d, updated=%d, skipped=%d%n", created, updated, skipped);
        Map<String, Object> r = new LinkedHashMap<>();
        r.put("created", created); r.put("updated", updated); r.put("skipped", skipped);
        return r;
    }

    // ── Type-specific data ─────────────────────────────────────────────────────

    private void applyWeaponData(AuroraElement el, Item item) {
        Map<String, String> s = el.getSetters();
        item.setDamageDice(s.getOrDefault("damage", ""));
        item.setDamageType(s.getOrDefault("damage-type", ""));
        // "Melee" or "Ranged"
        String range = s.getOrDefault("weapon-range", "Melee");
        item.setWeaponRange(range);
        // Weapon properties from GRANT rules of type "Weapon Property"
        List<String> props = el.getRules().stream()
            .filter(r -> r.getRuleType() == AuroraRule.RuleType.GRANT
                      && "Weapon Property".equals(r.getType())
                      && r.getName() != null && !r.getName().isBlank())
            .map(r -> r.getName().trim())
            .distinct()
            .collect(Collectors.toList());
        item.setWeaponProperties(props);
    }

    private void applyArmorData(AuroraElement el, Item item) {
        Map<String, String> s = el.getSetters();
        // e.g. "14 + Dex modifier (max 2)" → extract leading integer
        String acRaw = s.getOrDefault("armor-class", "");
        item.setArmorClass(parseLeadingInt(acRaw));
        // "Light Armor", "Medium Armor", "Heavy Armor", "Shield"
        item.setArmorType(s.getOrDefault("category", s.getOrDefault("type", "")));
        item.setStealthDisadvantage("Disadvantage".equalsIgnoreCase(
            s.getOrDefault("stealth", "")));
        // Max Dex bonus: present in the AC string for medium armor
        item.setMaxDexBonus(parseMaxDex(acRaw));
    }

    private void applyMagicItemData(AuroraElement el, Item item) {
        Map<String, String> s = el.getSetters();
        item.setRarity(s.getOrDefault("rarity", ""));
        String att = s.getOrDefault("attunement", "false");
        item.setRequiresAttunement("true".equalsIgnoreCase(att.trim()));
        item.setAttunementRequierement(s.getOrDefault("attunement-specific", ""));
    }

    private static final Map<String, String> ABILITY_SET_SUFFIX = Map.of(
        "strength", "str", "dexterity", "dex", "constitution", "con",
        "intelligence", "int", "wisdom", "wis", "charisma", "cha"
    );

    /**
     * Structured mechanical bonuses Aurora already encodes outside free text:
     * - setters "enhancement" (flat +N weapon/armor bonus) → bonusToHit (weapon)
     *   or bonusAc (armor/shield), based on the setters "type" sub-category.
     * - `<stat name="<ability>:score:set" value="N"/>` (e.g. Belts of Giant
     *   Strength) → the matching setXTo field.
     */
    private void applyMechanicalBonuses(AuroraElement el, Item item) {
        Map<String, String> s = el.getSetters();
        Integer enhancement = parseIntOrNull(s.get("enhancement"));
        if (enhancement != null) {
            String subType = s.getOrDefault("type", "");
            if ("Weapon".equals(subType)) {
                item.setBonusToHit(enhancement);
            } else if ("Armor".equals(subType)) {
                item.setBonusAc(enhancement);
            }
        }

        for (AuroraRule rule : el.getRules()) {
            if (rule.getRuleType() != AuroraRule.RuleType.STAT || rule.getName() == null) continue;
            String name = rule.getName().toLowerCase();
            if (!name.endsWith(":score:set")) continue;
            String ability = name.substring(0, name.length() - ":score:set".length());
            String suffix = ABILITY_SET_SUFFIX.get(ability);
            Integer value = parseIntOrNull(rule.getValue());
            if (suffix == null || value == null) continue;
            switch (suffix) {
                case "str" -> item.setSetStrTo(value);
                case "dex" -> item.setSetDexTo(value);
                case "con" -> item.setSetConTo(value);
                case "int" -> item.setSetIntTo(value);
                case "wis" -> item.setSetWisTo(value);
                case "cha" -> item.setSetChaTo(value);
            }
        }
    }

    private Integer parseIntOrNull(String s) {
        if (s == null || s.isBlank()) return null;
        try { return Integer.parseInt(s.trim()); } catch (NumberFormatException e) { return null; }
    }

    // ── Utilities ──────────────────────────────────────────────────────────────

    private String toItemType(String auroraType) {
        return switch (auroraType) {
            case "Weapon"     -> "weapon";
            case "Armor"      -> "armor";
            case "Magic Item" -> "magic_item";
            default           -> "adventuring_gear";
        };
    }

    /** Parses the leading integer from strings like "14 + Dex modifier (max 2)". */
    private Integer parseLeadingInt(String s) {
        if (s == null || s.isBlank()) return null;
        String trimmed = s.trim().split("[^0-9]")[0];
        try { return Integer.parseInt(trimmed); } catch (NumberFormatException e) { return null; }
    }

    /**
     * Parses the max Dex bonus from armor-class strings like "12 + Dex modifier (max 2)".
     * Returns null for light armor ("Dex modifier" with no max) and heavy armor (no Dex at all).
     */
    private Integer parseMaxDex(String s) {
        if (s == null) return null;
        int maxIdx = s.toLowerCase().indexOf("max ");
        if (maxIdx < 0) return null;
        String after = s.substring(maxIdx + 4).replaceAll("[^0-9].*", "");
        try { return Integer.parseInt(after); } catch (NumberFormatException e) { return null; }
    }

    /**
     * Parses cost strings like "15 gp", "50 sp", "200 cp" into copper pieces.
     * Returns 0 when unparseable.
     */
    private int parseCost(String s) {
        if (s == null || s.isBlank()) return 0;
        s = s.trim().toLowerCase();
        try {
            if (s.endsWith("gp")) return (int)(Double.parseDouble(s.replace("gp", "").trim()) * 100);
            if (s.endsWith("sp")) return (int)(Double.parseDouble(s.replace("sp", "").trim()) * 10);
            if (s.endsWith("cp")) return (int) Double.parseDouble(s.replace("cp", "").trim());
            if (s.endsWith("pp")) return (int)(Double.parseDouble(s.replace("pp", "").trim()) * 1000);
        } catch (NumberFormatException ignored) {}
        return 0;
    }

    private double parseDouble(String s, double def) {
        if (s == null || s.isBlank()) return def;
        try { return Double.parseDouble(s.trim()); } catch (NumberFormatException e) { return def; }
    }

    private Set<String> allowedSources() {
        return sourceRepo.findAll().stream()
            .map(ContentSource::getShortName)
            .filter(s -> !"PHB".equals(s))
            .collect(Collectors.toSet());
    }
}
